// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
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

  test('OLED is remembered and draws dark on black', () async {
    final settings = MemoryKeyValueStore();
    final c = makeContainer(fakeOverrides(FakeTix(), settings: settings));
    expect(c.read(darkTokensProvider), isNull);
    await c.read(themeSettingProvider.notifier).set(ThemeChoice.oled);
    expect(c.read(themeSettingProvider).mode, ThemeMode.dark);
    expect(c.read(darkTokensProvider), TixTokens.oled);
    expect(settings.values['settings.theme'], 'oled');

    await c.read(themeSettingProvider.notifier).set(ThemeChoice.dark);
    expect(c.read(darkTokensProvider), isNull);
  });

  test('Low contrast is remembered and draws the dim tokens', () async {
    final settings = MemoryKeyValueStore();
    final c = makeContainer(fakeOverrides(FakeTix(), settings: settings));
    await c.read(themeSettingProvider.notifier).set(ThemeChoice.dim);
    expect(c.read(themeSettingProvider).mode, ThemeMode.dark);
    expect(c.read(darkTokensProvider), TixTokens.dim);
    expect(settings.values['settings.theme'], 'dim');

    final again = makeContainer(fakeOverrides(FakeTix(), settings: settings));
    expect(again.read(themeSettingProvider), ThemeChoice.dim);
    expect(again.read(darkTokensProvider), TixTokens.dim);
  });

  test(
    'System, OLED when dark is the system choice with the black flag',
    () async {
      final settings = MemoryKeyValueStore();
      final c = makeContainer(fakeOverrides(FakeTix(), settings: settings));
      await c.read(themeSettingProvider.notifier).set(ThemeChoice.systemOled);
      expect(c.read(themeSettingProvider).mode, ThemeMode.system);
      expect(c.read(darkTokensProvider), TixTokens.oled);
      expect(settings.values, {
        'settings.theme': 'system',
        'settings.systemBlack': 'true',
      });

      final again = makeContainer(fakeOverrides(FakeTix(), settings: settings));
      expect(again.read(themeSettingProvider), ThemeChoice.systemOled);
      await again.read(themeSettingProvider.notifier).set(ThemeChoice.system);
      expect(again.read(darkTokensProvider), isNull);
      expect(settings.values.containsKey('settings.systemBlack'), isFalse);
    },
  );

  test('a device that had Pure black when dark on opens on it', () {
    for (final stored in [
      {'settings.theme': 'system', 'settings.systemBlack': 'true'},
      {'settings.systemBlack': 'true'},
    ]) {
      final settings = MemoryKeyValueStore()..values.addAll(stored);
      final c = makeContainer(fakeOverrides(FakeTix(), settings: settings));
      expect(c.read(themeSettingProvider), ThemeChoice.systemOled);
      expect(c.read(darkTokensProvider), TixTokens.oled);
    }
    final dark = MemoryKeyValueStore()
      ..values.addAll({
        'settings.theme': 'dark',
        'settings.systemBlack': 'true',
      });
    final c = makeContainer(fakeOverrides(FakeTix(), settings: dark));
    expect(c.read(themeSettingProvider), ThemeChoice.dark);
    expect(c.read(darkTokensProvider), isNull);
  });
}
