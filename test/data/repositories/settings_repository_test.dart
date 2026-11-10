// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

import '../../helpers/stores.dart';

void main() {
  test('theme mode is unset until chosen and round-trips', () async {
    final repo = SettingsRepository(MemoryKeyValueStore());
    expect(repo.themeMode(), isNull);
    await repo.setThemeMode('dark');
    expect(repo.themeMode(), 'dark');
  });

  test('language follows the system until chosen', () async {
    final repo = SettingsRepository(MemoryKeyValueStore());
    expect(repo.languageCode(), isNull);
    await repo.setLanguageCode('bg');
    expect(repo.languageCode(), 'bg');
    await repo.setLanguageCode(null);
    expect(repo.languageCode(), isNull);
  });

  test('the local idle timeout is unset until chosen', () async {
    final repo = SettingsRepository(MemoryKeyValueStore());
    expect(repo.localIdleMinutes(), isNull);
    await repo.setLocalIdleMinutes(0);
    expect(repo.localIdleMinutes(), 0);
    await repo.setLocalIdleMinutes(30);
    expect(repo.localIdleMinutes(), 30);
  });

  test('close to tray is unset until chosen, then either way', () async {
    final repo = SettingsRepository(MemoryKeyValueStore());
    expect(repo.closeToTray(), isNull);
    await repo.setCloseToTray(on: false);
    expect(repo.closeToTray(), isFalse);
    await repo.setCloseToTray(on: true);
    expect(repo.closeToTray(), isTrue);
  });

  test('start at login and the hotkey are off until turned on', () async {
    final store = MemoryKeyValueStore();
    final repo = SettingsRepository(store);
    expect(repo.autostart(), isFalse);
    expect(repo.quickAddHotkey(), isFalse);
    await repo.setAutostart(on: true);
    await repo.setQuickAddHotkey(on: true);
    expect(repo.autostart(), isTrue);
    expect(repo.quickAddHotkey(), isTrue);
    await repo.setAutostart(on: false);
    await repo.setQuickAddHotkey(on: false);
    expect(store.values, isEmpty);
  });
}
