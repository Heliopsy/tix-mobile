// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'keyboard_setting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The keyboard shortcut choices on this device. In `core` rather than the
/// settings feature because the shortcut layer in `core/design` reads it.

@ProviderFor(KeyboardSetting)
final keyboardSettingProvider = KeyboardSettingProvider._();

/// The keyboard shortcut choices on this device. In `core` rather than the
/// settings feature because the shortcut layer in `core/design` reads it.
final class KeyboardSettingProvider
    extends $NotifierProvider<KeyboardSetting, KeyboardChoice> {
  /// The keyboard shortcut choices on this device. In `core` rather than the
  /// settings feature because the shortcut layer in `core/design` reads it.
  KeyboardSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyboardSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyboardSettingHash();

  @$internal
  @override
  KeyboardSetting create() => KeyboardSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyboardChoice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyboardChoice>(value),
    );
  }
}

String _$keyboardSettingHash() => r'590fbe5e9b14888f3a4d0a7c0e866b2a8e30caec';

/// The keyboard shortcut choices on this device. In `core` rather than the
/// settings feature because the shortcut layer in `core/design` reads it.

abstract class _$KeyboardSetting extends $Notifier<KeyboardChoice> {
  KeyboardChoice build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<KeyboardChoice, KeyboardChoice>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KeyboardChoice, KeyboardChoice>,
              KeyboardChoice,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The keymap in force.

@ProviderFor(activeKeymap)
final activeKeymapProvider = ActiveKeymapProvider._();

/// The keymap in force.

final class ActiveKeymapProvider
    extends $FunctionalProvider<Keymap, Keymap, Keymap>
    with $Provider<Keymap> {
  /// The keymap in force.
  ActiveKeymapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeKeymapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeKeymapHash();

  @$internal
  @override
  $ProviderElement<Keymap> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Keymap create(Ref ref) {
    return activeKeymap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Keymap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Keymap>(value),
    );
  }
}

String _$activeKeymapHash() => r'c74a0dc9fea7a25fe9500d56f1a49df1390b4380';
