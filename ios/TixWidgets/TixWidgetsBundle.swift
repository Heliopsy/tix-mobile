// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import WidgetKit

/// tix's home screen widgets, and on iOS 18 its controls, one extension per platform built from these sources
/// (docs/widgets.md).
@main
struct TixWidgetsBundle: WidgetBundle {
  var body: some Widget {
    MyWorkWidget()
    InboxWidget()
    QuickAddWidget()
    ProjectWidget()
    #if os(iOS)
      if #available(iOS 18.0, *) {
        QuickAddControl()
        InboxControl()
      }
    #endif
  }
}
