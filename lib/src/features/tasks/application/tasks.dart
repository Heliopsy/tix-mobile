// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/task.dart';

part 'tasks.g.dart';

/// The tasks of one project, most urgent first, a page at a time: the
/// cached first page at once, then the server's, and again whenever a task
/// changes.
@riverpod
class ProjectTasks extends _$ProjectTasks {
  @override
  Future<Paged<Task>> build(String projectKey) async {
    final repo = ref.watch(tasksRepositoryProvider);
    refreshOn(ref, EventTopics.tasks);
    final page = await cachedFirst(
      ref: ref,
      cached: repo.cachedTasks(projectKey),
      fresh: () => repo.tasks(projectKey),
      onFresh: (p) => state = AsyncData(_paged(p)),
    );
    return _paged(page);
  }

  static Paged<Task> _paged(Page<Task> p) =>
      Paged(items: p.items, cursor: p.nextCursor);

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(tasksRepositoryProvider).tasks(projectKey, cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (task) => task.id,
  );

  /// Creates a task in this project from a quick-add [line] and reloads the
  /// list so it appears where the server sorts it.
  Future<Task> quickAdd(String line) async {
    final task = await ref
        .read(tasksRepositoryProvider)
        .quickAdd(projectKey, line);
    ref.invalidateSelf();
    return task;
  }
}

/// One task, by reference: the cached copy at once, then the server's, and
/// again whenever it or anything on it changes.
@riverpod
class TaskDetail extends _$TaskDetail {
  @override
  Future<Task> build(String taskRef) async {
    final repo = ref.watch(tasksRepositoryProvider);
    final task = await cachedFirst(
      ref: ref,
      cached: repo.cachedTask(taskRef),
      fresh: () => repo.task(taskRef),
      onFresh: (t) => state = AsyncData(t),
    );
    if (ref.mounted) {
      refreshOn(
        ref,
        EventTopics.taskDetail,
        where: (e) => e.subjectId == task.id || e.subjectId == task.ref,
      );
    }
    return task;
  }
}

/// One actor, by id.
@riverpod
Future<Actor> actor(Ref ref, String id) =>
    ref.watch(tasksRepositoryProvider).actor(id);
