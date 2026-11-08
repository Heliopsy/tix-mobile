// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/storage/stores.dart';

/// Theme, language and local engine choices, stored by name.
class SettingsRepository {
  /// Keeps the choices in [_store].
  SettingsRepository(this._store);

  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';
  static const _systemBlackKey = 'settings.systemBlack';
  static const _idleKey = 'settings.local_idle_minutes';
  static const _widgetLockCountsKey = 'settings.widgetLockCounts';

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

  /// Minutes a local engine may sit idle before it stops, 0 for never; null
  /// when never chosen.
  int? localIdleMinutes() => int.tryParse(_store.read(_idleKey) ?? '');

  /// Saves [minutes] as the local engine idle timeout, 0 for never.
  Future<void> setLocalIdleMinutes(int minutes) =>
      _store.write(_idleKey, '$minutes');

  /// Whether widgets on the lock screen show counts only; on until turned
  /// off.
  bool widgetLockCounts() => _store.read(_widgetLockCountsKey) != 'false';

  /// Saves whether widgets on the lock screen show counts only.
  Future<void> setWidgetLockCounts({required bool on}) => on
      ? _store.delete(_widgetLockCountsKey)
      : _store.write(_widgetLockCountsKey, 'false');
}
