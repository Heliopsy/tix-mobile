import Flutter
import UIKit
import UniformTypeIdentifiers
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var localAccess: LocalAccess?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets flutter_local_notifications show inbox notifications while the
    // app is in the foreground and hear taps on them.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TixLocalAccess") {
      localAccess = LocalAccess(messenger: registrar.messenger())
    }
  }
}

/// red.tix/local_access: folders picked in the Files app for databases
/// opened in place, kept as bookmarks. The folder is bookmarked, not the
/// file, because SQLite creates its -wal and -shm files beside the database.
/// Every start of access is balanced by one "close" from Dart.
final class LocalAccess: NSObject, UIDocumentPickerDelegate {
  private let channel: FlutterMethodChannel
  private var accessing: [String: (url: URL, count: Int)] = [:]
  private var picking: FlutterResult?

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
    guard picking == nil, let top = LocalAccess.topController() else {
      result(nil)
      return
    }
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
    picker.delegate = self
    picker.allowsMultipleSelection = false
    picking = result
    top.present(picker, animated: true)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let result = picking else { return }
    picking = nil
    guard let url = urls.first else {
      result(nil)
      return
    }
    guard url.startAccessingSecurityScopedResource() else {
      result(FlutterError(code: "denied", message: "no access to \(url.path)", details: nil))
      return
    }
    do {
      let data = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
      retain(url)
      result(["path": url.path, "bookmark": data.base64EncodedString()])
    } catch {
      url.stopAccessingSecurityScopedResource()
      result(FlutterError(code: "denied", message: error.localizedDescription, details: nil))
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    picking?(nil)
    picking = nil
  }

  private func resolve(_ data: Data, result: FlutterResult) {
    var stale = false
    let url: URL
    do {
      url = try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &stale)
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
      let renewed = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
    {
      bookmark = renewed
    }
    retain(url)
    result(["path": url.path, "bookmark": bookmark.base64EncodedString(), "stale": stale])
  }

  private func retain(_ url: URL) {
    let count = accessing[url.path]?.count ?? 0
    accessing[url.path] = (url: url, count: count + 1)
  }

  private func release(_ path: String) {
    guard let entry = accessing[path] else { return }
    entry.url.stopAccessingSecurityScopedResource()
    accessing[path] = entry.count > 1 ? (url: entry.url, count: entry.count - 1) : nil
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

  private static func topController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windows = scenes.flatMap { $0.windows }
    var top = (windows.first { $0.isKeyWindow } ?? windows.first)?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}
