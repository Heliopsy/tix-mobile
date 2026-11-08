// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';

part 'projects.g.dart';

/// The projects on the active server, a page at a time: the cached first
/// page at once, then the server's, and again whenever a project changes.
@riverpod
class Projects extends _$Projects {
  @override
  Future<Paged<Project>> build() async {
    final repo = ref.watch(tasksRepositoryProvider);
    refreshOn(ref, EventTopics.projects);
    final page = await cachedFirst(
      ref: ref,
      cached: repo.cachedProjects(),
      fresh: repo.projects,
      onFresh: (p) => state = AsyncData(_paged(p)),
    );
    return _paged(page);
  }

  static Paged<Project> _paged(Page<Project> p) =>
      Paged(items: p.items, cursor: p.nextCursor);

  /// Creates a project from [input] and reads the list again. A refusal
  /// is thrown to the form.
  Future<Project> create(CreateProjectInput input) async {
    final created = await ref.read(projectsRepositoryProvider).create(input);
    if (ref.mounted) ref.invalidateSelf();
    return created;
  }

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(tasksRepositoryProvider).projects(cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (project) => project.id,
  );
}

/// How many of project [key]'s tasks are still open.
@riverpod
Future<int> projectOpenCount(Ref ref, String key) =>
    ref.watch(tasksRepositoryProvider).projectOpenCount(key);
