// SPDX-License-Identifier: AGPL-3.0-or-later

/// A tix project, the container tasks live in, and the reader's stars on
/// projects.
library;

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Project;

export 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Project;

/// [projects] with those [starred] says are starred first, each part in the
/// order it came in.
List<Project> starredFirst(
  Iterable<Project> projects,
  bool Function(Project project) starred,
) => [...projects.where(starred), ...projects.where((p) => !starred(p))];

/// The projects one reader starred on one server, in the order their lanes
/// are drawn. A star is the reader's own; nobody else sees it.
@immutable
class StarredProjects {
  /// Holds [projects].
  const StarredProjects([this.projects = const []]);

  /// The starred projects.
  final List<Project> projects;

  /// The keys of the starred projects.
  Set<String> get keys => {for (final p in projects) p.key};

  /// Whether the project [key] is starred.
  bool has(String key) => projects.any((p) => p.key == key);

  /// [project] starred when [starred], or not: a new star goes last.
  StarredProjects toggled(Project project, {required bool starred}) {
    final rest = [
      for (final p in projects)
        if (p.key != project.key) p,
    ];
    if (!starred) return StarredProjects(rest);
    final at = projects.indexWhere((p) => p.key == project.key);
    final marked = project.copyWith(starred: true);
    return StarredProjects(
      at < 0 ? [...rest, marked] : ([...rest]..insert(at, marked)),
    );
  }

  /// [all] with the starred ones first.
  List<Project> first(Iterable<Project> all) =>
      starredFirst(all, (p) => has(p.key));

  @override
  bool operator ==(Object other) {
    if (other is! StarredProjects || other.projects.length != projects.length) {
      return false;
    }
    for (var i = 0; i < projects.length; i++) {
      if (other.projects[i] != projects[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(projects);
}
