// SPDX-License-Identifier: AGPL-3.0-or-later

import AppIntents
import Foundation
import WidgetKit

/// An instance and tenant a widget can be pinned to, or `active` to follow the app.
struct ContextEntity: AppEntity {
  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Context"
  static let defaultQuery = ContextQuery()

  let id: String
  let label: String

  static let followActive = ContextEntity(id: WidgetStore.activeContext, label: "")

  var displayRepresentation: DisplayRepresentation {
    if id == WidgetStore.activeContext {
      return DisplayRepresentation(title: "Follow the active context")
    }
    return DisplayRepresentation(title: "\(label)")
  }
}

/// Reads the contexts the app wrote into the index.
struct ContextQuery: EntityQuery {
  func entities(for identifiers: [ContextEntity.ID]) async throws -> [ContextEntity] {
    let all = Self.all()
    return identifiers.map { id in
      all.first { $0.id == id } ?? ContextEntity(id: id, label: id)
    }
  }

  func suggestedEntities() async throws -> [ContextEntity] {
    Self.all()
  }

  func defaultResult() async -> ContextEntity? {
    .followActive
  }

  static func all() -> [ContextEntity] {
    guard case .ready(let index) = SnapshotReader.index() else { return [.followActive] }
    return [.followActive] + (index.contexts ?? []).map { ContextEntity(id: $0.id, label: $0.label) }
  }
}

/// A project of the widget's context.
struct ProjectEntity: AppEntity {
  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Project"
  static let defaultQuery = ProjectQuery()

  let id: String
  let name: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(name)", subtitle: "\(id)")
  }
}

/// Reads `index.projects` of the context chosen in the same configuration.
struct ProjectQuery: EntityQuery {
  @IntentParameterDependency<ProjectWidgetIntent>(\.$context)
  var projectWidget

  @IntentParameterDependency<QuickAddWidgetIntent>(\.$context)
  var quickAddWidget

  func entities(for identifiers: [ProjectEntity.ID]) async throws -> [ProjectEntity] {
    let known = Self.everyProject()
    return identifiers.map { id in
      known.first { $0.id == id } ?? ProjectEntity(id: id, name: id)
    }
  }

  func suggestedEntities() async throws -> [ProjectEntity] {
    let chosen = Self.chosen(projectWidget?.context) ?? Self.chosen(quickAddWidget?.context)
    return Self.projects(in: WidgetStore.resolve(chosen?.id))
  }

  private static func chosen(_ entity: ContextEntity?) -> ContextEntity? {
    entity
  }

  static func projects(in ctx: String?) -> [ProjectEntity] {
    guard let ctx, case .ready(let index) = SnapshotReader.index() else { return [] }
    return index.catalog(in: ctx).map { ProjectEntity(id: $0.key, name: $0.name) }
  }

  private static func everyProject() -> [ProjectEntity] {
    guard case .ready(let index) = SnapshotReader.index() else { return [] }
    var seen = Set<String>()
    var result: [ProjectEntity] = []
    let ordered = [index.active].compactMap { $0 } + (index.contexts ?? []).map(\.id)
    for ctx in ordered {
      for project in index.catalog(in: ctx) where seen.insert(project.key).inserted {
        result.append(ProjectEntity(id: project.key, name: project.name))
      }
    }
    return result
  }
}

/// My work's configuration: which context it shows.
struct MyWorkWidgetIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "My work"

  @Parameter(title: "Context")
  var context: ContextEntity?
}

/// Inbox's configuration: which context it shows.
struct InboxWidgetIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Inbox"

  @Parameter(title: "Context")
  var context: ContextEntity?
}

/// Quick add's configuration: the context and, optionally, the project new tasks go to.
struct QuickAddWidgetIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Quick add"

  @Parameter(title: "Context")
  var context: ContextEntity?

  @Parameter(title: "Project")
  var project: ProjectEntity?
}

/// Project's configuration: the context and the project it shows.
struct ProjectWidgetIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Project"

  @Parameter(title: "Context")
  var context: ContextEntity?

  @Parameter(title: "Project")
  var project: ProjectEntity?
}
