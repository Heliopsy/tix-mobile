// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// How the task screen draws its selection.
enum TaskView {
  /// Rows.
  list,

  /// Columns per workflow state.
  board,

  /// One lane per project.
  lanes;

  /// The view named [name], as a saved filter stores it.
  static TaskView? named(String name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}

/// How the list splits its rows under headings.
enum TaskGrouping {
  /// One run of rows.
  none,

  /// A heading per status.
  status,

  /// A heading per project.
  project,
}

/// How many rows a list page holds.
const listPageSize = 50;

/// How many cards a board, lanes or My work page holds: they draw a page
/// at once, so a bigger one fills the columns, as the web's 200 does.
const boardPageSize = 200;

/// The fields `GET /tasks` sorts by; the empty one is tix's urgency.
const taskSorts = [
  '',
  'priority',
  'due_at',
  'created_at',
  'updated_at',
  'seq',
  'title',
];

/// What the task screen is scoped to before any filter.
@immutable
sealed class TaskScope {
  const TaskScope();

  /// The key that names this scope in providers and view preferences.
  String get id;
}

/// Every project.
final class AllScope extends TaskScope {
  /// Creates the scope.
  const AllScope();

  @override
  String get id => 'all';

  @override
  bool operator ==(Object other) => other is AllScope;

  @override
  int get hashCode => 0;
}

/// One project.
final class ProjectScope extends TaskScope {
  /// Scopes to the project [key].
  const ProjectScope(this.key);

  /// The project's key.
  final String key;

  @override
  String get id => 'project:${key.toLowerCase()}';

  @override
  bool operator ==(Object other) =>
      other is ProjectScope && other.key.toLowerCase() == key.toLowerCase();

  @override
  int get hashCode => key.toLowerCase().hashCode;
}

/// The reader's own open work.
final class MineScope extends TaskScope {
  /// Creates the scope.
  const MineScope();

  @override
  String get id => 'mine';

  @override
  bool operator ==(Object other) => other is MineScope;

  @override
  int get hashCode => 1;
}

/// One listing request: everything that decides which tasks, in what order.
/// A listing is cached per query, so two drawings of the same query share
/// it.
@immutable
class TaskQuery {
  /// A query over [scope] narrowed by [expression].
  const TaskQuery({
    this.scope = const AllScope(),
    this.expression = '',
    this.sort = '',
    this.descending = false,
    this.openOnly = false,
    this.limit = listPageSize,
  });

  /// Where the tasks come from.
  final TaskScope scope;

  /// tix's filter expression.
  final String expression;

  /// The sort field, empty for urgency.
  final String sort;

  /// Whether the sort runs backwards.
  final bool descending;

  /// Whether to ask only for unfinished states when no status is named.
  final bool openOnly;

  /// How many tasks one page holds.
  final int limit;

  @override
  bool operator ==(Object other) =>
      other is TaskQuery &&
      other.scope == scope &&
      other.expression == expression &&
      other.sort == sort &&
      other.descending == descending &&
      other.openOnly == openOnly &&
      other.limit == limit;

  @override
  int get hashCode =>
      Object.hash(scope, expression, sort, descending, openOnly, limit);
}

/// What the task screen shows: the typed filter, the drawing and the list's
/// options. Kept per scope while the app runs.
@immutable
class TaskScreenState {
  /// The state of a screen.
  const TaskScreenState({
    this.expression = '',
    this.sort = '',
    this.descending = false,
    this.view = TaskView.list,
    this.grouping = TaskGrouping.none,
    this.showFinished = false,
    this.savedFilterId,
    this.filterError,
  });

  /// The filter expression as applied.
  final String expression;

  /// The sort field.
  final String sort;

  /// Whether the sort runs backwards.
  final bool descending;

  /// The drawing.
  final TaskView view;

  /// The list's headings.
  final TaskGrouping grouping;

  /// Whether the list shows finished work too.
  final bool showFinished;

  /// The saved filter last applied, while the filter still matches it.
  final String? savedFilterId;

  /// Why the expression typed last was not applied, as tix words it.
  final String? filterError;

  /// A copy with the given fields replaced.
  TaskScreenState copyWith({
    String? expression,
    String? sort,
    bool? descending,
    TaskView? view,
    TaskGrouping? grouping,
    bool? showFinished,
    String? Function()? savedFilterId,
    String? Function()? filterError,
  }) => TaskScreenState(
    expression: expression ?? this.expression,
    sort: sort ?? this.sort,
    descending: descending ?? this.descending,
    view: view ?? this.view,
    grouping: grouping ?? this.grouping,
    showFinished: showFinished ?? this.showFinished,
    savedFilterId: savedFilterId == null ? this.savedFilterId : savedFilterId(),
    filterError: filterError == null ? this.filterError : filterError(),
  );

  /// The listing this state asks for over [scope].
  TaskQuery query(TaskScope scope) => TaskQuery(
    scope: scope,
    expression: expression,
    sort: sort,
    descending: descending,
    openOnly: scope is MineScope || (view == TaskView.list && !showFinished),
    limit: scope is MineScope || view != TaskView.list
        ? boardPageSize
        : listPageSize,
  );
}
