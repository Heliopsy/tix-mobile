// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/offline/merge.dart';
import 'package:tix_mobile/src/data/offline/sender.dart';
import 'package:tix_mobile/src/data/offline/sync_store.dart';

/// One call the fake server took.
typedef SentCall = ({
  OutboxOp op,
  String target,
  Map<String, Object?> values,
  String key,
  int? version,
});

/// A tix server in memory that checks versions as tix does: a PATCH or a
/// check against an old version is a 409.
class FakeSender implements OutboxSender {
  /// Starts with [tasks], by reference.
  FakeSender([Iterable<Task> tasks = const []])
    : tasks = {for (final t in tasks) t.ref: t};

  /// The tasks the server holds.
  final Map<String, Task> tasks;

  /// Every call, in the order it arrived.
  final calls = <SentCall>[];

  /// Comments, tags added and dependencies, by task.
  final comments = <String, List<String>>{};

  /// Whether the next request fails as if the network were down.
  bool down = false;

  /// Applies the next create, then loses the answer.
  bool loseNextAnswer = false;

  /// Whether the server honours `Idempotency-Key`.
  bool honoursKeys = false;

  /// Errors to throw for the next call to a task, by reference.
  final refuse = <String, TixException>{};

  /// States a move may not go to, with the server's reason.
  final forbiddenMoves = <String, String>{};

  final _keys = <String, Task?>{};
  var _next = 100;

  /// How many times the client asked whether keys are honoured.
  int probes = 0;

  /// Forgets every `Idempotency-Key` seen, as tix does a day later.
  void forgetKeys() => _keys.clear();

  /// Holds every send until completed, when set.
  Completer<void>? hold;

  @override
  Future<bool> detectIdempotency() async {
    if (down) throw const TixException(TixErrorKind.network);
    probes++;
    return honoursKeys;
  }

  @override
  Future<Task> fetch(String ref) async {
    if (down) throw const TixException(TixErrorKind.network);
    final t = tasks[ref];
    if (t == null) throw const TixException(TixErrorKind.notFound);
    return t;
  }

  @override
  Future<List<Task>> findCreated(
    Map<String, Object?> values,
    DateTime since,
  ) async => [
    for (final t in tasks.values)
      if ('${values['title']}'.startsWith(t.title) &&
          t.projectId == values['project_ref'])
        t,
  ];

  @override
  Future<Task?> send(
    OutboxOp op,
    String target,
    Map<String, Object?> values, {
    required String key,
    int? version,
  }) async {
    if (down) throw const TixException(TixErrorKind.network);
    final held = hold;
    if (held != null) await held.future;
    calls.add((
      op: op,
      target: target,
      values: values,
      key: key,
      version: version,
    ));
    if (honoursKeys && _keys.containsKey(key)) return _keys[key];
    final refused = refuse.remove(target);
    if (refused != null) throw refused;
    final answer = _apply(op, target, values, version);
    if (honoursKeys) _keys[key] = answer;
    if (op == OutboxOp.create && loseNextAnswer) {
      loseNextAnswer = false;
      throw const TixException(TixErrorKind.timeout);
    }
    return answer;
  }

  Task? _apply(
    OutboxOp op,
    String target,
    Map<String, Object?> values,
    int? version,
  ) {
    if (op == OutboxOp.create) {
      final project = '${values['project_ref']}';
      final t = Task(
        id: 'id-${_next++}',
        ref: '$project-${_next++}',
        title: '${values['title']}'.split(' !').first,
        projectId: project,
        parentId: '${values['parent_ref'] ?? ''}',
        version: 1,
        createdAt: DateTime.utc(2026, 11, 8),
      );
      tasks[t.ref] = t;
      return t;
    }
    if (op == OutboxOp.restore && trash.containsKey(target)) {
      return tasks[target] = trash.remove(target)!;
    }
    final t = tasks[target];
    if (t == null) throw const TixException(TixErrorKind.notFound);
    if (version != null && version != t.version) {
      throw const TixException(TixErrorKind.conflict, status: 409);
    }
    Task bump(Task n) => tasks[target] = n.copyWith(version: t.version + 1);
    switch (op) {
      case OutboxOp.update:
        final json = t.toJson();
        for (final MapEntry(:key, :value) in values.entries) {
          if (key == 'custom_fields' && value is Map) {
            json[key] = {
              ...?(json[key] as Map<String, Object?>?),
              ...value.cast<String, Object?>(),
            };
          } else {
            json[key] = value;
          }
        }
        return bump(Task.fromJson(json));
      case OutboxOp.check:
        return bump(t.copyWith(body: '${t.body} [x${values['item']}]'));
      case OutboxOp.move:
        final to = '${values['to']}';
        final reason = forbiddenMoves[to];
        if (reason != null) {
          throw TixException(
            TixErrorKind.preconditionFailed,
            message: reason,
            status: 422,
          );
        }
        return bump(t.copyWith(status: to));
      case OutboxOp.comment:
        (comments[target] ??= []).add('${values['body']}');
        return null;
      case OutboxOp.tagAdd:
        tasks[target] = t.copyWith(
          tags: mergeTags(
            base: t.tags,
            mine: [...t.tags, '${values['name']}'],
            theirs: t.tags,
          ),
        );
        return null;
      case OutboxOp.star:
        tasks[target] = t.copyWith(starred: true);
        return null;
      case OutboxOp.dependencyAdd:
        (comments['$target/deps'] ??= []).add('${values['depends_on']}');
        return null;
      case OutboxOp.restore:
        return t;
      case _:
        return null;
    }
  }

  /// Tasks in the trash, by reference.
  final trash = <String, Task>{};

  /// Deletes [ref] on the server, to the trash.
  void delete(String ref) => trash[ref] = tasks.remove(ref)!;

  /// Changes [ref] on the server as someone else would, bumping its
  /// version.
  void edit(String ref, Task Function(Task) change) {
    final t = tasks[ref]!;
    tasks[ref] = change(t).copyWith(version: t.version + 1);
  }
}
