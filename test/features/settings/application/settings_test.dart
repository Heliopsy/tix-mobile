// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  test('theme and language are remembered', () async {
    final settings = MemoryKeyValueStore();
    final c = makeContainer(fakeOverrides(FakeTix(), settings: settings));
    expect(c.read(themeSettingProvider), ThemeChoice.system);
    expect(c.read(localeSettingProvider), isNull);
    await c.read(themeSettingProvider.notifier).set(ThemeChoice.dark);
    await c.read(localeSettingProvider.notifier).set(const Locale('bg'));
    expect(c.read(themeSettingProvider), ThemeChoice.dark);
    expect(c.read(localeSettingProvider), const Locale('bg'));
    expect(settings.values, {
      'settings.theme': 'dark',
      'settings.locale': 'bg',
    });

    final again = makeContainer(fakeOverrides(FakeTix(), settings: settings));
    expect(again.read(themeSettingProvider), ThemeChoice.dark);
    expect(again.read(localeSettingProvider), const Locale('bg'));
    settings.values['settings.theme'] = 'neon';
    again.invalidate(settingsRepositoryProvider);
    expect(again.read(themeSettingProvider), ThemeChoice.system);
    await again.read(localeSettingProvider.notifier).set(null);
    expect(settings.values.containsKey('settings.locale'), isFalse);
  });

  test('OLED black is remembered and draws dark on black', () async {
    final settings = MemoryKeyValueStore();
    final c = makeContainer(fakeOverrides(FakeTix(), settings: settings));
    expect(c.read(darkIsBlackProvider), isFalse);
    await c.read(themeSettingProvider.notifier).set(ThemeChoice.oled);
    expect(c.read(themeSettingProvider).mode, ThemeMode.dark);
    expect(c.read(darkIsBlackProvider), isTrue);
    expect(settings.values['settings.theme'], 'oled');

    await c.read(themeSettingProvider.notifier).set(ThemeChoice.dark);
    expect(c.read(darkIsBlackProvider), isFalse);
    await c.read(themeSettingProvider.notifier).set(ThemeChoice.system);
    expect(c.read(themeSettingProvider).mode, ThemeMode.system);
    expect(c.read(darkIsBlackProvider), isFalse);
    await c.read(systemBlackSettingProvider.notifier).set(on: true);
    expect(c.read(darkIsBlackProvider), isTrue);
    expect(settings.values['settings.systemBlack'], 'true');

    final again = makeContainer(fakeOverrides(FakeTix(), settings: settings));
    expect(again.read(darkIsBlackProvider), isTrue);
    await again.read(themeSettingProvider.notifier).set(ThemeChoice.light);
    expect(again.read(darkIsBlackProvider), isFalse);
    await again.read(systemBlackSettingProvider.notifier).set(on: false);
    expect(settings.values.containsKey('settings.systemBlack'), isFalse);
  });
}
