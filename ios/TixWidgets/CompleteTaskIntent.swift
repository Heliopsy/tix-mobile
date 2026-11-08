// SPDX-License-Identifier: AGPL-3.0-or-later

import AppIntents
import Foundation
import WidgetKit

/// The tick on a widget row: queues the task's completion for the app to send.
///
/// Compiled into the app and the extension. In the extension it only queues (and on macOS wakes the running app);
/// in the iOS app it also drains the queue in a headless Flutter engine.
@available(iOS 17.0, macOS 14.0, *)
struct CompleteTaskIntent: AppIntent {
  static let title: LocalizedStringResource = "Complete task"
  static let openAppWhenRun: Bool = false
  static let isDiscoverable: Bool = false

  @Parameter(title: "Context")
  var ctx: String

  @Parameter(title: "Task")
  var ref: String

  init() {}

  init(ctx: String, ref: String) {
    self.ctx = ctx
    self.ref = ref
  }

  func perform() async throws -> some IntentResult {
    WidgetStore.enqueueComplete(ctx: ctx, ref: ref)
    #if TIX_WIDGET_EXTENSION
      #if os(macOS)
        WidgetStore.postQueued()
      #endif
    #else
      #if os(iOS)
        await WidgetHeadless.run("tixwidget://drain")
      #else
        WidgetStore.postQueued()
      #endif
    #endif
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

#if !TIX_WIDGET_EXTENSION && os(iOS)
  // home_widget's trick: an intent the extension cannot continue in the foreground runs in the app process.
  @available(iOS 17.0, *)
  @available(iOSApplicationExtension, unavailable)
  extension CompleteTaskIntent: ForegroundContinuableIntent {}
#endif
