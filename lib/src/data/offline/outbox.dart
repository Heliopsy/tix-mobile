// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/offline/merge.dart';
import 'package:tix_mobile/src/data/offline/replayer.dart';
import 'package:tix_mobile/src/data/offline/sender.dart';
import 'package:tix_mobile/src/data/offline/sync_store.dart';

export 'package:tix_mobile/src/data/offline/replayer.dart';
export 'package:tix_mobile/src/data/offline/sync_store.dart';

/// A comment waiting in the outbox: its entry's id, its text and when it
/// was written.
typedef QueuedComment = ({String id, String body, DateTime at});

/// Writes made while the server cannot be reached, for one context: how a
/// repository queues them, how the app draws them before they are sent, and
/// what the person decides about the ones that conflict.
class Outbox {
  /// Queues into [store]; `offline` says whether to skip the network.
  Outbox(
    this.store, {
    required this._offline,
    this._clock = DateTime.now,
    this._uuid = newUuid,
  });

  /// Where the outbox is kept.
  final SyncStore store;
  final bool Function() _offline;
  final DateTime Function() _clock;
  final String Function() _uuid;

  SyncSnapshot get _now => store.now;

  /// [ref], or the real reference a sent draft became.
  String realRef(String ref) => _now.drafts[ref] ?? ref;

  /// The writes waiting for [ref], oldest first.
  List<OutboxEntry> pendingFor(String ref) {
    final target = realRef(ref);
    return [
      for (final e in _now.entries)
        if (realRef(e.target) == target) e,
    ]..sort((a, b) => a.seq.compareTo(b.seq));
  }

  /// Whether a write to [target] has to wait in the outbox: the server is
  /// out of reach, the task is a draft, or earlier writes to it still wait
  /// and a later one must not overtake them.
  bool queues(String target) =>
      _offline() ||
      isDraftRef(realRef(target)) ||
      pendingFor(target).isNotEmpty;

  /// Sends [op] with [online] unless it has to wait; queues it when it has
  /// to or when the server turns out to be unreachable, and then answers
  /// with [local]. [online] gets the write's idempotency key.
  Future<T> write<T>({
    required OutboxOp op,
    required String target,
    required Future<T> Function(String key) online,
    required T Function(OutboxEntry entry) local,
    Task? base,
    Map<String, Object?> values = const {},
  }) async {
    await store.load();
    final key = _uuid();
    DateTime? tried;
    if (!queues(target)) {
      final at = _clock();
      try {
        return await online(key);
      } on TixException catch (e) {
        if (!isUnreachable(e)) rethrow;
        if (mayHaveArrived(e)) tried = at;
      }
    }
    final entry = await enqueue(
      op,
      target,
      base: base,
      values: values,
      key: key,
      firstSentAt: tried,
    );
    return local(entry);
  }

  /// Creates a task from [request] (tix's create body, `project_ref` set)
  /// with [online], or queues it and answers with a draft task. A create
  /// whose answer was lost on a server not known to honour
  /// `Idempotency-Key` is queued to be checked before it is sent again.
  Future<Task> create(
    Map<String, Object?> request, {
    required Future<Task> Function(String key) online,
  }) async {
    await store.load();
    final key = _uuid();
    final parent = request['parent_ref']?.toString() ?? '';
    var lost = false;
    DateTime? tried;
    if (!_offline() && !isDraftRef(parent)) {
      final at = _clock();
      try {
        return await online(key);
      } on TixException catch (e) {
        if (!isUnreachable(e)) rethrow;
        if (mayHaveArrived(e)) {
          tried = at;
          lost = _now.idempotency != true;
        }
      }
    }
    final project = request['project_ref']?.toString() ?? '';
    late OutboxEntry entry;
    await store.update((s) {
      final draft = makeDraftRef(project, s.nextDraft);
      entry = OutboxEntry(
        id: _uuid(),
        seq: s.nextSeq,
        op: OutboxOp.create,
        target: draft,
        draftRef: draft,
        values: request,
        idempotencyKey: key,
        createdAt: _clock(),
        firstSentAt: tried,
        state: lost ? OutboxState.needsCheck : OutboxState.pending,
      );
      return s.copyWith(
        entries: [...s.entries, entry],
        nextDraft: s.nextDraft + 1,
        nextSeq: s.nextSeq + 1,
      );
    });
    return draftTask(entry);
  }

  /// Adds a write to the outbox; [firstSentAt] when an attempt to send it
  /// may already have reached the server.
  Future<OutboxEntry> enqueue(
    OutboxOp op,
    String target, {
    Task? base,
    Map<String, Object?> values = const {},
    String? key,
    DateTime? firstSentAt,
  }) async {
    late OutboxEntry entry;
    await store.update((s) {
      entry = OutboxEntry(
        id: _uuid(),
        seq: s.nextSeq,
        op: op,
        target: target,
        baseVersion: base?.version,
        base: base?.toJson() ?? const {},
        values: values,
        idempotencyKey: key ?? _uuid(),
        createdAt: _clock(),
        firstSentAt: firstSentAt,
      );
      return s.copyWith(entries: [...s.entries, entry], nextSeq: s.nextSeq + 1);
    });
    return entry;
  }

  /// The task a queued create stands for until it is sent: its line as the
  /// title, since only the server parses quick-add syntax.
  static Task draftTask(OutboxEntry e) => Task(
    id: e.draftRef,
    ref: e.draftRef,
    title: e.values['title']?.toString() ?? '',
    parentId: e.values['parent_ref']?.toString() ?? '',
    createdAt: e.createdAt,
  );

  /// The draft [ref], null when there is none waiting.
  Task? draft(String ref) {
    for (final e in _now.entries) {
      if (e.op == OutboxOp.create && e.draftRef == ref) {
        return overlay(draftTask(e));
      }
    }
    return null;
  }

  /// The drafts waiting in project [key], or under the task [parent].
  List<Task> drafts({String? key, String? parent}) => [
    for (final e in _now.entries)
      if (e.op == OutboxOp.create &&
          (key == null || e.values['project_ref'] == key) &&
          (parent == null || realRef('${e.values['parent_ref']}') == parent))
        overlay(draftTask(e)),
  ];

  /// [task] with every write still waiting for it drawn on top.
  Task overlay(Task task) {
    var t = task;
    for (final e in pendingFor(task.ref)) {
      t = switch (e.op) {
        OutboxOp.update => _patch(t, e.values),
        OutboxOp.move => t.copyWith(status: '${e.values['to']}'),
        OutboxOp.star => t.copyWith(starred: true),
        OutboxOp.unstar => t.copyWith(starred: false),
        OutboxOp.snooze => t.copyWith(
          snoozedUntil: DateTime.tryParse('${e.values['until']}'),
        ),
        OutboxOp.tagAdd => t.copyWith(
          tags: [
            ...t.tags.where((x) => x != e.values['name']),
            '${e.values['name']}',
          ],
        ),
        OutboxOp.tagRemove => t.copyWith(
          tags: [...t.tags.where((x) => x != e.values['name'])],
        ),
        _ => t,
      };
    }
    return t;
  }

  static Task _patch(Task t, Map<String, Object?> body) {
    final json = t.toJson();
    for (final MapEntry(:key, :value) in body.entries) {
      if (key == 'custom_fields' && value is Map) {
        json['custom_fields'] = {
          ...?(json['custom_fields'] as Map<String, Object?>?),
          for (final f in value.entries) '${f.key}': f.value,
        }..removeWhere((_, v) => v == null);
      } else if (key != 'parent_ref') {
        json[key] = value;
      }
    }
    return Task.fromJson(json);
  }

  /// The stars and unstars of projects still waiting to be sent, oldest
  /// first; each one's target is the project's key.
  List<OutboxEntry> projectStarWrites() => [
    for (final e in _now.entries)
      if (e.op.onProject && e.state == OutboxState.pending) e,
  ]..sort((a, b) => a.seq.compareTo(b.seq));

  /// The comments queued for [ref].
  List<QueuedComment> comments(String ref) => [
    for (final e in pendingFor(ref))
      if (e.op == OutboxOp.comment)
        (id: e.id, body: '${e.values['body']}', at: e.createdAt),
  ];

  /// Settles the open conflict [recordId] as the person chose. [edited]
  /// gives the values to send for [Resolution.edited]; a refused move takes
  /// its new status as `{'to': ...}`.
  Future<void> resolve(
    String recordId,
    Resolution resolution, {
    Map<String, Object?> edited = const {},
  }) async {
    await store.update((s) {
      final record = s.conflicts.where((r) => r.id == recordId).firstOrNull;
      if (record == null || record.resolution != null) return s;
      final entry = s.entries.where((e) => e.id == record.entryId).firstOrNull;
      final entries = [...s.entries];
      var seq = s.nextSeq;
      if (entry != null) {
        final at = entries.indexOf(entry);
        switch ((record.kind, resolution)) {
          case (ConflictKind.deleted, Resolution.restored):
            entries
              ..[at] = entry.copyWith(state: OutboxState.pending)
              ..add(
                OutboxEntry(
                  id: _uuid(),
                  seq: entry.seq,
                  op: OutboxOp.restore,
                  target: entry.target,
                  idempotencyKey: _uuid(),
                  createdAt: _clock(),
                ),
              );
          case (ConflictKind.deleted, _):
            entries.removeWhere((e) => realRef(e.target) == record.taskRef);
          case (_, Resolution.theirs || Resolution.discarded):
            final rest = flatten(entry.values)
              ..removeWhere((k, _) => record.fields.any((f) => f.field == k));
            if (rest.isEmpty || entry.op != OutboxOp.update) {
              entries.removeAt(at);
            } else {
              entries[at] = entry.copyWith(
                state: OutboxState.pending,
                values: unflatten(rest),
              );
            }
          case (_, Resolution.edited):
            entries[at] = entry.copyWith(
              state: OutboxState.pending,
              values: entry.op == OutboxOp.update
                  ? unflatten({...flatten(entry.values), ...flatten(edited)})
                  : {...entry.values, ...edited},
              idempotencyKey: _uuid(),
            );
          case _:
            entries[at] = entry.copyWith(state: OutboxState.pending);
        }
        seq = s.nextSeq + 1;
      }
      return s.copyWith(
        entries: entries,
        nextSeq: seq,
        conflicts: [
          for (final r in s.conflicts)
            if (r.id == recordId)
              r.copyWith(
                resolution: resolution,
                auto: false,
                resolvedAt: _clock(),
              )
            else
              r,
        ],
      );
    });
  }

  /// Settles every open conflict over attributes the same way.
  Future<void> resolveAll(Resolution resolution) async {
    for (final r in _now.conflicts) {
      if (r.resolution == null && r.kind == ConflictKind.fields) {
        await resolve(r.id, resolution);
      }
    }
  }

  /// Puts back the side a settled conflict did not keep: queues the other
  /// values for the attributes it named, sent over whatever the server has
  /// then, since the person asked for exactly that.
  Future<void> reverse(String recordId) async {
    final record = _now.conflicts.where((r) => r.id == recordId).firstOrNull;
    if (record == null || !reversible(record)) return;
    final toTheirs = record.resolution != Resolution.theirs;
    if (record.kind == ConflictKind.invalidMove) {
      await enqueue(
        OutboxOp.move,
        record.taskRef,
        values: {'to': record.wanted},
      );
    } else if (record.fields.any((f) => f.field == 'status')) {
      final f = record.fields.firstWhere((f) => f.field == 'status');
      await enqueue(
        OutboxOp.move,
        record.taskRef,
        values: {'to': toTheirs ? f.theirs : f.mine},
      );
    } else {
      await enqueue(
        OutboxOp.update,
        record.taskRef,
        values: unflatten({
          for (final f in record.fields) f.field: toTheirs ? f.theirs : f.mine,
        }),
      );
    }
    await store.update(
      (s) => s.copyWith(
        conflicts: [
          for (final r in s.conflicts)
            if (r.id == recordId)
              r.copyWith(
                resolution: toTheirs ? Resolution.theirs : Resolution.mine,
                auto: false,
                resolvedAt: _clock(),
              )
            else
              r,
        ],
      ),
    );
  }

  /// Whether [record] can be reversed: a settled conflict over attributes,
  /// or a refused move that was dropped.
  static bool reversible(ConflictRecord record) => switch (record.kind) {
    ConflictKind.fields =>
      record.resolution == Resolution.mine ||
          record.resolution == Resolution.theirs ||
          record.resolution == Resolution.edited,
    ConflictKind.invalidMove => record.resolution == Resolution.theirs,
    ConflictKind.deleted => false,
  };

  /// Drops the write [entryId], and any open conflict about it.
  Future<void> discard(String entryId) => store.update(
    (s) => s.copyWith(
      entries: [
        for (final e in s.entries)
          if (e.id != entryId) e,
      ],
      conflicts: [
        for (final r in s.conflicts)
          if (r.entryId == entryId && r.resolution == null)
            r.copyWith(resolution: Resolution.discarded, resolvedAt: _clock())
          else
            r,
      ],
    ),
  );

  /// Drops every write still waiting, closing the conflicts about them.
  Future<void> discardAll() => store.update(
    (s) => s.copyWith(
      entries: const [],
      conflicts: [
        for (final r in s.conflicts)
          if (r.resolution == null)
            r.copyWith(resolution: Resolution.discarded, resolvedAt: _clock())
          else
            r,
      ],
    ),
  );

  /// Sends the refused or to-be-checked write [entryId] again, with
  /// [values] in place of its own when given.
  Future<void> retry(String entryId, {Map<String, Object?>? values}) =>
      store.update(
        (s) => s.copyWith(
          entries: [
            for (final e in s.entries)
              if (e.id == entryId)
                e.copyWith(
                  state: OutboxState.pending,
                  values: values ?? e.values,
                  errorCode: '',
                  errorMessage: '',
                  idempotencyKey: values == null ? e.idempotencyKey : _uuid(),
                )
              else
                e,
          ],
        ),
      );

  /// Takes the person's word that a create to check already reached the
  /// server: the draft is dropped, and so is everything queued on it.
  Future<void> forgetCreate(String entryId) => store.update((s) {
    final e = s.entries.where((x) => x.id == entryId).firstOrNull;
    if (e == null) return s;
    return s.copyWith(
      entries: [
        for (final x in s.entries)
          if (x.id != entryId &&
              x.target != e.draftRef &&
              !x.values.values.contains(e.draftRef))
            x,
      ],
    );
  });
}
