// SPDX-License-Identifier: AGPL-3.0-or-later

/// Tenant icons, by hand, until `tix.lock` pins the tix release that has
/// them. The bump replaces each call here with the generated one:
///
/// - [TenantIconShim.whoamiWithTenantIcons]: `identity.whoami()`, the icons
///   then read from `Actor.tenantIcon*` and `AccountMembership.icon*`.
/// - [TenantIconShim.tenantIconOf]: the icon fields of `tenant.show`.
/// - [TenantIconShim.setTenantIcon]: `tenant.update` with the icon fields of
///   `UpdateTenantInput`.
/// - [TenantIconShim.tenantIconImage]: `tenant.icon`.
library;

import 'dart:typed_data';

import 'package:tix_mobile/src/data/api/gen/client.gen.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Actor;
import 'package:tix_mobile/src/data/models/tenant_icon.dart';

/// The tenant icon calls the vendored spec does not have yet.
extension TenantIconShim on TixClient {
  /// `whoami`, with the icon of the caller's tenant and of each tenant it
  /// belongs to by tenant key.
  Future<(Actor, TenantIcon, Map<String, TenantIcon>)>
  whoamiWithTenantIcons() async {
    final raw = await transport.json('GET', '/api/v1/whoami');
    final memberships = raw['memberships'] as List<dynamic>? ?? const [];
    return (
      Actor.fromJson(raw),
      TenantIcon.ofActor(raw),
      {
        for (final m in memberships.whereType<Map<String, dynamic>>())
          if (m['tenant_key'] case final String key when key.isNotEmpty)
            key: TenantIcon.fromJson(m),
      },
    );
  }

  /// The icon of tenant [ref].
  Future<TenantIcon> tenantIconOf(String ref) async => TenantIcon.fromJson(
    await transport.json('GET', '/api/v1/tenants/${transport.segment(ref)}'),
  );

  /// Sends [change] alone to tenant [ref] and returns the icon it now has.
  Future<TenantIcon> setTenantIcon(String ref, TenantIconChange change) async =>
      TenantIcon.fromJson(
        await transport.json(
          'PATCH',
          '/api/v1/tenants/${transport.segment(ref)}',
          body: change.toJson(),
        ),
      );

  /// The uploaded icon image of tenant [ref].
  Future<Uint8List> tenantIconImage(String ref) =>
      transport.bytes('GET', '/api/v1/tenants/${transport.segment(ref)}/icon');
}
