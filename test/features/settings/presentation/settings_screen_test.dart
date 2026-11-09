// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/fake_widgets.dart';
import '../../../helpers/stores.dart';

void main() {
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    Size size = const Size(500, 1000),
    Locale locale = const Locale('en'),
    bool local = false,
    FakeWidgetBridge? widgets,
  }) {
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
      size: size,
      locale: locale,
      overrides: fakeOverrides(
        FakeTix(),
        settings: s.settings,
        secrets: s.secrets,
        local: local,
        widgets: widgets,
      ),
    );
  }

  testWidgets('the idle timeout of local engines is chosen and kept', (
    tester,
  ) async {
    final c = await pump(tester, local: true);
    final idle = find.byKey(const Key('settings.localIdle'));
    expect(tester.widget<SegmentedButton<int>>(idle).selected, {10});
    await tester.ensureVisible(idle);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: idle, matching: find.text('Never')));
    await tester.pumpAndSettle();
    expect(c.read(localIdleTimeoutProvider), isNull);
    expect(stores.settings.values['settings.local_idle_minutes'], '0');
    await tester.tap(find.descendant(of: idle, matching: find.text('30 min')));
    await tester.pumpAndSettle();
    expect(c.read(localEnginesProvider).idleAfter, const Duration(minutes: 30));
  });

  testWidgets('without local databases there is no idle timeout', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byKey(const Key('settings.localIdle')), findsNothing);
  });

  testWidgets('theme and language are chosen and remembered', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.text('Dark'));
    await tester.tap(find.text('Български'));
    await tester.pumpAndSettle();
    expect(c.read(themeSettingProvider), ThemeChoice.dark);
    expect(c.read(localeSettingProvider), const Locale('bg'));
    expect(stores.settings.values['settings.theme'], 'dark');
    expect(stores.settings.values['settings.locale'], 'bg');
    await tester.tap(find.text('System').last);
    await tester.pumpAndSettle();
    expect(c.read(localeSettingProvider), isNull);
  });

  testWidgets('OLED black is a theme, and the system can go black', (
    tester,
  ) async {
    final c = await pump(tester);
    final toggle = find.byKey(const Key('settings.systemBlack'));
    expect(toggle, findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(c.read(systemBlackSettingProvider), isTrue);
    expect(stores.settings.values['settings.systemBlack'], 'true');

    await tester.tap(find.text('OLED black'));
    await tester.pumpAndSettle();
    expect(c.read(themeSettingProvider), ThemeChoice.oled);
    expect(stores.settings.values['settings.theme'], 'oled');
    expect(toggle, findsNothing);
  });

  testWidgets('widgets keep the lock screen to counts until turned off', (
    tester,
  ) async {
    final c = await pump(tester, widgets: FakeWidgetBridge());
    final toggle = find.byKey(const Key('settings.widgetLockCounts'));
    await tester.scrollUntilVisible(toggle, 200);
    expect(c.read(widgetLockCountsSettingProvider), isTrue);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(c.read(widgetLockCountsSettingProvider), isFalse);
    expect(stores.settings.values['settings.widgetLockCounts'], 'false');
    expect(c.read(widgetsStaleProvider), 1);
  });

  testWidgets('no widgets section where the platform has none', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('settings.widgets')), findsNothing);
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
    await tester.ensureVisible(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(stores.secrets.values.containsKey('token.c1'), isTrue);

    await tester.ensureVisible(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
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

  testWidgets('about opens the About screen', (tester) async {
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
    expect(
      find.descendant(of: about, matching: find.byType(TixMark)),
      findsOneWidget,
    );
    await tester.ensureVisible(about);
    await tester.pumpAndSettle();
    await tester.tap(about);
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/about'), findsOneWidget);
  });

  testWidgets('every language is offered in its own name', (tester) async {
    await pump(tester);
    for (final name in ['English', 'Български', 'Français', 'Deutsch']) {
      expect(find.text(name), findsOneWidget);
    }
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(stores.settings.values['settings.locale'], 'de');
  });

  for (final locale in textLocales) {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width, $locale: fits at twice the text size', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pump(tester, size: size, locale: locale);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
