// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/local/local_wake.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/models/membership.dart';
import 'package:tix_mobile/src/data/repositories/auth_repository.dart';
import 'package:tix_mobile/src/data/repositories/identity_repository.dart';
import 'package:tix_mobile/src/data/repositories/inbox_repository.dart';
import 'package:tix_mobile/src/data/repositories/instances_repository.dart';
import 'package:tix_mobile/src/data/repositories/projects_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';
import 'package:tix_mobile/src/data/repositories/view_prefs_repository.dart';
import 'package:tix_mobile/src/data/repositories/workflows_repository.dart';

part 'session.g.dart';

/// The saved instances and connections.
@Riverpod(keepAlive: true)
InstancesRepository instancesRepository(Ref ref) => InstancesRepository(
  ref.watch(keyValueStoreProvider),
  ref.watch(secretStoreProvider),
);

/// Server checks, sign-in and tenant switches.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(tixApiFactoryProvider));

/// The active context: an instance, a connection and its tenant.
@immutable
class Session {
  /// Signs in to [instance] at [baseUrl] as [connection] with [credential].
  const Session({
    required this.instance,
    required this.connection,
    required this.baseUrl,
    required this.credential,
    this.problem,
  });

  /// The instance.
  final Instance instance;

  /// The connection and the tenant it targets.
  final Connection connection;

  /// Where the API answers: the remote address, or the engine's loopback.
  final String baseUrl;

  /// What every request presents.
  final Credential credential;

  /// Why the instance cannot be reached at all, such as an engine that
  /// would not start. Lists show it; the switcher still works.
  final TixException? problem;

  /// The context this session is.
  ContextRef get ref =>
      ContextRef(connectionId: connection.id, tenantKey: connection.tenantKey);

  /// This session with [connection] in place of its own.
  Session withConnection(Connection connection) => Session(
    instance: instance,
    connection: connection,
    baseUrl: baseUrl,
    credential: credential,
    problem: problem,
  );
}

/// The active session: null until someone connects.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<Session?> build() async {
    final repo = ref.watch(instancesRepositoryProvider);
    final engines = ref.read(localEnginesProvider);
    await repo.migrate();
    final active = repo.active();
    final connection = active == null
        ? null
        : repo.connection(active.connectionId);
    final instance = connection == null
        ? null
        : repo.instance(connection.instanceId);
    final secret = connection == null ? null : await repo.secret(connection);
    if (connection == null ||
        instance == null ||
        secret == null ||
        secret.isEmpty) {
      return null;
    }
    final credential = switch (connection.kind) {
      ConnectionKind.token => BearerCredential(secret) as Credential,
      ConnectionKind.signIn => SessionCredential(secret),
    };
    if (instance.kind == InstanceKind.remote) {
      await engines.stopAll();
      return _refreshed(
        Session(
          instance: instance,
          connection: connection,
          baseUrl: instance.baseUrl,
          credential: credential,
        ),
      );
    }
    ref.read(localEngineLifecycleProvider);
    final moved = engines.moved.listen((id) {
      if (id == instance.id) ref.invalidateSelf();
    });
    final renewed = engines.renewed.listen(repo.updateInstance);
    ref
      ..onDispose(moved.cancel)
      ..onDispose(renewed.cancel);
    try {
      final handle = await engines.ensure(instance);
      return _refreshed(
        Session(
          instance: instance,
          connection: connection,
          baseUrl: handle.baseUrl,
          credential: credential,
        ),
      );
    } on TixException catch (e) {
      return Session(
        instance: instance,
        connection: connection,
        baseUrl: '',
        credential: credential,
        problem: e,
      );
    }
  }

  /// Starts a background `whoami` when the connection lacks its tenant or
  /// handle, or is a sign-in whose memberships may have changed.
  Session _refreshed(Session session) {
    final c = session.connection;
    if (c.tenantKey.isEmpty ||
        c.handle.isEmpty ||
        c.kind == ConnectionKind.signIn) {
      unawaited(_refresh(session));
    }
    return session;
  }

  Future<void> _refresh(Session session) async {
    if (!ref.mounted) return;
    final Actor me;
    try {
      me = await ref
          .read(authRepositoryProvider)
          .whoami(session.baseUrl, session.credential);
    } on TixException {
      // Best effort: offline, the lists report the failure themselves.
      return;
    }
    if (!ref.mounted) return;
    final repo = ref.read(instancesRepositoryProvider);
    final current = repo.connection(session.connection.id);
    if (current == null) return;
    final updated = _withIdentity(current, me);
    if (updated == current) return;
    await repo.update(updated);
    if (repo.active()?.connectionId == updated.id) {
      await repo.activate(updated.ref);
    }
    if (ref.mounted && state.value?.connection.id == updated.id) {
      state = AsyncData(state.value!.withConnection(updated));
    }
  }

  static Connection _withIdentity(Connection c, Actor me) => c.copyWith(
    handle: me.handle.isEmpty ? c.handle : me.handle,
    tenantKey: me.tenantKey.isEmpty ? c.tenantKey : me.tenantKey,
    tenantName: me.tenantName.isEmpty ? c.tenantName : me.tenantName,
    memberships: me.memberships.isEmpty
        ? c.memberships
        : [for (final m in me.memberships) Membership.fromAccount(m)],
  );

  /// Checks that [url] is a tix server that accepts [token], then saves a
  /// token connection on its instance and makes it active. With [instanceId]
  /// the connection is added to that saved instance. Throws a
  /// [TixException] otherwise.
  Future<void> connect({
    required String url,
    required String token,
    String name = '',
    String? instanceId,
  }) async {
    final repo = ref.read(instancesRepositoryProvider);
    final auth = ref.read(authRepositoryProvider);
    final existing = instanceId == null ? null : repo.instance(instanceId);
    final address = existing?.baseUrl ?? normalizeServerUrl(url);
    if (address == null) throw const TixException(TixErrorKind.badUrl);
    final secret = token.trim();
    if (secret.isEmpty) throw const TixException(TixErrorKind.tokenRequired);
    final baseUrl = await auth.checkServer(address);
    final me = await auth.whoami(baseUrl, BearerCredential(secret));
    final instance = existing ?? _remoteInstance(baseUrl, name);
    final saved = await repo.save(
      instance: instance,
      connection: _withIdentity(
        Connection(
          id: InstancesRepository.newId(),
          instanceId: instance.id,
          kind: ConnectionKind.token,
          label: name.trim(),
          createdAt: DateTime.now(),
        ),
        me,
      ),
      secret: secret,
    );
    await _activate(saved.ref);
  }

  /// Saves a sign-in to [baseUrl] holding [session] for [me], and makes it
  /// active. [replacing] keeps an existing connection's id.
  Future<void> saveSignIn({
    required String baseUrl,
    required String email,
    required String session,
    required Actor me,
    required bool pinned,
    String name = '',
    String? replacing,
  }) async {
    final repo = ref.read(instancesRepositoryProvider);
    final old = replacing == null ? null : repo.connection(replacing);
    final instance =
        (old == null ? null : repo.instance(old.instanceId)) ??
        _remoteInstance(baseUrl, name);
    final base =
        old ??
        Connection(
          id: InstancesRepository.newId(),
          instanceId: instance.id,
          kind: ConnectionKind.signIn,
          label: name.trim(),
          createdAt: DateTime.now(),
        );
    final saved = await repo.save(
      instance: instance,
      connection: _withIdentity(
        base.copyWith(email: email.trim(), pinned: pinned),
        me,
      ),
      secret: session,
    );
    await _activate(saved.ref);
  }

  /// Saves a token minted by the engine [handle] for [tenant] of the local
  /// database at [dbPath], used [inPlace] through [bookmark] or not, and
  /// makes it active.
  Future<void> saveLocal({
    required String dbPath,
    required LocalHandle handle,
    required TenantRef tenant,
    required String token,
    String name = '',
    bool inPlace = false,
    String bookmark = '',
    SyncFindings found = SyncFindings.none,
  }) async {
    final repo = ref.read(instancesRepositoryProvider);
    final existing = repo.localAt(dbPath);
    final instance = existing == null
        ? Instance(
            id: InstancesRepository.newId(),
            name: name.trim().isEmpty ? _fileName(dbPath) : name.trim(),
            kind: InstanceKind.local,
            dbPath: dbPath,
            inPlace: inPlace,
            bookmark: bookmark,
            createdAt: DateTime.now(),
          )
        : bookmark.isEmpty
        ? existing
        : existing.copyWith(bookmark: bookmark);
    ref.read(localEnginesProvider).adopt(instance, handle, found: found);
    final saved = await repo.save(
      instance: instance,
      connection: Connection(
        id: InstancesRepository.newId(),
        instanceId: instance.id,
        kind: ConnectionKind.token,
        tenantKey: tenant.key,
        tenantName: tenant.name,
        createdAt: DateTime.now(),
      ),
      secret: token,
    );
    await _activate(saved.ref);
  }

  /// Makes [target] the active context. A switchable sign-in moving to
  /// another tenant switches its session first, sending [code] when the
  /// target asks for one; without it a code challenge throws
  /// [TixErrorKind.codeRequired].
  Future<void> activate(ContextRef target, {String? code}) async {
    final repo = ref.read(instancesRepositoryProvider);
    final connection = repo.connection(target.connectionId);
    if (connection == null) return;
    if (!connection.switchable ||
        target.tenantKey.isEmpty ||
        target.tenantKey == connection.tenantKey) {
      await _activate(connection.ref);
      return;
    }
    final instance = repo.instance(connection.instanceId)!;
    final secret = await repo.secret(connection) ?? '';
    final auth = ref.read(authRepositoryProvider);
    final result = await auth.switchTenant(
      instance.baseUrl,
      session: secret,
      tenant: target.tenantKey,
      code: code,
    );
    final session = result.session;
    if (session == null) throw const TixException(TixErrorKind.codeRequired);
    await repo.writeSecret(connection, session.token);
    final me = await auth.whoami(
      instance.baseUrl,
      SessionCredential(session.token),
    );
    final updated = _withIdentity(connection, me);
    await repo.update(updated);
    await _activate(updated.ref);
  }

  /// Pins the sign-in [connectionId] to its tenant, or makes it switchable.
  Future<void> setPinned(String connectionId, {required bool pinned}) async {
    final repo = ref.read(instancesRepositoryProvider);
    final connection = repo.connection(connectionId);
    if (connection == null || connection.kind != ConnectionKind.signIn) return;
    await repo.update(connection.copyWith(pinned: pinned));
    ref.invalidateSelf();
    await future;
  }

  /// Swaps the API token of the remote connection [connectionId] for a
  /// rotated one and keeps only the new value. Throws when the server
  /// refuses; the old token then stays.
  Future<void> rotateToken(String connectionId) async {
    final repo = ref.read(instancesRepositoryProvider);
    final connection = repo.connection(connectionId);
    final instance = repo.instance(connection?.instanceId ?? '');
    if (connection == null ||
        instance == null ||
        connection.kind != ConnectionKind.token ||
        instance.kind != InstanceKind.remote) {
      return;
    }
    final secret = await repo.secret(connection);
    if (secret == null || secret.isEmpty) {
      throw const TixException(TixErrorKind.tokenRequired);
    }
    final issued = await ref
        .read(authRepositoryProvider)
        .rotateToken(instance.baseUrl, BearerCredential(secret));
    await repo.writeSecret(connection, issued.token);
    if (state.value?.connection.id == connectionId) {
      ref.invalidateSelf();
      await future;
    }
  }

  /// Forgets the active connection, falling back to another saved context
  /// if there is one.
  Future<void> signOut() async {
    final current = state.value;
    if (current == null) return;
    await removeConnection(current.connection.id);
  }

  /// Forgets the connection [id] and its secret, ending a sign-in's session.
  Future<void> removeConnection(String id) async {
    final repo = ref.read(instancesRepositoryProvider);
    final connection = repo.connection(id);
    if (connection == null) return;
    await _endSession(connection);
    await _forgetCache(id);
    final instanceId = connection.instanceId;
    await repo.removeConnection(id);
    if (repo.instance(instanceId) == null) {
      await ref.read(localEnginesProvider).stop(instanceId);
    }
    ref.invalidateSelf();
    await future;
  }

  /// Forgets the instance [id] with all its connections.
  Future<void> removeInstance(String id) async {
    final repo = ref.read(instancesRepositoryProvider);
    for (final c in repo.connectionsOf(id)) {
      await _endSession(c);
      await _forgetCache(c.id);
    }
    await ref.read(localEnginesProvider).stop(id);
    await repo.removeInstance(id);
    ref.invalidateSelf();
    await future;
  }

  /// Hands a copy of the local instance [id]'s database to the person. Its
  /// engine stops first, so the copy holds every write, and starts again
  /// afterwards if it was running. Whether the copy went anywhere.
  Future<bool> exportLocal(String id, {Rect? origin}) async {
    final instance = ref.read(instancesRepositoryProvider).instance(id);
    if (instance == null || instance.kind != InstanceKind.local) return false;
    final engines = ref.read(localEnginesProvider);
    final running = engines.running.contains(id);
    await engines.stop(id);
    try {
      return await ref
          .read(filePickingProvider)
          .exportDatabase(instance.dbPath, origin: origin);
    } finally {
      if (running) {
        ref.invalidateSelf();
        await future;
      }
    }
  }

  Future<void> _endSession(Connection connection) async {
    if (connection.kind != ConnectionKind.signIn) return;
    final repo = ref.read(instancesRepositoryProvider);
    final instance = repo.instance(connection.instanceId);
    final secret = await repo.secret(connection);
    if (instance == null || secret == null) return;
    try {
      await ref.read(authRepositoryProvider).logout(instance.baseUrl, secret);
    } on TixException {
      // Forgetting must not depend on the server: an expired session or an
      // unreachable host still lets the person remove the connection.
    }
  }

  /// Drops what was cached for [connectionId]: a forgotten connection
  /// leaves no copy of its server's data behind.
  Future<void> _forgetCache(String connectionId) async {
    try {
      await ref.read(cacheStoreProvider).clearConnection(connectionId);
    } on Exception catch (e, s) {
      log(
        'could not clear the cache of $connectionId',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _activate(ContextRef ref) async {
    await this.ref.read(instancesRepositoryProvider).activate(ref);
    this.ref.invalidateSelf();
    await future;
  }

  Instance _remoteInstance(String baseUrl, String name) =>
      ref.read(instancesRepositoryProvider).remoteAt(baseUrl) ??
      Instance(
        id: InstancesRepository.newId(),
        name: name.trim().isEmpty ? Uri.parse(baseUrl).host : name.trim(),
        kind: InstanceKind.remote,
        baseUrl: baseUrl,
        createdAt: DateTime.now(),
      );

  static String _fileName(String path) {
    final name = path.split(RegExp(r'[/\\]')).last;
    return name.endsWith('.db') ? name.substring(0, name.length - 3) : name;
  }
}

/// One place the switcher can go: a connection in one tenant.
@immutable
class ContextEntry {
  /// Creates an entry.
  const ContextEntry({
    required this.instance,
    required this.connection,
    required this.tenantKey,
    required this.tenantName,
    this.elsewhere = '',
  });

  /// The instance.
  final Instance instance;

  /// The connection.
  final Connection connection;

  /// The tenant.
  final String tenantKey;

  /// The tenant's name, its key when unknown.
  final String tenantName;

  /// The tenant's own address when it is served there and not here.
  final String elsewhere;

  /// The context this entry opens.
  ContextRef get ref =>
      ContextRef(connectionId: connection.id, tenantKey: tenantKey);
}

/// An instance with its connections and the contexts they reach.
@immutable
class InstanceGroup {
  /// Creates a group.
  const InstanceGroup({
    required this.instance,
    required this.connections,
    required this.entries,
  });

  /// The instance.
  final Instance instance;

  /// Its connections.
  final List<Connection> connections;

  /// The contexts its connections reach.
  final List<ContextEntry> entries;
}

/// Everything the switcher and the instances screen draw.
@immutable
class ContextDirectory {
  /// Creates a directory.
  const ContextDirectory({required this.recent, required this.groups});

  /// Recent contexts, newest first.
  final List<ContextEntry> recent;

  /// Every instance, in the order they were added.
  final List<InstanceGroup> groups;
}

/// The contexts each connection reaches: one for a pinned connection, one
/// per membership for a switchable one.
List<ContextEntry> entriesOf(Instance instance, Connection connection) {
  if (!connection.switchable || connection.memberships.isEmpty) {
    return [
      ContextEntry(
        instance: instance,
        connection: connection,
        tenantKey: connection.tenantKey,
        tenantName: connection.tenantLabel,
      ),
    ];
  }
  return [
    for (final Membership m in connection.memberships)
      ContextEntry(
        instance: instance,
        connection: connection,
        tenantKey: m.tenantKey,
        tenantName: m.tenantName.isEmpty ? m.tenantKey : m.tenantName,
        elsewhere: m.servedElsewhere(instance.host) ? m.host : '',
      ),
  ];
}

/// The saved contexts, refreshed whenever the session changes.
@riverpod
ContextDirectory contextDirectory(Ref ref) {
  ref.watch(sessionControllerProvider);
  final repo = ref.watch(instancesRepositoryProvider);
  final connections = repo.connections();
  final groups = [
    for (final i in repo.instances())
      () {
        final own = [
          for (final c in connections)
            if (c.instanceId == i.id) c,
        ];
        return InstanceGroup(
          instance: i,
          connections: own,
          entries: [for (final c in own) ...entriesOf(i, c)],
        );
      }(),
  ];
  final all = [for (final g in groups) ...g.entries];
  final recent = <ContextEntry>[];
  for (final r in repo.recents()) {
    for (final e in all) {
      final same =
          e.connection.id == r.connectionId &&
          (!e.connection.switchable || e.tenantKey == r.tenantKey);
      if (same && !recent.contains(e) && e.elsewhere.isEmpty) recent.add(e);
    }
  }
  return ContextDirectory(recent: recent, groups: groups);
}

/// The API client for the active session.
///
/// A local instance's client wakes its engine before every request, so an
/// engine stopped while idle comes back on its own. Kept alive so live
/// updates, which outlive every screen, share it.
@Riverpod(keepAlive: true)
TixApi sessionApi(Ref ref) {
  final target = ref.watch(
    sessionControllerProvider.select(
      (s) => (
        s.value?.baseUrl,
        s.value?.credential,
        s.value?.problem,
        s.value?.instance.kind == InstanceKind.local,
      ),
    ),
  );
  final (baseUrl, credential, problem, local) = target;
  if (problem != null) throw problem;
  if (baseUrl == null) throw StateError('no active session');
  final api = ref.watch(tixApiFactoryProvider)(baseUrl, credential);
  final instance = ref.read(sessionControllerProvider).value?.instance;
  if (local && instance != null) {
    final engines = ref.watch(localEnginesProvider);
    api.transport.dio.interceptors.insert(
      0,
      LocalWakeInterceptor(
        wake: () async => (await engines.wake(instance)).baseUrl,
        done: () => engines.done(instance.id),
      ),
    );
  }
  return api;
}

/// The cache scope of the active context, null with no session.
///
/// A connection reaches one tenant unless it is a switchable sign-in, so
/// only that kind names its tenant in the scope. The rest leave it empty,
/// which keeps the scope stable while a background `whoami` fills in the
/// tenant's key.
@Riverpod(keepAlive: true)
CacheScope? activeCacheScope(Ref ref) => ref.watch(
  sessionControllerProvider.select((s) {
    final c = s.value?.connection;
    if (c == null) return null;
    return CacheScope(c.id, c.switchable ? c.tenantKey : '');
  }),
);

/// The response cache of the active context. Reads are best effort, so a
/// cache that cannot be opened behaves as an empty one.
@riverpod
ResponseCache responseCache(Ref ref) {
  final scope = ref.watch(activeCacheScopeProvider);
  if (scope == null) throw StateError('no active session');
  final cache = ResponseCache(
    ref.watch(cacheStoreProvider),
    scope,
    now: ref.watch(clockProvider),
  );
  ref.onDispose(cache.dispose);
  return cache;
}

/// Projects and tasks for the active session.
@riverpod
TasksRepository tasksRepository(Ref ref) => TasksRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// What the task screen reads and changes, for the active session.
@riverpod
TaskDetailRepository taskDetailRepository(Ref ref) => TaskDetailRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// Listings, quick and bulk actions and workflows for the active session.
@riverpod
TaskListRepository taskListRepository(Ref ref) => TaskListRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// View arrangements and saved filters for the active session.
@riverpod
ViewPrefsRepository viewPrefsRepository(Ref ref) => ViewPrefsRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// The inbox, personal channels and the summary for the active session.
@riverpod
InboxRepository inboxRepository(Ref ref) => InboxRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// Who the active credential is, for the active session.
@riverpod
IdentityRepository identityRepository(Ref ref) => IdentityRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// Project administration and custom fields, for the active session.
@riverpod
ProjectsRepository projectsRepository(Ref ref) => ProjectsRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// The tenant's workflows, for the active session.
@riverpod
WorkflowsRepository workflowsRepository(Ref ref) => WorkflowsRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);
