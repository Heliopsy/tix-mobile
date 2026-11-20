import AuthenticationServices
import Flutter
import UIKit
import UniformTypeIdentifiers
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var localAccess: LocalAccess?
  private var sso: SsoSession?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets flutter_local_notifications show inbox notifications while the
    // app is in the foreground and hear taps on them.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    WidgetRefresh.register()
    ControlReload.start()
    NotificationCenter.default.addObserver(
      forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main
    ) { _ in
      WidgetRefresh.schedule()
      ControlReload.now()
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TixLocalAccess") {
      localAccess = LocalAccess(messenger: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TixSso") {
      sso = SsoSession(messenger: registrar.messenger())
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

/// tix/sso: a provider sign-in in ASWebAuthenticationSession, the system's
/// own browser sheet, which hands the red.tix.mobile redirect straight back
/// (lib/src/core/platform/sso_browser.dart). A cancel answers "cancelled".
final class SsoSession: NSObject, ASWebAuthenticationPresentationContextProviding {
  private let channel: FlutterMethodChannel
  private var session: ASWebAuthenticationSession?
  private var pending: FlutterResult?
  private var attempt = UUID()

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "tix/sso", binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "authenticate":
      let args = call.arguments as? [String: Any] ?? [:]
      guard let text = args["url"] as? String, let url = URL(string: text),
        let scheme = args["scheme"] as? String
      else {
        result(FlutterError(code: "failed", message: "no url", details: nil))
        return
      }
      start(url, scheme: scheme, result: result)
    case "cancel":
      session?.cancel()
      finish(FlutterError(code: "cancelled", message: nil, details: nil))
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func start(_ url: URL, scheme: String, result: @escaping FlutterResult) {
    session?.cancel()
    finish(FlutterError(code: "cancelled", message: nil, details: nil))
    let id = UUID()
    let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme) {
      [weak self] callback, error in
      DispatchQueue.main.async {
        guard let self, self.attempt == id else { return }
        if let callback {
          self.finish(callback.absoluteString)
        } else if let error = error as? ASWebAuthenticationSessionError,
          error.code == .canceledLogin
        {
          self.finish(FlutterError(code: "cancelled", message: nil, details: nil))
        } else {
          self.finish(
            FlutterError(code: "failed", message: error?.localizedDescription, details: nil))
        }
      }
    }
    attempt = id
    session.presentationContextProvider = self
    self.session = session
    pending = result
    if !session.start() {
      finish(FlutterError(code: "failed", message: "not started", details: nil))
    }
  }

  private func finish(_ value: Any?) {
    let result = pending
    pending = nil
    session = nil
    result?(value)
  }

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windows = scenes.flatMap { $0.windows }
    return windows.first { $0.isKeyWindow } ?? windows.first ?? ASPresentationAnchor()
  }
}
