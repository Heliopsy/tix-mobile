// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/design/accent_provider.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/session/session.dart';

part 'tenant_admin.g.dart';

/// The tenant the active context targets: its key when the connection
/// names one, else the id `whoami` reports, which is all a token knows.
@riverpod
Future<String> currentTenantRef(Ref ref) async {
  final key = await ref.watch(
    sessionControllerProvider.selectAsync((s) => s?.connection.tenantKey),
  );
  if (key != null && key.isNotEmpty) return key;
  final me = await ref.watch(adminRepositoryProvider).me();
  return me.tenantKey.isNotEmpty ? me.tenantKey : me.tenantId;
}

/// The settings of tenant [tenantRef]: the cached copy at once, then the
/// server's.
@riverpod
class TenantSettings extends _$TenantSettings {
  @override
  Future<Tenant> build(String tenantRef) {
    final repo = ref.watch(adminRepositoryProvider);
    return cachedFirst(
      ref: ref,
      cached: repo.cachedTenant(tenantRef),
      fresh: () => repo.tenant(tenantRef),
      onFresh: (t) => state = AsyncData(t),
    );
  }

  /// Sends [input], which names only what changes, and shows the answer.
  /// A new theme on the active tenant recolours the app at once.
  Future<void> save(UpdateTenantInput input) async {
    final saved = await ref
        .read(adminRepositoryProvider)
        .updateTenant(tenantRef, input);
    if (!ref.mounted) return;
    state = AsyncData(saved);
    if (input.theme != null) ref.invalidate(tenantAccentProvider);
  }

  /// Deletes the tenant.
  Future<void> delete() =>
      ref.read(adminRepositoryProvider).deleteTenant(tenantRef);
}

/// The hostnames mapped to the caller's tenant.
@riverpod
class TenantDomainList extends _$TenantDomainList {
  @override
  Future<List<Domain>> build() => ref.watch(adminRepositoryProvider).domains();

  /// Maps a hostname to the tenant.
  Future<void> add(AddDomainInput input) async {
    final added = await ref.read(adminRepositoryProvider).addDomain(input);
    if (!ref.mounted) return;
    state = AsyncData([...?state.value, added]);
  }

  /// Detaches [hostname].
  Future<void> remove(String hostname) async {
    await ref.read(adminRepositoryProvider).removeDomain(hostname);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final d in state.value ?? const <Domain>[])
        if (d.hostname != hostname) d,
    ]);
  }
}

/// What the server screen shows: the version, and the tenant's live
/// connections with the counts beside them.
@immutable
class ServerOverview {
  /// Holds [health] and [connections].
  const ServerOverview({required this.health, required this.connections});

  /// The version the server names.
  final HealthBody health;

  /// The live connections.
  final ConnectionList connections;
}

/// The server's version and the tenant's live connections.
@riverpod
class ServerStatus extends _$ServerStatus {
  @override
  Future<ServerOverview> build() async {
    final repo = ref.watch(adminRepositoryProvider);
    final (health, connections) = await (
      repo.health(),
      repo.connections(),
    ).wait;
    return ServerOverview(health: health, connections: connections);
  }

  /// Closes connection [id] and reads the list again.
  Future<void> end(String id) async {
    await ref.read(adminRepositoryProvider).endConnection(id);
    if (ref.mounted) ref.invalidateSelf();
  }
}
