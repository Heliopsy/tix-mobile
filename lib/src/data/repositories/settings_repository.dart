// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/storage/stores.dart';

/// Theme and language choices, stored by name.
class SettingsRepository {
  /// Keeps the choices in [_store].
  SettingsRepository(this._store);

  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';

  final KeyValueStore _store;

  /// The chosen theme mode's name, null when never chosen.
  String? themeMode() => _store.read(_themeKey);

  /// Saves the theme mode named [name].
  Future<void> setThemeMode(String name) => _store.write(_themeKey, name);

  /// The chosen language code, null to follow the system.
  String? languageCode() => _store.read(_localeKey);

  /// Saves [code], or follows the system again when it is null.
  Future<void> setLanguageCode(String? code) =>
      code == null ? _store.delete(_localeKey) : _store.write(_localeKey, code);
}
