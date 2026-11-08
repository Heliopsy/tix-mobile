// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import WidgetKit

/// The widget kinds, which are also the first part of a `tix.widget.wanted` key.
enum TixWidgetKind {
  static let myWork = "TixMyWork"
  static let inbox = "TixInbox"
  static let quickAdd = "TixQuickAdd"
  static let project = "TixProject"
}

/// What a widget draws: a skeleton, a single line of text, or its snapshot.
enum Panel<Payload> {
  case placeholder
  case message(String)
  case ready(Payload)
}

/// One timeline entry: the index (theme, privacy, labels), the resolved context and the panel.
struct TixEntry<Payload>: TimelineEntry {
  let date: Date
  let index: WidgetIndex?
  let ctx: String?
  let panel: Panel<Payload>

  static var placeholder: TixEntry<Payload> {
    TixEntry(date: Date(), index: nil, ctx: nil, panel: .placeholder)
  }

  var labels: Labels { Labels(index?.strings) }
}

/// The index's labels, which the app has localized, with the extension's own strings as fallback.
struct Labels {
  private let strings: [String: String]

  init(_ strings: [String: String]?) {
    self.strings = strings ?? [:]
  }

  func callAsFunction(_ key: String, _ fallback: String.LocalizationValue) -> String {
    if let value = strings[key], !value.isEmpty { return value }
    return String(localized: fallback)
  }

  var myWork: String { self("myWork", "My work") }
  var inbox: String { self("inbox", "Inbox") }
  var quickAdd: String { self("quickAdd", "Quick add") }
  var addTask: String { self("addTask", "Add a task") }
  var nothingDue: String { self("nothingDue", "Nothing assigned to you") }
  var allRead: String { self("allRead", "All caught up") }
  var noOpenTasks: String { self("noOpenTasks", "No open tasks") }
  var updated: String { self("updated", "Updated") }
  var openApp: String { self("openApp", "Open tix to load this widget") }
  var openUpdate: String { self("openUpdate", "Open tix to update") }
  var localStale: String { self("localStale", "Refreshes when tix is open") }
  var overdue: String { self("overdue", "Overdue") }
  var today: String { self("today", "Today") }
  var complete: String { self("complete", "Complete") }
  var projectMissing: String { self("projectMissing", "Not in this context") }
  var signedOut: String { self("signedOut", "Sign in to tix") }
  var pickProject: String { self("pickProject", "Edit the widget to choose a project") }
}

/// Resolves the index and the widget's context, then reads one snapshot.
enum EntryLoader {
  static func load<Payload: Decodable>(
    _ type: Payload.Type,
    configured: String?,
    key: (String) -> String?
  ) -> TixEntry<Payload> {
    let now = Date()
    let index: WidgetIndex
    switch SnapshotReader.index() {
    case .missing:
      return TixEntry(date: now, index: nil, ctx: nil, panel: .message(Labels(nil).openApp))
    case .outdated:
      return TixEntry(date: now, index: nil, ctx: nil, panel: .message(Labels(nil).openUpdate))
    case .ready(let value):
      index = value
    }
    let labels = Labels(index.strings)
    guard let ctx = resolve(configured, in: index) else {
      return TixEntry(date: now, index: index, ctx: nil, panel: .message(labels.signedOut))
    }
    guard let storageKey = key(ctx) else {
      return TixEntry(date: now, index: index, ctx: ctx, panel: .message(labels.pickProject))
    }
    switch SnapshotReader.read(type, key: storageKey) {
    case .missing:
      return TixEntry(date: now, index: index, ctx: ctx, panel: .message(labels.openApp))
    case .outdated:
      return TixEntry(date: now, index: index, ctx: ctx, panel: .message(labels.openUpdate))
    case .ready(let value):
      return TixEntry(date: now, index: index, ctx: ctx, panel: .ready(value))
    }
  }

  /// The configured context, or `index.active` when following the active one.
  static func resolve(_ configured: String?, in index: WidgetIndex) -> String? {
    guard let configured, !configured.isEmpty, configured != WidgetStore.activeContext else {
      return index.active
    }
    return configured
  }

  static func timeline<Payload>(_ entry: TixEntry<Payload>) -> Timeline<TixEntry<Payload>> {
    Timeline(entries: [entry], policy: .after(entry.date.addingTimeInterval(30 * 60)))
  }

  static func myWork(_ configured: String?) -> TixEntry<MyWorkSnapshot> {
    load(MyWorkSnapshot.self, configured: configured) { SnapshotReader.myWorkKey($0) }
  }

  static func inbox(_ configured: String?) -> TixEntry<InboxSnapshot> {
    load(InboxSnapshot.self, configured: configured) { SnapshotReader.inboxKey($0) }
  }

  static func project(_ configured: String?, project: String?) -> TixEntry<ProjectSnapshot> {
    let entry = load(ProjectSnapshot.self, configured: configured) { ctx in
      project.map { SnapshotReader.projectKey(ctx, $0) }
    }
    guard case .message = entry.panel, let ctx = entry.ctx, let index = entry.index, let project else {
      return entry
    }
    if !index.catalog(in: ctx).contains(where: { $0.key == project }) {
      return TixEntry(date: entry.date, index: index, ctx: ctx, panel: .message(entry.labels.projectMissing))
    }
    return entry
  }

  static func quickAdd(_ configured: String?, project: String?) -> TixEntry<QuickAddPayload> {
    let now = Date()
    guard case .ready(let index) = SnapshotReader.index() else {
      return TixEntry(date: now, index: nil, ctx: nil, panel: .message(Labels(nil).openApp))
    }
    guard let ctx = resolve(configured, in: index) else {
      return TixEntry(date: now, index: index, ctx: nil, panel: .message(Labels(index.strings).signedOut))
    }
    var accent: AccentColours?
    if case .ready(let snapshot) = SnapshotReader.read(MyWorkSnapshot.self, key: SnapshotReader.myWorkKey(ctx)) {
      accent = snapshot.accent
    } else if case .ready(let snapshot) = SnapshotReader.read(
      InboxSnapshot.self, key: SnapshotReader.inboxKey(ctx))
    {
      accent = snapshot.accent
    }
    let payload = QuickAddPayload(ctx: index.context(ctx), accent: accent, project: project)
    return TixEntry(date: now, index: index, ctx: ctx, panel: .ready(payload))
  }
}

typealias MyWorkEntry = TixEntry<MyWorkSnapshot>
typealias InboxEntry = TixEntry<InboxSnapshot>
typealias QuickAddEntry = TixEntry<QuickAddPayload>
typealias ProjectWidgetEntry = TixEntry<ProjectSnapshot>

/// My work's timeline.
struct MyWorkProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> MyWorkEntry { .placeholder }

  func snapshot(for configuration: MyWorkWidgetIntent, in context: Context) async -> MyWorkEntry {
    EntryLoader.myWork(configuration.context?.id)
  }

  func timeline(for configuration: MyWorkWidgetIntent, in context: Context) async -> Timeline<MyWorkEntry> {
    let ctx = configuration.context?.id ?? WidgetStore.activeContext
    WidgetStore.recordWanted(kind: TixWidgetKind.myWork, ctx: ctx, project: nil)
    return EntryLoader.timeline(EntryLoader.myWork(ctx))
  }
}

/// Inbox's timeline.
struct InboxProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> InboxEntry { .placeholder }

  func snapshot(for configuration: InboxWidgetIntent, in context: Context) async -> InboxEntry {
    EntryLoader.inbox(configuration.context?.id)
  }

  func timeline(for configuration: InboxWidgetIntent, in context: Context) async -> Timeline<InboxEntry> {
    let ctx = configuration.context?.id ?? WidgetStore.activeContext
    WidgetStore.recordWanted(kind: TixWidgetKind.inbox, ctx: ctx, project: nil)
    return EntryLoader.timeline(EntryLoader.inbox(ctx))
  }
}

/// Quick add's timeline.
struct QuickAddProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> QuickAddEntry { .placeholder }

  func snapshot(for configuration: QuickAddWidgetIntent, in context: Context) async -> QuickAddEntry {
    EntryLoader.quickAdd(configuration.context?.id, project: configuration.project?.id)
  }

  func timeline(for configuration: QuickAddWidgetIntent, in context: Context) async -> Timeline<QuickAddEntry> {
    let ctx = configuration.context?.id ?? WidgetStore.activeContext
    let project = configuration.project?.id
    WidgetStore.recordWanted(kind: TixWidgetKind.quickAdd, ctx: ctx, project: project)
    return EntryLoader.timeline(EntryLoader.quickAdd(ctx, project: project))
  }
}

/// Project's timeline.
struct ProjectProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> ProjectWidgetEntry { .placeholder }

  func snapshot(for configuration: ProjectWidgetIntent, in context: Context) async -> ProjectWidgetEntry {
    EntryLoader.project(configuration.context?.id, project: configuration.project?.id)
  }

  func timeline(for configuration: ProjectWidgetIntent, in context: Context) async -> Timeline<ProjectWidgetEntry> {
    let ctx = configuration.context?.id ?? WidgetStore.activeContext
    let project = configuration.project?.id
    WidgetStore.recordWanted(kind: TixWidgetKind.project, ctx: ctx, project: project)
    return EntryLoader.timeline(EntryLoader.project(ctx, project: project))
  }
}
