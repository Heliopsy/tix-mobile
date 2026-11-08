// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import WidgetKit

/// Quick add: one button that opens the quick add sheet, in the widget's project when it has one.
struct QuickAddWidget: Widget {
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: TixWidgetKind.quickAdd, intent: QuickAddWidgetIntent.self, provider: QuickAddProvider()
    ) { entry in
      QuickAddView(entry: entry)
    }
    .configurationDisplayName("Quick add")
    .description("Add a task in one tap.")
    .supportedFamilies([.systemSmall])
  }
}

struct QuickAddView: View {
  let entry: QuickAddEntry

  @Environment(\.colorScheme) private var scheme

  var body: some View {
    let palette = Palette.resolve(entry.index, scheme: scheme)
    content(palette)
      .tixBackground(palette)
  }

  @ViewBuilder
  private func content(_ palette: Palette) -> some View {
    let labels = entry.labels
    switch entry.panel {
    case .placeholder:
      button(accent: palette.lineStrong, onAccent: palette.bg, title: labels.addTask, palette: palette)
        .redacted(reason: .placeholder)
    case .message(let text):
      VStack(alignment: .leading, spacing: 8) {
        HeaderView(title: labels.quickAdd, count: nil, mark: palette.lineStrong, palette: palette)
        MessageView(text: text, palette: palette)
      }
      .widgetURL(Links.app(ctx: entry.ctx))
    case .ready(let payload):
      VStack(alignment: .leading, spacing: 6) {
        button(
          accent: palette.accent(payload.accent), onAccent: palette.onAccent(payload.accent),
          title: labels.addTask, palette: palette)
        if let ctx = payload.ctx {
          Text(payload.project.map { "\(ctx.label) · \($0)" } ?? ctx.label)
            .font(WidgetFont.footer)
            .foregroundStyle(palette.muted)
            .lineLimit(1)
        }
      }
      .widgetURL(entry.ctx.map { Links.quickAdd(ctx: $0, project: payload.project) } ?? Links.app(ctx: nil))
    }
  }

  private func button(accent: Color, onAccent: Color, title: String, palette: Palette) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Image(systemName: "plus")
        .font(.system(size: 22, weight: .semibold))
        .foregroundStyle(onAccent)
        .frame(width: 44, height: 44)
        .background(Circle().fill(accent))
      Spacer(minLength: 0)
      Text(title)
        .font(WidgetFont.title)
        .foregroundStyle(palette.ink)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}
