// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
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

  /// Replaces the text under [key] in [scope].
  Future<void> write(CacheScope scope, String key, String value);

  /// Forgets everything cached for [connectionId], in every tenant.
  Future<void> clearConnection(String connectionId);
}

/// A [CacheStore] in memory, for tests.
class MemoryCacheStore implements CacheStore {
  /// The entries, by connection, tenant and key.
  final entries = <String, Map<String, String>>{};

  static String _scope(CacheScope s) => '${s.connectionId}/${s.tenantKey}';

  @override
  Future<String?> read(CacheScope scope, String key) async =>
      entries[_scope(scope)]?[key];

  @override
  Future<void> write(CacheScope scope, String key, String value) async =>
      (entries[_scope(scope)] ??= {})[key] = value;

  @override
  Future<void> clearConnection(String connectionId) async =>
      entries.removeWhere((k, _) => k.startsWith('$connectionId/'));
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
    final file = await _file(scope, key);
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(value, flush: true);
    await tmp.rename(file.path);
  }

  @override
  Future<void> clearConnection(String connectionId) async {
    final base = await _base();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}${_seg(connectionId)}',
    );
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}
