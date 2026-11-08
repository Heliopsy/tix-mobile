// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/features/admin/presentation/account_log_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/domains_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/global_admins_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/server_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_detail.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_settings_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_users_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenants_screen.dart';
import 'package:tix_mobile/src/features/security/presentation/security_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_admin.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester, Size size) async {
    final server = FakeTix();
    FakeAdmin.on(server);
    final stores = signedInStores();
    await setSize(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(App)));
  }

  final routes = <String, Type>{
    Routes.security: SecurityScreen,
    Routes.manageTenant: TenantSettingsScreen,
    Routes.manageDomains: DomainsScreen,
    Routes.manageServer: ServerScreen,
    Routes.manageTenants: TenantsScreen,
    Routes.manageGlobalAdmins: GlobalAdminsScreen,
    Routes.manageTenantSettings('acme'): TenantSettingsScreen,
    Routes.manageTenantUsers('acme'): TenantUsersScreen,
    Routes.accountLog('raj@example.com'): AccountLogScreen,
  };

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: every admin route opens its screen', (tester) async {
      final c = await pumpApp(tester, size);
      for (final MapEntry(key: location, value: type) in routes.entries) {
        c.read(routerProvider).go(location);
        await tester.pumpAndSettle();
        expect(find.byType(type), findsOneWidget, reason: location);
        expect(tester.takeException(), isNull, reason: location);
      }
    });
  }

  testWidgets('a tenant opens on its own on a phone and beside the list '
      'on a wide window', (tester) async {
    final c = await pumpApp(tester, phone);
    c.read(routerProvider).go(Routes.manageTenantDetail('acme'));
    await tester.pumpAndSettle();
    expect(find.byType(TenantDetailScreen), findsOneWidget);
    expect(find.byType(TenantsScreen), findsNothing);
    await setSize(tester, desktop);
    await tester.pumpAndSettle();
    c.read(routerProvider).go(Routes.manageTenantDetail('default'));
    await tester.pumpAndSettle();
    expect(find.byType(TenantsScreen), findsOneWidget);
    expect(find.byType(TenantDetail), findsOneWidget);
  });

  testWidgets('settings lead to security', (tester) async {
    final c = await pumpApp(tester, phone);
    c.read(routerProvider).go(Routes.settings);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings.security.open')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('settings.security.open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.security.open')));
    await tester.pumpAndSettle();
    expect(find.byType(SecurityScreen), findsOneWidget);
  });

  test('admin routes escape keys and emails', () {
    expect(Routes.manageTenantDetail('a b'), '/manage/tenants/a%20b');
    expect(Routes.manageTenantUsers('acme'), '/manage/tenants/acme/users');
    expect(Routes.accountLog('a@b.c'), '/manage/accounts/a%40b.c/log');
  });
}
