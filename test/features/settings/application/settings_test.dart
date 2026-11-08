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
    expect(c.read(themeModeSettingProvider), ThemeMode.system);
    expect(c.read(localeSettingProvider), isNull);
    await c.read(themeModeSettingProvider.notifier).set(ThemeMode.dark);
    await c.read(localeSettingProvider.notifier).set(const Locale('bg'));
    expect(c.read(themeModeSettingProvider), ThemeMode.dark);
    expect(c.read(localeSettingProvider), const Locale('bg'));
    expect(settings.values, {
      'settings.theme': 'dark',
      'settings.locale': 'bg',
    });

    final again = makeContainer(fakeOverrides(FakeTix(), settings: settings));
    expect(again.read(themeModeSettingProvider), ThemeMode.dark);
    expect(again.read(localeSettingProvider), const Locale('bg'));
    settings.values['settings.theme'] = 'neon';
    again.invalidate(settingsRepositoryProvider);
    expect(again.read(themeModeSettingProvider), ThemeMode.system);
    await again.read(localeSettingProvider.notifier).set(null);
    expect(settings.values.containsKey('settings.locale'), isFalse);
  });
}
