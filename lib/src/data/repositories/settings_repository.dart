// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';

part 'settings_repository.g.dart';

/// Theme and language choices.
class SettingsRepository {
  /// Keeps the choices in [_store].
  SettingsRepository(this._store);

  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';

  final KeyValueStore _store;

  /// The chosen theme mode, system by default.
  ThemeMode themeMode() => ThemeMode.values.firstWhere(
    (m) => m.name == _store.read(_themeKey),
    orElse: () => ThemeMode.system,
  );

  /// Saves [mode].
  Future<void> setThemeMode(ThemeMode mode) =>
      _store.write(_themeKey, mode.name);

  /// The chosen language code, null to follow the system.
  String? languageCode() => _store.read(_localeKey);

  /// Saves [code], or follows the system again when it is null.
  Future<void> setLanguageCode(String? code) =>
      code == null ? _store.delete(_localeKey) : _store.write(_localeKey, code);
}

/// Theme and language choices.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(ref.watch(keyValueStoreProvider));
