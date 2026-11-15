// SPDX-License-Identifier: AGPL-3.0-or-later

import AppIntents
import Foundation

// The intents behind the controls and the App Shortcuts. Each opens a `tixwidget://` link in the active context.
// Compiled into the app and the extension: the controls run them in the extension, Siri and Shortcuts in the app.
// `OpenURLIntent` lets the system open the link, so a cold start still sees it as the launch link.

/// Add a task: quick add, with `text` in the line when given. The line is not sent until the person sends it.
@available(iOS 18.0, *)
struct OpenQuickAddIntent: AppIntent {
  static let title: LocalizedStringResource = "Add a task"

  @Parameter(title: "Title")
  var text: String?

  init() {}

  func perform() async throws -> some IntentResult & OpensIntent {
    let link = Links.quickAdd(ctx: WidgetStore.activeContext, project: nil, text: text)
    return .result(opensIntent: OpenURLIntent(link))
  }
}

/// Open inbox.
@available(iOS 18.0, *)
struct OpenInboxIntent: AppIntent {
  static let title: LocalizedStringResource = "Open inbox"

  init() {}

  func perform() async throws -> some IntentResult & OpensIntent {
    .result(opensIntent: OpenURLIntent(Links.open(ctx: WidgetStore.activeContext, route: "/inbox")))
  }
}

/// Open my work.
@available(iOS 18.0, *)
struct OpenMyWorkIntent: AppIntent {
  static let title: LocalizedStringResource = "Open my work"

  init() {}

  func perform() async throws -> some IntentResult & OpensIntent {
    .result(opensIntent: OpenURLIntent(Links.open(ctx: WidgetStore.activeContext, route: "/mine")))
  }
}
