// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/models/task.dart';

/// One bulk action that ran: what was asked, the tasks as they were, and
/// what the server did.
@immutable
class BulkRun {
  /// Records [request] over [before] answered by [result].
  const BulkRun({
    required this.request,
    required this.before,
    required this.result,
  });

  /// The request.
  final BulkTaskInput request;

  /// The tasks it named as they were before, by reference.
  final Map<String, Task> before;

  /// The server's answer.
  final BulkResult result;
}

/// [task] as [request] leaves it, for drawing before the server answers.
Task localBulkChange(BulkTaskInput request, Task task) =>
    switch (request.action) {
      BulkAction.move => task.copyWith(status: request.to ?? task.status),
      BulkAction.priority => task.copyWith(
        priority: request.priority ?? task.priority,
      ),
      BulkAction.tagAdd =>
        task.tags.contains(request.tag)
            ? task
            : task.copyWith(tags: [...task.tags, ?request.tag]),
      BulkAction.tagRemove => task.copyWith(
        tags: [
          for (final t in task.tags)
            if (t != request.tag) t,
        ],
      ),
      BulkAction.assign => task.copyWith(
        assigneeActorId: request.assigneeActorId ?? '',
      ),
      BulkAction.star => task.copyWith(starred: true),
      BulkAction.unstar => task.copyWith(starred: false),
      BulkAction.copy ||
      BulkAction.delete ||
      BulkAction.restore ||
      null => task,
    };

/// The requests that put back what [request] changed: only the tasks it was
/// applied to, each to the value it had in [before].
List<BulkTaskInput> undoRequests(
  BulkTaskInput request,
  Map<String, Task> before,
  BulkResult result,
) {
  final applied = [
    for (final o in result.outcomes)
      if (o.applied) o,
  ];
  final refs = [for (final o in applied) o.ref];
  List<BulkTaskInput> grouped<K>(
    K Function(Task) key,
    BulkTaskInput Function(K, List<String>) build,
  ) {
    final groups = <K, List<String>>{};
    for (final r in refs) {
      final t = before[r];
      if (t != null) (groups[key(t)] ??= []).add(r);
    }
    return [for (final e in groups.entries) build(e.key, e.value)];
  }

  List<BulkTaskInput> one(
    BulkAction action,
    List<String> refs, {
    String? tag,
  }) => refs.isEmpty
      ? const []
      : [BulkTaskInput(action: action, refs: refs, tag: tag)];

  return switch (request.action) {
    BulkAction.move => grouped(
      (t) => t.status,
      (s, r) => BulkTaskInput(action: BulkAction.move, refs: r, to: s),
    ),
    BulkAction.priority => grouped(
      (t) => t.priority,
      (p, r) =>
          BulkTaskInput(action: BulkAction.priority, refs: r, priority: p),
    ),
    BulkAction.assign => grouped(
      (t) => t.assigneeActorId,
      (a, r) =>
          BulkTaskInput(action: BulkAction.assign, refs: r, assigneeActorId: a),
    ),
    BulkAction.tagAdd => one(BulkAction.tagRemove, [
      for (final r in refs)
        if (!(before[r]?.tags.contains(request.tag) ?? true)) r,
    ], tag: request.tag),
    BulkAction.tagRemove => one(BulkAction.tagAdd, [
      for (final r in refs)
        if (before[r]?.tags.contains(request.tag) ?? false) r,
    ], tag: request.tag),
    BulkAction.star => one(BulkAction.unstar, [
      for (final r in refs)
        if (!(before[r]?.starred ?? true)) r,
    ]),
    BulkAction.unstar => one(BulkAction.star, [
      for (final r in refs)
        if (before[r]?.starred ?? false) r,
    ]),
    BulkAction.copy => one(BulkAction.delete, [
      for (final o in applied)
        if (o.copyRef.isNotEmpty) o.copyRef,
    ]),
    BulkAction.delete => one(BulkAction.restore, refs),
    BulkAction.restore => one(BulkAction.delete, refs),
    null => const [],
  };
}
