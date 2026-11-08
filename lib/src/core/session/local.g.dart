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

/// How long a local engine may serve no request before it stops; null for
/// never. Ten minutes until the person picks another.

@ProviderFor(LocalIdleTimeout)
final localIdleTimeoutProvider = LocalIdleTimeoutProvider._();

/// How long a local engine may serve no request before it stops; null for
/// never. Ten minutes until the person picks another.
final class LocalIdleTimeoutProvider
    extends $NotifierProvider<LocalIdleTimeout, Duration?> {
  /// How long a local engine may serve no request before it stops; null for
  /// never. Ten minutes until the person picks another.
  LocalIdleTimeoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localIdleTimeoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localIdleTimeoutHash();

  @$internal
  @override
  LocalIdleTimeout create() => LocalIdleTimeout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration?>(value),
    );
  }
}

String _$localIdleTimeoutHash() => r'1f79f411a403337ad625b1a83027cedbf9c9dd9b';

/// How long a local engine may serve no request before it stops; null for
/// never. Ten minutes until the person picks another.

abstract class _$LocalIdleTimeout extends $Notifier<Duration?> {
  Duration? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Duration?, Duration?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Duration?, Duration?>,
              Duration?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

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

String _$localEnginesHash() => r'48ca00fbd2b6810a0b2ceb25d5d02c687c4c85e9';

/// Every local engine's status, refreshed as engines start and stop.

@ProviderFor(localEngineStatuses)
final localEngineStatusesProvider = LocalEngineStatusesProvider._();

/// Every local engine's status, refreshed as engines start and stop.

final class LocalEngineStatusesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, LocalEngineStatus>>,
          Map<String, LocalEngineStatus>,
          Stream<Map<String, LocalEngineStatus>>
        >
    with
        $FutureModifier<Map<String, LocalEngineStatus>>,
        $StreamProvider<Map<String, LocalEngineStatus>> {
  /// Every local engine's status, refreshed as engines start and stop.
  LocalEngineStatusesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localEngineStatusesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localEngineStatusesHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, LocalEngineStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, LocalEngineStatus>> create(Ref ref) {
    return localEngineStatuses(ref);
  }
}

String _$localEngineStatusesHash() =>
    r'c4ee73ec6b47c97757e50ea56042fd10cd00544b';

/// Stops every engine when the app exits, and on phones while it is in the
/// background, starting them again on resume. Engines of files used in
/// place rest whenever the app is hidden, on every platform, so a sync
/// client finds their log checkpointed into the file. Read when a local
/// instance first becomes active; exit is a request on desktop and a detach
/// on phones, where it is best effort.

@ProviderFor(localEngineLifecycle)
final localEngineLifecycleProvider = LocalEngineLifecycleProvider._();

/// Stops every engine when the app exits, and on phones while it is in the
/// background, starting them again on resume. Engines of files used in
/// place rest whenever the app is hidden, on every platform, so a sync
/// client finds their log checkpointed into the file. Read when a local
/// instance first becomes active; exit is a request on desktop and a detach
/// on phones, where it is best effort.

final class LocalEngineLifecycleProvider
    extends
        $FunctionalProvider<
          AppLifecycleListener,
          AppLifecycleListener,
          AppLifecycleListener
        >
    with $Provider<AppLifecycleListener> {
  /// Stops every engine when the app exits, and on phones while it is in the
  /// background, starting them again on resume. Engines of files used in
  /// place rest whenever the app is hidden, on every platform, so a sync
  /// client finds their log checkpointed into the file. Read when a local
  /// instance first becomes active; exit is a request on desktop and a detach
  /// on phones, where it is best effort.
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
    r'cae7781423fe324e37f5ed109b3fff38e150525d';
