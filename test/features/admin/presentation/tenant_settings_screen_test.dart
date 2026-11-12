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
        for (final title in [
          'General',
          'Theme',
          'Second factor',
          'Claims',
          'Sessions',
          'Artifacts',
        ]) {
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

      testWidgets('sessions load as tix reads them, with the server greyed', (
        tester,
      ) async {
        admin.tenants['default']!
          ..['session_ttl'] = '8h0m0s'
          ..['session_remember_off'] = true;
        await pumpAdmin(
          tester,
          server,
          const TenantSettingsScreen(),
          size: size,
        );
        final ttl = find.byKey(const Key('tenant.sessionTtl'));
        await reveal(tester, find.byKey(const Key('tenant.sessionRemember')));
        expect(tester.widget<TextField>(ttl).controller!.text, '8h');
        expect(
          tester
              .widget<TextField>(
                find.byKey(const Key('tenant.sessionRemember')),
              )
              .controller!
              .text,
          'off',
        );
        final idle = tester.widget<TextField>(
          find.byKey(const Key('tenant.sessionIdle')),
        );
        expect(idle.controller!.text, isEmpty);
        expect(idle.decoration!.hintText, 'never');
        expect(tester.widget<TextField>(ttl).decoration!.hintText, '12h');
        expect(tester.takeException(), isNull);
      });

      testWidgets('a session setting saves alone, and a refusal says why', (
        tester,
      ) async {
        await pumpAdmin(
          tester,
          server,
          const TenantSettingsScreen(),
          size: size,
        );
        final idle = find.byKey(const Key('tenant.sessionIdle'));
        await reveal(tester, idle);
        await tester.enterText(idle, '30m');
        await tester.pump();
        await tapShown(tester, find.byKey(const Key('tenant.session.save')));
        expect(lastPatch(), {'session_idle_timeout': '30m'});
        admin.refuse['session_ttl'] =
            "session lifetime 48h is longer than the server's 12h";
        final ttl = find.byKey(const Key('tenant.sessionTtl'));
        await reveal(tester, ttl);
        await tester.enterText(ttl, '48h');
        await tester.pump();
        await tapShown(tester, find.byKey(const Key('tenant.session.save')));
        expect(lastPatch(), {'session_ttl': '48h'});
        expect(find.textContaining('longer than the server'), findsOneWidget);
        expect(tester.widget<TextField>(ttl).controller!.text, '48h');
        expect(admin.tenants['default']!['session_ttl'], isNull);
      });

      testWidgets('artifact limits load, save alone, and show a refusal', (
        tester,
      ) async {
        admin.tenants['default']!
          ..['artifact_max_bytes'] = 524288
          ..['artifact_types'] = ['image/*'];
        await pumpAdmin(
          tester,
          server,
          const TenantSettingsScreen(),
          size: size,
        );
        final bytes = find.byKey(const Key('tenant.artifactMaxBytes'));
        final types = find.byKey(const Key('tenant.artifactTypes'));
        await reveal(tester, types);
        expect(tester.widget<TextField>(bytes).controller!.text, '512KiB');
        expect(tester.widget<TextField>(types).controller!.text, 'image/*');
        expect(tester.widget<TextField>(bytes).decoration!.hintText, '1MiB');
        await tester.enterText(types, 'image/*, application/pdf');
        await tester.pump();
        await tapShown(tester, find.byKey(const Key('tenant.artifact.save')));
        expect(lastPatch(), {
          'artifact_types': ['image/*', 'application/pdf'],
        });
        admin.refuse['artifact_max_bytes'] =
            "artifact size limit 2 MiB is above the server's 1 MiB";
        await tester.enterText(bytes, '2 MiB');
        await tester.pump();
        await tapShown(tester, find.byKey(const Key('tenant.artifact.save')));
        expect(lastPatch(), {'artifact_max_bytes': 2097152});
        expect(find.textContaining("above the server's"), findsOneWidget);
        expect(tester.widget<TextField>(bytes).controller!.text, '2 MiB');
      });
    });
  }

  testWidgets('an unreadable size is flagged and not sent', (tester) async {
    await pumpAdmin(
      tester,
      server,
      const TenantSettingsScreen(),
      size: desktop,
    );
    final bytes = find.byKey(const Key('tenant.artifactMaxBytes'));
    await reveal(tester, bytes);
    await tester.enterText(bytes, 'big');
    await tester.pump();
    expect(
      find.text('Write a size such as 1048576, 512KiB or 5MiB.'),
      findsOneWidget,
    );
    final save = find.byKey(const Key('tenant.artifact.save'));
    expect(tester.widget<TixButton>(save).onPressed, isNull);
  });

  testWidgets('emptied session and artifact settings inherit the server', (
    tester,
  ) async {
    admin.tenants['default']!
      ..['session_ttl'] = '8h0m0s'
      ..['session_remember_ttl'] = '168h0m0s'
      ..['artifact_max_bytes'] = 524288
      ..['artifact_types'] = ['image/*'];
    await pumpAdmin(
      tester,
      server,
      const TenantSettingsScreen(),
      size: desktop,
    );
    final ttl = find.byKey(const Key('tenant.sessionTtl'));
    final remember = find.byKey(const Key('tenant.sessionRemember'));
    await reveal(tester, remember);
    expect(tester.widget<TextField>(remember).controller!.text, '7d');
    await tester.enterText(ttl, '');
    await tester.enterText(remember, '');
    await tester.pump();
    await tapShown(tester, find.byKey(const Key('tenant.session.save')));
    expect(lastPatch(), {'session_ttl': '0', 'session_remember_ttl': ''});
    final bytes = find.byKey(const Key('tenant.artifactMaxBytes'));
    final types = find.byKey(const Key('tenant.artifactTypes'));
    await reveal(tester, types);
    await tester.enterText(bytes, '');
    await tester.enterText(types, '');
    await tester.pump();
    await tapShown(tester, find.byKey(const Key('tenant.artifact.save')));
    expect(lastPatch(), {
      'artifact_max_bytes': 0,
      'artifact_types': <String>[],
    });
  });

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
