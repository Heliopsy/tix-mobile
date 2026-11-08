// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import WidgetKit

/// tix's home screen widgets, one extension per platform built from these sources (docs/widgets.md).
@main
struct TixWidgetsBundle: WidgetBundle {
  var body: some Widget {
    MyWorkWidget()
    InboxWidget()
    QuickAddWidget()
    ProjectWidget()
  }
}
