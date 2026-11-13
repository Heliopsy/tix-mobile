// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
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
    test('reads the icon of the tenant and of each membership', () async {
      server.tenantIcons
        ..['default'] = {'icon': '🚀'}
        ..['acme'] = {'icon_name': 'rocket'};
      final s = server.startSession('ana@example.com', 'default');
      final who = await AuthRepository(server.factory)
          .identity(base, SessionCredential(s));
      expect(who.me.tenantKey, 'default');
      expect(who.icon, const TenantIcon(text: '🚀'));
      expect(who.icons, {
        'default': const TenantIcon(text: '🚀'),
        'acme': const TenantIcon(name: 'rocket'),
      });
    });

    test('a tix without tenant icons reports none', () async {
      final s = server.startSession('ana@example.com', 'default');
      final who = await AuthRepository(server.factory)
          .identity(base, SessionCredential(s));
      expect(who.icon.isEmpty, isTrue);
      expect(who.icons.values.every((i) => i.isEmpty), isTrue);
      expect(who.me.memberships, hasLength(2));
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

    test('reads the icon fields of GET /tenants/{ref}', () async {
      server.tenantIcons['acme'] = {'icon_image': 'abc'};
      expect(await repo.tenantIcon('acme'), const TenantIcon(image: 'abc'));
      expect(server.requests.last.uri.path, '/api/v1/tenants/acme');
    });

    test('each change sends only its own field', () async {
      expect(
        await repo.setTenantIcon(
          'acme',
          const TenantIconChange.builtin('bolt'),
        ),
        const TenantIcon(name: 'bolt'),
      );
      expect(server.requests.last.method, 'PATCH');
      expect(server.requests.last.body, {'icon_name': 'bolt'});
      await repo.setTenantIcon('acme', const TenantIconChange.text('AC'));
      expect(server.requests.last.body, {'icon': 'AC'});
      expect(
        await repo.setTenantIcon('acme', const TenantIconChange.text('')),
        const TenantIcon(),
      );
      expect(server.requests.last.body, {'icon': ''});
      final set = await repo.setTenantIcon(
        'acme',
        const TenantIconChange.image(
          ProjectIconFile(contentType: 'image/png', data: 'AQID'),
        ),
      );
      expect(server.requests.last.body, {
        'icon_file': {'content_type': 'image/png', 'data': 'AQID'},
      });
      expect(set.image, isNotEmpty);
    });

    test('reads the uploaded image', () async {
      await repo.setTenantIcon(
        'default',
        const TenantIconChange.image(
          ProjectIconFile(contentType: 'image/png', data: 'AQID'),
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
