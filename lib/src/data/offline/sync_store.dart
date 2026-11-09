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

/// The outbox, the conflicts and the draft map of one context, kept in the
/// cache store under `sync/state`.
///
/// Unlike the response cache this is not best effort: it holds writes that
/// exist nowhere else, so a failure to keep it is logged loudly and the
/// copy in memory stays the truth until the next write succeeds.
class SyncStore {
  /// Keeps the state of [scope] in [_store].
  SyncStore(this._store, this.scope);

  final CacheStore _store;

  /// The context.
  final CacheScope scope;

  /// The key everything is kept under; `sync/` is never cleared with the
  /// read cache.
  static const key = 'sync/state';

  SyncSnapshot _now = const SyncSnapshot();
  Future<void>? _loaded;
  Future<void> _writes = Future.value();
  final _changes = StreamController<SyncSnapshot>.broadcast();

  /// The state as it is now; empty until [load] completes.
  SyncSnapshot get now => _now;

  /// Every change after [load].
  Stream<SyncSnapshot> get changes => _changes.stream;

  /// Reads the kept state once.
  Future<SyncSnapshot> load() async {
    await (_loaded ??= _read());
    return _now;
  }

  Future<void> _read() async {
    try {
      final text = await _store.read(scope, key);
      if (text == null) return;
      _now = SyncSnapshot.fromJson(jsonDecode(text) as Map<String, dynamic>);
      // A state no build can read must not stop the app from starting; it is
      // logged, and the next write replaces it.
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      log('unreadable sync state', error: e, stackTrace: s);
    }
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
