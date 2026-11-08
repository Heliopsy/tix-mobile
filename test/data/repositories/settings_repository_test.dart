// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

import '../../helpers/stores.dart';

void main() {
  test('theme mode defaults to system and round-trips', () async {
    final store = MemoryKeyValueStore();
    final repo = SettingsRepository(store);
    expect(repo.themeMode(), ThemeMode.system);
    await repo.setThemeMode(ThemeMode.dark);
    expect(repo.themeMode(), ThemeMode.dark);
    store.values['settings.theme'] = 'neon';
    expect(repo.themeMode(), ThemeMode.system);
  });

  test('language follows the system until chosen', () async {
    final repo = SettingsRepository(MemoryKeyValueStore());
    expect(repo.languageCode(), isNull);
    await repo.setLanguageCode('bg');
    expect(repo.languageCode(), 'bg');
    await repo.setLanguageCode(null);
    expect(repo.languageCode(), isNull);
  });
}
