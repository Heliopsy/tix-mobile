// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/data/query/filter_suggest.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

export 'package:tix_mobile/src/data/query/filter_suggest.dart';

part 'filter_suggest.g.dart';

/// What the filter field over [scope] suggests from: the projects, tags,
/// people and workflow states loaded so far. A list still loading or failed
/// is left out rather than holding the others back.
@riverpod
FilterSuggestData filterSuggestData(Ref ref, TaskScope scope) {
  final index = ref.watch(taskContextProvider).value;
  final tags = ref.watch(tagDirectoryProvider).value ?? const <Tag>[];
  final actors = ref.watch(actorDirectoryProvider).value ?? const <Actor>[];
  final workflows = switch (scope) {
    ProjectScope(:final key) => [?index?.workflowOfProject(index.project(key))],
    _ => index?.workflows ?? const <Workflow>[],
  };
  return FilterSuggestData(
    scoped: scope is ProjectScope,
    projects: [
      for (final p in index?.projects ?? const <Project>[])
        if (p.archivedAt == null) (key: p.key, name: p.name),
    ],
    tags: [for (final t in tags) t.name],
    people: [
      for (final a in actors)
        if (a.handle.isNotEmpty) a.handle,
    ],
    statuses: {
      for (final w in workflows)
        for (final s in w.states)
          if (s.key case final String k when k.isNotEmpty) k,
    }.toList(),
  );
}
