// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/repositories/stats_repository.dart';

export 'package:tix_mobile/src/data/repositories/stats_repository.dart';

part 'stats.g.dart';

/// The windows the screen offers, in days, as the web's Statistics screen.
const statsWindows = [7, 14, 30, 90];

/// The window the screen opens on.
const defaultStatsWindow = 14;

/// The most projects the picker walks, as the web bounds its own.
const statsProjectLimit = 500;

/// What the Statistics screen shows: a window ending now and a project, or
/// every project when [project] is empty.
@immutable
class StatsQuery {
  /// The figures for [days] over [project].
  const StatsQuery({this.days = defaultStatsWindow, this.project = ''});

  /// How many days the window reaches back.
  final int days;

  /// The project's key, empty for every project.
  final String project;

  @override
  bool operator ==(Object other) =>
      other is StatsQuery && other.days == days && other.project == project;

  @override
  int get hashCode => Object.hash(days, project);
}

/// The tenant's statistics, for the active session.
@riverpod
StatsRepository statsRepository(Ref ref) =>
    StatsRepository(ref.watch(sessionApiProvider));

/// The window and project the Statistics screen shows.
@riverpod
class StatsFilter extends _$StatsFilter {
  @override
  StatsQuery build() => const StatsQuery();

  /// Shows the [days] ending now.
  void window(int days) =>
      state = StatsQuery(days: days, project: state.project);

  /// Shows [project], or every project when it is empty.
  void project(String project) =>
      state = StatsQuery(days: state.days, project: project);
}

/// The figures for [query].
@riverpod
Future<Stats> statsReport(Ref ref, StatsQuery query) {
  refreshOn(ref, EventTopics.tasks);
  return ref
      .watch(statsRepositoryProvider)
      .read(days: query.days, project: query.project);
}

/// The projects the picker offers, and whether that is every one of them.
typedef StatsProjects = ({List<Project> projects, bool whole});

/// The tenant's projects for the picker, walked a page at a time up to
/// [statsProjectLimit].
@riverpod
Future<StatsProjects> statsProjects(Ref ref) async {
  refreshOn(ref, EventTopics.projects);
  final repo = ref.watch(projectsRepositoryProvider);
  final out = <Project>[];
  String? cursor;
  do {
    final page = await repo.all(cursor: cursor);
    out.addAll(page.items.where((p) => p.archivedAt == null));
    cursor = page.nextCursor;
  } while (cursor != null &&
      cursor.isNotEmpty &&
      out.length < statsProjectLimit);
  return (projects: out, whole: cursor == null || cursor.isEmpty);
}
