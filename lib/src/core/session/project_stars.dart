// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/cache/optimistic.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/project.dart';

export 'package:tix_mobile/src/data/models/project.dart';

part 'project_stars.g.dart';

/// The view whose group stars are the project stars.
const _lanes = 'lanes';

/// The projects the reader starred on the active server: the copy last read
/// at once, then the server's, and again whenever a project or a lane star
/// changes. Null when the server keeps no project stars, which hides every
/// star control.
///
/// A project star is the star on the project's lane, so starring a lane on
/// the task screen stars the project, and the other way round.
@riverpod
class ProjectStars extends _$ProjectStars {
  @override
  Future<StarredProjects?> build() async {
    final repo = ref.watch(projectsRepositoryProvider);
    refreshOn(ref, EventTopics.projects);
    refreshOn(
      ref,
      EventTopics.views,
      where: (e) => e.payload['view'] == _lanes,
    );
    final cached = await repo.cachedStarred();
    final read = await cachedFirst<List<Project>?>(
      ref: ref,
      cached: Future.value(cached),
      fresh: repo.starred,
      onFresh: (p) => state = AsyncData(_wrap(p)),
    );
    return _wrap(read);
  }

  static StarredProjects? _wrap(List<Project>? p) =>
      p == null ? null : StarredProjects(p);

  /// [project] starred, or not, on screen at once and then on the server,
  /// queued while the server is out of reach. Undone by the opposite star.
  OptimisticChange<StarredProjects> star(
    Project project, {
    required bool starred,
  }) {
    final repo = ref.read(projectsRepositoryProvider);
    final resets = ref.read(arrangementResetsProvider.notifier);
    Future<void> send({required bool on}) async {
      await (on ? repo.star(project) : repo.unstar(project));
      resets.bump();
    }

    return OptimisticChange(
      read: () => state.value,
      write: (s) => state = AsyncData(s),
      change: (s) => s.toggled(project, starred: starred),
      send: () => send(on: starred),
      reverse: () => send(on: !starred),
    );
  }
}
