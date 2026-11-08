// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/task.dart';

part 'tasks.g.dart';

/// The tasks of one project, most urgent first, a page at a time.
@riverpod
class ProjectTasks extends _$ProjectTasks {
  @override
  Future<Paged<Task>> build(String projectKey) async {
    final page = await ref.watch(tasksRepositoryProvider).tasks(projectKey);
    return Paged(items: page.items, cursor: page.nextCursor);
  }

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

/// One task, by reference.
@riverpod
Future<Task> taskDetail(Ref ref, String taskRef) =>
    ref.watch(tasksRepositoryProvider).task(taskRef);

/// One actor, by id.
@riverpod
Future<Actor> actor(Ref ref, String id) =>
    ref.watch(tasksRepositoryProvider).actor(id);
