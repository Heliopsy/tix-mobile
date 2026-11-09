// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/offline/outbox_entry.dart';

export 'package:tix_mobile/src/data/offline/outbox_entry.dart';

/// Whether [ref] is a task created offline and not yet sent, such as
/// `infra-draft3`.
bool isDraftRef(String ref) => _draft.hasMatch(ref);

final _draft = RegExp(r'-draft\d+$');

/// The reference draft [n] in project [key] shows until it is sent. It
/// keeps the project key in front, as a real reference does, so links built
/// from it name the right project.
String makeDraftRef(String key, int n) => '$key-draft$n';

/// A random version 4 UUID, for `Idempotency-Key` and entry ids.
String newUuid([Random? random]) {
  final r = random ?? Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = [for (final x in b) x.toRadixString(16).padLeft(2, '0')].join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}

/// How long a settled conflict stays in the history.
const settledConflictsKept = Duration(days: 30);

/// How many settled conflicts the history keeps at most.
const settledConflictsMax = 100;

/// How many sent drafts keep their real reference, so old links still work.
const sentDraftsMax = 200;

/// [s] without settled conflicts older than [settledConflictsKept] or past
/// the newest [settledConflictsMax], and with the [sentDraftsMax] most
/// recent sent drafts plus any a waiting write still names. Answers [s]
/// itself when nothing goes.
SyncSnapshot pruneSnapshot(SyncSnapshot s, DateTime now) {
  final cutoff = now.subtract(settledConflictsKept);
  var settled = 0;
  final conflicts = [
    for (final r in s.conflicts)
      if (r.resolution == null ||
          (!(r.resolvedAt ?? r.createdAt).isBefore(cutoff) &&
              ++settled <= settledConflictsMax))
        r,
  ];
  final named = <String>{
    for (final e in s.entries) ...[
      e.target,
      for (final v in e.values.values)
        if (v is String) v,
    ],
  };
  final keys = s.drafts.keys.toList();
  final recent = keys.skip(max(0, keys.length - sentDraftsMax));
  final keep = {...recent, ...keys.where(named.contains)};
  final drafts = {
    for (final k in keys)
      if (keep.contains(k)) k: s.drafts[k]!,
  };
  if (conflicts.length == s.conflicts.length &&
      drafts.length == s.drafts.length) {
    return s;
  }
  return s.copyWith(conflicts: conflicts, drafts: drafts);
}

/// The outbox, the conflicts and the draft map of one context, kept in the
/// cache store under `sync/state`.
///
/// Unlike the response cache this is not best effort: it holds writes that
/// exist nowhere else, so a failure to keep it is logged loudly and the
/// copy in memory stays the truth until the next write succeeds.
class SyncStore {
  /// Keeps the state of [scope] in [_store]; [now] stamps a state set
  /// aside.
  SyncStore(this._store, this.scope, {DateTime Function()? now})
    : _clock = now ?? DateTime.now;

  final CacheStore _store;
  final DateTime Function() _clock;

  /// The context.
  final CacheScope scope;

  /// The key everything is kept under; `sync/` is never cleared with the
  /// read cache.
  static const key = 'sync/state';

  /// The key a state no build can read is moved to, stamped with [at].
  static String corruptKey(DateTime at) =>
      '$key.corrupt-${at.toUtc().millisecondsSinceEpoch}';

  SyncSnapshot _now = const SyncSnapshot();
  String? _setAside;
  bool _unsafe = false;
  Future<void>? _loaded;
  Future<void> _writes = Future.value();
  final _changes = StreamController<SyncSnapshot>.broadcast();

  /// The state as it is now; empty until [load] completes.
  SyncSnapshot get now => _now;

  /// Every change after [load].
  Stream<SyncSnapshot> get changes => _changes.stream;

  /// Whether [load] found a state it could not read. It is kept under
  /// [setAside]; when even that failed, [setAside] is null and nothing is
  /// written over the original.
  bool get unreadable => _setAside != null || _unsafe;

  /// Where an unreadable state was moved to, null when there was none.
  String? get setAside => _setAside;

  /// The state kept for [scope] in [store], read without changing anything;
  /// null when there is none or it cannot be read.
  static Future<SyncSnapshot?> peek(CacheStore store, CacheScope scope) async {
    try {
      final text = await store.read(scope, key);
      if (text == null) return null;
      return SyncSnapshot.fromJson(jsonDecode(text) as Map<String, dynamic>);
      // Same reason as in _read.
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      log('unreadable sync state', error: e, stackTrace: s);
      return null;
    }
  }

  /// Reads the kept state once.
  Future<SyncSnapshot> load() async {
    await (_loaded ??= _read());
    return _now;
  }

  Future<void> _read() async {
    final String? text;
    try {
      text = await _store.read(scope, key);
    } on Exception catch (e, s) {
      log('could not read the sync state', error: e, stackTrace: s);
      _unsafe = true;
      return;
    }
    if (text == null) return;
    try {
      _now = SyncSnapshot.fromJson(jsonDecode(text) as Map<String, dynamic>);
      // A state no build can read must not stop the app from starting, nor
      // be written over: it holds writes that exist nowhere else.
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      log('unreadable sync state, setting it aside', error: e, stackTrace: s);
      await _putAside(text);
    }
  }

  Future<void> _putAside(String text) async {
    final aside = corruptKey(_clock());
    try {
      await _store.write(scope, aside, text);
      _setAside = aside;
    } on Exception catch (e, s) {
      log('could not set the sync state aside', error: e, stackTrace: s);
      _unsafe = true;
    }
  }

  /// Drops old settled conflicts and sent drafts, see [pruneSnapshot].
  Future<void> prune(DateTime now) async {
    await load();
    if (identical(pruneSnapshot(_now, now), _now)) return;
    await update((s) => pruneSnapshot(s, now));
  }

  /// Applies [change] to the state and keeps the result. Changes run one
  /// at a time, in the order they were asked for.
  Future<SyncSnapshot> update(
    SyncSnapshot Function(SyncSnapshot now) change,
  ) async {
    await load();
    final done = Completer<SyncSnapshot>();
    _writes = _writes.then((_) async {
      _now = change(_now);
      if (!_changes.isClosed) _changes.add(_now);
      if (_unsafe) {
        log('sync state kept in memory only: the stored one was unreadable');
        done.complete(_now);
        return;
      }
      try {
        await _store.write(scope, key, jsonEncode(_now.toJson()));
      } on Exception catch (e, s) {
        log('could not keep the sync state', error: e, stackTrace: s);
      }
      done.complete(_now);
    });
    return await done.future;
  }

  /// Stops reporting changes.
  Future<void> close() => _changes.close();
}

/// One [SyncStore] per context for the life of the app, so every writer of
/// a context (the outbox, each replay, the conflicts screen) shares one
/// snapshot and one ordered write path, however often the session changes.
/// Two stores of one context would each hold their own copy, and the last
/// to write would undo the other's changes.
class SyncStores {
  /// Stores in [_store], stamping set-aside states with [now].
  SyncStores(this._store, {DateTime Function()? now}) : _clock = now;

  final CacheStore _store;
  final DateTime Function()? _clock;
  final _byScope = <CacheScope, SyncStore>{};

  /// The store of [scope], made and loaded the first time it is asked for.
  SyncStore of(CacheScope scope) => _byScope.putIfAbsent(scope, () {
    final store = SyncStore(_store, scope, now: _clock);
    unawaited(store.load());
    return store;
  });

  /// Drops and closes the stores of [connectionId], which is forgotten.
  Future<void> forget(String connectionId) async {
    final gone = [
      for (final MapEntry(:key, :value) in _byScope.entries)
        if (key.connectionId == connectionId) value,
    ];
    _byScope.removeWhere((k, _) => k.connectionId == connectionId);
    for (final s in gone) {
      await s.close();
    }
  }
}
