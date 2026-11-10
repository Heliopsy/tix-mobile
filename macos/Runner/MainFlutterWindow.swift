import Carbon.HIToolbox
import Cocoa
import FlutterMacOS
import ServiceManagement

class MainFlutterWindow: NSWindow {
  private var localAccess: LocalAccess?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    localAccess = LocalAccess(messenger: flutterViewController.engine.binaryMessenger)
    WidgetChannel.shared.attach(to: flutterViewController.engine.binaryMessenger)
    DesktopChannel.shared.attach(to: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}

/// red.tix/local_access: folders picked for databases opened in place, kept
/// as security-scoped bookmarks (com.apple.security.files.bookmarks.app-scope).
/// The folder is bookmarked, not the file, because the sandbox only lets the
/// app create files inside what the person picked, and SQLite creates its
/// -wal and -shm files beside the database. Every access started here is
/// balanced by one "close" from Dart.
final class LocalAccess: NSObject {
  private let channel: FlutterMethodChannel
  private var accessing: [String: (url: URL, count: Int, scoped: Bool)] = [:]

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "red.tix/local_access", binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "pickFolder":
      pickFolder(result: result)
    case "open":
      guard let text = args["bookmark"] as? String, let data = Data(base64Encoded: text) else {
        result(FlutterError(code: "denied", message: "no bookmark", details: nil))
        return
      }
      resolve(data, result: result)
    case "close":
      if let path = args["path"] as? String { release(path) }
      result(nil)
    case "downloaded":
      result(downloaded(args["path"] as? String ?? ""))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func pickFolder(result: @escaping FlutterResult) {
    let panel = NSOpenPanel()
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.canCreateDirectories = true
    panel.allowsMultipleSelection = false
    panel.begin { [weak self] response in
      guard let self = self, response == .OK, let url = panel.url else {
        result(nil)
        return
      }
      do {
        let data = try url.bookmarkData(
          options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        self.retain(url, scoped: url.startAccessingSecurityScopedResource())
        result(["path": url.path, "bookmark": data.base64EncodedString()])
      } catch {
        result(FlutterError(code: "denied", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func resolve(_ data: Data, result: FlutterResult) {
    var stale = false
    let url: URL
    do {
      url = try URL(
        resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil,
        bookmarkDataIsStale: &stale)
    } catch {
      result(FlutterError(code: "denied", message: error.localizedDescription, details: nil))
      return
    }
    guard url.startAccessingSecurityScopedResource() else {
      result(FlutterError(code: "denied", message: "no access to \(url.path)", details: nil))
      return
    }
    var bookmark = data
    if stale,
      let renewed = try? url.bookmarkData(
        options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
    {
      bookmark = renewed
    }
    retain(url, scoped: true)
    result(["path": url.path, "bookmark": bookmark.base64EncodedString(), "stale": stale])
  }

  private func retain(_ url: URL, scoped: Bool) {
    if let entry = accessing[url.path] {
      if scoped && entry.scoped { url.stopAccessingSecurityScopedResource() }
      accessing[url.path] = (url: entry.url, count: entry.count + 1, scoped: entry.scoped || scoped)
    } else {
      accessing[url.path] = (url: url, count: 1, scoped: scoped)
    }
  }

  private func release(_ path: String) {
    guard let entry = accessing[path] else { return }
    if entry.count > 1 {
      accessing[path] = (url: entry.url, count: entry.count - 1, scoped: entry.scoped)
      return
    }
    if entry.scoped { entry.url.stopAccessingSecurityScopedResource() }
    accessing[path] = nil
  }

  /// False for an iCloud file not downloaded yet, whose download it starts.
  private func downloaded(_ path: String) -> Bool {
    let url = URL(fileURLWithPath: path)
    let keys: Set<URLResourceKey> = [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey]
    guard let values = try? url.resourceValues(forKeys: keys), values.isUbiquitousItem == true else {
      return true
    }
    if values.ubiquitousItemDownloadingStatus == .current { return true }
    try? FileManager.default.startDownloadingUbiquitousItem(at: url)
    return false
  }
}

/// tix/links and tix/desktop on macOS: `tix://` links for Dart to take, what
/// the Mac offers, start at login (SMAppService, macOS 13 and later) and the
/// ⌃⇧Space quick-add hotkey (Carbon, which needs no accessibility grant).
/// See lib/src/core/platform/deep_links.dart and desktop.dart.
final class DesktopChannel: NSObject, FlutterAppLifecycleDelegate {
  static let shared = DesktopChannel()
  static let scheme = "tix"

  private var links: FlutterMethodChannel?
  private var desktop: FlutterMethodChannel?
  private var pendingLink: String?
  private var listening = false
  private var hotkey: EventHotKeyRef?
  private var hotkeyHandler: EventHandlerRef?

  func attach(to messenger: FlutterBinaryMessenger) {
    let links = FlutterMethodChannel(name: "tix/links", binaryMessenger: messenger)
    links.setMethodCallHandler { [weak self] call, result in
      guard let self, call.method == "take" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.listening = true
      result(self.pendingLink)
      self.pendingLink = nil
    }
    self.links = links
    let desktop = FlutterMethodChannel(name: "tix/desktop", binaryMessenger: messenger)
    desktop.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    self.desktop = desktop
  }

  // FlutterAppDelegate forwards application(_:open:) to lifecycle delegates under this selector.
  @objc(handleOpenURLs:)
  func handleOpen(_ urls: [URL]) -> Bool {
    guard let url = urls.last(where: { $0.scheme == Self.scheme }) else { return false }
    showWindow()
    pendingLink = url.absoluteString
    if listening { links?.invokeMethod("opened", arguments: nil) }
    return true
  }

  /// Brings the main window back, hidden or not, and the app to the front.
  func showWindow() {
    let window = (NSApp.delegate as? FlutterAppDelegate)?.mainFlutterWindow
    window?.setIsVisible(true)
    window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let on = call.arguments as? Bool ?? false
    switch call.method {
    case "capabilities":
      var autostart = false
      if #available(macOS 13.0, *) { autostart = true }
      result(["tray": true, "autostart": autostart, "hotkey": true, "background": false])
    case "autostart":
      if #available(macOS 13.0, *) {
        result(SMAppService.mainApp.status == .enabled)
      } else {
        result(false)
      }
    case "setAutostart":
      result(setAutostart(on))
    case "setHotkey":
      result(setHotkey(on))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setAutostart(_ on: Bool) -> Bool {
    guard #available(macOS 13.0, *) else { return false }
    do {
      if on {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
      return true
    } catch {
      return false
    }
  }

  private func setHotkey(_ on: Bool) -> Bool {
    if !on {
      if let hotkey { UnregisterEventHotKey(hotkey) }
      hotkey = nil
      return true
    }
    if hotkey != nil { return true }
    if hotkeyHandler == nil {
      var pressed = EventTypeSpec(
        eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
      let status = InstallEventHandler(
        GetApplicationEventTarget(),
        { _, _, context in
          guard let context else { return noErr }
          let channel = Unmanaged<DesktopChannel>.fromOpaque(context).takeUnretainedValue()
          DispatchQueue.main.async { channel.desktop?.invokeMethod("hotkey", arguments: nil) }
          return noErr
        }, 1, &pressed, Unmanaged.passUnretained(self).toOpaque(), &hotkeyHandler)
      guard status == noErr else { return false }
    }
    // 'tix!' as the signature.
    let id = EventHotKeyID(signature: OSType(0x7469_7821), id: 1)
    var ref: EventHotKeyRef?
    let status = RegisterEventHotKey(
      UInt32(kVK_Space), UInt32(controlKey | shiftKey), id, GetApplicationEventTarget(), 0, &ref)
    guard status == noErr, let ref else { return false }
    hotkey = ref
    return true
  }
}
