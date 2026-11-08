// SPDX-License-Identifier: AGPL-3.0-or-later

import Cocoa
import FlutterMacOS
import WidgetKit

/// The `tix/widgets` method channel: widget storage, redraws and taps on macOS, where home_widget does not run.
///
/// Dart calls `save`, `read`, `reload` and `launch`; Swift calls `opened` for a `tixwidget://` link that arrives
/// while the app runs and `queued` when the widget extension has added to the queue.
final class WidgetChannel: NSObject, FlutterAppLifecycleDelegate {
  static let shared = WidgetChannel()
  static let name = "tix/widgets"
  static let scheme = "tixwidget"

  private var channel: FlutterMethodChannel?
  private var pendingLaunch: String?
  private var dartListening = false
  private var observingQueue = false

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: Self.name, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    self.channel = channel
    observeQueue()
  }

  // FlutterAppDelegate forwards application(_:open:) to lifecycle delegates under this selector.
  @objc(handleOpenURLs:)
  func handleOpen(_ urls: [URL]) -> Bool {
    guard let url = urls.last(where: { $0.scheme == Self.scheme }) else { return false }
    if dartListening, let channel {
      channel.invokeMethod("opened", arguments: ["url": url.absoluteString])
    } else {
      pendingLaunch = url.absoluteString
    }
    return true
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "save":
      guard let key = args?["key"] as? String else {
        result(FlutterError(code: "bad-args", message: "save needs a key", details: nil))
        return
      }
      WidgetStore.set(args?["value"] as? String, for: key)
      result(nil)
    case "read":
      guard let key = args?["key"] as? String else {
        result(FlutterError(code: "bad-args", message: "read needs a key", details: nil))
        return
      }
      result(WidgetStore.string(key))
    case "reload":
      WidgetCenter.shared.reloadAllTimelines()
      result(nil)
    case "launch":
      dartListening = true
      result(pendingLaunch)
      pendingLaunch = nil
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func observeQueue() {
    guard !observingQueue else { return }
    observingQueue = true
    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      Unmanaged.passUnretained(self).toOpaque(),
      { _, observer, _, _, _ in
        guard let observer else { return }
        let widgets = Unmanaged<WidgetChannel>.fromOpaque(observer).takeUnretainedValue()
        DispatchQueue.main.async { widgets.queued() }
      },
      WidgetStore.queuedNotification as CFString,
      nil,
      .deliverImmediately)
  }

  private func queued() {
    channel?.invokeMethod("queued", arguments: nil)
  }
}
