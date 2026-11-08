// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/features/connect/application/session.dart';

part 'projects.g.dart';

/// The projects on the active server, a page at a time.
@riverpod
class Projects extends _$Projects {
  @override
  Future<Paged<Project>> build() async {
    final page = await ref.watch(tasksRepositoryProvider).projects();
    return Paged(items: page.items, cursor: page.nextCursor);
  }

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(tasksRepositoryProvider).projects(cursor: cursor),
    emit: (next) => state = AsyncData(next),
  );
}
