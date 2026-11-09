// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/offline/connection_jobs.dart';
import 'package:tix_mobile/src/data/offline/merge.dart';
import 'package:tix_mobile/src/data/offline/sender.dart';
import 'package:tix_mobile/src/data/offline/sync_store.dart';

/// How long after its first send a create's `Idempotency-Key` is trusted.
/// tix forgets a key a day after it first sees it; the hour short of that
/// covers a clock that runs behind the server's.
const idempotencyKeyLife = Duration(hours: 23);

/// One replay at a time per context, across every replayer: one is built
/// for each session change, and two replays of the same outbox would send
/// the same writes twice.
class ReplayLocks {
  final _tails = <CacheScope, Completer<void>>{};

  /// Runs [body] once every replay of [scope] asked for before it ended.
  Future<T> run<T>(CacheScope scope, Future<T> Function() body) async {
    final before = _tails[scope];
    final mine = Completer<void>();
    _tails[scope] = mine;
    try {
      if (before != null) await before.future;
      return await body();
    } finally {
      mine.complete();
      if (identical(_tails[scope], mine)) _tails.remove(scope);
    }
  }

  /// Whether a replay of [scope] runs or waits.
  bool busy(CacheScope scope) => _tails.containsKey(scope);
}

/// What one replay did.
@immutable
class ReplayReport {
  /// Creates a report.
  const ReplayReport({
    this.sent = 0,
    this.conflicts = 0,
    this.failed = 0,
    this.unreachable = false,
  });

  /// Writes the server took.
  final int sent;

  /// Conflicts found, settled by the policy or waiting for the person.
  final int conflicts;

  /// Writes the server refused.
  final int failed;

  /// Whether the server could not be reached, so writes are still waiting.
  final bool unreachable;
}

/// Whether [e] means the server was not reached, or not reached properly:
/// the write may be sent again later.
bool isUnreachable(TixException e) => switch (e.kind) {
  TixErrorKind.network || TixErrorKind.timeout => true,
  TixErrorKind.upstream || TixErrorKind.notTix => true,
  _ => false,
};

/// Whether [e] is a refusal the person has to look at: no retry helps.
bool _refused(TixException e) => switch (e.kind) {
  TixErrorKind.forbidden ||
  TixErrorKind.invalid ||
  TixErrorKind.preconditionFailed ||
  TixErrorKind.unauthenticated => true,
  _ => false,
};

/// The order writes are replayed in: by when they were made, a restore
/// before the write it was added for.
int _byOrder(OutboxEntry a, OutboxEntry b) {
  final s = a.seq.compareTo(b.seq);
  if (s != 0) return s;
  if (a.op == OutboxOp.restore) return -1;
  if (b.op == OutboxOp.restore) return 1;
  return 0;
}

class _Stop implements Exception {
  const _Stop({this.unreachable = false});
  final bool unreachable;
}

/// Sends the outbox of one context, and settles what the person decides
/// about conflicts.
///
/// Writes to one task go in the order they were made; writes to different
/// tasks go in parallel. A task's writes stop at the first that waits for
/// the person (a conflict, a refusal, a create to check), so a later write
/// never overtakes an earlier one. A write to a draft waits for the draft's
/// create, and is rewritten to the real reference once it is known.
class OutboxReplayer {
  /// Replays the outbox in [_store] through [_sender], settling conflicts by
  /// `policy`, read once at the start of each replay. Replays of the same
  /// context wait for each other through [locks].
  OutboxReplayer(
    this._store,
    this._sender, {
    required this._policy,
    ReplayLocks? locks,
    this._clock = DateTime.now,
    this._uuid = newUuid,
  }) : _locks = locks ?? ReplayLocks();

  final SyncStore _store;
  final OutboxSender _sender;
  final ConflictPolicy Function() _policy;
  final ReplayLocks _locks;
  final DateTime Function() _clock;
  final String Function() _uuid;
  Future<ReplayReport>? _running;
  ConflictPolicy _policyNow = ConflictPolicy.ask;

  /// Whether a replay is under way.
  bool get running => _running != null;

  /// Sends every waiting write, after any replay of the same context still
  /// running. A replay asked for while this replayer's runs joins it. It
  /// stops with [JobCancelled] once [job] is cancelled.
  Future<ReplayReport> replay({ConnectionJob? job}) => _running ??= _locks
      .run(_store.scope, () => _replay(job))
      .whenComplete(() => _running = null);

  Future<ReplayReport> _replay(ConnectionJob? job) async {
    job?.check();
    _policyNow = _policy();
    var snap = await _store.load();
    if (snap.idempotency == null && snap.entries.isNotEmpty) {
      final bool keyed;
      try {
        keyed = await _sender.detectIdempotency();
      } on TixException catch (x) {
        if (isUnreachable(x)) return const ReplayReport(unreachable: true);
        rethrow;
      }
      snap = await _store.update((s) => s.copyWith(idempotency: keyed));
    }
    var sent = 0;
    var conflicts = 0;
    var failed = 0;
    var unreachable = false;
    final waiting = [...snap.entries]..sort(_byOrder);
    final chains = <String, List<OutboxEntry>>{};
    final blocked = <String>{};
    for (final e in waiting) {
      final chain = _resolve(snap, e.target);
      if (e.state != OutboxState.pending && e.state != OutboxState.needsCheck) {
        blocked.add(chain);
      }
      if (blocked.contains(chain)) continue;
      (chains[chain] ??= []).add(e);
      if (e.state == OutboxState.needsCheck) blocked.add(chain);
    }
    final drafts = <String, Completer<String?>>{
      for (final e in waiting)
        if (e.op == OutboxOp.create && e.draftRef.isNotEmpty)
          e.draftRef: Completer<String?>(),
    };
    for (final MapEntry(key: draft, value: real) in snap.drafts.entries) {
      (drafts[draft] ??= Completer<String?>()).complete(real);
    }

    Future<void> runChain(List<OutboxEntry> chain) async {
      for (final queued in chain) {
        if (job?.cancelled ?? false) break;
        final current = _find(queued.id);
        if (current == null) continue;
        try {
          final outcome = await _run(current, drafts);
          sent += outcome.sent;
          conflicts += outcome.conflicts;
          if (outcome.stop) {
            if (outcome.failed) failed++;
            break;
          }
        } on _Stop catch (s) {
          if (s.unreachable) unreachable = true;
          break;
        }
      }
      for (final e in chain) {
        if (e.op != OutboxOp.create || e.draftRef.isEmpty) continue;
        final done = drafts[e.draftRef]!;
        if (!done.isCompleted) done.complete(_store.now.drafts[e.draftRef]);
      }
    }

    await Future.wait([for (final c in chains.values) runChain(c)]);
    job?.check();
    await _store.prune(_clock());
    return ReplayReport(
      sent: sent,
      conflicts: conflicts,
      failed: failed,
      unreachable: unreachable,
    );
  }

  OutboxEntry? _find(String id) {
    for (final e in _store.now.entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  static String _resolve(SyncSnapshot s, String ref) => s.drafts[ref] ?? ref;

  /// [values] with every draft reference it names replaced by the real one,
  /// waiting for each draft's create. Null when a draft never got one.
  Future<Map<String, Object?>?> _rewrite(
    Map<String, Object?> values,
    Map<String, Completer<String?>> drafts,
  ) async {
    final out = <String, Object?>{};
    for (final MapEntry(:key, :value) in values.entries) {
      if (value is String && isDraftRef(value)) {
        final real = await (drafts[value]?.future ?? Future<String?>.value());
        if (real == null) return null;
        out[key] = real;
      } else {
        out[key] = value;
      }
    }
    return out;
  }

  Future<_Outcome> _run(
    OutboxEntry queued,
    Map<String, Completer<String?>> drafts,
  ) async {
    var e = queued;
    String target;
    if (e.op == OutboxOp.create) {
      target = e.target;
    } else if (isDraftRef(e.target)) {
      final real = await (drafts[e.target]?.future ?? Future<String?>.value());
      if (real == null) throw const _Stop();
      target = real;
    } else {
      target = e.target;
    }
    final values = await _rewrite(e.values, drafts);
    if (values == null) throw const _Stop();
    e = _find(e.id) ?? e;
    try {
      return switch (e.op) {
        OutboxOp.update => await _update(e, target, values),
        OutboxOp.check => await _check(e, target, values),
        OutboxOp.move => await _move(e, target, values),
        OutboxOp.create => await _create(e, values, drafts),
        _ => await _plain(e, target, values),
      };
    } on TixException catch (x) {
      if (isUnreachable(x)) throw const _Stop(unreachable: true);
      switch (keyedAnswer(x)) {
        case KeyedAnswer.inFlight:
          throw const _Stop(unreachable: true);
        case KeyedAnswer.appliedLost:
          await _done(e, await _sender.fetch(target));
          return const _Outcome(sent: 1);
        case KeyedAnswer.mismatch:
          return await _fail(e, x);
        case KeyedAnswer.none:
      }
      if (x.kind == TixErrorKind.notFound && e.op != OutboxOp.create) {
        return await _open(e, target, ConflictKind.deleted, reason: x.message);
      }
      if (_refused(x)) return await _fail(e, x);
      await _replace(e.copyWith(attempts: e.attempts + 1));
      throw const _Stop();
    }
  }

  Future<_Outcome> _plain(
    OutboxEntry e,
    String target,
    Map<String, Object?> values,
  ) async {
    final task = await _sender.send(
      e.op,
      target,
      values,
      key: e.idempotencyKey,
      version: e.op == OutboxOp.check ? e.baseVersion : null,
    );
    await _done(e, task);
    return const _Outcome(sent: 1);
  }

  Future<_Outcome> _update(
    OutboxEntry e,
    String target,
    Map<String, Object?> values,
  ) async {
    var entry = e;
    var body = values;
    var found = 0;
    for (var round = 0; round < 3; round++) {
      try {
        final task = await _sender.send(
          OutboxOp.update,
          target,
          body,
          key: entry.idempotencyKey,
          version: entry.baseVersion,
        );
        await _done(entry, task);
        return _Outcome(sent: 1, conflicts: found);
      } on TixException catch (x) {
        if (x.kind != TixErrorKind.conflict) rethrow;
        if (keyedAnswer(x) != KeyedAnswer.none) rethrow;
      }
      final theirs = await _sender.fetch(target);
      final merged = merge3(
        base: entry.base,
        mine: body,
        theirs: theirs.toJson(),
      );
      if (merged.empty) {
        await _done(entry, theirs);
        return _Outcome(conflicts: found);
      }
      final policy = _policyNow;
      final settled = settle(merged, policy);
      if (merged.conflicts.isNotEmpty) {
        found++;
        final waiting = entry.copyWith(
          baseVersion: theirs.version,
          base: theirs.toJson(),
          values: unflatten({
            ...flatten(merged.send),
            for (final c in merged.conflicts) c.field: c.mine,
          }),
          idempotencyKey: _uuid(),
        );
        final record = _record(
          waiting,
          target,
          theirs,
          ConflictKind.fields,
          fields: merged.conflicts,
        );
        if (settled == null) {
          await _replace(waiting.copyWith(state: OutboxState.conflict));
          await _addRecord(record);
          return _Outcome(conflicts: found, stop: true);
        }
        await _addRecord(
          record.copyWith(
            resolution: policy == ConflictPolicy.keepMine
                ? Resolution.mine
                : Resolution.theirs,
            auto: true,
            resolvedAt: _clock(),
          ),
        );
      }
      if (settled!.isEmpty) {
        await _done(entry, theirs);
        return _Outcome(conflicts: found);
      }
      entry = entry.copyWith(
        baseVersion: theirs.version,
        base: theirs.toJson(),
        values: settled,
        idempotencyKey: _uuid(),
      );
      body = settled;
      await _replace(entry);
    }
    await _replace(entry.copyWith(attempts: entry.attempts + 1));
    throw const _Stop();
  }

  Future<_Outcome> _check(
    OutboxEntry e,
    String target,
    Map<String, Object?> values,
  ) async {
    try {
      return await _plain(e, target, values);
    } on TixException catch (x) {
      if (x.kind != TixErrorKind.conflict) rethrow;
      if (keyedAnswer(x) != KeyedAnswer.none) rethrow;
    }
    final theirs = await _sender.fetch(target);
    if (same(theirs.body, e.base['body'])) {
      return await _plain(
        e.copyWith(baseVersion: theirs.version),
        target,
        values,
      );
    }
    final conflict = FieldConflict(
      field: 'body',
      base: e.base['body'],
      mine: e.base['body'],
      theirs: theirs.body,
    );
    return await _decide(
      e,
      target,
      theirs,
      conflict,
      () => _plain(e.copyWith(baseVersion: theirs.version), target, values),
    );
  }

  Future<_Outcome> _move(
    OutboxEntry e,
    String target,
    Map<String, Object?> values,
  ) async {
    final to = values['to']?.toString() ?? '';
    final from = e.base['status'];
    if (from != null) {
      final theirs = await _sender.fetch(target);
      if (theirs.status == to) {
        await _done(e, theirs);
        return const _Outcome();
      }
      if (!same(theirs.status, from)) {
        final conflict = FieldConflict(
          field: 'status',
          base: from,
          mine: to,
          theirs: theirs.status,
        );
        return await _decide(
          e,
          target,
          theirs,
          conflict,
          () => _route(e, target),
        );
      }
    }
    return await _route(e, target);
  }

  Future<_Outcome> _route(OutboxEntry e, String target) async {
    try {
      return await _plain(e, target, e.values);
    } on TixException catch (x) {
      if (keyedAnswer(x) != KeyedAnswer.none) rethrow;
      if (x.kind != TixErrorKind.preconditionFailed &&
          x.kind != TixErrorKind.invalid &&
          x.kind != TixErrorKind.conflict) {
        rethrow;
      }
      if (_policyNow == ConflictPolicy.keepTheirs) {
        final theirs = await _sender.fetch(target);
        await _addRecord(
          _record(
            e,
            target,
            theirs,
            ConflictKind.invalidMove,
            reason: x.message,
          ).copyWith(
            resolution: Resolution.theirs,
            auto: true,
            resolvedAt: _clock(),
          ),
        );
        await _done(e, theirs);
        return const _Outcome(conflicts: 1);
      }
      return await _open(
        e,
        target,
        ConflictKind.invalidMove,
        reason: x.message,
      );
    }
  }

  /// Settles one same-attribute conflict by the policy: [mine] sends the
  /// person's side, keeping theirs drops the write, asking waits.
  Future<_Outcome> _decide(
    OutboxEntry e,
    String target,
    Task theirs,
    FieldConflict conflict,
    Future<_Outcome> Function() mine,
  ) async {
    final policy = _policyNow;
    final record = _record(
      e,
      target,
      theirs,
      ConflictKind.fields,
      fields: [conflict],
    );
    switch (policy) {
      case ConflictPolicy.ask:
        await _replace(
          e.copyWith(
            state: OutboxState.conflict,
            baseVersion: theirs.version,
            base: theirs.toJson(),
          ),
        );
        await _addRecord(record);
        return const _Outcome(conflicts: 1, stop: true);
      case ConflictPolicy.keepMine:
        await _addRecord(
          record.copyWith(
            resolution: Resolution.mine,
            auto: true,
            resolvedAt: _clock(),
          ),
        );
        final sent = await mine();
        return _Outcome(
          sent: sent.sent,
          conflicts: sent.conflicts + 1,
          stop: sent.stop,
        );
      case ConflictPolicy.keepTheirs:
        await _addRecord(
          record.copyWith(
            resolution: Resolution.theirs,
            auto: true,
            resolvedAt: _clock(),
          ),
        );
        await _done(e, theirs);
        return const _Outcome(conflicts: 1);
    }
  }

  bool _keyExpired(OutboxEntry e) {
    final first = e.firstSentAt;
    return first != null && _clock().difference(first) >= idempotencyKeyLife;
  }

  Future<_Outcome> _create(
    OutboxEntry queued,
    Map<String, Object?> values,
    Map<String, Completer<String?>> drafts,
  ) async {
    var e = queued;
    final keyed = _store.now.idempotency ?? false;
    final expired = keyed && _keyExpired(e);
    if (expired && e.state == OutboxState.pending) {
      e = e.copyWith(state: OutboxState.needsCheck);
      await _replace(e);
    }
    if (e.state == OutboxState.needsCheck && (!keyed || expired)) {
      final found = await _sender.findCreated(values, e.createdAt);
      if (found.length == 1) {
        await _created(e, found.single, drafts);
        return const _Outcome(sent: 1);
      }
      if (found.length > 1) return const _Outcome(stop: true);
      if (expired) {
        e = e.copyWith(
          state: OutboxState.pending,
          idempotencyKey: _uuid(),
          firstSentAt: null,
        );
      }
    }
    if (e.firstSentAt == null) {
      e = e.copyWith(firstSentAt: _clock());
      await _replace(e);
    }
    final Task? task;
    try {
      task = await _sender.send(
        OutboxOp.create,
        e.target,
        values,
        key: e.idempotencyKey,
      );
    } on TixException catch (x) {
      if (keyedAnswer(x) == KeyedAnswer.appliedLost) {
        final found = await _sender.findCreated(values, e.createdAt);
        if (found.length == 1) {
          await _created(e, found.single, drafts);
          return const _Outcome(sent: 1);
        }
        await _replace(e.copyWith(state: OutboxState.needsCheck));
        return const _Outcome(stop: true);
      }
      if (!isUnreachable(x)) rethrow;
      if (!keyed) await _replace(e.copyWith(state: OutboxState.needsCheck));
      throw const _Stop(unreachable: true);
    }
    await _created(e, task!, drafts);
    return const _Outcome(sent: 1);
  }

  Future<void> _created(
    OutboxEntry e,
    Task task,
    Map<String, Completer<String?>> drafts,
  ) async {
    final draft = e.draftRef;
    await _store.update(
      (s) => s.copyWith(
        entries: [
          for (final x in s.entries)
            if (x.id != e.id) _rewriteEntry(x, draft, task.ref),
        ],
        drafts: {...s.drafts, if (draft.isNotEmpty) draft: task.ref},
      ),
    );
    final done = drafts[draft];
    if (done != null && !done.isCompleted) done.complete(task.ref);
  }

  static OutboxEntry _rewriteEntry(OutboxEntry x, String draft, String real) {
    if (draft.isEmpty) return x;
    return x.copyWith(
      target: x.target == draft ? real : x.target,
      values: {
        for (final MapEntry(:key, :value) in x.values.entries)
          key: value == draft ? real : value,
      },
    );
  }

  /// Takes [e] out of the outbox, and moves the writes after it on the same
  /// task to the version it produced.
  Future<void> _done(OutboxEntry e, Task? answer) => _store.update((s) {
    final from = e.baseVersion;
    final to = answer?.version;
    final target = _resolve(s, e.target);
    bool follows(OutboxEntry x) =>
        from != null &&
        to != null &&
        x.baseVersion == from &&
        _resolve(s, x.target) == target;
    return s.copyWith(
      entries: [
        for (final x in s.entries.where((x) => x.id != e.id))
          if (follows(x))
            x.copyWith(baseVersion: to, base: answer!.toJson())
          else
            x,
      ],
    );
  });

  Future<void> _replace(OutboxEntry e) => _store.update(
    (s) => s.copyWith(
      entries: [
        for (final x in s.entries)
          if (x.id == e.id) e else x,
      ],
    ),
  );

  Future<_Outcome> _fail(OutboxEntry e, TixException x) async {
    await _replace(
      e.copyWith(
        state: OutboxState.failed,
        errorCode: x.kind.name,
        errorMessage: x.message,
      ),
    );
    return const _Outcome(stop: true, failed: true);
  }

  Future<_Outcome> _open(
    OutboxEntry e,
    String target,
    ConflictKind kind, {
    String reason = '',
  }) async {
    await _replace(e.copyWith(state: OutboxState.conflict));
    await _addRecord(
      ConflictRecord(
        id: _uuid(),
        entryId: e.id,
        taskRef: target,
        taskTitle: e.base['title']?.toString() ?? '',
        kind: kind,
        reason: reason,
        wanted: e.op == OutboxOp.move ? e.values['to']?.toString() ?? '' : '',
        createdAt: _clock(),
      ),
    );
    return const _Outcome(conflicts: 1, stop: true);
  }

  ConflictRecord _record(
    OutboxEntry e,
    String target,
    Task theirs,
    ConflictKind kind, {
    List<FieldConflict> fields = const [],
    String reason = '',
  }) => ConflictRecord(
    id: _uuid(),
    entryId: e.id,
    taskRef: target,
    taskTitle: theirs.title,
    kind: kind,
    fields: fields,
    reason: reason,
    wanted: e.op == OutboxOp.move ? e.values['to']?.toString() ?? '' : '',
    createdAt: _clock(),
    theirsVersion: theirs.version,
  );

  Future<void> _addRecord(ConflictRecord r) =>
      _store.update((s) => s.copyWith(conflicts: [r, ...s.conflicts]));
}

class _Outcome {
  const _Outcome({
    this.sent = 0,
    this.conflicts = 0,
    this.stop = false,
    this.failed = false,
  });
  final int sent;
  final int conflicts;
  final bool stop;
  final bool failed;
}
