// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/design/accent_provider.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/admin/application/global_admin.dart';
import 'package:tix_mobile/src/features/admin/application/tenant_admin.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_admin.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('a token without a tenant key finds its tenant by whoami', () async {
    final server = FakeTix();
    FakeAdmin.on(server);
    final c = await signedInContainer(server);
    expect(await c.read(currentTenantRefProvider.future), 'id-default');
  });

  test('saving a theme recolours the app', () async {
    final server = FakeTix();
    final admin = FakeAdmin.on(server);
    final stores = signInStores(server);
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    await c.read(sessionControllerProvider.future);
    final accent = c.listen(tenantAccentProvider, (_, _) {});
    addTearDown(accent.close);
    final settings = tenantSettingsProvider('default');
    final sub = c.listen(settings, (_, _) {});
    addTearDown(sub.close);
    await c.read(settings.future);
    await c
        .read(settings.notifier)
        .save(const UpdateTenantInput(theme: 'indigo'));
    expect(c.read(settings).value!.theme, 'indigo');
    expect(admin.tenants['default']!['theme'], 'indigo');
    await pumpEventQueue();
    expect(c.read(tenantAccentProvider).name, TixAccent.resolve('indigo').name);
  });

  test('domains add and remove in place', () async {
    final server = FakeTix();
    FakeAdmin.on(server);
    final c = await signedInContainer(server);
    final sub = c.listen(tenantDomainListProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(tenantDomainListProvider.future);
    await c
        .read(tenantDomainListProvider.notifier)
        .add(const AddDomainInput(hostname: 'b.example.com', certMode: 'none'));
    expect(c.read(tenantDomainListProvider).value!.map((d) => d.hostname), [
      'tix.example.com',
      'b.example.com',
    ]);
    await c.read(tenantDomainListProvider.notifier).remove('tix.example.com');
    expect(c.read(tenantDomainListProvider).value!.map((d) => d.hostname), [
      'b.example.com',
    ]);
  });

  test('server status reads the version and connections; ending one '
      'reads them again', () async {
    final server = FakeTix();
    FakeAdmin.on(server);
    final c = await signedInContainer(server);
    final sub = c.listen(serverStatusProvider, (_, _) {});
    addTearDown(sub.close);
    final first = await c.read(serverStatusProvider.future);
    expect(first.health.version, 'v1.2.3');
    expect(first.connections.connections, hasLength(2));
    await c.read(serverStatusProvider.notifier).end('c1');
    final second = await c.read(serverStatusProvider.future);
    expect(second.connections.connections.single.id, 'c2');
  });

  test('tenants page, create and delete', () async {
    final server = FakeTix()..pageSize = 1;
    final admin = FakeAdmin.on(server);
    final c = await signedInContainer(server);
    final sub = c.listen(tenantDirectoryProvider, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(tenantDirectoryProvider.future)).items, hasLength(2));
    final created = await c
        .read(tenantDirectoryProvider.notifier)
        .create(
          const CreateTenantInput(
            key: 'beta',
            name: 'Beta',
            admins: [TenantAdminInput(email: 'boss@beta.example')],
          ),
        );
    expect(created.initialCredentials, hasLength(1));
    expect(admin.tenants.keys, contains('beta'));
    await c.read(tenantDirectoryProvider.future);
    await c.read(tenantDirectoryProvider.notifier).delete('beta');
    expect(
      c.read(tenantDirectoryProvider).value!.items.map((t) => t.key),
      isNot(contains('beta')),
    );
  });

  test('tenant access follows the connection', () async {
    final server = FakeTix();
    FakeAdmin.on(server);
    final stores = signInStores(server, tenants: ['default', 'acme']);
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    await c.read(sessionControllerProvider.future);
    expect(c.read(tenantAccessProvider('default')), TenantAccess.current);
    expect(c.read(tenantAccessProvider('acme')), TenantAccess.member);
    expect(c.read(tenantAccessProvider('beta')), TenantAccess.join);
    final token = await signedInContainer(FakeTix());
    expect(token.read(tenantAccessProvider('acme')), TenantAccess.pinned);
  });

  test('switching into a tenant the person is not in joins it first', () async {
    final server = FakeTix();
    final admin = FakeAdmin.on(server);
    server.tenants['acme'] = (name: 'Acme', host: '');
    final stores = signInStores(server);
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    await c.read(sessionControllerProvider.future);
    final sub = c.listen(tenantDirectoryProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(tenantDirectoryProvider.future);
    // Joining makes ana a member, as tix does, before the switch.
    server.routes.insert(0, (o, path, caller) {
      if (o.method == 'POST' && path == '/api/v1/tenants/acme/members') {
        server.accounts['ana@example.com'] = FakeAccount(
          password: 'pw',
          tenants: ['default', 'acme'],
        );
      }
      return null;
    });
    await c.read(tenantDirectoryProvider.notifier).switchTo('acme', join: true);
    expect(admin.users['acme']!.last['email'], 'ana@example.com');
    expect(admin.users['acme']!.last['role'], 'admin');
    final session = await c.read(sessionControllerProvider.future);
    expect(session!.connection.tenantKey, 'acme');
  });

  test('tenant users page and change', () async {
    final server = FakeTix()..pageSize = 1;
    final admin = FakeAdmin.on(server);
    final c = await signedInContainer(server);
    final users = tenantUsersProvider('default');
    final sub = c.listen(users, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(users.future)).items, hasLength(1));
    await c.read(users.notifier).loadMore();
    expect(c.read(users).value!.items, hasLength(2));
    await c
        .read(users.notifier)
        .edit('u2', const UpdateUserInput(role: Role.viewer));
    expect(admin.users['default']![1]['role'], 'viewer');
    await c.read(users.notifier).clearSecondFactor('u1');
    expect(admin.cleared, ['u1']);
    await c.read(users.notifier).delete('u2');
    expect(admin.users['default'], hasLength(1));
  });

  test('global admins grant and revoke; account logs page', () async {
    final server = FakeTix()..pageSize = 1;
    FakeAdmin.on(server);
    final c = await signedInContainer(server);
    final sub = c.listen(globalAdminsProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(globalAdminsProvider.future);
    await c.read(globalAdminsProvider.notifier).grant('raj@example.com');
    expect(await c.read(globalAdminsProvider.future), hasLength(2));
    await c.read(globalAdminsProvider.notifier).revoke('raj@example.com');
    expect(c.read(globalAdminsProvider).value, hasLength(1));
    final log = accountLogProvider('raj@example.com');
    final logSub = c.listen(log, (_, _) {});
    addTearDown(logSub.close);
    expect((await c.read(log.future)).items.single.seq, 2);
    await c.read(log.notifier).loadMore();
    expect(c.read(log).value!.items.map((e) => e.seq), [2, 1]);
  });

  test('tenant domains toggle shared in place', () async {
    final server = FakeTix();
    FakeAdmin.on(server);
    final c = await signedInContainer(server);
    final domains = tenantDomainsProvider('default');
    final sub = c.listen(domains, (_, _) {});
    addTearDown(sub.close);
    await c.read(domains.future);
    await c.read(domains.notifier).setShared('tix.example.com', shared: true);
    expect(c.read(domains).value!.single.shared, isTrue);
  });
}
