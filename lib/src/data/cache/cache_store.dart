// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

/// Which context a cached response belongs to: a connection and the tenant
/// it targets. Nothing cached for one is ever served to another.
@immutable
class CacheScope {
  /// The scope of [connectionId] in [tenantKey].
  const CacheScope(this.connectionId, this.tenantKey);

  /// The saved connection.
  final String connectionId;

  /// The tenant, empty when the connection does not name one.
  final String tenantKey;

  @override
  bool operator ==(Object other) =>
      other is CacheScope &&
      other.connectionId == connectionId &&
      other.tenantKey == tenantKey;

  @override
  int get hashCode => Object.hash(connectionId, tenantKey);
}

/// Where the last good responses are kept, as JSON text by scope and key.
abstract interface class CacheStore {
  /// The text under [key] in [scope], null when there is none.
  Future<String?> read(CacheScope scope, String key);

  /// Replaces the text under [key] in [scope]. Throws [ConnectionForgotten]
  /// once [clearConnection] has run for the scope's connection.
  Future<void> write(CacheScope scope, String key, String value);

  /// Forgets everything cached for [connectionId], in every tenant,
  /// [syncPrefix] included, and refuses every later [write] for it.
  Future<void> clearConnection(String connectionId);

  /// How many bytes [scope] takes, entries under [syncPrefix] included.
  Future<int> sizeOf(CacheScope scope);

  /// Forgets what was cached for [scope], except entries under
  /// [syncPrefix]: those are changes not yet sent, never a copy.
  Future<void> clearScope(CacheScope scope);

  /// Keys under this prefix hold work waiting to be sent (the outbox,
  /// conflicts, drafts), so [clearScope] keeps them.
  static const syncPrefix = 'sync/';
}

/// Thrown by [CacheStore.write] for a connection that was forgotten.
class ConnectionForgotten implements Exception {
  /// The write to [connectionId] that was refused.
  const ConnectionForgotten(this.connectionId);

  /// The forgotten connection.
  final String connectionId;

  @override
  String toString() => 'ConnectionForgotten($connectionId)';
}

/// A [CacheStore] in memory, for tests.
class MemoryCacheStore implements CacheStore {
  /// The entries, by connection, tenant and key.
  final entries = <String, Map<String, String>>{};

  final _forgotten = <String>{};

  static String _scope(CacheScope s) => '${s.connectionId}/${s.tenantKey}';

  @override
  Future<String?> read(CacheScope scope, String key) async =>
      entries[_scope(scope)]?[key];

  @override
  Future<void> write(CacheScope scope, String key, String value) async {
    if (_forgotten.contains(scope.connectionId)) {
      throw ConnectionForgotten(scope.connectionId);
    }
    (entries[_scope(scope)] ??= {})[key] = value;
  }

  @override
  Future<void> clearConnection(String connectionId) async {
    _forgotten.add(connectionId);
    entries.removeWhere((k, _) => k.startsWith('$connectionId/'));
  }

  @override
  Future<int> sizeOf(CacheScope scope) async => (entries[_scope(scope)] ?? {})
      .values
      .fold<int>(0, (sum, v) => sum + utf8.encode(v).length);

  @override
  Future<void> clearScope(CacheScope scope) async => entries[_scope(scope)]
      ?.removeWhere((k, _) => !k.startsWith(CacheStore.syncPrefix));
}

/// A [CacheStore] of one file per entry under a directory: no database and
/// no native code, since nothing here is ever queried, only read by key.
///
/// Layout: `<root>/v1/<connection>/<tenant>/<key>.json`, every segment
/// percent-encoded so any id is a safe file name on every platform.
class FileCacheStore implements CacheStore {
  /// Keeps files under the directory the given function resolves to.
  FileCacheStore(this._root);

  final Future<Directory> Function() _root;
  Future<Directory>? _resolved;
  final _forgotten = <String>{};

  /// Bump when the stored form changes; older files are never read.
  static const version = 'v1';

  Future<Directory> _base() => _resolved ??= _root().then(
    (d) => Directory('${d.path}${Platform.pathSeparator}$version'),
  );

  static String _seg(String s) =>
      s.isEmpty ? '_' : Uri.encodeComponent(s).replaceAll('*', '%2A');

  Future<File> _file(CacheScope scope, String key) async {
    final sep = Platform.pathSeparator;
    final base = await _base();
    return File(
      '${base.path}$sep${_seg(scope.connectionId)}$sep'
      '${_seg(scope.tenantKey)}$sep${_seg(key)}.json',
    );
  }

  @override
  Future<String?> read(CacheScope scope, String key) async {
    final file = await _file(scope, key);
    if (!file.existsSync()) return null;
    return await file.readAsString();
  }

  @override
  Future<void> write(CacheScope scope, String key, String value) async {
    final id = scope.connectionId;
    if (_forgotten.contains(id)) throw ConnectionForgotten(id);
    final file = await _file(scope, key);
    try {
      await file.parent.create(recursive: true);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(value, flush: true);
      await tmp.rename(file.path);
    } finally {
      // A write that passed the check while the connection was being
      // forgotten may have created its folder again after the delete.
      if (_forgotten.contains(id)) await _deleteConnection(id);
    }
    if (_forgotten.contains(id)) throw ConnectionForgotten(id);
  }

  @override
  Future<void> clearConnection(String connectionId) async {
    _forgotten.add(connectionId);
    await _deleteConnection(connectionId);
  }

  Future<void> _deleteConnection(String connectionId) async {
    final base = await _base();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}${_seg(connectionId)}',
    );
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  Future<Directory> _dir(CacheScope scope) async {
    final sep = Platform.pathSeparator;
    final base = await _base();
    return Directory(
      '${base.path}$sep${_seg(scope.connectionId)}$sep'
      '${_seg(scope.tenantKey)}',
    );
  }

  @override
  Future<int> sizeOf(CacheScope scope) async {
    final dir = await _dir(scope);
    if (!dir.existsSync()) return 0;
    var total = 0;
    await for (final e in dir.list(recursive: true)) {
      if (e is File) total += await e.length();
    }
    return total;
  }

  @override
  Future<void> clearScope(CacheScope scope) async {
    final dir = await _dir(scope);
    if (!dir.existsSync()) return;
    final keep = _seg(CacheStore.syncPrefix);
    await for (final e in dir.list()) {
      final name = e.path.split(Platform.pathSeparator).last;
      if (name.startsWith(keep)) continue;
      await e.delete(recursive: true);
    }
  }
}
