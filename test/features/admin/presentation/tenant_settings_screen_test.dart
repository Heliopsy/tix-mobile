// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_settings_screen.dart';

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

  Color accentFor(String theme) => buildTixTheme(
    Brightness.light,
    accent: TixAccent.resolve(theme),
  ).extension<TixTokens>()!.accent;

  Map<String, Object?> lastPatch() =>
      server.requests.lastWhere((r) => r.method == 'PATCH').body;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then every section', (tester) async {
        server.gate = Completer<void>();
        await pumpAdmin(
          tester,
          server,
          const TenantSettingsScreen(),
          size: size,
          settle: false,
        );
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('Default · default'), findsOneWidget);
        for (final title in ['General', 'Theme', 'Second factor', 'Claims']) {
          await reveal(tester, find.widgetWithText(TixSection, title));
          expect(find.widgetWithText(TixSection, title), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets('a failure explains itself and retries', (tester) async {
        server.override = FakeResponse(403, envelope('forbidden', 'no'));
        await pumpAdmin(
          tester,
          server,
          const TenantSettingsScreen(tenantRef: 'acme'),
          size: size,
        );
        expect(find.byType(ErrorState), findsOneWidget);
        expect(find.widgetWithText(TixSection, 'Theme'), findsNothing);
        server.override = null;
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(find.text('Acme · acme'), findsOneWidget);
      });
    });
  }

  testWidgets('the name saves only once it changes, and only the name', (
    tester,
  ) async {
    await pumpAdmin(
      tester,
      server,
      const TenantSettingsScreen(),
      size: desktop,
    );
    final save = find.byKey(const Key('tenant.general.save'));
    expect(tester.widget<TixButton>(save).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('tenant.name')), 'Default HQ');
    await tester.pump();
    expect(tester.widget<TixButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(lastPatch(), {'name': 'Default HQ'});
    expect(admin.tenants['default']!['name'], 'Default HQ');
    expect(find.text('Default HQ · default'), findsOneWidget);
  });

  testWidgets('a refused value keeps what was typed and says why', (
    tester,
  ) async {
    await pumpAdmin(
      tester,
      server,
      const TenantSettingsScreen(),
      size: desktop,
    );
    await tester.enterText(find.byKey(const Key('tenant.name')), '');
    await tester.pump();
    await tapShown(tester, find.byKey(const Key('tenant.general.save')));
    expect(find.textContaining('name must not be blank'), findsOneWidget);
    expect(admin.tenants['default']!['name'], 'Default');
  });

  testWidgets('picking a theme previews it in both schemes before saving', (
    tester,
  ) async {
    await pumpAdmin(
      tester,
      server,
      const TenantSettingsScreen(),
      size: desktop,
    );
    final preview = find.byKey(const Key('preview.light'));
    Color accentOf() => tester
        .widget<Icon>(
          find.descendant(
            of: preview,
            matching: find.byIcon(Icons.check_circle),
          ),
        )
        .color!;
    expect(accentOf(), accentFor(''));
    await tester.tap(find.byKey(const Key('theme.indigo')));
    await tester.pump();
    expect(accentOf(), accentFor('indigo'));
    expect(find.byKey(const Key('preview.dark')), findsOneWidget);
    expect(
      server.requests.where((r) => r.method == 'PATCH'),
      isEmpty,
      reason: 'a preview sends nothing',
    );
    await tester.enterText(
      find.byKey(const Key('tenant.customColour')),
      '#FF8800',
    );
    await tester.pump();
    expect(accentOf(), accentFor('#ff8800'));
    await tapShown(tester, find.byKey(const Key('tenant.theme.save')));
    expect(lastPatch(), {'theme': '#ff8800'});
  });

  testWidgets('a malformed colour says how to write it', (tester) async {
    await pumpAdmin(tester, server, const TenantSettingsScreen());
    await tester.enterText(find.byKey(const Key('tenant.customColour')), 'red');
    await tester.pump();
    expect(
      find.text('Write the colour as #rrggbb, such as #0f766e.'),
      findsOneWidget,
    );
  });

  testWidgets('second factor and trash switches save at once', (tester) async {
    await pumpAdmin(
      tester,
      server,
      const TenantSettingsScreen(),
      size: desktop,
    );
    await tapShown(tester, find.byKey(const Key('tenant.totpWeb')));
    expect(lastPatch(), {'require_totp_web': true});
    await tapShown(tester, find.byKey(const Key('tenant.trash')));
    expect(lastPatch(), {'trash_off': true});
    expect(
      find.text(
        'Deleting a task is permanent. Tasks already in the trash stay there.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('leases clear back to the server default with zero', (
    tester,
  ) async {
    admin.tenants['default']!['lease_default'] = '30m';
    await pumpAdmin(
      tester,
      server,
      const TenantSettingsScreen(),
      size: desktop,
    );
    await reveal(tester, find.byKey(const Key('tenant.leaseDefault')));
    await tester.enterText(find.byKey(const Key('tenant.leaseDefault')), '');
    await tester.enterText(find.byKey(const Key('tenant.leaseMax')), '4h');
    await tester.pump();
    await tapShown(tester, find.byKey(const Key('tenant.lease.save')));
    expect(lastPatch(), {'lease_default': '0', 'lease_max': '4h'});
  });

  testWidgets('deleting the active tenant asks first, then signs out', (
    tester,
  ) async {
    final c = await pumpAdmin(tester, server, const TenantSettingsScreen());
    await tapShown(tester, find.byKey(const Key('tenant.delete')));
    expect(admin.tenants, contains('default'));
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(admin.tenants, isNot(contains('default')));
    expect(await c.read(sessionControllerProvider.future), isNull);
  });
}
