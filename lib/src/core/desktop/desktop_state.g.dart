// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'desktop_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What this desktop offers, asked once. [DesktopCaps.none] on phones.

@ProviderFor(desktopCaps)
final desktopCapsProvider = DesktopCapsProvider._();

/// What this desktop offers, asked once. [DesktopCaps.none] on phones.

final class DesktopCapsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DesktopCaps>,
          DesktopCaps,
          FutureOr<DesktopCaps>
        >
    with $FutureModifier<DesktopCaps>, $FutureProvider<DesktopCaps> {
  /// What this desktop offers, asked once. [DesktopCaps.none] on phones.
  DesktopCapsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'desktopCapsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$desktopCapsHash();

  @$internal
  @override
  $FutureProviderElement<DesktopCaps> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DesktopCaps> create(Ref ref) {
    return desktopCaps(ref);
  }
}

String _$desktopCapsHash() => r'5c0e37210239325b82fc4e97435cfc5641f1a48b';

/// The active context's unread inbox count for the tray and the dock, null
/// before it has counted. Core cannot read the inbox, so `main` puts the
/// inbox's count in place of this null; it is only watched while someone is
/// signed in.

@ProviderFor(trayUnread)
final trayUnreadProvider = TrayUnreadProvider._();

/// The active context's unread inbox count for the tray and the dock, null
/// before it has counted. Core cannot read the inbox, so `main` puts the
/// inbox's count in place of this null; it is only watched while someone is
/// signed in.

final class TrayUnreadProvider extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// The active context's unread inbox count for the tray and the dock, null
  /// before it has counted. Core cannot read the inbox, so `main` puts the
  /// inbox's count in place of this null; it is only watched while someone is
  /// signed in.
  TrayUnreadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trayUnreadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trayUnreadHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return trayUnread(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$trayUnreadHash() => r'df6ce6a308e1fabc9c1e8da71c3e45a7bbbf32ee';

/// Whether closing the window hides it to the tray: on until turned off
/// where a tray shows, and always off where none does, so the window can
/// never vanish with no way back.

@ProviderFor(CloseToTraySetting)
final closeToTraySettingProvider = CloseToTraySettingProvider._();

/// Whether closing the window hides it to the tray: on until turned off
/// where a tray shows, and always off where none does, so the window can
/// never vanish with no way back.
final class CloseToTraySettingProvider
    extends $NotifierProvider<CloseToTraySetting, bool> {
  /// Whether closing the window hides it to the tray: on until turned off
  /// where a tray shows, and always off where none does, so the window can
  /// never vanish with no way back.
  CloseToTraySettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'closeToTraySettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$closeToTraySettingHash();

  @$internal
  @override
  CloseToTraySetting create() => CloseToTraySetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$closeToTraySettingHash() =>
    r'0acb22a540a1cda15696f4fed1df72c1d8051600';

/// Whether closing the window hides it to the tray: on until turned off
/// where a tray shows, and always off where none does, so the window can
/// never vanish with no way back.

abstract class _$CloseToTraySetting extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the app starts at login. The platform's answer where it can
/// give one, else what was last chosen here (Flatpak's portal cannot be
/// asked).

@ProviderFor(AutostartSetting)
final autostartSettingProvider = AutostartSettingProvider._();

/// Whether the app starts at login. The platform's answer where it can
/// give one, else what was last chosen here (Flatpak's portal cannot be
/// asked).
final class AutostartSettingProvider
    extends $AsyncNotifierProvider<AutostartSetting, bool> {
  /// Whether the app starts at login. The platform's answer where it can
  /// give one, else what was last chosen here (Flatpak's portal cannot be
  /// asked).
  AutostartSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autostartSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autostartSettingHash();

  @$internal
  @override
  AutostartSetting create() => AutostartSetting();
}

String _$autostartSettingHash() => r'8d6e5c2849de8ad41a033716302a420eaa88833d';

/// Whether the app starts at login. The platform's answer where it can
/// give one, else what was last chosen here (Flatpak's portal cannot be
/// asked).

abstract class _$AutostartSetting extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the global quick-add hotkey is on, where the desktop has global
/// hotkeys.

@ProviderFor(QuickAddHotkeySetting)
final quickAddHotkeySettingProvider = QuickAddHotkeySettingProvider._();

/// Whether the global quick-add hotkey is on, where the desktop has global
/// hotkeys.
final class QuickAddHotkeySettingProvider
    extends $NotifierProvider<QuickAddHotkeySetting, bool> {
  /// Whether the global quick-add hotkey is on, where the desktop has global
  /// hotkeys.
  QuickAddHotkeySettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickAddHotkeySettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickAddHotkeySettingHash();

  @$internal
  @override
  QuickAddHotkeySetting create() => QuickAddHotkeySetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$quickAddHotkeySettingHash() =>
    r'7e9af5fd5ffe7a3d620825853eef6e89596081aa';

/// Whether the global quick-add hotkey is on, where the desktop has global
/// hotkeys.

abstract class _$QuickAddHotkeySetting extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
