// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import WidgetKit

/// Project: a project's open tasks under each unfinished status, with counts.
struct ProjectWidget: Widget {
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: TixWidgetKind.project, intent: ProjectWidgetIntent.self, provider: ProjectProvider()) {
      entry in
      ProjectView(entry: entry)
    }
    .configurationDisplayName("Project")
    .description("A project's open tasks by status.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

/// One line of the project list: a status heading or a task under it.
private enum ProjectLine: Hashable {
  case group(ProjectGroup, count: Int)
  case task(TaskItem)

  var id: String {
    switch self {
    case .group(let group, _): return "g:\(group.status)"
    case .task(let task): return "t:\(task.ref)"
    }
  }
}

struct ProjectView: View {
  let entry: ProjectWidgetEntry

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
    let title = String(localized: "Project")
    switch entry.panel {
    case .placeholder:
      SkeletonView(title: title, palette: palette)
    case .message(let text):
      VStack(alignment: .leading, spacing: 8) {
        HeaderView(title: title, count: nil, mark: palette.lineStrong, palette: palette)
        MessageView(text: text, palette: palette)
      }
      .widgetURL(Links.app(ctx: entry.ctx))
    case .ready(let snapshot):
      ready(snapshot, palette: palette, labels: labels)
    }
  }

  @ViewBuilder
  private func ready(_ snapshot: ProjectSnapshot, palette: Palette, labels: Labels) -> some View {
    let ctx = snapshot.ctx.id
    let queued = WidgetStore.queuedRefs(ctx: ctx)
    let groups = snapshot.groups ?? []
    let hidden = groups.reduce(0) { sum, group in
      sum + (group.tasks ?? []).filter { queued.contains($0.ref) }.count
    }
    let open = max((snapshot.open ?? 0) - hidden, 0)
    let mark = palette.pick(snapshot.project.colour, fallback: palette.accent(snapshot.accent))
    let header = Links.open(ctx: ctx, route: "/projects/\(snapshot.project.key)")
    let sensitive = entry.index?.hidesTitlesWhenLocked ?? true

    if family == .systemSmall {
      VStack(alignment: .leading, spacing: 4) {
        HeaderView(title: snapshot.project.name, count: nil, mark: mark, palette: palette)
        Text("\(open)")
          .font(WidgetFont.count)
          .foregroundStyle(palette.ink)
        Spacer(minLength: 0)
        ForEach(Self.lines(groups, queued: queued).compactMap(Self.groupOnly).prefix(2), id: \.id) { line in
          lineView(line, ctx: ctx, sensitive: sensitive, labels: labels, palette: palette)
        }
      }
      .widgetURL(header)
    } else {
      VStack(alignment: .leading, spacing: 5) {
        Link(destination: header) {
          HeaderView(title: snapshot.project.name, count: "\(open)", mark: mark, palette: palette)
        }
        let lines = Self.lines(groups, queued: queued)
        if lines.isEmpty {
          MessageView(text: labels.noOpenTasks, palette: palette)
        } else {
          ForEach(Array(lines.prefix(rows)), id: \.id) { line in
            lineView(line, ctx: ctx, sensitive: sensitive, labels: labels, palette: palette)
          }
          Spacer(minLength: 0)
        }
        FooterView(ctx: snapshot.ctx, at: Date(millis: snapshot.at), labels: labels, palette: palette)
      }
    }
  }

  @ViewBuilder
  private func lineView(_ line: ProjectLine, ctx: String, sensitive: Bool, labels: Labels, palette: Palette)
    -> some View
  {
    switch line {
    case .group(let group, let count):
      HStack(spacing: 6) {
        Circle()
          .fill(palette.status(group.category))
          .frame(width: 6, height: 6)
        Text(group.label)
          .font(WidgetFont.meta.weight(.semibold))
          .foregroundStyle(palette.status(group.category))
          .lineLimit(1)
        Spacer(minLength: 4)
        Text("\(count)")
          .font(WidgetFont.meta.monospacedDigit())
          .foregroundStyle(palette.muted)
      }
    case .task(let task):
      TaskRow(
        task: task, ctx: ctx, now: entry.date, tick: false, sensitive: sensitive, labels: labels, palette: palette)
    }
  }

  private var rows: Int {
    family == .systemLarge ? 12 : 4
  }

  private static func groupOnly(_ line: ProjectLine) -> ProjectLine? {
    if case .group = line { return line }
    return nil
  }

  private static func lines(_ groups: [ProjectGroup], queued: Set<String>) -> [ProjectLine] {
    var lines: [ProjectLine] = []
    for group in groups {
      let all = group.tasks ?? []
      let tasks = all.filter { !queued.contains($0.ref) }
      let count = max((group.count ?? all.count) - (all.count - tasks.count), 0)
      guard count > 0 || !tasks.isEmpty else { continue }
      lines.append(.group(group, count: count))
      lines.append(contentsOf: tasks.map(ProjectLine.task))
    }
    return lines
  }
}
