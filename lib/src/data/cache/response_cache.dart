// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';

export 'package:tix_mobile/src/data/cache/cache_store.dart';

/// The last good response of each read, for one context.
///
/// A cache is best effort by design: a read that fails for any reason is a
/// miss and a write that fails is dropped, so a full disk or a response
/// shape a newer app no longer reads never breaks a screen. The server stays
/// the only source of truth; the cache lets a screen draw at once, and
/// stands in for the server while it cannot be reached.
class ResponseCache {
  /// Caches in [_store] under [scope], stamping entries with [now].
  ResponseCache(this._store, this.scope, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final CacheStore _store;
  final DateTime Function() _now;

  /// The context this cache belongs to.
  final CacheScope scope;

  final _served = <String>{};
  final _stale = <String, DateTime>{};
  final _staleChanges = StreamController<DateTime?>.broadcast();

  static const _strict = #tixResponseCacheStrict;

  /// Whether [error] means the server could not be reached, as opposed to
  /// an answer from it: no network, a timeout, or a gateway in front of it
  /// (502, 503, 504) that could not reach it.
  static bool isUnreachable(Object error) =>
      error is TixException &&
      (error.kind == TixErrorKind.network ||
          error.kind == TixErrorKind.timeout ||
          error.kind == TixErrorKind.upstream);

  /// Runs [body] with the offline fallback of [remember] turned off, so a
  /// read that cannot reach the server fails instead of answering with the
  /// stored copy. A prefetch runs in here, so it never mistakes the old
  /// copy for a fresh one.
  static Future<T> strict<T>(Future<T> Function() body) =>
      runZoned(body, zoneValues: {_strict: true});

  /// When the oldest stored copy served in place of the server was kept,
  /// null while every read since the last success reached the server.
  DateTime? get staleSince => _stale.isEmpty
      ? null
      : _stale.values.reduce((a, b) => a.isBefore(b) ? a : b);

  /// [staleSince], each time it changes.
  Stream<DateTime?> get staleChanges => _staleChanges.stream;

  /// Stops [staleChanges].
  Future<void> dispose() => _staleChanges.close();

  /// The cached value of [key], decoded with [decode], or null.
  ///
  /// Each key is served at most once per cache: the first time a screen
  /// opens it draws from here, and every refresh after that asks the server,
  /// so a pull to refresh is never answered with what is already shown.
  Future<T?> peek<T>(String key, T Function(Object? json) decode) async {
    if (!_served.add(key)) return null;
    try {
      final text = await _store.read(scope, key);
      if (text == null) return null;
      final entry = jsonDecode(text) as Map<String, Object?>;
      return decode(entry['data']);
      // Anything at all, Errors included: a file written by an older build
      // whose shape no longer decodes is a miss, never a crash.
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      log('cache miss on $key', error: e, stackTrace: s);
      return null;
    }
  }

  /// The value kept under [key], decoded with [decode], and when it was
  /// kept, or null. Unlike [peek] it answers every time.
  Future<({T value, DateTime at})?> stored<T>(
    String key,
    T Function(Object? json) decode,
  ) async {
    try {
      final text = await _store.read(scope, key);
      if (text == null) return null;
      final entry = jsonDecode(text) as Map<String, Object?>;
      return (
        value: decode(entry['data']),
        at: DateTime.parse(entry['at']! as String),
      );
      // Same reason as in peek.
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      log('cache miss on $key', error: e, stackTrace: s);
      return null;
    }
  }

  /// Awaits [fresh], keeps it under [key] encoded with [encode], and returns
  /// it. A failure to keep it is not the caller's.
  ///
  /// When [fresh] fails because the server cannot be reached
  /// ([isUnreachable]) and a copy is kept under [key], the copy decoded
  /// with [decode] is returned instead and [staleSince] says how old it is.
  /// Any other failure, and every failure without [decode] or a copy, is
  /// the caller's.
  Future<T> remember<T>(
    String key,
    Future<T> fresh,
    Object? Function(T value) encode, {
    T Function(Object? json)? decode,
  }) async {
    final T value;
    try {
      value = await fresh;
    } on TixException catch (e) {
      if (decode == null || Zone.current[_strict] == true) rethrow;
      if (!isUnreachable(e)) rethrow;
      final copy = await stored(key, decode);
      if (copy == null) rethrow;
      _markStale(key, copy.at);
      return copy.value;
    }
    _clearStale();
    await keep(key, value, encode);
    return value;
  }

  /// Keeps [value] under [key], encoded with [encode]. A failure to keep it
  /// is logged and dropped.
  Future<void> keep<T>(
    String key,
    T value,
    Object? Function(T value) encode,
  ) async {
    try {
      await _store.write(
        scope,
        key,
        jsonEncode({
          'at': _now().toUtc().toIso8601String(),
          'data': encode(value),
        }),
      );
      // Same reason as in peek: keeping a copy must never fail the read.
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      log('cache write failed on $key', error: e, stackTrace: s);
    }
  }

  void _markStale(String key, DateTime at) {
    _stale[key] = at;
    if (!_staleChanges.isClosed) _staleChanges.add(staleSince);
  }

  void _clearStale() {
    if (_stale.isEmpty) return;
    _stale.clear();
    if (!_staleChanges.isClosed) _staleChanges.add(null);
  }
}
