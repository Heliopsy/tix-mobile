// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/cache/optimistic.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/data/query/filter_expression.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/features/tasks/application/bulk.dart';
import 'package:tix_mobile/src/features/tasks/application/task_query.dart';

export 'package:tix_mobile/src/features/tasks/application/bulk.dart';
export 'package:tix_mobile/src/features/tasks/application/task_query.dart';

part 'listing.g.dart';

/// How long a listing nobody is looking at stays cached, so going back to it
/// draws at once.
const listingCacheFor = Duration(minutes: 5);

void _keepFor(Ref ref, Duration duration) {
  final link = ref.keepAlive();
  Timer? timer;
  ref
    ..onCancel(() => timer = Timer(duration, link.close))
    ..onResume(() => timer?.cancel())
    ..onDispose(() => timer?.cancel());
}

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

/// The projects and workflows of the active session: the cached copies at
/// once, then the server's, and again when a project or workflow changes.
@riverpod
class TaskContext extends _$TaskContext {
  @override
  Future<TaskIndex> build() async {
    final tasks = ref.watch(tasksRepositoryProvider);
    final lists = ref.watch(taskListRepositoryProvider);
    refreshOn(ref, {...EventTopics.projects, ...EventTopics.workflows});
    Future<TaskIndex?> cached() async {
      final p = await tasks.cachedProjects();
      final w = await lists.cachedWorkflows();
      if (p == null || w == null || p.hasMore) return null;
      return TaskIndex(projects: p.items, workflows: w);
    }

    Future<TaskIndex> fresh() async {
      final workflows = lists.workflows()..ignore();
      final projects = <Project>[];
      String? cursor;
      do {
        final page = await tasks.projects(cursor: cursor);
        projects.addAll(page.items);
        cursor = page.nextCursor;
      } while (cursor != null);
      return TaskIndex(projects: projects, workflows: await workflows);
    }

    return await cachedFirst(
      ref: ref,
      cached: cached(),
      fresh: fresh,
      onFresh: (v) => state = AsyncData(v),
    );
  }
}

/// The signed-in reader.
@riverpod
Future<Actor> me(Ref ref) => ref.watch(taskListRepositoryProvider).me();

/// The `GET /tasks` parameters [query] stands for, read at [now] against
/// [context].
TaskParams paramsFor(TaskQuery query, TaskIndex context, DateTime now) {
  final params = parseFilterExpression(query.expression, now: now);
  switch (query.scope) {
    case ProjectScope(:final key):
      params['project'] = [key];
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

/// The tasks one query selects, a page at a time: the cached first page at
/// once, then the server's, again whenever a task changes, and kept for a
/// few minutes after the last screen leaves it.
@riverpod
class TaskListing extends _$TaskListing {
  ListingRequest? _request;

  @override
  Future<Paged<Task>> build(TaskQuery query) async {
    _keepFor(ref, listingCacheFor);
    ref.watch(tasksChangedProvider);
    refreshOn(ref, {...EventTopics.tasks, ...EventTopics.tags});
    final context = await ref.watch(taskContextProvider.future);
    final request = (
      params: paramsFor(query, context, ref.read(clockProvider)()),
      sort: query.scope is MineScope && query.sort.isEmpty
          ? 'due_at'
          : query.sort.isEmpty
          ? null
          : query.sort,
      direction: query.descending ? 'desc' : null,
      limit: query.limit,
    );
    _request = request;
    final repo = ref.read(taskListRepositoryProvider);
    final page = await cachedFirst(
      ref: ref,
      cached: repo.cachedList(request),
      fresh: () => repo.list(request),
      onFresh: (p) => state = AsyncData(_paged(p)),
    );
    return _paged(page);
  }

  static Paged<Task> _paged(Page<Task> p) =>
      Paged(items: p.items, cursor: p.nextCursor);

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() async {
    final request = _request;
    if (request == null) return;
    await loadNextPage(
      current: state.value,
      fetch: (cursor) =>
          ref.read(taskListRepositoryProvider).list(request, cursor: cursor),
      emit: (next) => state = AsyncData(next),
      idOf: (task) => task.id,
    );
  }

  /// A task becoming [updated] on screen at once, sent with [send], and
  /// undone on the server with [reverse].
  OptimisticChange<Paged<Task>> change(
    Task updated, {
    required Future<void> Function() send,
    Future<void> Function()? reverse,
  }) => OptimisticChange(
    read: () => state.value,
    write: (p) => state = AsyncData(p),
    change: (p) => p.copyWith(
      items: [
        for (final t in p.items)
          if (t.id == updated.id) updated else t,
      ],
    ),
    send: send,
    reverse: reverse,
  );

  /// Puts [paged] back, undoing local changes.
  void restore(Paged<Task>? paged) {
    if (paged != null) state = AsyncData(paged);
  }

  /// Replaces the loaded rows that share an id with one of [tasks].
  void apply(Iterable<Task> tasks) {
    final current = state.value;
    if (current == null) return;
    final byId = {for (final t in tasks) t.id: t};
    state = AsyncData(
      current.copyWith(items: [for (final t in current.items) byId[t.id] ?? t]),
    );
  }

  /// Takes the rows with [ids] out of the list.
  void remove(Set<String> ids) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final t in current.items)
            if (!ids.contains(t.id)) t,
        ],
      ),
    );
  }

  TaskListRepository get _repo => ref.read(taskListRepositoryProvider);

  /// Asks the server to move [ref] to [status].
  Future<void> sendMove(String ref, String status) => _repo.move(ref, status);

  /// Asks the server to star or unstar [ref].
  Future<void> sendStar(String ref, {required bool starred}) =>
      starred ? _repo.star(ref) : _repo.unstar(ref);

  /// Asks the server to snooze [ref] until [until], or wake it when null.
  Future<void> sendSnooze(String ref, DateTime? until) async {
    if (until == null) {
      await _repo.unsnooze(ref);
    } else {
      await _repo.snooze(ref, until);
    }
  }

  /// Asks the server to assign [ref] to [actorId], or nobody when empty.
  Future<void> sendAssign(String ref, String actorId) =>
      _repo.assign(ref, actorId);

  /// Applies [request] to the loaded rows at once, sends it, and puts back
  /// any task the server refused. Returns what happened and how to undo it.
  Future<BulkRun> bulk(BulkTaskInput request) async {
    final before = <String, Task>{
      for (final t in state.value?.items ?? const <Task>[])
        if (request.targets.contains(t.ref)) t.ref: t,
    };
    final snapshot = state.value;
    _applyLocal(request, before);
    final BulkResult result;
    try {
      result = await _repo.bulk(request);
    } on Object {
      restore(snapshot);
      rethrow;
    }
    final refused = {for (final o in result.refusals) o.ref};
    if (refused.isNotEmpty) {
      if (request.action == BulkAction.delete) {
        restore(snapshot);
        _applyLocal(
          request.copyWith(
            refs: [
              for (final r in request.targets)
                if (!refused.contains(r)) r,
            ],
          ),
          before,
        );
      } else {
        apply([
          for (final r in refused)
            if (before[r] != null) before[r]!,
        ]);
      }
    }
    if (request.action == BulkAction.copy) ref.invalidateSelf();
    return BulkRun(request: request, before: before, result: result);
  }

  /// Reverses [run]: the rows go back at once, then the server is asked,
  /// one request per previous value. The first failure or refusal stops
  /// the rest and reloads the listing, so the rows show what the server
  /// holds rather than an Undo that half happened; the error is rethrown
  /// for the caller to say why.
  Future<void> undo(BulkRun run) async {
    final requests = undoRequests(run.request, run.before, run.result);
    final reload =
        run.request.action == BulkAction.delete ||
        run.request.action == BulkAction.copy;
    if (!reload) {
      final applied = {
        for (final o in run.result.outcomes)
          if (o.applied) o.ref,
      };
      apply([
        for (final e in run.before.entries)
          if (applied.contains(e.key)) e.value,
      ]);
    }
    try {
      for (final r in requests) {
        final refused = (await _repo.bulk(r)).refusals;
        if (refused.isNotEmpty) throw refusalError(refused.first);
      }
    } on Object {
      ref.invalidateSelf();
      rethrow;
    }
    if (reload) ref.invalidateSelf();
  }

  void _applyLocal(BulkTaskInput request, Map<String, Task> before) {
    if (request.action == BulkAction.delete) {
      remove({
        for (final r in request.targets)
          if (before[r] != null) before[r]!.id,
      });
      return;
    }
    apply([
      for (final r in request.targets)
        if (before[r] case final Task t) localBulkChange(request, t),
    ]);
  }
}
