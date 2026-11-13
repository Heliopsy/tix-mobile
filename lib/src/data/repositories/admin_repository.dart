// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/tenant_icon_shim.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/tenant_icon.dart';

export 'package:tix_mobile/src/data/models/admin.dart';
export 'package:tix_mobile/src/data/models/tenant_icon.dart';

/// Tenant and server administration: the tenant's settings and domains,
/// the server's live connections, and for a global admin every tenant,
/// its users, the global admins and any account's log.
///
/// Only the tenant's settings are cached. Nothing here that carries a
/// generated password ([CreatedTenant]) is ever kept.
class AdminRepository {
  /// Reads and writes through [_api], keeping copies in [_cache].
  AdminRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  /// Who the credential is (`identity.whoami`).
  Future<Actor> me() => _api.identity.whoami();

  /// The tenant [ref], by key or id (`tenant.show`).
  Future<Tenant> tenant(String ref) => _cache.remember(
    'admin/tenant/$ref',
    _api.tenant.show(ref),
    (t) => t.toJson(),
  );

  /// The tenant [ref] as last read.
  Future<Tenant?> cachedTenant(String ref) => _cache.peek(
    'admin/tenant/$ref',
    (j) => Tenant.fromJson(j! as Map<String, dynamic>),
  );

  /// Changes the tenant [ref] (`tenant.update`).
  Future<Tenant> updateTenant(String ref, UpdateTenantInput input) =>
      _api.tenant.update(ref, input);

  /// The icon of tenant [ref].
  Future<TenantIcon> tenantIcon(String ref) => _api.tenantIconOf(ref);

  /// Gives tenant [ref] the icon [change] names, and returns the icon it now
  /// has.
  Future<TenantIcon> setTenantIcon(String ref, TenantIconChange change) =>
      _api.setTenantIcon(ref, change);

  /// The uploaded icon image of tenant [ref].
  Future<Uint8List> tenantIconImage(String ref) => _api.tenantIconImage(ref);

  /// The server's session settings beside the active tenant's
  /// (`session.policy`).
  Future<SessionPolicy> sessionPolicy() => _api.session.policy();

  /// The server's artifact limits beside the active tenant's
  /// (`artifact.limits`).
  Future<ArtifactLimits> artifactLimits() => _api.artifact.limits();

  /// Deletes the tenant [ref] (`tenant.delete`).
  Future<void> deleteTenant(String ref) => _api.tenant.delete(ref);

  /// One page of the tenants the caller can see (`tenant.list`).
  Future<Page<Tenant>> tenants({String? cursor}) =>
      _api.tenant.list(cursor: cursor, sort: 'key', direction: 'asc');

  /// Creates a tenant with its first admins (`tenant.create`). The answer
  /// carries generated passwords once; it is never cached.
  Future<CreatedTenant> createTenant(CreateTenantInput input) =>
      _api.tenant.create(input);

  /// One page of the users of tenant [ref] (`tenant.user.list`).
  Future<Page<TenantUser>> tenantUsers(String ref, {String? cursor}) =>
      _api.tenant.userList(ref, cursor: cursor);

  /// Creates a user in tenant [ref] (`tenant.user.create`).
  Future<User> createTenantUser(String ref, CreateUserInput input) =>
      _api.tenant.userCreate(ref, input);

  /// Adds an existing account to tenant [ref] (`tenant.member.add`).
  Future<User> addTenantMember(String ref, AddTenantMemberInput input) =>
      _api.tenant.memberAdd(ref, input);

  /// Changes user [id] of tenant [ref] (`tenant.user.update`).
  Future<User> updateTenantUser(String ref, String id, UpdateUserInput input) =>
      _api.tenant.userUpdate(ref, id, input);

  /// Deletes user [id] of tenant [ref] (`tenant.user.delete`).
  Future<void> deleteTenantUser(String ref, String id) =>
      _api.tenant.userDelete(ref, id);

  /// Clears the second factor of user [id] of the caller's tenant
  /// (`totp.clear`).
  Future<void> clearSecondFactor(String id) => _api.totp.clear(id);

  /// The hostnames mapped to tenant [ref] (`tenant.domain.list`).
  Future<List<Domain>> tenantDomains(String ref) =>
      _api.tenant.domainList(ref).then((p) => p.items);

  /// Marks [hostname] shared or not (`domain.update`).
  Future<Domain> setDomainShared(String hostname, {required bool shared}) =>
      _api.domain.update(hostname, UpdateDomainInput(shared: shared));

  /// The hostnames mapped to the caller's tenant (`domain.list`).
  Future<List<Domain>> domains() => _api.domain.list().then((p) => p.items);

  /// Maps a hostname to the caller's tenant (`domain.add`).
  Future<Domain> addDomain(AddDomainInput input) => _api.domain.add(input);

  /// Detaches [hostname] from the caller's tenant (`domain.remove`).
  Future<void> removeDomain(String hostname) => _api.domain.remove(hostname);

  /// Every global admin (`global_admin.list`).
  Future<List<User>> globalAdmins() =>
      _api.globalAdmin.list().then((p) => p.items);

  /// Makes [email] a global admin (`global_admin.grant`).
  Future<User> grantGlobalAdmin(String email) =>
      _api.globalAdmin.grant(GlobalAdminInput(email: email));

  /// Takes global admin away from [email] (`global_admin.revoke`).
  Future<void> revokeGlobalAdmin(String email) =>
      _api.globalAdmin.revoke(email);

  /// One page of the log of the account [email], newest first
  /// (`account.log.any`).
  Future<Page<AccountLogEntry>> accountLog(String email, {String? cursor}) =>
      _api.account.logAny(email, cursor: cursor, direction: 'desc');

  /// The server's version (`server.health`).
  Future<HealthBody> health() => _api.server.health();

  /// The caller's tenant's live connections and the counts beside them
  /// (`connection.list`).
  Future<ConnectionList> connections() => _api.connection.list();

  /// Closes the live connection [id] (`connection.end`).
  Future<void> endConnection(String id) => _api.connection.end(id);
}
