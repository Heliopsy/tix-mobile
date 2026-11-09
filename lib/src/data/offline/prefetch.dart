// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/offline/connection_jobs.dart';
import 'package:tix_mobile/src/data/offline/offline_prefs.dart';
import 'package:tix_mobile/src/data/query/task_index.dart';
import 'package:tix_mobile/src/data/query/task_query.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';

/// The filter the Starred listing is: the task screen over every project
/// with only `is:starred` typed.
const starredExpression = 'is:starred';

/// The queries the task screen sends, untouched, for what [choice] keeps:
/// each project's list, My work and Starred.
List<TaskQuery> offlineQueries(OfflineChoice choice, Iterable<Project> all) {
  const screen = TaskScreenState();
  return [
    for (final p in all)
      if (choice.projects.contains(p.key)) screen.query(ProjectScope(p.key)),
    if (choice.myWork) screen.query(const MineScope()),
    if (choice.starred)
      const TaskScreenState(expression: starredExpression)
          .query(const AllScope()),
  ];
}

/// Reads everything [OfflineChoice] names through the repositories, so each
/// answer lands under the key the screens read: every page of each listing
/// merged into its first page, each task with its comments and subtasks,
/// the projects, workflows, fields, tags and actors needed to draw them.
class Prefetcher {
  /// Reads through the given repositories, at most [concurrency] requests
  /// at a time, with [now] as the clock the screens use for filters. It
  /// stops with [JobCancelled] once [job] is cancelled.
  Prefetcher({
    required this.tasks,
    required this.lists,
    required this.detail,
    required this.now,
    this.job,
    this.concurrency = 4,
  });

  /// Projects, tasks and the task detail record.
  final TasksRepository tasks;

  /// Listings and workflows.
  final TaskListRepository lists;

  /// Comments, subtasks, fields, workflows, tags and actors.
  final TaskDetailRepository detail;

  /// What time it is.
  final DateTime Function() now;

  /// The job this prefetch runs as, if any.
  final ConnectionJob? job;

  /// How many requests run at once.
  final int concurrency;

  /// Fetches what [choice] keeps. A failure to reach the server or a
  /// cancelled [job] stops it at once; any other failure (a task gone, a
  /// refused scope) skips that read, and the first one is thrown after
  /// everything else has been fetched.
  Future<void> run(OfflineChoice choice) =>
      ResponseCache.strict(() => _run(choice));

  Future<void> _run(OfflineChoice choice) async {
    final failures = <(Object, StackTrace)>[];
    job?.check();
    final workflows = lists.workflows()..ignore();
    final projects = await tasks.allProjects();
    final index = TaskIndex(projects: projects, workflows: await workflows);
    final listed = <String, Task>{};
    final queries = offlineQueries(choice, projects);
    await _pool([
      detail.tags,
      detail.actors,
      for (final q in queries)
        () async {
          final page = await lists.listAll(
            TaskListRepository.requestFor(q, index, now()),
          );
          for (final t in page.items) {
            listed[t.ref] = t;
          }
        },
    ], failures);
    final shown = {
      for (final p in projects)
        if (choice.projects.contains(p.key)) p.id: p,
    };
    for (final t in listed.values) {
      final p = index.projectOf(t);
      if (p != null) shown[p.id] = p;
    }
    await _pool([
      for (final p in shown.values) ...[
        () => detail.project(p.id),
        () => detail.fields(p.id),
        () => detail.workflow(p.workflowId),
      ],
      for (final ref in listed.keys) ...[
        () => tasks.task(ref),
        () => detail.comments(ref),
        () => detail.subtasks(ref),
      ],
    ], failures);
    job?.check();
    if (failures.isNotEmpty) {
      Error.throwWithStackTrace(failures.first.$1, failures.first.$2);
    }
  }

  Future<void> _pool(
    List<Future<void> Function()> jobs,
    List<(Object, StackTrace)> failures,
  ) async {
    var next = 0;
    var stopped = false;
    Future<void> worker() async {
      while (!stopped && next < jobs.length) {
        final read = jobs[next++];
        try {
          job?.check();
          await read();
        } on Object catch (e, s) {
          if (e is JobCancelled || ResponseCache.isUnreachable(e)) {
            stopped = true;
            rethrow;
          }
          failures.add((e, s));
        }
      }
    }

    await Future.wait([
      for (var i = 0; i < concurrency && i < jobs.length; i++) worker(),
    ]);
  }
}
