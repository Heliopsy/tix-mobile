// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'local.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the add-instance screen offers local databases. Set with
/// `--dart-define=TIX_LOCAL_INSTANCES=true` until the engine ships.

@ProviderFor(localInstancesEnabled)
final localInstancesEnabledProvider = LocalInstancesEnabledProvider._();

/// Whether the add-instance screen offers local databases. Set with
/// `--dart-define=TIX_LOCAL_INSTANCES=true` until the engine ships.

final class LocalInstancesEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the add-instance screen offers local databases. Set with
  /// `--dart-define=TIX_LOCAL_INSTANCES=true` until the engine ships.
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
    r'd73701659f946a11a5ede75fc0aab69fa323efc5';

/// The embedded engine. This build has none; the FFI library replaces this.

@ProviderFor(localTixEngine)
final localTixEngineProvider = LocalTixEngineProvider._();

/// The embedded engine. This build has none; the FFI library replaces this.

final class LocalTixEngineProvider
    extends $FunctionalProvider<LocalTixEngine, LocalTixEngine, LocalTixEngine>
    with $Provider<LocalTixEngine> {
  /// The embedded engine. This build has none; the FFI library replaces this.
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

String _$localTixEngineHash() => r'1403a2e2806fe633ee68cd229246ef21fa66dfc6';

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

String _$localEnginesHash() => r'9982db5017ca2cd118ba126c01d138077b4054b4';

/// Stops every engine when the app exits. Read when a local instance first
/// becomes active; exit is a request on desktop and a detach on phones,
/// where it is best effort.

@ProviderFor(localEngineLifecycle)
final localEngineLifecycleProvider = LocalEngineLifecycleProvider._();

/// Stops every engine when the app exits. Read when a local instance first
/// becomes active; exit is a request on desktop and a detach on phones,
/// where it is best effort.

final class LocalEngineLifecycleProvider
    extends
        $FunctionalProvider<
          AppLifecycleListener,
          AppLifecycleListener,
          AppLifecycleListener
        >
    with $Provider<AppLifecycleListener> {
  /// Stops every engine when the app exits. Read when a local instance first
  /// becomes active; exit is a request on desktop and a detach on phones,
  /// where it is best effort.
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
    r'9d9c5b66a0cf30e18b1c1dedec5d5d45581cd7c9';
