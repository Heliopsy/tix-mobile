// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/membership.dart';
import 'package:tix_mobile/src/data/repositories/admin_repository.dart';
import 'package:tix_mobile/src/data/repositories/auth_repository.dart';

import '../../helpers/fake_admin.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  const base = 'https://tix.example';

  setUp(() {
    server = FakeTix()
      ..tenants['acme'] = (name: 'Acme', host: '')
      ..accounts['ana@example.com'] = FakeAccount(
        password: 'pw',
        tenants: ['default', 'acme'],
      );
  });

  group('whoami', () {
    test('carries the icon of the tenant and of each membership', () async {
      server.tenantIcons
        ..['default'] = {'icon': '🚀'}
        ..['acme'] = {'icon_name': 'rocket'};
      final s = server.startSession('ana@example.com', 'default');
      final me = await AuthRepository(server.factory)
          .whoami(base, SessionCredential(s));
      expect(TenantIcon.ofActor(me), const TenantIcon(text: '🚀'));
      expect(
        {
          for (final m in me.memberships)
            m.tenantKey: Membership.fromAccount(m).icon,
        },
        {
          'default': const TenantIcon(text: '🚀'),
          'acme': const TenantIcon(name: 'rocket'),
        },
      );
    });

    test('a token takes its icon from GET /tenants/{id}', () async {
      server.tenantIcons['default'] = {'icon_name': 'bolt'};
      final me = await AuthRepository(server.factory)
          .whoami(base, const BearerCredential('tok'));
      expect(me.tenantKey, 'default');
      expect(TenantIcon.ofActor(me), const TenantIcon(name: 'bolt'));
    });

    test('a tix without tenant icons reports none', () async {
      final s = server.startSession('ana@example.com', 'default');
      final me = await AuthRepository(server.factory)
          .whoami(base, SessionCredential(s));
      expect(TenantIcon.ofActor(me).isEmpty, isTrue);
      expect(
        me.memberships.map((m) => Membership.fromAccount(m).icon.isEmpty),
        everyElement(isTrue),
      );
    });
  });

  group('tenant settings', () {
    late AdminRepository repo;

    setUp(() {
      FakeAdmin.on(server);
      repo = AdminRepository(
        server.factory(base, const BearerCredential('tok')),
        ResponseCache(MemoryCacheStore(), const CacheScope('c1', '')),
      );
    });

    test('a tenant carries its icon', () async {
      server.tenantIcons['acme'] = {'icon_image': 'abc'};
      expect(
        TenantIcon.ofTenant(await repo.tenant('acme')),
        const TenantIcon(image: 'abc'),
      );
    });

    test('each icon change sends only its own field', () async {
      final t = await repo.updateTenant(
        'acme',
        const UpdateTenantInput(iconName: 'bolt'),
      );
      expect(server.requests.last.body, {'icon_name': 'bolt'});
      expect(TenantIcon.ofTenant(t), const TenantIcon(name: 'bolt'));
      final cleared = await repo.updateTenant(
        'acme',
        const UpdateTenantInput(icon: ''),
      );
      expect(server.requests.last.body, {'icon': ''});
      expect(TenantIcon.ofTenant(cleared).isEmpty, isTrue);
      final uploaded = await repo.updateTenant(
        'acme',
        const UpdateTenantInput(
          iconFile: ProjectIconFile(contentType: 'image/png', data: 'AQID'),
        ),
      );
      expect(server.requests.last.body, {
        'icon_file': {'content_type': 'image/png', 'data': 'AQID'},
      });
      expect(uploaded.iconImage, isNotEmpty);
    });

    test('reads the uploaded image (tenant.icon)', () async {
      await repo.updateTenant(
        'default',
        const UpdateTenantInput(
          iconFile: ProjectIconFile(contentType: 'image/png', data: 'AQID'),
        ),
      );
      expect(await repo.tenantIconImage('default'), [1, 2, 3]);
      expect(server.requests.last.uri.path, '/api/v1/tenants/default/icon');
    });
  });

  test('the icon round-trips through storage', () {
    const icon = TenantIcon(name: 'rocket');
    expect(TenantIcon.fromJson(icon.toJson()), icon);
    expect(const TenantIcon().toJson(), isEmpty);
  });
}
