// SPDX-License-Identifier: AGPL-3.0-or-later

import BackgroundTasks
import Flutter
import Foundation
import WidgetKit

/// Runs one widget job (`tixwidget://drain` or `tixwidget://refresh`) in a headless Flutter engine.
///
/// The Dart side is `widgetHeadlessMain` in lib/main.dart; it signals `done` on `tix/widgets/headless`. Runs are
/// serialised, and each gives up after 25 seconds.
@MainActor
enum WidgetHeadless {
  static let entrypoint = "widgetHeadlessMain"
  static let channelName = "tix/widgets/headless"
  static let timeout: TimeInterval = 25

  private static var tail: Task<Void, Never>?

  static func run(_ url: String) async {
    let previous = tail
    let job = Task { @MainActor in
      await previous?.value
      await runOnce(url)
    }
    tail = job
    await job.value
  }

  private static func runOnce(_ url: String) async {
    let engine = FlutterEngine(name: "tix_widget_headless", project: nil, allowHeadlessExecution: true)
    // A channel handler can only be set on a running engine: setting it first aborts the app (seen from the
    // background refresh on iOS 18.5). Dart's `done` is delivered on this main thread, so it cannot arrive
    // between run() returning and the handler being set below.
    guard engine.run(withEntrypoint: entrypoint, libraryURI: nil, initialRoute: nil, entrypointArgs: [url]) else {
      engine.destroyContext()
      return
    }
    GeneratedPluginRegistrant.register(with: engine)
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: engine.binaryMessenger)
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      var finished = false
      let finish = {
        guard !finished else { return }
        finished = true
        continuation.resume()
      }
      channel.setMethodCallHandler { call, result in
        guard call.method == "done" else {
          result(FlutterMethodNotImplemented)
          return
        }
        result(nil)
        finish()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { finish() }
    }
    channel.setMethodCallHandler(nil)
    engine.destroyContext()
  }
}

/// The `BGAppRefreshTask` that keeps the widgets' snapshots fresh while the app is in the background.
enum WidgetRefresh {
  static let identifier = "red.tix.tixMobile.widgets.refresh"

  /// Registers the task handler. Must run before `application(_:didFinishLaunchingWithOptions:)` returns.
  static func register() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
      guard let refresh = task as? BGAppRefreshTask else {
        task.setTaskCompleted(success: false)
        return
      }
      handle(refresh)
    }
  }

  /// Asks for the next refresh in 30 minutes at the earliest.
  static func schedule() {
    let request = BGAppRefreshTaskRequest(identifier: identifier)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
    try? BGTaskScheduler.shared.submit(request)
  }

  private static func handle(_ task: BGAppRefreshTask) {
    schedule()
    let completion = TaskCompletion(task)
    task.expirationHandler = {
      DispatchQueue.main.async { completion.finish(success: false) }
    }
    Task { @MainActor in
      await WidgetHeadless.run("tixwidget://refresh")
      WidgetCenter.shared.reloadAllTimelines()
      ControlReload.now()
      completion.finish(success: true)
    }
  }
}

/// Asks iOS 18 and later to redraw tix's controls, whose Inbox count reads the widget snapshots.
enum ControlReload {
  private static var pending: DispatchWorkItem?

  /// Reloads the controls shortly after any defaults change in this process, which includes every snapshot the app
  /// writes to the App Group. Bursts are gathered into one reload.
  static func start() {
    NotificationCenter.default.addObserver(
      forName: UserDefaults.didChangeNotification, object: nil, queue: .main
    ) { _ in
      schedule()
    }
  }

  static func schedule() {
    pending?.cancel()
    let work = DispatchWorkItem { now() }
    pending = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: work)
  }

  static func now() {
    if #available(iOS 18.0, *) {
      ControlCenter.shared.reloadAllControls()
    }
  }
}

/// Completes a background task exactly once, whichever of the work and the expiration comes first.
private final class TaskCompletion {
  private let task: BGTask
  private var done = false

  init(_ task: BGTask) {
    self.task = task
  }

  func finish(success: Bool) {
    guard !done else { return }
    done = true
    task.setTaskCompleted(success: success)
  }
}
