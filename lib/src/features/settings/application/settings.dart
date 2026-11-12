// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/platform/adb_bridge.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

part 'settings.g.dart';

/// Theme and language choices.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(ref.watch(keyValueStoreProvider));

/// The colour scheme a person picks, in the order tix's web offers them.
/// [oled] is dark on a pure black page; [dim] is tix's Low contrast.
enum ThemeChoice {
  /// Follow the platform's light or dark.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,

  /// Always dark, on pure black.
  oled,

  /// Always dark, with softer contrast.
  dim,

  /// Follow the platform, on pure black whenever it is dark.
  systemOled;

  /// The Material theme mode this choice runs in.
  ThemeMode get mode => switch (this) {
    system || systemOled => ThemeMode.system,
    light => ThemeMode.light,
    dark || oled || dim => ThemeMode.dark,
  };
}

/// The chosen colour scheme. [ThemeChoice.systemOled] is kept as the
/// system choice with the pure-black flag, the way it was stored before it
/// was a choice of its own, so older stored values read the same.
@Riverpod(keepAlive: true)
class ThemeSetting extends _$ThemeSetting {
  @override
  ThemeChoice build() {
    final repo = ref.watch(settingsRepositoryProvider);
    final choice = ThemeChoice.values.firstWhere(
      (m) => m.name == repo.themeMode(),
      orElse: () => ThemeChoice.system,
    );
    return choice == ThemeChoice.system && repo.systemBlack()
        ? ThemeChoice.systemOled
        : choice;
  }

  /// Switches to [choice] and remembers it.
  Future<void> set(ThemeChoice choice) async {
    state = choice;
    final repo = ref.read(settingsRepositoryProvider);
    final oled = choice == ThemeChoice.systemOled;
    await repo.setThemeMode(oled ? ThemeChoice.system.name : choice.name);
    await repo.setSystemBlack(on: oled);
    ref.read(widgetsStaleProvider.notifier).touch();
  }
}

/// The tokens the dark theme is built on: OLED black, Low contrast, or
/// null for tix's dark.
@Riverpod(keepAlive: true)
TixTokens? darkTokens(Ref ref) => switch (ref.watch(themeSettingProvider)) {
  ThemeChoice.oled || ThemeChoice.systemOled => TixTokens.oled,
  ThemeChoice.dim => TixTokens.dim,
  ThemeChoice.system || ThemeChoice.light || ThemeChoice.dark => null,
};

/// The chosen language, null to follow the system.
@Riverpod(keepAlive: true)
class LocaleSetting extends _$LocaleSetting {
  @override
  Locale? build() {
    final code = ref.watch(settingsRepositoryProvider).languageCode();
    return code == null ? null : Locale(code);
  }

  /// Switches to [locale], or back to the system's with null.
  Future<void> set(Locale? locale) async {
    state = locale;
    await ref
        .read(settingsRepositoryProvider)
        .setLanguageCode(locale?.languageCode);
    ref.read(widgetsStaleProvider.notifier).touch();
  }
}

/// Theme and language changed over ADB, through the same notifiers as the
/// Settings screen, so the app redraws at once. `main` puts it in place of
/// the stored-only default.
class LiveAppearance implements AdbAppearance {
  /// Changes settings through [_ref].
  LiveAppearance(this._ref);

  final Ref _ref;

  @override
  Future<void> setTheme(String name) => _ref
      .read(themeSettingProvider.notifier)
      .set(ThemeChoice.values.byName(name));

  @override
  Future<void> setLocale(String? code) => _ref
      .read(localeSettingProvider.notifier)
      .set(code == null ? null : Locale(code));
}

/// Whether widgets on the lock screen show counts only.
@Riverpod(keepAlive: true)
class WidgetLockCountsSetting extends _$WidgetLockCountsSetting {
  @override
  bool build() => ref.watch(settingsRepositoryProvider).widgetLockCounts();

  /// Turns counts only on or off, remembers it and rewrites the widgets.
  Future<void> set({required bool on}) async {
    state = on;
    await ref.read(settingsRepositoryProvider).setWidgetLockCounts(on: on);
    ref.read(widgetsStaleProvider.notifier).touch();
  }
}

/// Whether touch feedback is on, on this device.
@Riverpod(keepAlive: true)
class HapticsSetting extends _$HapticsSetting {
  @override
  bool build() => ref.watch(settingsRepositoryProvider).haptics();

  /// Turns touch feedback on or off and remembers it.
  Future<void> set({required bool on}) async {
    state = on;
    await ref.read(settingsRepositoryProvider).setHaptics(on: on);
  }
}

/// Whether the app keeps still whatever the platform asks, on this device.
@Riverpod(keepAlive: true)
class ReduceMotionSetting extends _$ReduceMotionSetting {
  @override
  bool build() => ref.watch(settingsRepositoryProvider).reduceMotion();

  /// Turns reduced motion on or off and remembers it.
  Future<void> set({required bool on}) async {
    state = on;
    await ref.read(settingsRepositoryProvider).setReduceMotion(on: on);
  }
}

/// The screen the app opens on, on this device.
@Riverpod(keepAlive: true)
class StartScreenSetting extends _$StartScreenSetting {
  @override
  StartScreen build() =>
      StartScreen.named(ref.watch(settingsRepositoryProvider).startScreen());

  /// Opens on [screen] from the next start.
  Future<void> set(StartScreen screen) async {
    state = screen;
    await ref
        .read(settingsRepositoryProvider)
        .setStartScreen(screen == StartScreen.projects ? null : screen.name);
  }
}

/// The views whose arrangement the reader can reset from Settings: the
/// board, lanes and My work, as tix names them.
const arrangedViews = ['board', 'lanes', 'mine'];

/// The reader's arrangements of the shared views, kept with their account.
@riverpod
class ArrangementSettings extends _$ArrangementSettings {
  @override
  void build() {}

  /// Forgets every group the reader hid, starred, collapsed or moved in
  /// [arrangedViews], on the server.
  Future<void> reset() async {
    final repo = ref.read(viewPrefsRepositoryProvider);
    final resets = ref.read(arrangementResetsProvider.notifier);
    try {
      await Future.wait([for (final v in arrangedViews) repo.reset(v)]);
    } finally {
      resets.bump();
    }
  }
}
