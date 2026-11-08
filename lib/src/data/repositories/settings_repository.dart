// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/storage/stores.dart';

/// Theme and language choices, stored by name.
class SettingsRepository {
  /// Keeps the choices in [_store].
  SettingsRepository(this._store);

  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';
  static const _systemBlackKey = 'settings.systemBlack';

  final KeyValueStore _store;

  /// The chosen theme's name, null when never chosen.
  String? themeMode() => _store.read(_themeKey);

  /// Saves the theme named [name].
  Future<void> setThemeMode(String name) => _store.write(_themeKey, name);

  /// Whether the system theme's dark is pure black.
  bool systemBlack() => _store.read(_systemBlackKey) == 'true';

  /// Saves whether the system theme's dark is pure black.
  Future<void> setSystemBlack({required bool on}) => on
      ? _store.write(_systemBlackKey, 'true')
      : _store.delete(_systemBlackKey);

  /// The chosen language code, null to follow the system.
  String? languageCode() => _store.read(_localeKey);

  /// Saves [code], or follows the system again when it is null.
  Future<void> setLanguageCode(String? code) =>
      code == null ? _store.delete(_localeKey) : _store.write(_localeKey, code);
}
