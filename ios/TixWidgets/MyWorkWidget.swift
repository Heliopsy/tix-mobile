// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import WidgetKit

/// My work: the caller's next open tasks, overdue and due today first, with a tick on each.
struct MyWorkWidget: Widget {
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: TixWidgetKind.myWork, intent: MyWorkWidgetIntent.self, provider: MyWorkProvider()) {
      entry in
      MyWorkView(entry: entry)
    }
    .configurationDisplayName("My work")
    .description("Your next open tasks. Tick one to complete it.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct MyWorkView: View {
  let entry: MyWorkEntry

  @Environment(\.widgetFamily) private var family
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
      SkeletonView(title: labels.myWork, palette: palette)
    case .message(let text):
      VStack(alignment: .leading, spacing: 8) {
        HeaderView(title: labels.myWork, count: nil, mark: palette.lineStrong, palette: palette)
        MessageView(text: text, palette: palette)
      }
      .widgetURL(Links.app(ctx: entry.ctx))
    case .ready(let snapshot):
      ready(snapshot, palette: palette, labels: labels)
    }
  }

  @ViewBuilder
  private func ready(_ snapshot: MyWorkSnapshot, palette: Palette, labels: Labels) -> some View {
    let ctx = snapshot.ctx.id
    let queued = WidgetStore.queuedRefs(ctx: ctx)
    let all = snapshot.tasks ?? []
    let tasks = all.filter { !queued.contains($0.ref) }
    let hidden = all.count - tasks.count
    let total = max((snapshot.total ?? all.count) - hidden, 0)
    let accent = palette.accent(snapshot.accent)
    let sensitive = entry.index?.hidesTitlesWhenLocked ?? true
    let updated = Date(millis: snapshot.at)

    if family == .systemSmall {
      VStack(alignment: .leading, spacing: 4) {
        HeaderView(title: labels.myWork, count: nil, mark: accent, palette: palette)
        Text("\(total)")
          .font(WidgetFont.count)
          .foregroundStyle(palette.ink)
        Spacer(minLength: 0)
        if let first = tasks.first {
          TaskRow(
            task: first, ctx: ctx, now: entry.date, tick: true, sensitive: sensitive, labels: labels,
            palette: palette)
        } else {
          Text(labels.nothingDue)
            .font(WidgetFont.meta)
            .foregroundStyle(palette.muted)
            .lineLimit(2)
        }
      }
      .widgetURL(Links.app(ctx: ctx))
    } else {
      VStack(alignment: .leading, spacing: 6) {
        Link(destination: Links.app(ctx: ctx)) {
          HeaderView(title: labels.myWork, count: "\(total)", mark: accent, palette: palette)
        }
        if tasks.isEmpty {
          MessageView(text: labels.nothingDue, palette: palette)
        } else {
          ForEach(tasks.prefix(rows), id: \.ref) { task in
            TaskRow(
              task: task, ctx: ctx, now: entry.date, tick: true, sensitive: sensitive, labels: labels,
              palette: palette)
          }
          if family == .systemLarge, total > min(tasks.count, rows) {
            Text(verbatim: "+\(total - min(tasks.count, rows))")
              .font(WidgetFont.meta)
              .foregroundStyle(palette.muted)
          }
          Spacer(minLength: 0)
        }
        FooterView(ctx: snapshot.ctx, at: updated, labels: labels, palette: palette)
      }
    }
  }

  private var rows: Int {
    family == .systemLarge ? 8 : 2
  }
}
