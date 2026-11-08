// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/admin_repository.dart';
import 'package:tix_mobile/src/data/repositories/security_repository.dart';

import '../../helpers/fake_admin.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeAdmin admin;
  late MemoryCacheStore store;
  late AdminRepository repo;
  late SecurityRepository security;
  late List<String> logged;

  setUp(() {
    server = FakeTix();
    admin = FakeAdmin.on(server);
    store = MemoryCacheStore();
    final api = server.factory(
      'https://tix.example',
      const BearerCredential('tok'),
    );
    repo = AdminRepository(
      api,
      ResponseCache(store, const CacheScope('c1', '')),
    );
    security = SecurityRepository(api);
    logged = [];
    logListener = logged.add;
    addTearDown(() => logListener = null);
  });

  RequestOptions last() => server.requests.last;

  String cached() => store.entries.values.expand((m) => m.values).join('\n');

  test('a tenant is read once, then served from the cache first', () async {
    expect((await repo.tenant('acme')).theme, 'ember');
    expect(last().uri.path, '/api/v1/tenants/acme');
    expect((await repo.cachedTenant('acme'))!.name, 'Acme');
  });

  test('an update sends only what changes', () async {
    final t = await repo.updateTenant(
      'acme',
      const UpdateTenantInput(theme: '#ff8800'),
    );
    expect(last().method, 'PATCH');
    expect(last().body, {'theme': '#ff8800'});
    expect(t.theme, '#ff8800');
  });

  test('tenants page by key; deleting one removes it', () async {
    final page = await repo.tenants();
    expect(page.items.map((t) => t.key), ['default', 'acme']);
    expect(last().uri.queryParameters, {'sort': 'key', 'direction': 'asc'});
    await repo.deleteTenant('acme');
    expect(last().method, 'DELETE');
    expect(admin.tenants.keys, ['default']);
  });

  test('a new tenant brings its generated password once, never cached '
      'or logged', () async {
    final created = await repo.createTenant(
      const CreateTenantInput(
        key: 'beta',
        name: 'Beta',
        admins: [TenantAdminInput(email: 'boss@beta.example')],
      ),
    );
    expect(last().body, {
      'key': 'beta',
      'name': 'Beta',
      'admins': [
        {'email': 'boss@beta.example'},
      ],
    });
    expect(created.initialCredentials.single.password, 'gen-pass-1234');
    await repo.tenants();
    expect(cached(), isNot(contains('gen-pass-1234')));
    expect(logged.join('\n'), isNot(contains('gen-pass-1234')));
  });

  test('tenant users: list, create, add, edit, delete', () async {
    final page = await repo.tenantUsers('default');
    expect(page.items.map((u) => u.email), [
      'ana@example.com',
      'raj@example.com',
    ]);
    expect(page.items.first.role, Role.admin);
    await repo.createTenantUser(
      'acme',
      const CreateUserInput(email: 'new@acme.example', role: Role.member),
    );
    expect(last().uri.path, '/api/v1/tenants/acme/users');
    expect(last().body, {'email': 'new@acme.example', 'role': 'member'});
    await repo.addTenantMember(
      'acme',
      const AddTenantMemberInput(email: 'raj@example.com'),
    );
    expect(last().uri.path, '/api/v1/tenants/acme/members');
    await repo.updateTenantUser(
      'default',
      'u2',
      const UpdateUserInput(disabled: true),
    );
    expect(last().body, {'disabled': true});
    expect(admin.users['default']![1]['disabled_at'], isNotNull);
    await repo.deleteTenantUser('default', 'u2');
    expect(last().uri.path, '/api/v1/tenants/default/users/u2');
    await repo.clearSecondFactor('u1');
    expect(last().uri.path, '/api/v1/users/u1/totp');
    expect(admin.cleared, ['u1']);
  });

  test('domains: list, add with a cert mode, share, remove', () async {
    expect((await repo.domains()).single.hostname, 'tix.example.com');
    final d = await repo.addDomain(
      const AddDomainInput(hostname: 'Board.Example.com', certMode: 'none'),
    );
    expect(d.hostname, 'board.example.com');
    await expectLater(
      repo.addDomain(const AddDomainInput(hostname: 'x', certMode: 'auto')),
      throwsA(
        isA<TixException>()
            .having((e) => e.kind, 'kind', TixErrorKind.invalid)
            .having((e) => e.message, 'message', contains('"none" or "file"')),
      ),
    );
    final shared = await repo.setDomainShared('tix.example.com', shared: true);
    expect(last().body, {'shared': true});
    expect(shared.shared, isTrue);
    expect((await repo.tenantDomains('default')).first.shared, isTrue);
    await repo.removeDomain('board.example.com');
    expect(last().uri.path, '/api/v1/domains/board.example.com');
  });

  test('global admins: list, grant, revoke', () async {
    expect((await repo.globalAdmins()).single.email, 'ana@example.com');
    await repo.grantGlobalAdmin('raj@example.com');
    expect(last().body, {'email': 'raj@example.com'});
    await repo.revokeGlobalAdmin('raj@example.com');
    expect(last().method, 'DELETE');
    expect(admin.globalAdmins, ['ana@example.com']);
  });

  test('a global admin route refuses anyone else', () async {
    admin.globalAdmin = false;
    await expectLater(
      repo.globalAdmins(),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.forbidden,
        ),
      ),
    );
  });

  test('an account log reads newest first', () async {
    final page = await repo.accountLog('raj@example.com');
    expect(last().uri.queryParameters['direction'], 'desc');
    expect(page.items.map((e) => e.seq), [2, 1]);
  });

  test('server: version and live connections, one of which ends', () async {
    expect((await repo.health()).version, 'v1.2.3');
    final list = await repo.connections();
    expect(list.counts!.process, 5);
    expect(list.connections.map((c) => c.surface), [
      ConnectionSurface.events,
      ConnectionSurface.ssh,
    ]);
    await repo.endConnection('c1');
    expect(last().uri.path, '/api/v1/connections/c1');
    expect(admin.connections.single['id'], 'c2');
  });

  test('the second factor: enrol, confirm, new codes, remove', () async {
    expect((await security.status()).enrolled, isFalse);
    final e = await security.enrol();
    expect(e.secret, FakeAdmin.secret);
    await expectLater(security.confirm('000000'), throwsA(isA<TixException>()));
    expect(await security.confirm(FakeAdmin.goodCode), FakeAdmin.codes);
    expect(last().body, {'code': FakeAdmin.goodCode});
    final status = await security.status();
    expect(status.enrolled, isTrue);
    expect(status.recoveryCodesLeft, 3);
    expect(await security.newRecoveryCodes(), FakeAdmin.codes);
    await security.removeSecondFactor();
    expect(last().method, 'DELETE');
    expect((await security.status()).enrolled, isFalse);
  });

  test('the authenticator secret and recovery codes reach neither the '
      'cache nor the log', () async {
    await security.enrol();
    await security.confirm(FakeAdmin.goodCode);
    await security.newRecoveryCodes();
    await repo.tenant('default');
    final everything = '${cached()}\n${logged.join('\n')}';
    expect(everything, isNot(contains(FakeAdmin.secret)));
    for (final code in FakeAdmin.codes) {
      expect(everything, isNot(contains(code)));
    }
    expect(logged, isNotEmpty);
  });

  test('SSH keys: list, enrol everywhere, revoke', () async {
    expect((await security.sshKeys()).single.label, 'laptop');
    final k = await security.addSshKey(
      const EnrolSSHKeyInput(
        publicKey: 'ssh-ed25519 AAAA desk',
        label: 'desk',
        allTenants: true,
      ),
    );
    expect(last().body, {
      'public_key': 'ssh-ed25519 AAAA desk',
      'label': 'desk',
      'all_tenants': true,
    });
    expect(k.enrolledIn, ['default', 'acme']);
    await security.revokeSshKey('k1');
    expect(last().uri.path, '/api/v1/ssh-keys/k1');
    expect((await security.sshKeys()).first.revokedAt, isNotNull);
  });
}
