// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/data/query/filter_expression.dart';
import 'package:tix_mobile/src/data/query/task_query.dart';

/// Every project, workflow and the reader: what rows, cards and columns need
/// to resolve a task's project, colour and status category.
class TaskIndex {
  /// Indexes [projects] and [workflows].
  TaskIndex({required this.projects, required this.workflows})
    : _byId = {for (final p in projects) p.id: p},
      _byKey = {for (final p in projects) p.key.toLowerCase(): p},
      _workflows = {for (final w in workflows) w.id: w};

  /// Every project, in the server's order.
  final List<Project> projects;

  /// Every workflow.
  final List<Workflow> workflows;

  final Map<String, Project> _byId;
  final Map<String, Project> _byKey;
  final Map<String, Workflow> _workflows;

  /// The project [task] is in.
  Project? projectOf(Task task) => _byId[task.projectId];

  /// The project with [key].
  Project? project(String key) => _byKey[key.toLowerCase()];

  /// The workflow [project] runs.
  Workflow? workflowOfProject(Project? project) =>
      project == null ? null : _workflows[project.workflowId];

  /// The workflow [task] follows.
  Workflow? workflowOf(Task task) => workflowOfProject(projectOf(task));

  /// The category of [task]'s state, from its workflow, or null.
  String? categoryOf(Task task) {
    final w = workflowOf(task);
    final state = w?.state(task.status);
    return state == null ? null : w!.categoryOf(state);
  }

  /// Whether [task] is in a terminal state of its workflow.
  bool isFinished(Task task) =>
      task.completedAt != null ||
      (workflowOf(task)?.state(task.status)?.terminal ?? false);

  /// The keys of every unfinished state any workflow has.
  List<String> get openStates =>
      {for (final w in workflows) ...w.openStates}.toList();
}

/// The `GET /tasks` parameters [query] stands for, read at [now] against
/// [context]. With [held], My work asks for the tasks the reader holds a
/// claim on instead of the ones assigned to them.
TaskParams paramsFor(
  TaskQuery query,
  TaskIndex context,
  DateTime now, {
  bool held = false,
}) {
  final params = parseFilterExpression(query.expression, now: now);
  switch (query.scope) {
    case ProjectScope(:final key):
      params['project'] = [key];
    case MineScope() when held:
      params['claimed_by'] = ['me'];
    case MineScope():
      params['assignee'] = ['me'];
    case AllScope():
  }
  final trash = params['trashed']?.contains('true') ?? false;
  if (query.openOnly && !params.containsKey('status') && !trash) {
    final open = context.openStates;
    if (open.isNotEmpty) params['status'] = open;
  }
  return params;
}
