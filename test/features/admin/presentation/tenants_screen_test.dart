// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/admin/presentation/account_log_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/global_admins_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_detail.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_users_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenants_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_admin.dart';
import '../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;
  late FakeAdmin admin;

  setUp(() {
    server = FakeTix();
    admin = FakeAdmin.on(server);
  });

  group('tenants', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      group(width, () {
        testWidgets('loading, then every tenant', (tester) async {
          server.gate = Completer<void>();
          await pumpAdmin(
            tester,
            server,
            const TenantsScreen(),
            size: size,
            settle: false,
          );
          expect(find.byType(SkeletonList), findsOneWidget);
          server.gate!.complete();
          await tester.pumpAndSettle();
          final acme = find.byKey(const Key('tenant.acme'));
          expect(
            find.descendant(of: acme, matching: find.text('Second factor')),
            findsOneWidget,
          );
          expect(find.byKey(const Key('tenant.default')), findsOneWidget);
        });

        testWidgets('empty carries the create action', (tester) async {
          admin.tenants.clear();
          await pumpAdmin(tester, server, const TenantsScreen(), size: size);
          expect(
            find.descendant(
              of: find.byType(EmptyState),
              matching: find.text('New tenant'),
            ),
            findsOneWidget,
          );
        });

        testWidgets('a person who is not a global admin is refused', (
          tester,
        ) async {
          server.override = FakeResponse(
            403,
            envelope('forbidden', 'only a global admin may do this'),
          );
          await pumpAdmin(tester, server, const TenantsScreen(), size: size);
          expect(find.byType(ErrorState), findsOneWidget);
        });
      });
    }

    testWidgets('a wide window shows the chosen tenant beside the list', (
      tester,
    ) async {
      await pumpAdmin(
        tester,
        server,
        const TenantsScreen(selectedKey: 'acme'),
        size: desktop,
      );
      expect(find.byType(TenantDetail), findsOneWidget);
      expect(find.text('ember'), findsOneWidget);
      await tester.tap(find.byKey(const Key('tenant.default')));
      await tester.pumpAndSettle();
      expect(find.text('route:/manage/tenants/default'), findsOneWidget);
    });

    testWidgets('creating a tenant shows its generated password once', (
      tester,
    ) async {
      await pumpAdmin(tester, server, const TenantsScreen());
      await tester.tap(find.byKey(const Key('tenants.create')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('tenant.create.key')),
        'beta',
      );
      await tester.enterText(
        find.byKey(const Key('tenant.create.name')),
        'Beta',
      );
      await tester.enterText(
        find.byKey(const Key('tenant.create.email')),
        'boss@beta.example',
      );
      await tester.tap(find.byKey(const Key('form.submit')));
      await tester.pumpAndSettle();
      final panel = find.byKey(const Key('tenant.credentials'));
      expect(
        find.descendant(
          of: panel,
          matching: find.text('boss@beta.example  gen-pass-1234'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('tenant.credentialsDone')));
      await tester.pumpAndSettle();
      expect(panel, findsNothing);
      expect(find.textContaining('gen-pass-1234'), findsNothing);
      expect(find.byKey(const Key('tenant.beta')), findsOneWidget);
    });
  });

  group('tenant detail', () {
    testWidgets('a token cannot switch, and says why', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const TenantDetailScreen(tenantKey: 'acme'),
      );
      final button = tester.widget<TixButton>(
        find.byKey(const Key('tenant.switch')),
      );
      expect(button.onPressed, isNull);
      expect(find.byType(InfoTip), findsWidgets);
    });

    testWidgets('a global admin joins a tenant and switches into it', (
      tester,
    ) async {
      server.tenants['acme'] = (name: 'Acme', host: '');
      server.routes.insert(0, (o, path, caller) {
        if (o.method == 'POST' && path == '/api/v1/tenants/acme/members') {
          server.accounts['ana@example.com'] = FakeAccount(
            password: 'pw',
            tenants: ['default', 'acme'],
          );
        }
        return null;
      });
      final c = await pumpAdmin(
        tester,
        server,
        const TenantDetailScreen(tenantKey: 'acme'),
        signIn: true,
      );
      expect(find.text('Join and switch'), findsOneWidget);
      await tester.tap(find.byKey(const Key('tenant.switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tenant.joinConfirm')));
      await tester.pumpAndSettle();
      final session = await c.read(sessionControllerProvider.future);
      expect(session!.connection.tenantKey, 'acme');
      expect(find.text('route:/projects'), findsOneWidget);
    });

    testWidgets('the active tenant cannot be deleted from here', (
      tester,
    ) async {
      await pumpAdmin(
        tester,
        server,
        const TenantDetailScreen(tenantKey: 'default'),
        signIn: true,
      );
      await reveal(tester, find.byKey(const Key('tenant.delete')));
      final button = tester.widget<TixButton>(
        find.byKey(const Key('tenant.delete')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('another tenant is deleted after a confirm', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const TenantDetailScreen(tenantKey: 'acme'),
        signIn: true,
      );
      await tapShown(tester, find.byKey(const Key('tenant.delete')));
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      expect(admin.tenants, isNot(contains('acme')));
      expect(find.text('route:/manage/tenants'), findsOneWidget);
    });

    testWidgets('a domain is shared with its switch', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const TenantDetailScreen(tenantKey: 'default'),
      );
      await tapShown(
        tester,
        find.byKey(const Key('domain.shared.tix.example.com')),
      );
      expect(admin.domains['default']!.single['shared'], isTrue);
    });
  });

  group('users', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      group(width, () {
        testWidgets('loading, then users with their marks', (tester) async {
          server.gate = Completer<void>();
          await pumpAdmin(
            tester,
            server,
            const TenantUsersScreen(tenantKey: 'default'),
            size: size,
            settle: false,
          );
          expect(find.byType(SkeletonList), findsOneWidget);
          server.gate!.complete();
          await tester.pumpAndSettle();
          final ana = find.byKey(const Key('user.u1'));
          for (final mark in ['Admin', 'Global admin', 'Second factor']) {
            expect(
              find.descendant(of: ana, matching: find.text(mark)),
              findsOneWidget,
            );
          }
        });

        testWidgets('empty', (tester) async {
          await pumpAdmin(
            tester,
            server,
            const TenantUsersScreen(tenantKey: 'beta'),
            size: size,
          );
          expect(find.text('No users in this tenant.'), findsOneWidget);
        });
      });
    }

    testWidgets('creating a user sends the role and the password rule', (
      tester,
    ) async {
      await pumpAdmin(
        tester,
        server,
        const TenantUsersScreen(tenantKey: 'acme'),
      );
      await tester.tap(find.byKey(const Key('users.create')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('user.email')),
        'new@acme.example',
      );
      await tester.tap(find.text('Admin').last);
      await tester.enterText(
        find.byKey(const Key('user.password')),
        'correct horse battery',
      );
      await tester.pumpAndSettle();
      await tapShown(tester, find.byKey(const Key('form.submit')));
      final sent = server.requests.lastWhere((r) => r.method == 'POST').body;
      expect(sent, {
        'email': 'new@acme.example',
        'role': 'admin',
        'password': 'correct horse battery',
        'require_password_change': true,
      });
      expect(admin.users['acme']!.last['email'], 'new@acme.example');
    });

    testWidgets('editing a user sends only what changed', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const TenantUsersScreen(tenantKey: 'default'),
      );
      await tester.tap(find.byKey(const Key('user.menu.u2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('user.edit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('user.disabled')));
      await tester.pumpAndSettle();
      await tapShown(tester, find.byKey(const Key('form.submit')));
      expect(server.requests.lastWhere((r) => r.method == 'PATCH').body, {
        'disabled': true,
      });
      expect(
        find.descendant(
          of: find.byKey(const Key('user.u2')),
          matching: find.text('Disabled'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('clearing a second factor is offered in the active tenant '
        'only, and asks first', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const TenantUsersScreen(tenantKey: 'default'),
        signIn: true,
      );
      await tester.tap(find.byKey(const Key('user.menu.u1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('user.clearTotp')));
      await tester.pumpAndSettle();
      expect(admin.cleared, isEmpty);
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      expect(admin.cleared, ['u1']);
    });

    testWidgets('no clearing in another tenant', (tester) async {
      admin.users['acme']!.first['totp_enrolled'] = true;
      await pumpAdmin(
        tester,
        server,
        const TenantUsersScreen(tenantKey: 'acme'),
        signIn: true,
      );
      await tester.tap(find.byKey(const Key('user.menu.u3')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('user.clearTotp')), findsNothing);
      expect(find.byKey(const Key('user.delete')), findsOneWidget);
    });

    testWidgets('deleting a user asks first', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const TenantUsersScreen(tenantKey: 'default'),
      );
      await tester.tap(find.byKey(const Key('user.menu.u2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('user.delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      expect(admin.users['default']!.map((u) => u['id']), ['u1']);
      expect(find.byKey(const Key('user.u2')), findsNothing);
    });

    testWidgets('an existing account is added with a role', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const TenantUsersScreen(tenantKey: 'acme'),
      );
      await tester.tap(find.byKey(const Key('users.addMember')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('member.email')),
        'raj@example.com',
      );
      await tester.tap(find.byKey(const Key('form.submit')));
      await tester.pumpAndSettle();
      expect(server.requests.lastWhere((r) => r.method == 'POST').body, {
        'email': 'raj@example.com',
        'role': 'member',
      });
    });

    testWidgets('the account log opens from a user', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const TenantUsersScreen(tenantKey: 'default'),
      );
      await tester.tap(find.byKey(const Key('user.menu.u2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('user.log')));
      await tester.pumpAndSettle();
      expect(
        find.text('route:/manage/accounts/raj%40example.com/log'),
        findsOneWidget,
      );
    });
  });

  group('global admins', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width: list, grant and revoke', (tester) async {
        await pumpAdmin(tester, server, const GlobalAdminsScreen(), size: size);
        expect(
          find.byKey(const Key('globalAdmin.ana@example.com')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('globalAdmins.grant')).first);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('globalAdmin.email')),
          'raj@example.com',
        );
        await tester.tap(find.byKey(const Key('form.submit')));
        await tester.pumpAndSettle();
        expect(admin.globalAdmins, contains('raj@example.com'));
        await tester.tap(
          find.byKey(const Key('globalAdmin.revoke.raj@example.com')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm.ok')));
        await tester.pumpAndSettle();
        expect(admin.globalAdmins, ['ana@example.com']);
      });
    }

    testWidgets('refused for anyone else', (tester) async {
      admin.globalAdmin = false;
      await pumpAdmin(tester, server, const GlobalAdminsScreen());
      expect(
        find.text('This token is not allowed to do that.'),
        findsOneWidget,
      );
    });
  });

  group('account log', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width: entries newest first, and empty', (tester) async {
        await pumpAdmin(
          tester,
          server,
          const AccountLogScreen(email: 'raj@example.com'),
          size: size,
        );
        final first = find.byKey(const Key('accountLog.2'));
        expect(
          find.descendant(of: first, matching: find.text('role: member')),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(first).dy,
          lessThan(tester.getTopLeft(find.byKey(const Key('accountLog.1'))).dy),
        );
      });
    }

    testWidgets('an account with no history says so', (tester) async {
      await pumpAdmin(
        tester,
        server,
        const AccountLogScreen(email: 'nobody@example.com'),
      );
      expect(find.text('Nothing logged for this account.'), findsOneWidget);
    });
  });
}
