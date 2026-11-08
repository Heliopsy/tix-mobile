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
      guard engine.run(withEntrypoint: entrypoint, libraryURI: nil, initialRoute: nil, entrypointArgs: [url])
      else {
        finish()
        return
      }
      GeneratedPluginRegistrant.register(with: engine)
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
      completion.finish(success: true)
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
