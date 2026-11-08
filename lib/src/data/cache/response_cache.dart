// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';

export 'package:tix_mobile/src/data/cache/cache_store.dart';

/// The last good response of each read, for one context.
///
/// A cache is best effort by design: a read that fails for any reason is a
/// miss and a write that fails is dropped, so a full disk or a response
/// shape a newer app no longer reads never breaks a screen. The server stays
/// the only source of truth; the cache only lets a screen draw at once.
class ResponseCache {
  /// Caches in [_store] under [scope].
  ResponseCache(this._store, this.scope);

  final CacheStore _store;

  /// The context this cache belongs to.
  final CacheScope scope;

  final _served = <String>{};

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

  /// Awaits [fresh], keeps it under [key] encoded with [encode], and returns
  /// it. A failure of [fresh] is the caller's; a failure to keep it is not.
  Future<T> remember<T>(
    String key,
    Future<T> fresh,
    Object? Function(T value) encode,
  ) async {
    final value = await fresh;
    try {
      await _store.write(
        scope,
        key,
        jsonEncode({
          'at': DateTime.now().toUtc().toIso8601String(),
          'data': encode(value),
        }),
      );
      // Same reason as in peek: keeping a copy must never fail the read.
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      log('cache write failed on $key', error: e, stackTrace: s);
    }
    return value;
  }
}
