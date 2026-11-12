// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/cache/optimistic.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/task_patch.dart';
import 'package:tix_mobile/src/data/query/task_index.dart';
import 'package:tix_mobile/src/data/query/task_query.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/features/tasks/application/bulk.dart';

export 'package:tix_mobile/src/data/query/task_index.dart';
export 'package:tix_mobile/src/data/query/task_query.dart';
export 'package:tix_mobile/src/features/tasks/application/bulk.dart';

part 'listing.g.dart';

/// How long a listing nobody is looking at stays cached, so going back to it
/// draws at once.
const listingCacheFor = Duration(minutes: 5);

/// How many of [tasks] an agent holds at [now]: claimed, with a lease that
/// has not run out. tix's web summary counts its page the same way, so a
/// claim with no lease is not counted.
int heldByAgent(Iterable<Task> tasks, DateTime now) => tasks
    .where(
      (t) =>
          t.claimedByActorId.isNotEmpty &&
          (t.leaseExpiresAt?.isAfter(now) ?? false),
    )
    .length;

void _keepFor(Ref ref, Duration duration) {
  final link = ref.keepAlive();
  Timer? timer;
  ref
    ..onCancel(() => timer = Timer(duration, link.close))
    ..onResume(() => timer?.cancel())
    ..onDispose(() => timer?.cancel());
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

/// The most overdue tasks My work's badge counts; past it the badge reads
/// "99+", as the web's does.
const overdueBadgeCap = 99;

/// How many of the reader's open assigned tasks are past their deadline, up
/// to one more than [overdueBadgeCap]: what My work's badge shows. Asked
/// again whenever a task changes.
@riverpod
Future<int> myOverdue(Ref ref) async {
  ref.watch(tasksChangedProvider);
  refreshOn(ref, EventTopics.tasks);
  final context = await ref.watch(taskContextProvider.future);
  const query = TaskQuery(
    scope: MineScope(),
    expression: 'due:overdue',
    openOnly: true,
    limit: overdueBadgeCap + 1,
  );
  final request = TaskListRepository.requestFor(
    query,
    context,
    ref.read(clockProvider)(),
  );
  final page = await ref.read(taskListRepositoryProvider).list(request);
  return page.items.length;
}

/// The signed-in reader.
@riverpod
Future<Actor> me(Ref ref) => ref.watch(taskListRepositoryProvider).me();

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
    final request = TaskListRepository.requestFor(
      query,
      context,
      ref.read(clockProvider)(),
    );
    _request = request;
    final repo = ref.read(taskListRepositoryProvider);
    final project = switch (query.scope) {
      ProjectScope(:final key) => key,
      _ => null,
    };
    Paged<Task> shown(Page<Task> p) =>
        _paged(repo.withQueued(p, project: project));
    final held = query.includeHeld
        ? TaskListRepository.requestFor(
            query,
            context,
            ref.read(clockProvider)(),
            held: true,
          )
        : null;
    Future<Page<Task>> fresh() async {
      if (held == null) return await repo.list(request);
      final heldPage = repo.list(held);
      return TaskListRepository.withHeld(
        await repo.list(request),
        await heldPage,
      );
    }

    Future<Page<Task>?> cached() async {
      final assigned = await repo.cachedList(request);
      if (held == null || assigned == null) return assigned;
      final heldPage = await repo.cachedList(held);
      return heldPage == null
          ? null
          : TaskListRepository.withHeld(assigned, heldPage);
    }

    final page = await cachedFirst(
      ref: ref,
      cached: cached(),
      fresh: fresh,
      onFresh: (p) => state = AsyncData(shown(p)),
    );
    return shown(page);
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

  /// Asks the server to apply [patch] to [task], as the row showed it.
  Future<void> sendPatch(Task task, TaskPatch patch) async {
    await ref
        .read(taskDetailRepositoryProvider)
        .update(task.ref, patch, base: task);
  }

  /// Asks the server to put the tag [name] on [taskRef], or take it off.
  Future<void> sendTag(String taskRef, String name, {required bool add}) {
    final repo = ref.read(taskDetailRepositoryProvider);
    return add ? repo.addTag(taskRef, name) : repo.removeTag(taskRef, name);
  }

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
    if (request.action == BulkAction.moveProject) {
      ref.read(tasksChangedProvider.notifier).touch();
    }
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
