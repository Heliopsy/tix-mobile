// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'adb_bridge.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether `am broadcast` commands run in a release build: off until a
/// person turns it on, and kept on this device only.

@ProviderFor(AdbControlSetting)
final adbControlSettingProvider = AdbControlSettingProvider._();

/// Whether `am broadcast` commands run in a release build: off until a
/// person turns it on, and kept on this device only.
final class AdbControlSettingProvider
    extends $NotifierProvider<AdbControlSetting, bool> {
  /// Whether `am broadcast` commands run in a release build: off until a
  /// person turns it on, and kept on this device only.
  AdbControlSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adbControlSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adbControlSettingHash();

  @$internal
  @override
  AdbControlSetting create() => AdbControlSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adbControlSettingHash() => r'aebaf8ce7233076de81c9ec87de1bf7679f90cf2';

/// Whether `am broadcast` commands run in a release build: off until a
/// person turns it on, and kept on this device only.

abstract class _$AdbControlSetting extends $Notifier<bool> {
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

/// Whether this platform has ADB, so Settings offers the switch.

@ProviderFor(adbControlOffered)
final adbControlOfferedProvider = AdbControlOfferedProvider._();

/// Whether this platform has ADB, so Settings offers the switch.

final class AdbControlOfferedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this platform has ADB, so Settings offers the switch.
  AdbControlOfferedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adbControlOfferedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adbControlOfferedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return adbControlOffered(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adbControlOfferedHash() => r'05ed44d072ea293d7889900498a00b84a8425770';

/// Whether this is a debug build, which runs every command.

@ProviderFor(adbDebugBuild)
final adbDebugBuildProvider = AdbDebugBuildProvider._();

/// Whether this is a debug build, which runs every command.

final class AdbDebugBuildProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this is a debug build, which runs every command.
  AdbDebugBuildProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adbDebugBuildProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adbDebugBuildHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return adbDebugBuild(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adbDebugBuildHash() => r'b6080a7ae923b9c11048aea40cefc55df31bbea7';

/// Whether this is the engine Android starts to answer ADB while the app is
/// not open: no session, no live updates, no local engine.

@ProviderFor(adbHeadless)
final adbHeadlessProvider = AdbHeadlessProvider._();

/// Whether this is the engine Android starts to answer ADB while the app is
/// not open: no session, no live updates, no local engine.

final class AdbHeadlessProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this is the engine Android starts to answer ADB while the app is
  /// not open: no session, no live updates, no local engine.
  AdbHeadlessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adbHeadlessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adbHeadlessHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return adbHeadless(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adbHeadlessHash() => r'74a81880445de2b591a5f0997e3773bff5f9123b';

/// How commands change theme and language. `main` swaps in the settings
/// feature's, which redraws the app at once.

@ProviderFor(adbAppearance)
final adbAppearanceProvider = AdbAppearanceProvider._();

/// How commands change theme and language. `main` swaps in the settings
/// feature's, which redraws the app at once.

final class AdbAppearanceProvider
    extends $FunctionalProvider<AdbAppearance, AdbAppearance, AdbAppearance>
    with $Provider<AdbAppearance> {
  /// How commands change theme and language. `main` swaps in the settings
  /// feature's, which redraws the app at once.
  AdbAppearanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adbAppearanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adbAppearanceHash();

  @$internal
  @override
  $ProviderElement<AdbAppearance> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdbAppearance create(Ref ref) {
    return adbAppearance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdbAppearance value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdbAppearance>(value),
    );
  }
}

String _$adbAppearanceHash() => r'90e0555599e23a850c365a40f728b3e77237ef66';

/// The bridge of this engine.

@ProviderFor(adbBridge)
final adbBridgeProvider = AdbBridgeProvider._();

/// The bridge of this engine.

final class AdbBridgeProvider
    extends $FunctionalProvider<AdbBridge, AdbBridge, AdbBridge>
    with $Provider<AdbBridge> {
  /// The bridge of this engine.
  AdbBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adbBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adbBridgeHash();

  @$internal
  @override
  $ProviderElement<AdbBridge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdbBridge create(Ref ref) {
    return adbBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdbBridge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdbBridge>(value),
    );
  }
}

String _$adbBridgeHash() => r'134f075b052cf39798e20c6a77e87d2dc06b90d3';
