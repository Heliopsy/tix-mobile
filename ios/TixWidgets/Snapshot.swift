// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

/// A colour the app resolved for the light and the dark scheme, `#rrggbb`.
struct ColourPair: Decodable, Hashable {
  let light: String
  let dark: String
}

/// The tenant's accent, already contrast-checked by the app.
struct AccentColours: Decodable, Hashable {
  let light: String
  let dark: String
  let onLight: String
  let onDark: String
}

/// One instance and tenant the app is signed in to.
struct ContextInfo: Decodable, Hashable {
  let id: String
  let instance: String
  let tenant: String
  let local: Bool?

  /// "Work · Acme", as every widget footer names its context.
  var label: String {
    tenant.isEmpty ? instance : "\(instance) · \(tenant)"
  }

  var isLocal: Bool { local ?? false }
}

/// A project as the pickers and the project header show it.
struct ProjectInfo: Decodable, Hashable {
  let key: String
  let name: String
  let colour: ColourPair?
}

/// `tix.widget.index`: the active context, the catalog of contexts and projects, theme, privacy and labels.
struct WidgetIndex: Decodable {
  let v: Int
  let at: Int64?
  let active: String?
  let contexts: [ContextInfo]?
  let projects: [String: [ProjectInfo]]?
  let theme: String?
  let systemBlack: Bool?
  let lockCounts: Bool?
  let strings: [String: String]?

  var hidesTitlesWhenLocked: Bool { lockCounts ?? true }

  func context(_ id: String) -> ContextInfo? {
    contexts?.first { $0.id == id }
  }

  func catalog(in ctx: String) -> [ProjectInfo] {
    projects?[ctx] ?? []
  }
}

/// A task row, shared by My work and Project.
struct TaskItem: Decodable, Hashable {
  let ref: String
  let title: String
  let project: String?
  let colour: ColourPair?
  let due: Int64?
  let priority: String?
  let status: String?
  let category: String?
  let route: String

  var dueDate: Date? { due.map(Date.init(millis:)) }
}

/// `tix.widget.mywork.<ctx>`.
struct MyWorkSnapshot: Decodable {
  let v: Int
  let at: Int64
  let ctx: ContextInfo
  let accent: AccentColours?
  let total: Int?
  let more: Bool?
  let moreText: String?
  let tasks: [TaskItem]?
}

/// One unread inbox item.
struct InboxItem: Decodable, Hashable {
  let id: String
  let what: String
  let task: String?
  let excerpt: String?
  let at: Int64
  let route: String

  var date: Date { Date(millis: at) }
}

/// `tix.widget.inbox.<ctx>`.
struct InboxSnapshot: Decodable {
  let v: Int
  let at: Int64
  let ctx: ContextInfo
  let accent: AccentColours?
  let unread: Int?
  let more: Bool?
  let unreadText: String?
  let items: [InboxItem]?
}

/// One unfinished workflow state of a project, with its first tasks.
struct ProjectGroup: Decodable, Hashable {
  let status: String
  let label: String
  let category: String?
  let count: Int?
  let tasks: [TaskItem]?
}

/// `tix.widget.project.<ctx>.<KEY>`.
struct ProjectSnapshot: Decodable {
  let v: Int
  let at: Int64
  let ctx: ContextInfo
  let accent: AccentColours?
  let project: ProjectInfo
  let open: Int?
  let more: Bool?
  let groups: [ProjectGroup]?
}

/// What Quick add draws: the context, its accent and the configured project.
struct QuickAddPayload {
  let ctx: ContextInfo?
  let accent: AccentColours?
  let project: String?
}

/// Only the version of a stored value, read before the rest.
private struct VersionProbe: Decodable {
  let v: Int?
}

/// The result of reading one key.
enum Stored<Value> {
  case missing
  case outdated
  case ready(Value)
}

/// Reads and decodes the snapshot JSON from the App Group.
enum SnapshotReader {
  static let version = 1

  static func read<Value: Decodable>(_ type: Value.Type, key: String) -> Stored<Value> {
    guard let raw = WidgetStore.string(key), let data = raw.data(using: .utf8) else { return .missing }
    let decoder = JSONDecoder()
    guard let probe = try? decoder.decode(VersionProbe.self, from: data), probe.v == version,
      let value = try? decoder.decode(type, from: data)
    else { return .outdated }
    return .ready(value)
  }

  static func index() -> Stored<WidgetIndex> {
    read(WidgetIndex.self, key: WidgetStore.indexKey)
  }

  static func myWorkKey(_ ctx: String) -> String { "tix.widget.mywork.\(ctx)" }
  static func inboxKey(_ ctx: String) -> String { "tix.widget.inbox.\(ctx)" }
  static func projectKey(_ ctx: String, _ project: String) -> String { "tix.widget.project.\(ctx).\(project)" }
}

extension Date {
  init(millis: Int64) {
    self.init(timeIntervalSince1970: TimeInterval(millis) / 1000)
  }
}
