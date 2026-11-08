// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/page.dart';

part 'global_admin.g.dart';

Paged<T> _paged<T>(Page<T> p) => Paged(items: p.items, cursor: p.nextCursor);

/// Every tenant of the installation, for a global admin; anybody else
/// sees their own.
@riverpod
class TenantDirectory extends _$TenantDirectory {
  @override
  Future<Paged<Tenant>> build() async =>
      _paged(await ref.watch(adminRepositoryProvider).tenants());

  /// Fetches the next page.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(adminRepositoryProvider).tenants(cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (t) => t.id,
  );

  /// Creates a tenant and returns it with any generated passwords, which
  /// the caller shows once and drops.
  Future<CreatedTenant> create(CreateTenantInput input) async {
    final created = await ref.read(adminRepositoryProvider).createTenant(input);
    if (ref.mounted) ref.invalidateSelf();
    return created;
  }

  /// Makes tenant [key] the active context, first adding the person to it
  /// as an admin when [join] is set, as a global admin may.
  Future<void> switchTo(String key, {required bool join}) async {
    final session = ref.read(sessionControllerProvider).value;
    if (session == null) return;
    final repo = ref.read(adminRepositoryProvider);
    final sessions = ref.read(sessionControllerProvider.notifier);
    if (join) {
      final me = await repo.me();
      await repo.addTenantMember(
        key,
        AddTenantMemberInput(email: me.email, role: Role.admin),
      );
    }
    await sessions.activate(
      ContextRef(connectionId: session.connection.id, tenantKey: key),
    );
  }

  /// Deletes tenant [key].
  Future<void> delete(String key) async {
    await ref.read(adminRepositoryProvider).deleteTenant(key);
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final t in current.items)
            if (t.key != key) t,
        ],
      ),
    );
  }
}

/// How the active connection can open a tenant.
enum TenantAccess {
  /// It is the active tenant already.
  current,

  /// The person belongs to it and the connection can switch.
  member,

  /// The connection can switch, once the person joins it.
  join,

  /// The connection is a token or a pinned sign-in, which cannot switch.
  pinned,
}

/// How the active connection can open tenant [key].
@riverpod
TenantAccess tenantAccess(Ref ref, String key) {
  final connection = ref.watch(
    sessionControllerProvider.select((s) => s.value?.connection),
  );
  if (connection == null) return TenantAccess.pinned;
  if (connection.tenantKey == key) return TenantAccess.current;
  if (!connection.switchable) return TenantAccess.pinned;
  return connection.memberships.any((m) => m.tenantKey == key)
      ? TenantAccess.member
      : TenantAccess.join;
}

/// The users of tenant [tenantRef] with their role there.
@riverpod
class TenantUsers extends _$TenantUsers {
  @override
  Future<Paged<TenantUser>> build(String tenantRef) async =>
      _paged(await ref.watch(adminRepositoryProvider).tenantUsers(tenantRef));

  /// Fetches the next page.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) => ref
        .read(adminRepositoryProvider)
        .tenantUsers(tenantRef, cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (u) => u.id,
  );

  AdminRepository get _repo => ref.read(adminRepositoryProvider);

  Future<void> _reload() async {
    if (ref.mounted) ref.invalidateSelf();
  }

  /// Creates a user in the tenant.
  Future<void> create(CreateUserInput input) async {
    await _repo.createTenantUser(tenantRef, input);
    await _reload();
  }

  /// Adds an existing account to the tenant.
  Future<void> addMember(AddTenantMemberInput input) async {
    await _repo.addTenantMember(tenantRef, input);
    await _reload();
  }

  /// Changes user [id].
  Future<void> edit(String id, UpdateUserInput input) async {
    await _repo.updateTenantUser(tenantRef, id, input);
    await _reload();
  }

  /// Deletes user [id] and their membership.
  Future<void> delete(String id) async {
    await _repo.deleteTenantUser(tenantRef, id);
    await _reload();
  }

  /// Returns user [id] to having no second factor. tix takes this for the
  /// caller's own tenant only.
  Future<void> clearSecondFactor(String id) async {
    await _repo.clearSecondFactor(id);
    await _reload();
  }
}

/// The hostnames mapped to tenant [tenantRef], each with whether it is
/// shared.
@riverpod
class TenantDomains extends _$TenantDomains {
  @override
  Future<List<Domain>> build(String tenantRef) =>
      ref.watch(adminRepositoryProvider).tenantDomains(tenantRef);

  /// Marks [hostname] shared or not.
  Future<void> setShared(String hostname, {required bool shared}) async {
    final saved = await ref
        .read(adminRepositoryProvider)
        .setDomainShared(hostname, shared: shared);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final d in state.value ?? const <Domain>[])
        if (d.hostname == hostname) saved else d,
    ]);
  }
}

/// Every global admin of the installation.
@riverpod
class GlobalAdmins extends _$GlobalAdmins {
  @override
  Future<List<User>> build() =>
      ref.watch(adminRepositoryProvider).globalAdmins();

  /// Makes [email] a global admin.
  Future<void> grant(String email) async {
    await ref.read(adminRepositoryProvider).grantGlobalAdmin(email);
    if (ref.mounted) ref.invalidateSelf();
  }

  /// Takes global admin away from [email].
  Future<void> revoke(String email) async {
    await ref.read(adminRepositoryProvider).revokeGlobalAdmin(email);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final u in state.value ?? const <User>[])
        if (u.email != email) u,
    ]);
  }
}

/// The log of the account [email], newest first.
@riverpod
class AccountLog extends _$AccountLog {
  @override
  Future<Paged<AccountLogEntry>> build(String email) async =>
      _paged(await ref.watch(adminRepositoryProvider).accountLog(email));

  /// Fetches the next page.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(adminRepositoryProvider).accountLog(email, cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (e) => e.seq,
  );
}
