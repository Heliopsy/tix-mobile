// SPDX-License-Identifier: AGPL-3.0-or-later

import AppIntents
import SwiftUI
import WidgetKit

/// Text sizes shared by every widget.
enum WidgetFont {
  static let title = Font.system(size: 13, weight: .semibold)
  static let row = Font.system(size: 13)
  static let meta = Font.system(size: 11)
  static let footer = Font.system(size: 10)
  static let count = Font.system(size: 34, weight: .semibold).monospacedDigit()
}

/// A line of text centred in the widget: nothing to show, or why not.
struct MessageView: View {
  let text: String
  let palette: Palette

  var body: some View {
    Text(text)
      .font(WidgetFont.row)
      .foregroundStyle(palette.muted)
      .multilineTextAlignment(.center)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

/// Grey bars while WidgetKit asks for a placeholder.
struct SkeletonView: View {
  let title: String
  let palette: Palette

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HeaderView(title: title, count: nil, mark: palette.lineStrong, palette: palette)
      ForEach(0..<3, id: \.self) { _ in
        RoundedRectangle(cornerRadius: 3)
          .fill(palette.line)
          .frame(height: 10)
      }
      Spacer(minLength: 0)
    }
    .redacted(reason: .placeholder)
  }
}

/// The header: a mark in the accent or the project's colour, the title and a count.
struct HeaderView: View {
  let title: String
  let count: String?
  let mark: Color
  let palette: Palette

  var body: some View {
    HStack(spacing: 6) {
      RoundedRectangle(cornerRadius: 2)
        .fill(mark)
        .frame(width: 4, height: 14)
      Text(title)
        .font(WidgetFont.title)
        .foregroundStyle(palette.ink)
        .lineLimit(1)
      Spacer(minLength: 4)
      if let count {
        Text(count)
          .font(WidgetFont.title.monospacedDigit())
          .foregroundStyle(palette.muted)
          .lineLimit(1)
      }
    }
  }
}

/// The footer: which context the widget shows and how old its snapshot is.
struct FooterView: View {
  let ctx: ContextInfo?
  let at: Date
  let labels: Labels
  let palette: Palette

  var body: some View {
    VStack(alignment: .leading, spacing: 1) {
      HStack(spacing: 4) {
        if let ctx {
          Text(ctx.label)
            .lineLimit(1)
        }
        Spacer(minLength: 4)
        Text("\(labels.updated) \(Text(at, style: .relative))")
          .lineLimit(1)
      }
      if ctx?.isLocal == true {
        Text(labels.localStale)
          .lineLimit(1)
      }
    }
    .font(WidgetFont.footer)
    .foregroundStyle(palette.muted)
  }
}

/// A task's due date: overdue in danger, today and this week in warn, decided against the device clock.
struct DueText: View {
  let due: Date
  let now: Date
  let labels: Labels
  let palette: Palette

  var body: some View {
    let calendar = Calendar.current
    let days =
      calendar.dateComponents(
        [.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: due)
      ).day ?? 0
    Group {
      if days < 0 {
        Text(labels.overdue).foregroundStyle(palette.danger)
      } else if days == 0 {
        Text(labels.today).foregroundStyle(palette.warn)
      } else {
        Text(due, format: .dateTime.day().month(.abbreviated))
          .foregroundStyle(days < 7 ? palette.warn : palette.muted)
      }
    }
    .font(WidgetFont.meta)
    .lineLimit(1)
  }
}

/// One task: an optional tick, the project's colour, the title, priority and due date.
struct TaskRow: View {
  let task: TaskItem
  let ctx: String
  let now: Date
  let tick: Bool
  let sensitive: Bool
  let labels: Labels
  let palette: Palette

  var body: some View {
    HStack(spacing: 8) {
      if tick {
        Button(intent: CompleteTaskIntent(ctx: ctx, ref: task.ref)) {
          Image(systemName: "circle")
            .font(.system(size: 15))
            .foregroundStyle(palette.muted)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(labels.complete)
      }
      Link(destination: Links.open(ctx: ctx, route: task.route)) {
        HStack(spacing: 6) {
          RoundedRectangle(cornerRadius: 1.5)
            .fill(palette.pick(task.colour, fallback: palette.lineStrong))
            .frame(width: 3, height: 14)
          Text(task.title)
            .font(WidgetFont.row)
            .foregroundStyle(palette.ink)
            .lineLimit(1)
            .privacySensitive(sensitive)
          Spacer(minLength: 4)
          if palette.isHighPriority(task.priority) {
            Image(systemName: "chevron.up")
              .font(.system(size: 9, weight: .bold))
              .foregroundStyle(palette.danger)
          }
          if let due = task.dueDate {
            DueText(due: due, now: now, labels: labels, palette: palette)
          }
        }
      }
    }
  }
}

extension View {
  /// The widget's background in the resolved palette.
  func tixBackground(_ palette: Palette) -> some View {
    containerBackground(palette.bg, for: .widget)
  }
}
