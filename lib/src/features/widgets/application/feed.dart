// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/widget_snapshot.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/data/repositories/inbox_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';
import 'package:tix_mobile/src/features/widgets/application/snapshots.dart';

/// How many assigned tasks one refresh reads.
const _mineRead = 50;

/// How many open tasks of a project one refresh reads.
const _projectRead = 100;

/// What became of one queued action.
enum ActionOutcome {
  /// The server took it, or it was already so.
  done,

  /// The server will never take it; drop it.
  refused,

  /// Try again later.
  later,
}

/// Reads what the widgets of one context show, and runs their actions,
/// through that context's repositories.
class WidgetFeed {
  /// Reads through the given repositories.
  WidgetFeed({required this.tasks, required this.lists, required this.inbox});

  /// Projects and single tasks.
  final TasksRepository tasks;

  /// Listings, moves and workflows.
  final TaskListRepository lists;

  /// The inbox.
  final InboxRepository inbox;

  Future<List<Project>> _projects() async {
    final all = <Project>[];
    String? cursor;
    do {
      final page = await tasks.projects(cursor: cursor);
      all.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null);
    return all;
  }

  static List<String> _open(Iterable<Workflow> workflows) =>
      {for (final w in workflows) ...w.openStates}
          .where((s) => s.isNotEmpty)
          .toList();

  /// Everything the widgets of [ctx] draw, plus the open tasks of each
  /// project in [projects].
  Future<WidgetFeedData> load({
    required WidgetContext ctx,
    required TixAccent accent,
    Set<String> projects = const {},
  }) async {
    final all = await _projects();
    final workflows = await lists.workflows();
    final open = _open(workflows);
    final mine = await lists.list((
      params: {
        'assignee': ['me'],
        if (open.isNotEmpty) 'status': open,
      },
      sort: 'due_at',
      direction: null,
      limit: _mineRead,
    ));
    final unread = await inbox.unreadCount();
    final items = unread == 0 ? null : await inbox.items(unread: true);
    final byKey = {for (final p in all) p.key.toLowerCase(): p};
    final byId = {for (final w in workflows) w.id: w};
    final perProject = <String, ({List<Task> tasks, bool more})>{};
    for (final key in projects) {
      final project = byKey[key.toLowerCase()];
      if (project == null) continue;
      final states = _open([?byId[project.workflowId]]);
      final page = await lists.list((
        params: {
          'project': [project.key],
          if (states.isNotEmpty) 'status': states,
        },
        sort: null,
        direction: null,
        limit: _projectRead,
      ));
      perProject[key] = (tasks: page.items, more: page.hasMore);
    }
    return WidgetFeedData(
      ctx: ctx,
      accent: accent,
      projects: all,
      workflows: workflows,
      mine: mine.items,
      mineMore: mine.hasMore,
      unread: unread,
      unreadMore: false,
      inbox: items?.items ?? const [],
      projectTasks: perProject,
    );
  }

  /// Completes [ref] by its workflow's done state.
  Future<ActionOutcome> complete(String ref) async {
    try {
      final task = await tasks.task(ref);
      if (task.completedAt != null) return ActionOutcome.done;
      final all = await _projects();
      final workflows = await lists.workflows();
      Project? project;
      for (final p in all) {
        if (p.id == task.projectId) project = p;
      }
      Workflow? workflow;
      for (final w in workflows) {
        if (w.id == project?.workflowId) workflow = w;
      }
      final done = workflow?.doneState?.key;
      if (done == null || done.isEmpty) return ActionOutcome.refused;
      if (workflow!.state(task.status)?.terminal ?? false) {
        return ActionOutcome.done;
      }
      await lists.move(ref, done);
      return ActionOutcome.done;
    } on TixException catch (e) {
      return switch (e.kind) {
        TixErrorKind.notFound ||
        TixErrorKind.forbidden ||
        TixErrorKind.invalid ||
        TixErrorKind.preconditionFailed ||
        TixErrorKind.conflict => ActionOutcome.refused,
        _ => ActionOutcome.later,
      };
    }
  }
}
