// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/storage/stores.dart';

/// The choices kept on this device: theme, language, motion, haptics, the
/// screen the app opens on, the local engine's idle timeout and the desktop's
/// tray, login and hotkey choices, the update choices and the keyboard
/// shortcuts, stored by name.
class SettingsRepository {
  /// Keeps the choices in [_store].
  SettingsRepository(this._store);

  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';
  static const _systemBlackKey = 'settings.systemBlack';
  static const _idleKey = 'settings.local_idle_minutes';
  static const _widgetLockCountsKey = 'settings.widgetLockCounts';
  static const _hapticsKey = 'settings.haptics';
  static const _reduceMotionKey = 'settings.reduceMotion';
  static const _startKey = 'settings.start';
  static const _closeToTrayKey = 'settings.closeToTray';
  static const _autostartKey = 'settings.autostart';
  static const _hotkeyKey = 'settings.quickAddHotkey';
  static const _updateCheckKey = 'settings.updateCheck';
  static const _updateAutoKey = 'settings.updateAutoInstall';
  static const _shortcutsKey = 'settings.shortcuts';
  static const _keymapKey = 'settings.keymap';

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

  /// Whether touch feedback is on; on until turned off.
  bool haptics() => _store.read(_hapticsKey) != 'off';

  /// Saves whether touch feedback is on.
  Future<void> setHaptics({required bool on}) =>
      on ? _store.delete(_hapticsKey) : _store.write(_hapticsKey, 'off');

  /// Whether the app keeps still whatever the platform asks.
  bool reduceMotion() => _store.read(_reduceMotionKey) == 'true';

  /// Saves whether the app keeps still.
  Future<void> setReduceMotion({required bool on}) => on
      ? _store.write(_reduceMotionKey, 'true')
      : _store.delete(_reduceMotionKey);

  /// The name of the screen the app opens on, null for the default.
  String? startScreen() => _store.read(_startKey);

  /// Saves the screen named [name] to open on, or the default with null.
  Future<void> setStartScreen(String? name) =>
      name == null ? _store.delete(_startKey) : _store.write(_startKey, name);

  /// Whether closing the window hides it to the tray, null when never
  /// chosen.
  bool? closeToTray() => switch (_store.read(_closeToTrayKey)) {
    'true' => true,
    'false' => false,
    _ => null,
  };

  /// Saves whether closing the window hides it to the tray.
  Future<void> setCloseToTray({required bool on}) =>
      _store.write(_closeToTrayKey, '$on');

  /// Whether start at login was turned on here, for platforms that cannot
  /// be asked.
  bool autostart() => _store.read(_autostartKey) == 'true';

  /// Saves whether start at login is on.
  Future<void> setAutostart({required bool on}) =>
      on ? _store.write(_autostartKey, 'true') : _store.delete(_autostartKey);

  /// Whether the global quick-add hotkey is on.
  bool quickAddHotkey() => _store.read(_hotkeyKey) == 'true';

  /// Saves whether the global quick-add hotkey is on.
  Future<void> setQuickAddHotkey({required bool on}) =>
      on ? _store.write(_hotkeyKey, 'true') : _store.delete(_hotkeyKey);

  /// Whether the app looks for updates on its own; on until turned off.
  bool updateCheck() => _store.read(_updateCheckKey) != 'off';

  /// Saves whether the app looks for updates on its own.
  Future<void> setUpdateCheck({required bool on}) => on
      ? _store.delete(_updateCheckKey)
      : _store.write(_updateCheckKey, 'off');

  /// Whether a downloaded update is installed on quit; off until turned on.
  bool updateAutoInstall() => _store.read(_updateAutoKey) == 'true';

  /// Saves whether a downloaded update is installed on quit.
  Future<void> setUpdateAutoInstall({required bool on}) =>
      on ? _store.write(_updateAutoKey, 'true') : _store.delete(_updateAutoKey);

  /// Whether keyboard shortcuts are on; on until turned off.
  bool shortcuts() => _store.read(_shortcutsKey) != 'off';

  /// Saves whether keyboard shortcuts are on.
  Future<void> setShortcuts({required bool on}) =>
      on ? _store.delete(_shortcutsKey) : _store.write(_shortcutsKey, 'off');

  /// The keymap preset's name, null when never chosen.
  String? keymap() => _store.read(_keymapKey);

  /// Saves the keymap preset named [name], or the default with null.
  Future<void> setKeymap(String? name) =>
      name == null ? _store.delete(_keymapKey) : _store.write(_keymapKey, name);
}
