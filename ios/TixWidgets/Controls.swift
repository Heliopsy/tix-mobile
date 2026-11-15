// SPDX-License-Identifier: AGPL-3.0-or-later

import AppIntents
import SwiftUI
import WidgetKit

/// The control kinds.
enum TixControlKind {
  static let quickAdd = "TixQuickAddControl"
  static let inbox = "TixInboxControl"
}

/// Quick add in Control Center, on the Lock Screen and on the Action Button.
@available(iOS 18.0, *)
struct QuickAddControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: TixControlKind.quickAdd) {
      ControlWidgetButton(action: OpenQuickAddIntent()) {
        Label("Quick add", systemImage: "plus")
      }
    }
    .displayName("Quick add")
    .description("Add a task in one tap.")
  }
}

/// Inbox, with the active context's unread count when the app has written a snapshot.
@available(iOS 18.0, *)
struct InboxControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: TixControlKind.inbox, provider: InboxControlProvider()) { title in
      ControlWidgetButton(action: OpenInboxIntent()) {
        Label(title, systemImage: "tray")
      }
    }
    .displayName("Inbox")
    .description("Mentions, assignments and replies you have not read.")
  }
}

/// "Inbox · 5" from the inbox snapshot of the active context, or "Inbox" without one.
@available(iOS 18.0, *)
struct InboxControlProvider: ControlValueProvider {
  var previewValue: String { Labels(nil).inbox }

  func currentValue() async throws -> String {
    let entry = EntryLoader.inbox(nil)
    guard case .ready(let snapshot) = entry.panel else { return entry.labels.inbox }
    return "\(entry.labels.inbox) · \(InboxCount(snapshot).short)"
  }
}
