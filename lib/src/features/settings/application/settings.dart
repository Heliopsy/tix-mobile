// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

part 'settings.g.dart';

/// Theme and language choices.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(ref.watch(keyValueStoreProvider));

/// The theme a person picks. [oled] is dark on a pure black page.
enum ThemeChoice {
  /// Follow the platform's light or dark.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,

  /// Always dark, on pure black.
  oled;

  /// The Material theme mode this choice runs in.
  ThemeMode get mode => switch (this) {
    system => ThemeMode.system,
    light => ThemeMode.light,
    dark || oled => ThemeMode.dark,
  };
}

/// The chosen theme.
@Riverpod(keepAlive: true)
class ThemeSetting extends _$ThemeSetting {
  @override
  ThemeChoice build() {
    final name = ref.watch(settingsRepositoryProvider).themeMode();
    return ThemeChoice.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeChoice.system,
    );
  }

  /// Switches to [choice] and remembers it.
  Future<void> set(ThemeChoice choice) async {
    state = choice;
    await ref.read(settingsRepositoryProvider).setThemeMode(choice.name);
  }
}

/// Whether the system theme goes pure black when the platform is dark.
@Riverpod(keepAlive: true)
class SystemBlackSetting extends _$SystemBlackSetting {
  @override
  bool build() => ref.watch(settingsRepositoryProvider).systemBlack();

  /// Turns pure black for the system's dark on or off and remembers it.
  Future<void> set({required bool on}) async {
    state = on;
    await ref.read(settingsRepositoryProvider).setSystemBlack(on: on);
  }
}

/// Whether the dark theme is drawn on pure black.
@Riverpod(keepAlive: true)
bool darkIsBlack(Ref ref) => switch (ref.watch(themeSettingProvider)) {
  ThemeChoice.oled => true,
  ThemeChoice.system => ref.watch(systemBlackSettingProvider),
  ThemeChoice.light || ThemeChoice.dark => false,
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
  }
}
