// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';

/// Where the app offers one tix operation.
///
/// The idea is tix's own `internal/capability`: every operation is declared
/// once with what exposes it, and a test holds the app to the whole API.
/// Here the API is `api/tix-openapi.yaml`, and an operation is either bound
/// below, or exempt or pending in `exemptions.yaml` beside this file.
@immutable
class Binding {
  /// Binds an operation to [action] in [feature], shipped in [wave].
  const Binding({
    required this.feature,
    required this.action,
    required this.wave,
  });

  /// The directory under `lib/src/features/`, or `core/<dir>` for an
  /// operation the app uses without a screen of its own.
  final String feature;

  /// What the person does, or what the app does for them: a short id.
  final String action;

  /// The wave it shipped in: 0 for what predates the parity work, then 1
  /// daily work, 2 team, 3 admin.
  final int wave;
}

/// Every operationId the app performs, and where.
const bindings = <String, Binding>{
  'server.health': Binding(feature: 'connect', action: 'check-server', wave: 0),
  'identity.whoami': Binding(feature: 'connect', action: 'identify', wave: 0),
  'tenant.show': Binding(feature: 'connect', action: 'name-tenant', wave: 0),
  'session.login': Binding(feature: 'connect', action: 'sign-in', wave: 0),
  'session.switch': Binding(feature: 'shell', action: 'switch-tenant', wave: 0),
  'session.logout': Binding(feature: 'instances', action: 'sign-out', wave: 0),
  'project.list': Binding(feature: 'projects', action: 'list', wave: 0),
  'task.list': Binding(feature: 'tasks', action: 'list', wave: 0),
  'task.show': Binding(feature: 'tasks', action: 'detail', wave: 0),
  'task.create': Binding(feature: 'tasks', action: 'quick-add', wave: 0),
  'actor.show': Binding(feature: 'tasks', action: 'assignee', wave: 0),
  // Wave 1: quick add, templates and the palette.
  'task.import': Binding(feature: 'quick', action: 'preview-line', wave: 1),
  'template.list': Binding(feature: 'templates', action: 'list', wave: 1),
  'template.show': Binding(feature: 'templates', action: 'show', wave: 1),
  'template.save': Binding(feature: 'templates', action: 'save', wave: 1),
  'template.update': Binding(feature: 'templates', action: 'edit', wave: 1),
  'template.delete': Binding(feature: 'templates', action: 'delete', wave: 1),
  'template.use': Binding(feature: 'templates', action: 'use', wave: 1),
  'event.subscribe': Binding(
    feature: 'core/events',
    action: 'live-updates',
    wave: 0,
  ),
  'task.update': Binding(feature: 'tasks', action: 'edit', wave: 1),
  'task.check': Binding(feature: 'tasks', action: 'tick-checklist', wave: 1),
  'task.route': Binding(feature: 'tasks', action: 'move', wave: 1),
  // Wave 1: board, lists, filters and bulk actions.
  'task.bulk': Binding(feature: 'tasks', action: 'bulk', wave: 1),
  'task.star': Binding(feature: 'tasks', action: 'star', wave: 1),
  'task.unstar': Binding(feature: 'tasks', action: 'unstar', wave: 1),
  'task.snooze': Binding(feature: 'tasks', action: 'snooze', wave: 1),
  'task.unsnooze': Binding(feature: 'tasks', action: 'wake', wave: 1),
  'task.copy': Binding(feature: 'tasks', action: 'copy', wave: 1),
  'task.delete': Binding(feature: 'tasks', action: 'delete', wave: 1),
  'task.restore': Binding(feature: 'tasks', action: 'undo-delete', wave: 1),
  'task.tree': Binding(feature: 'tasks', action: 'subtasks', wave: 1),
  'task.audit': Binding(feature: 'tasks', action: 'history', wave: 1),
  'tag.add': Binding(feature: 'tasks', action: 'add-tag', wave: 1),
  'tag.remove': Binding(feature: 'tasks', action: 'remove-tag', wave: 1),
  'tag.list': Binding(feature: 'tasks', action: 'tag-picker', wave: 1),
  'comment.list': Binding(feature: 'tasks', action: 'comments', wave: 1),
  'comment.add': Binding(feature: 'tasks', action: 'comment', wave: 1),
  'comment.edit': Binding(feature: 'tasks', action: 'edit-comment', wave: 1),
  'comment.delete': Binding(
    feature: 'tasks',
    action: 'delete-comment',
    wave: 1,
  ),
  'dependency.list': Binding(feature: 'tasks', action: 'dependencies', wave: 1),
  'dependency.add': Binding(
    feature: 'tasks',
    action: 'add-dependency',
    wave: 1,
  ),
  'dependency.remove': Binding(
    feature: 'tasks',
    action: 'remove-dependency',
    wave: 1,
  ),
  'artifact.list': Binding(feature: 'tasks', action: 'artifacts', wave: 1),
  'artifact.put': Binding(feature: 'tasks', action: 'attach', wave: 1),
  'field.list': Binding(feature: 'tasks', action: 'custom-fields', wave: 1),
  'project.show': Binding(feature: 'tasks', action: 'project-of-task', wave: 1),
  'workflow.get': Binding(feature: 'tasks', action: 'workflow-moves', wave: 1),
  'actor.list': Binding(feature: 'tasks', action: 'actor-picker', wave: 1),
  'trash.status': Binding(feature: 'tasks', action: 'delete-undo', wave: 1),
  'workflow.list': Binding(feature: 'tasks', action: 'board-columns', wave: 1),
  'view.groups': Binding(feature: 'tasks', action: 'arrangement', wave: 1),
  'view.group.set': Binding(feature: 'tasks', action: 'arrange-group', wave: 1),
  'view.order': Binding(feature: 'tasks', action: 'move-group', wave: 1),
  'view.reset': Binding(feature: 'tasks', action: 'reset-arrangement', wave: 1),
  'filter.list': Binding(feature: 'tasks', action: 'saved-filters', wave: 1),
  'filter.save': Binding(feature: 'tasks', action: 'save-filter', wave: 1),
  'filter.update': Binding(feature: 'tasks', action: 'edit-filter', wave: 1),
  'filter.delete': Binding(feature: 'tasks', action: 'delete-filter', wave: 1),
  'filter.order': Binding(feature: 'tasks', action: 'order-filters', wave: 1),
  'stats.read': Binding(feature: 'projects', action: 'open-count', wave: 1),
};
