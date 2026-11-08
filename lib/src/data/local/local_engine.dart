// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';

/// A running embedded engine: its handle and the loopback address it serves.
@immutable
class LocalHandle {
  /// Creates a handle.
  const LocalHandle({required this.id, required this.baseUrl});

  /// The engine's identifier for this run.
  final String id;

  /// Where the engine serves the HTTP API, `http://127.0.0.1:PORT`.
  final String baseUrl;

  @override
  bool operator ==(Object other) =>
      other is LocalHandle && other.id == id && other.baseUrl == baseUrl;

  @override
  int get hashCode => Object.hash(id, baseUrl);
}

/// A tenant in a local database.
@immutable
class TenantRef {
  /// Creates a reference.
  const TenantRef({required this.key, required this.name});

  /// The tenant's key.
  final String key;

  /// The tenant's display name.
  final String name;

  @override
  bool operator ==(Object other) =>
      other is TenantRef && other.key == key && other.name == name;

  @override
  int get hashCode => Object.hash(key, name);
}

/// tix embedded in the app, serving a database file over loopback HTTP. The
/// FFI library implements this; everything else talks to it over HTTP.
abstract interface class LocalTixEngine {
  /// Opens [dbPath], creating it when missing and [initIfMissing], and serves
  /// it.
  Future<LocalHandle> start({
    required String dbPath,
    bool initIfMissing = true,
  });

  /// Stops serving [h].
  Future<void> stop(LocalHandle h);

  /// The tenants in the database [h] serves.
  Future<List<TenantRef>> tenants(LocalHandle h);

  /// Creates the tenant [key] named [name].
  Future<TenantRef> createTenant(
    LocalHandle h, {
    required String key,
    required String name,
  });

  /// Mints an API token named [name] in [tenant].
  Future<String> token(
    LocalHandle h, {
    required String tenant,
    required String name,
    List<String>? scopes,
  });

  /// The engine's tix version.
  Future<String> version();
}

/// The engine of a build that has none yet: every call says so.
class UnavailableLocalTixEngine implements LocalTixEngine {
  /// Creates the stub.
  const UnavailableLocalTixEngine();

  static Never _unavailable() =>
      throw const TixException(TixErrorKind.engineUnavailable);

  @override
  Future<LocalHandle> start({
    required String dbPath,
    bool initIfMissing = true,
  }) async => _unavailable();

  @override
  Future<void> stop(LocalHandle h) async {}

  @override
  Future<List<TenantRef>> tenants(LocalHandle h) async => _unavailable();

  @override
  Future<TenantRef> createTenant(
    LocalHandle h, {
    required String key,
    required String name,
  }) async => _unavailable();

  @override
  Future<String> token(
    LocalHandle h, {
    required String tenant,
    required String name,
    List<String>? scopes,
  }) async => _unavailable();

  @override
  Future<String> version() async => _unavailable();
}

/// An engine that keeps databases in memory and serves nothing, for tests.
class InMemoryLocalTixEngine implements LocalTixEngine {
  /// Creates an engine with no databases; [existing] are paths that already
  /// hold a database with the default tenant.
  InMemoryLocalTixEngine({Iterable<String> existing = const []}) {
    for (final path in existing) {
      _databases[path] = [const TenantRef(key: 'default', name: 'Default')];
    }
  }

  final _databases = <String, List<TenantRef>>{};
  final _running = <String, String>{};
  var _next = 0;

  /// Every token minted, by tenant key.
  final minted = <String, List<String>>{};

  /// Paths started, in order.
  final started = <String>[];

  /// Handles stopped, in order.
  final stopped = <LocalHandle>[];

  /// The handles running now.
  Iterable<String> get running => _running.keys;

  /// Whether a database exists at [path].
  bool exists(String path) => _databases.containsKey(path);

  @override
  Future<LocalHandle> start({
    required String dbPath,
    bool initIfMissing = true,
  }) async {
    if (!_databases.containsKey(dbPath)) {
      if (!initIfMissing) {
        throw TixException(TixErrorKind.notFound, message: dbPath);
      }
      _databases[dbPath] = [const TenantRef(key: 'default', name: 'Default')];
    }
    final n = _next++;
    final h = LocalHandle(id: 'h$n', baseUrl: 'http://127.0.0.1:${49152 + n}');
    _running[h.id] = dbPath;
    started.add(dbPath);
    return h;
  }

  @override
  Future<void> stop(LocalHandle h) async {
    if (_running.remove(h.id) != null) stopped.add(h);
  }

  List<TenantRef> _db(LocalHandle h) {
    final path = _running[h.id];
    if (path == null) {
      throw const TixException(TixErrorKind.engineUnavailable);
    }
    return _databases[path]!;
  }

  @override
  Future<List<TenantRef>> tenants(LocalHandle h) async => List.of(_db(h));

  @override
  Future<TenantRef> createTenant(
    LocalHandle h, {
    required String key,
    required String name,
  }) async {
    final db = _db(h);
    if (db.any((t) => t.key == key)) {
      throw TixException(TixErrorKind.conflict, message: key);
    }
    final t = TenantRef(key: key, name: name.isEmpty ? key : name);
    db.add(t);
    return t;
  }

  @override
  Future<String> token(
    LocalHandle h, {
    required String tenant,
    required String name,
    List<String>? scopes,
  }) async {
    if (!_db(h).any((t) => t.key == tenant)) {
      throw TixException(TixErrorKind.notFound, message: tenant);
    }
    final list = minted.putIfAbsent(tenant, () => []);
    final secret = 'local-$tenant-${list.length + 1}';
    list.add(secret);
    return secret;
  }

  @override
  Future<String> version() async => 'in-memory';
}
