// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

part 'settings.g.dart';

/// The chosen theme mode.
@Riverpod(keepAlive: true)
class ThemeModeSetting extends _$ThemeModeSetting {
  @override
  ThemeMode build() => ref.watch(settingsRepositoryProvider).themeMode();

  /// Switches to [mode] and remembers it.
  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsRepositoryProvider).setThemeMode(mode);
  }
}

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
