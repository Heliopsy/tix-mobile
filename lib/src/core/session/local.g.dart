// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'local.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the add-instance screen offers local databases: when this build
/// has the engine, unless `--dart-define=TIX_LOCAL_INSTANCES=false` (or
/// `true`, to show the screens in a build without it) says otherwise.

@ProviderFor(localInstancesEnabled)
final localInstancesEnabledProvider = LocalInstancesEnabledProvider._();

/// Whether the add-instance screen offers local databases: when this build
/// has the engine, unless `--dart-define=TIX_LOCAL_INSTANCES=false` (or
/// `true`, to show the screens in a build without it) says otherwise.

final class LocalInstancesEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the add-instance screen offers local databases: when this build
  /// has the engine, unless `--dart-define=TIX_LOCAL_INSTANCES=false` (or
  /// `true`, to show the screens in a build without it) says otherwise.
  LocalInstancesEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localInstancesEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localInstancesEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return localInstancesEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$localInstancesEnabledHash() =>
    r'590a3f61ee994e7a8a925bdf936920eed98326d2';

/// The embedded engine: libtix when this build bundles it, otherwise one
/// that says local databases are not available.

@ProviderFor(localTixEngine)
final localTixEngineProvider = LocalTixEngineProvider._();

/// The embedded engine: libtix when this build bundles it, otherwise one
/// that says local databases are not available.

final class LocalTixEngineProvider
    extends $FunctionalProvider<LocalTixEngine, LocalTixEngine, LocalTixEngine>
    with $Provider<LocalTixEngine> {
  /// The embedded engine: libtix when this build bundles it, otherwise one
  /// that says local databases are not available.
  LocalTixEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localTixEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localTixEngineHash();

  @$internal
  @override
  $ProviderElement<LocalTixEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalTixEngine create(Ref ref) {
    return localTixEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalTixEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalTixEngine>(value),
    );
  }
}

String _$localTixEngineHash() => r'92137b65b167ed58d9f58a4b4250ed0173cc6a52';

/// Whether engines stop while the app is in the background. Phones suspend
/// a backgrounded app anyway; desktops keep running when minimised.

@ProviderFor(localEnginesStopInBackground)
final localEnginesStopInBackgroundProvider =
    LocalEnginesStopInBackgroundProvider._();

/// Whether engines stop while the app is in the background. Phones suspend
/// a backgrounded app anyway; desktops keep running when minimised.

final class LocalEnginesStopInBackgroundProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether engines stop while the app is in the background. Phones suspend
  /// a backgrounded app anyway; desktops keep running when minimised.
  LocalEnginesStopInBackgroundProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localEnginesStopInBackgroundProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localEnginesStopInBackgroundHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return localEnginesStopInBackground(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$localEnginesStopInBackgroundHash() =>
    r'acbee4b01440a83c46d2cfcf7d6d1169bede6636';

/// The running engines; all stop when the container goes.

@ProviderFor(localEngines)
final localEnginesProvider = LocalEnginesProvider._();

/// The running engines; all stop when the container goes.

final class LocalEnginesProvider
    extends $FunctionalProvider<LocalEngines, LocalEngines, LocalEngines>
    with $Provider<LocalEngines> {
  /// The running engines; all stop when the container goes.
  LocalEnginesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localEnginesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localEnginesHash();

  @$internal
  @override
  $ProviderElement<LocalEngines> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalEngines create(Ref ref) {
    return localEngines(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalEngines value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalEngines>(value),
    );
  }
}

String _$localEnginesHash() => r'c6c30357d60ffa5861a528cbfa0b370cfd9257a0';

/// Stops every engine when the app exits, and on phones while it is in the
/// background, starting them again on resume. Read when a local instance
/// first becomes active; exit is a request on desktop and a detach on
/// phones, where it is best effort.

@ProviderFor(localEngineLifecycle)
final localEngineLifecycleProvider = LocalEngineLifecycleProvider._();

/// Stops every engine when the app exits, and on phones while it is in the
/// background, starting them again on resume. Read when a local instance
/// first becomes active; exit is a request on desktop and a detach on
/// phones, where it is best effort.

final class LocalEngineLifecycleProvider
    extends
        $FunctionalProvider<
          AppLifecycleListener,
          AppLifecycleListener,
          AppLifecycleListener
        >
    with $Provider<AppLifecycleListener> {
  /// Stops every engine when the app exits, and on phones while it is in the
  /// background, starting them again on resume. Read when a local instance
  /// first becomes active; exit is a request on desktop and a detach on
  /// phones, where it is best effort.
  LocalEngineLifecycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localEngineLifecycleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localEngineLifecycleHash();

  @$internal
  @override
  $ProviderElement<AppLifecycleListener> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppLifecycleListener create(Ref ref) {
    return localEngineLifecycle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLifecycleListener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLifecycleListener>(value),
    );
  }
}

String _$localEngineLifecycleHash() =>
    r'311b0e1ef46ac8ccc771b2781e5ed3a85c49d156';
