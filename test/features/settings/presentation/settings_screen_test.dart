// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  Future<ProviderContainer> pump(WidgetTester tester) {
    final s = signedInStores();
    s.settings.values['contexts'] = jsonEncode([
      {
        'id': 'c1',
        'name': 'Work',
        'base_url': 'https://tix.example',
        'handle': 'ana',
      },
      {'id': 'c2', 'name': 'Home', 'base_url': 'https://home.example'},
    ]);
    s.secrets.values['token.c2'] = 'tok';
    stores = (settings: s.settings, secrets: s.secrets);
    return pumpScreen(
      tester,
      const SettingsScreen(),
      size: const Size(500, 1000),
      overrides: fakeOverrides(
        FakeTix(),
        settings: s.settings,
        secrets: s.secrets,
      ),
    );
  }

  testWidgets('theme and language are chosen and remembered', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.text('Dark'));
    await tester.tap(find.text('Български'));
    await tester.pumpAndSettle();
    expect(c.read(themeModeSettingProvider), ThemeMode.dark);
    expect(c.read(localeSettingProvider), const Locale('bg'));
    expect(stores.settings.values['settings.theme'], 'dark');
    expect(stores.settings.values['settings.locale'], 'bg');
    await tester.tap(find.text('System').last);
    await tester.pumpAndSettle();
    expect(c.read(localeSettingProvider), isNull);
  });

  testWidgets('instances shows the active context and opens the list', (
    tester,
  ) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('settings.instances')),
        matching: find.text('2 instances · Work · Default'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('settings.instances')));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/instances'), findsOneWidget);
  });

  testWidgets('add an instance goes to connect', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('settings.add')));
    await tester.pumpAndSettle();
    expect(find.text('route:/connect?add=1'), findsOneWidget);
  });

  testWidgets('sign out asks first and forgets the token', (tester) async {
    final c = await pump(tester);
    expect(find.text('Signed in as @ana'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(stores.secrets.values.containsKey('token.c1'), isTrue);

    await tester.tap(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('forgets this connection to Work'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(stores.secrets.values.containsKey('token.c1'), isFalse);
    expect(c.read(sessionControllerProvider).value!.connection.id, 'c2');
    expect(find.textContaining('1 instance · Home'), findsOneWidget);
  });

  testWidgets('about shows the tix mark beside the app name', (tester) async {
    await pump(tester);
    final about = find.byKey(const Key('settings.about'));
    await tester.scrollUntilVisible(
      about,
      100,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.tap(about);
    await tester.pumpAndSettle();
    final dialog = find.byType(AboutDialog);
    expect(
      find.descendant(of: dialog, matching: find.byType(TixMark)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('tix')),
      findsOneWidget,
    );
  });
}
