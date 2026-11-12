// SPDX-License-Identifier: AGPL-3.0-or-later

/// The subtask tree under one task, as `task.tree` answers it.
library;

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

/// One subtask in a drawn [SubtaskTree].
class SubtaskNode {
  /// [task] at [level], 1 for a direct subtask.
  const SubtaskNode({
    required this.task,
    required this.level,
    this.children = const [],
    this.more = 0,
  });

  /// The subtask.
  final Task task;

  /// How deep it sits under the tree's task, 1 for a direct subtask.
  final int level;

  /// Its subtasks that were drawn.
  final List<SubtaskNode> children;

  /// How many subtasks it has that were read but not drawn.
  final int more;
}

/// A task's live descendants, drawn [drawDepth] levels deep.
///
/// [tasks] is `task.tree`'s depth-first list without the task itself. A task
/// whose parent is not in the list is a direct subtask, which is also where
/// a subtask added since, or an offline draft, lands.
class SubtaskTree {
  /// The tree of [tasks]; [shallow] when only direct subtasks were read.
  SubtaskTree({this.tasks = const [], this.shallow = false});

  /// How many levels are drawn at once, as the web draws them.
  static const drawDepth = 3;

  /// How deep to read: one level more than drawn, to know which nodes on
  /// the last drawn level have subtasks of their own.
  static const int readDepth = drawDepth + 1;

  /// The descendants in depth-first order.
  final List<Task> tasks;

  /// Whether the server refused the whole tree as too large, so only the
  /// direct subtasks were read.
  final bool shallow;

  /// The direct subtasks, each with the levels drawn under it.
  late final List<SubtaskNode> nodes = _grow();

  /// Whether there is no subtask at all.
  bool get isEmpty => tasks.isEmpty;

  /// Whether every descendant was read, so [tasks] counts them all.
  bool get complete => !shallow && !_any(nodes, (n) => n.more > 0);

  /// Whether any subtask has subtasks of its own.
  bool get nested => _any(nodes, (n) => n.children.isNotEmpty || n.more > 0);

  /// This tree with [added] as direct subtasks after the rest.
  SubtaskTree plus(List<Task> added) => added.isEmpty
      ? this
      : SubtaskTree(tasks: [...tasks, ...added], shallow: shallow);

  List<SubtaskNode> _grow() {
    final ids = {for (final t in tasks) t.id};
    final kids = <String, List<Task>>{};
    final top = <Task>[];
    for (final t in tasks) {
      if (ids.contains(t.parentId) && t.parentId != t.id) {
        (kids[t.parentId] ??= []).add(t);
      } else {
        top.add(t);
      }
    }
    List<SubtaskNode> grow(List<Task> level, int depth) => [
      for (final t in level)
        if (depth < drawDepth)
          SubtaskNode(
            task: t,
            level: depth,
            children: grow(kids[t.id] ?? const [], depth + 1),
          )
        else
          SubtaskNode(task: t, level: depth, more: kids[t.id]?.length ?? 0),
    ];
    return grow(top, 1);
  }

  static bool _any(List<SubtaskNode> nodes, bool Function(SubtaskNode) test) =>
      nodes.any((n) => test(n) || _any(n.children, test));
}
