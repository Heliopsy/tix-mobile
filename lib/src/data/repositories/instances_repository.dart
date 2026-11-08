// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/models/server_context.dart';

/// What the 0.1 saved servers become.
typedef Migrated = ({
  List<Instance> instances,
  List<Connection> connections,
  ContextRef? active,
});

/// Turns the 0.1 `contexts` list and active id into instances and token
/// connections. Each connection keeps its context's id, so its token stays
/// under the same secure storage key.
Migrated migrateServers(String? contextsJson, String? activeId, DateTime now) {
  if (contextsJson == null) {
    return (instances: const [], connections: const [], active: null);
  }
  final old = [
    for (final e in jsonDecode(contextsJson) as List<dynamic>)
      ServerContext.fromJson(e as Map<String, dynamic>),
  ];
  final byUrl = <String, Instance>{};
  final connections = <Connection>[];
  for (final c in old) {
    final instance = byUrl.putIfAbsent(
      c.baseUrl,
      () => Instance(
        id: 'i-${c.id}',
        name: c.name,
        kind: InstanceKind.remote,
        baseUrl: c.baseUrl,
        createdAt: now,
      ),
    );
    connections.add(
      Connection(
        id: c.id,
        instanceId: instance.id,
        kind: ConnectionKind.token,
        label: c.name,
        handle: c.handle,
        createdAt: now,
      ),
    );
  }
  final active = connections.any((c) => c.id == activeId)
      ? ContextRef(connectionId: activeId!)
      : null;
  return (
    instances: byUrl.values.toList(),
    connections: connections,
    active: active,
  );
}

/// Instances and connections in settings, their secrets in secure storage.
class InstancesRepository {
  /// Keeps lists in [_settings] and secrets in [_secrets].
  InstancesRepository(this._settings, this._secrets, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _instancesKey = 'instances';
  static const _connectionsKey = 'connections';
  static const _activeKey = 'context.active';
  static const _recentKey = 'context.recent';
  static const _versionKey = 'storage.version';
  static const _legacyListKey = 'contexts';
  static const _legacyActiveKey = 'contexts.active';

  /// How many recent contexts are remembered.
  static const recentLimit = 8;

  final KeyValueStore _settings;
  final SecretStore _secrets;
  final DateTime Function() _now;
  static int _counter = 0;

  /// A new identifier, unique on this device.
  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${(_counter++).toRadixString(36)}';

  /// Moves 0.1's saved servers over, once. The old keys are left in place so
  /// an older build still opens.
  Future<void> migrate() async {
    if (_settings.read(_versionKey) != null) return;
    if (_settings.read(_instancesKey) == null) {
      final m = migrateServers(
        _settings.read(_legacyListKey),
        _settings.read(_legacyActiveKey),
        _now(),
      );
      await _writeInstances(m.instances);
      await _writeConnections(m.connections);
      final active = m.active;
      if (active != null) {
        await _settings.write(_activeKey, jsonEncode(active.toJson()));
        await _writeRecents([active]);
      }
    }
    await _settings.write(_versionKey, '2');
  }

  /// Every instance, in the order they were added.
  List<Instance> instances() => [
    for (final e in _readList(_instancesKey))
      Instance.fromJson(e as Map<String, dynamic>),
  ];

  /// Every connection, in the order they were added.
  List<Connection> connections() => [
    for (final e in _readList(_connectionsKey))
      Connection.fromJson(e as Map<String, dynamic>),
  ];

  /// The connections of the instance [instanceId].
  List<Connection> connectionsOf(String instanceId) => [
    for (final c in connections())
      if (c.instanceId == instanceId) c,
  ];

  /// The instance [id], null when there is none.
  Instance? instance(String id) => _find(instances(), (i) => i.id == id);

  /// The connection [id], null when there is none.
  Connection? connection(String id) => _find(connections(), (c) => c.id == id);

  /// The remote instance at [baseUrl], null when none is saved.
  Instance? remoteAt(String baseUrl) => _find(
    instances(),
    (i) => i.kind == InstanceKind.remote && i.baseUrl == baseUrl,
  );

  /// The local instance on [dbPath], null when none is saved.
  Instance? localAt(String dbPath) => _find(
    instances(),
    (i) => i.kind == InstanceKind.local && i.dbPath == dbPath,
  );

  /// The active context, null when none is saved or it no longer exists.
  ContextRef? active() {
    final raw = _settings.read(_activeKey);
    if (raw == null) return null;
    final ref = ContextRef.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return connection(ref.connectionId) == null ? null : ref;
  }

  /// Recent contexts, newest first, of connections that still exist.
  List<ContextRef> recents() {
    final ids = {for (final c in connections()) c.id};
    return [
      for (final e in _readList(_recentKey))
        if (ids.contains((e as Map<String, dynamic>)['connection_id']))
          ContextRef.fromJson(e),
    ];
  }

  /// The secret of [connection]: its API token or its session.
  Future<String?> secret(Connection connection) =>
      _secrets.read(_secretKey(connection));

  /// Replaces the secret of [connection].
  Future<void> writeSecret(Connection connection, String secret) =>
      _secrets.write(_secretKey(connection), secret);

  /// Saves [connection] on [instance] with [secret], replacing a connection
  /// of the same kind, handle, email and tenant there, and returns what was
  /// saved. The instance is added or updated too.
  Future<Connection> save({
    required Instance instance,
    required Connection connection,
    required String secret,
  }) async {
    final same = _find(
      connections(),
      (c) =>
          c.id != connection.id &&
          c.instanceId == instance.id &&
          c.kind == connection.kind &&
          c.handle == connection.handle &&
          c.email == connection.email &&
          c.tenantKey == connection.tenantKey,
    );
    final saved = same == null
        ? connection.copyWith(instanceId: instance.id)
        : connection.copyWith(
            id: same.id,
            instanceId: instance.id,
            createdAt: same.createdAt,
          );
    await writeSecret(saved, secret);
    await _upsertInstance(instance);
    await _upsertConnection(saved);
    return saved;
  }

  /// Replaces the stored record of [connection], keeping its secret.
  Future<void> update(Connection connection) => _upsertConnection(connection);

  /// Makes [ref] the active context and the most recent one.
  Future<void> activate(ContextRef ref) async {
    final now = _now();
    final conn = connection(ref.connectionId);
    if (conn == null) return;
    await _settings.write(_activeKey, jsonEncode(ref.toJson()));
    await _writeRecents([
      ref,
      for (final r in recents())
        if (r != ref) r,
    ]);
    await _upsertConnection(conn.copyWith(lastUsedAt: now));
    final instance = this.instance(conn.instanceId);
    if (instance != null) {
      await _upsertInstance(instance.copyWith(lastUsedAt: now));
    }
  }

  /// Forgets the connection [id] and its secret, and its instance when that
  /// was the last connection. When it was active, the most recent remaining
  /// context, else the first connection, becomes active.
  Future<void> removeConnection(String id) async {
    final conn = connection(id);
    if (conn == null) return;
    await _secrets.delete(_secretKey(conn));
    await _writeConnections([
      for (final c in connections())
        if (c.id != id) c,
    ]);
    if (connectionsOf(conn.instanceId).isEmpty) {
      await _writeInstances([
        for (final i in instances())
          if (i.id != conn.instanceId) i,
      ]);
    }
    await _writeRecents(recents());
    await _settleActive();
  }

  /// Forgets the instance [id] with every connection and secret it holds.
  Future<void> removeInstance(String id) async {
    for (final c in connectionsOf(id)) {
      await removeConnection(c.id);
    }
    await _writeInstances([
      for (final i in instances())
        if (i.id != id) i,
    ]);
  }

  Future<void> _settleActive() async {
    if (active() != null) return;
    final next = recents().firstOrNull;
    final first = connections().firstOrNull;
    if (next != null) {
      await _settings.write(_activeKey, jsonEncode(next.toJson()));
    } else if (first != null) {
      await _settings.write(
        _activeKey,
        jsonEncode(
          ContextRef(
            connectionId: first.id,
            tenantKey: first.tenantKey,
          ).toJson(),
        ),
      );
    } else {
      await _settings.delete(_activeKey);
    }
  }

  static String _secretKey(Connection c) => switch (c.kind) {
    ConnectionKind.token => 'token.${c.id}',
    ConnectionKind.signIn => 'session.${c.id}',
  };

  static T? _find<T>(List<T> list, bool Function(T) test) {
    for (final e in list) {
      if (test(e)) return e;
    }
    return null;
  }

  List<dynamic> _readList(String key) {
    final raw = _settings.read(key);
    return raw == null ? const [] : jsonDecode(raw) as List<dynamic>;
  }

  /// Replaces the stored record of [instance], or adds it.
  Future<void> _upsertInstance(Instance instance) {
    final list = instances();
    final at = list.indexWhere((i) => i.id == instance.id);
    if (at < 0) {
      list.add(instance);
    } else {
      list[at] = instance;
    }
    return _writeInstances(list);
  }

  Future<void> _upsertConnection(Connection connection) {
    final list = connections();
    final at = list.indexWhere((c) => c.id == connection.id);
    if (at < 0) {
      list.add(connection);
    } else {
      list[at] = connection;
    }
    return _writeConnections(list);
  }

  Future<void> _writeInstances(List<Instance> list) => _settings.write(
    _instancesKey,
    jsonEncode([for (final i in list) i.toJson()]),
  );

  Future<void> _writeConnections(List<Connection> list) => _settings.write(
    _connectionsKey,
    jsonEncode([for (final c in list) c.toJson()]),
  );

  Future<void> _writeRecents(List<ContextRef> list) => _settings.write(
    _recentKey,
    jsonEncode([for (final r in list.take(recentLimit)) r.toJson()]),
  );
}
