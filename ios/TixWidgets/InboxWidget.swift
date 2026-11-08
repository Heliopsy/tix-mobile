// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import WidgetKit

/// Inbox: the unread count and the latest items; on the iOS lock screen, the count.
struct InboxWidget: Widget {
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: TixWidgetKind.inbox, intent: InboxWidgetIntent.self, provider: InboxProvider()) {
      entry in
      InboxView(entry: entry)
    }
    .configurationDisplayName("Inbox")
    .description("Mentions, assignments and replies you have not read.")
    .supportedFamilies(Self.families)
  }

  private static var families: [WidgetFamily] {
    #if os(iOS)
      return [
        .systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline,
      ]
    #else
      return [.systemSmall, .systemMedium, .systemLarge]
    #endif
  }
}

struct InboxView: View {
  let entry: InboxEntry

  @Environment(\.widgetFamily) private var family
  @Environment(\.colorScheme) private var scheme

  var body: some View {
    #if os(iOS)
      if isAccessory {
        InboxAccessoryView(entry: entry, family: family)
      } else {
        home
      }
    #else
      home
    #endif
  }

  private var isAccessory: Bool {
    #if os(iOS)
      switch family {
      case .accessoryCircular, .accessoryRectangular, .accessoryInline: return true
      default: return false
      }
    #else
      return false
    #endif
  }

  private var home: some View {
    let palette = Palette.resolve(entry.index, scheme: scheme)
    return content(palette)
      .tixBackground(palette)
  }

  @ViewBuilder
  private func content(_ palette: Palette) -> some View {
    let labels = entry.labels
    switch entry.panel {
    case .placeholder:
      SkeletonView(title: labels.inbox, palette: palette)
    case .message(let text):
      VStack(alignment: .leading, spacing: 8) {
        HeaderView(title: labels.inbox, count: nil, mark: palette.lineStrong, palette: palette)
        MessageView(text: text, palette: palette)
      }
      .widgetURL(Links.app(ctx: entry.ctx))
    case .ready(let snapshot):
      ready(snapshot, palette: palette, labels: labels)
    }
  }

  @ViewBuilder
  private func ready(_ snapshot: InboxSnapshot, palette: Palette, labels: Labels) -> some View {
    let ctx = snapshot.ctx.id
    let items = snapshot.items ?? []
    let count = InboxCount(snapshot)
    let accent = palette.accent(snapshot.accent)
    let sensitive = entry.index?.hidesTitlesWhenLocked ?? true
    let inbox = Links.open(ctx: ctx, route: "/inbox")

    if family == .systemSmall {
      VStack(alignment: .leading, spacing: 4) {
        HeaderView(title: labels.inbox, count: nil, mark: accent, palette: palette)
        Text(count.short)
          .font(WidgetFont.count)
          .foregroundStyle(palette.ink)
        Spacer(minLength: 0)
        if let first = items.first {
          Text(first.what)
            .font(WidgetFont.meta)
            .foregroundStyle(palette.muted)
            .lineLimit(2)
            .privacySensitive(sensitive)
        } else {
          Text(labels.allRead)
            .font(WidgetFont.meta)
            .foregroundStyle(palette.muted)
        }
      }
      .widgetURL(inbox)
    } else {
      VStack(alignment: .leading, spacing: 6) {
        Link(destination: inbox) {
          HeaderView(title: labels.inbox, count: count.short, mark: accent, palette: palette)
        }
        if items.isEmpty {
          MessageView(text: labels.allRead, palette: palette)
        } else {
          ForEach(items.prefix(rows), id: \.id) { item in
            Link(destination: Links.open(ctx: ctx, route: item.route, item: item.id)) {
              InboxRow(item: item, now: entry.date, sensitive: sensitive, palette: palette)
            }
          }
          Spacer(minLength: 0)
        }
        FooterView(ctx: snapshot.ctx, at: Date(millis: snapshot.at), labels: labels, palette: palette)
      }
    }
  }

  private var rows: Int {
    family == .systemLarge ? 5 : 1
  }
}

/// The unread count as the widgets print it: "5", or "5+" when the snapshot holds a floor.
struct InboxCount {
  let unread: Int
  let more: Bool
  let text: String?

  init(_ snapshot: InboxSnapshot) {
    unread = snapshot.unread ?? snapshot.items?.count ?? 0
    more = snapshot.more ?? false
    text = snapshot.unreadText
  }

  var short: String { more ? "\(unread)+" : "\(unread)" }
}

/// One inbox item: what happened, on which task, and when.
struct InboxRow: View {
  let item: InboxItem
  let now: Date
  let sensitive: Bool
  let palette: Palette

  var body: some View {
    VStack(alignment: .leading, spacing: 1) {
      HStack(spacing: 6) {
        Text(item.what)
          .font(WidgetFont.row)
          .foregroundStyle(palette.ink)
          .lineLimit(1)
          .privacySensitive(sensitive)
        Spacer(minLength: 4)
        Text(item.date.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated)))
          .font(WidgetFont.meta)
          .foregroundStyle(palette.muted)
          .lineLimit(1)
      }
      if let task = item.task, !task.isEmpty {
        Text(task)
          .font(WidgetFont.meta)
          .foregroundStyle(palette.muted)
          .lineLimit(1)
          .privacySensitive(sensitive)
      }
    }
  }
}

#if os(iOS)
  /// The lock screen accessories: the count only while `lockCounts` is on.
  struct InboxAccessoryView: View {
    let entry: InboxEntry
    let family: WidgetFamily

    var body: some View {
      content
        .containerBackground(for: .widget) {
          if family == .accessoryCircular {
            AccessoryWidgetBackground()
          } else {
            Color.clear
          }
        }
        .widgetURL(link)
    }

    private var link: URL {
      guard let ctx = entry.ctx else { return Links.app(ctx: nil) }
      return Links.open(ctx: ctx, route: "/inbox")
    }

    @ViewBuilder
    private var content: some View {
      let labels = entry.labels
      switch entry.panel {
      case .placeholder:
        Image(systemName: "tray")
      case .message(let text):
        if family == .accessoryCircular {
          Image(systemName: "tray")
        } else {
          Text(text)
        }
      case .ready(let snapshot):
        ready(snapshot, labels: labels)
      }
    }

    @ViewBuilder
    private func ready(_ snapshot: InboxSnapshot, labels: Labels) -> some View {
      let count = InboxCount(snapshot)
      let showsTitle = !(entry.index?.hidesTitlesWhenLocked ?? true)
      switch family {
      case .accessoryCircular:
        VStack(spacing: 0) {
          Image(systemName: "tray")
            .font(.system(size: 12))
          Text(count.short)
            .font(.system(size: 18, weight: .semibold).monospacedDigit())
            .minimumScaleFactor(0.6)
        }
      case .accessoryInline:
        Label("\(labels.inbox) \(count.short)", systemImage: "tray")
      default:
        VStack(alignment: .leading, spacing: 1) {
          Text("\(labels.inbox) · \(count.short)")
            .font(.headline)
            .widgetAccentable()
          if showsTitle, let first = snapshot.items?.first {
            Text(first.what)
              .lineLimit(2)
          } else if let text = count.text, !text.isEmpty {
            Text(text)
          } else if count.unread == 0 {
            Text(labels.allRead)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
#endif
