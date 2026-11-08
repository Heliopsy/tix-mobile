// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';
import 'package:tix_mobile/src/features/shell/presentation/home_shell.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix()..tenants['acme'] = (name: 'Acme', host: '');
  });

  Future<void> palette(WidgetTester tester, String query) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('palette.query')), query);
    await tester.pump();
  }

  testWidgets('the palette switches to another saved context', (tester) async {
    final stores = signInStores(server, tenants: ['default', 'acme']);
    final c = await pumpScreen(
      tester,
      const TixShortcuts(
        child: ContextCommands(child: Scaffold(body: Text('home'))),
      ),
      size: desktop,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    await palette(tester, 'acme');
    final entry = find.descendant(
      of: find.byKey(const Key('palette')),
      matching: find.byKey(const Key('palette.context.s1.acme')),
    );
    expect(entry, findsOneWidget);
    expect(find.byKey(const Key('palette.context.s1.default')), findsNothing);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(
      c.read(sessionControllerProvider).value!.connection.tenantKey,
      'acme',
    );
  });

  testWidgets('the palette sets the theme', (tester) async {
    final stores = signedInStores();
    final c = await pumpScreen(
      tester,
      const TixShortcuts(
        child: SettingsCommands(child: Scaffold(body: Text('home'))),
      ),
      size: desktop,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    await palette(tester, 'dark theme');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(c.read(themeSettingProvider), ThemeChoice.dark);
    expect(stores.settings.values.values, contains('dark'));

    await palette(tester, 'OLED black');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(c.read(themeSettingProvider), ThemeChoice.oled);
    expect(stores.settings.values['settings.theme'], 'oled');
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: the quick add button asks for quick add', (
      tester,
    ) async {
      final stores = signedInStores();
      final c = await pumpScreen(
        tester,
        Scaffold(body: QuickAddButton(extended: size == desktop)),
        size: size,
        overrides: fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      expect(c.read(quickAddDraftsProvider), isNull);
      await tester.tap(find.byKey(const Key('shell.quickAdd')));
      await tester.pump();
      expect(c.read(quickAddDraftsProvider), isNotNull);
    });
  }
}
