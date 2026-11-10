// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/keyboard/keymap.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

export 'package:tix_mobile/src/core/keyboard/keymap.dart';

part 'keyboard_setting.g.dart';

/// Whether shortcuts are on and which preset, as kept on this device.
typedef KeyboardChoice = ({bool enabled, KeymapPreset preset});

/// The keyboard shortcut choices on this device. In `core` rather than the
/// settings feature because the shortcut layer in `core/design` reads it.
@Riverpod(keepAlive: true)
class KeyboardSetting extends _$KeyboardSetting {
  SettingsRepository get _repo =>
      SettingsRepository(ref.read(keyValueStoreProvider));

  @override
  KeyboardChoice build() {
    final repo = SettingsRepository(ref.watch(keyValueStoreProvider));
    return (
      enabled: repo.shortcuts(),
      preset: KeymapPreset.byId(repo.keymap()),
    );
  }

  /// Turns every shortcut on or off and remembers it.
  Future<void> setEnabled({required bool on}) async {
    state = (enabled: on, preset: state.preset);
    await _repo.setShortcuts(on: on);
  }

  /// Switches to [preset] and remembers it.
  Future<void> setPreset(KeymapPreset preset) async {
    state = (enabled: state.enabled, preset: preset);
    await _repo.setKeymap(preset == KeymapPreset.standard ? null : preset.id);
  }
}

/// The keymap in force.
@Riverpod(keepAlive: true)
Keymap activeKeymap(Ref ref) {
  final choice = ref.watch(keyboardSettingProvider);
  return Keymap.of(choice.preset, enabled: choice.enabled);
}
