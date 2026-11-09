// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What each context keeps offline, in preferences.

@ProviderFor(offlinePrefsRepository)
final offlinePrefsRepositoryProvider = OfflinePrefsRepositoryProvider._();

/// What each context keeps offline, in preferences.

final class OfflinePrefsRepositoryProvider
    extends
        $FunctionalProvider<
          OfflinePrefsRepository,
          OfflinePrefsRepository,
          OfflinePrefsRepository
        >
    with $Provider<OfflinePrefsRepository> {
  /// What each context keeps offline, in preferences.
  OfflinePrefsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlinePrefsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlinePrefsRepositoryHash();

  @$internal
  @override
  $ProviderElement<OfflinePrefsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OfflinePrefsRepository create(Ref ref) {
    return offlinePrefsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflinePrefsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflinePrefsRepository>(value),
    );
  }
}

String _$offlinePrefsRepositoryHash() =>
    r'be4105951c14468ac115eb42566f1456e8cde94f';

/// Whether sync runs on its own (on activation, every [syncEvery], and when
/// the network comes back). Tests turn it off unless they test it.

@ProviderFor(autoSync)
final autoSyncProvider = AutoSyncProvider._();

/// Whether sync runs on its own (on activation, every [syncEvery], and when
/// the network comes back). Tests turn it off unless they test it.

final class AutoSyncProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether sync runs on its own (on activation, every [syncEvery], and when
  /// the network comes back). Tests turn it off unless they test it.
  AutoSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoSyncHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return autoSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$autoSyncHash() => r'f0212f956b59545a8108c2b046506e6ebdb13726';

/// The timer background sync repeats on.

@ProviderFor(periodicTimer)
final periodicTimerProvider = PeriodicTimerProvider._();

/// The timer background sync repeats on.

final class PeriodicTimerProvider
    extends $FunctionalProvider<PeriodicTimer, PeriodicTimer, PeriodicTimer>
    with $Provider<PeriodicTimer> {
  /// The timer background sync repeats on.
  PeriodicTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'periodicTimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$periodicTimerHash();

  @$internal
  @override
  $ProviderElement<PeriodicTimer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PeriodicTimer create(Ref ref) {
    return periodicTimer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeriodicTimer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeriodicTimer>(value),
    );
  }
}

String _$periodicTimerHash() => r'b710e8ca601db4602787c91f988501cab1fbfb93';

/// The steps [OfflineSync.syncNow] awaits, in order, before it prefetches.
///
/// Sending queued changes belongs here, so the prefetch then reads the
/// server's answer to them: `ref.read(syncStepsProvider.notifier).add(step)`
/// registers one and returns what unregisters it. A step that throws stops
/// the sync, and its error becomes [OfflineSyncState.error].

@ProviderFor(SyncSteps)
final syncStepsProvider = SyncStepsProvider._();

/// The steps [OfflineSync.syncNow] awaits, in order, before it prefetches.
///
/// Sending queued changes belongs here, so the prefetch then reads the
/// server's answer to them: `ref.read(syncStepsProvider.notifier).add(step)`
/// registers one and returns what unregisters it. A step that throws stops
/// the sync, and its error becomes [OfflineSyncState.error].
final class SyncStepsProvider
    extends $NotifierProvider<SyncSteps, List<SyncStep>> {
  /// The steps [OfflineSync.syncNow] awaits, in order, before it prefetches.
  ///
  /// Sending queued changes belongs here, so the prefetch then reads the
  /// server's answer to them: `ref.read(syncStepsProvider.notifier).add(step)`
  /// registers one and returns what unregisters it. A step that throws stops
  /// the sync, and its error becomes [OfflineSyncState.error].
  SyncStepsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStepsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStepsHash();

  @$internal
  @override
  SyncSteps create() => SyncSteps();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SyncStep> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SyncStep>>(value),
    );
  }
}

String _$syncStepsHash() => r'd381ed465a287133fd827e5af4980cb0d9eaffc7';

/// The steps [OfflineSync.syncNow] awaits, in order, before it prefetches.
///
/// Sending queued changes belongs here, so the prefetch then reads the
/// server's answer to them: `ref.read(syncStepsProvider.notifier).add(step)`
/// registers one and returns what unregisters it. A step that throws stops
/// the sync, and its error becomes [OfflineSyncState.error].

abstract class _$SyncSteps extends $Notifier<List<SyncStep>> {
  List<SyncStep> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<SyncStep>, List<SyncStep>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SyncStep>, List<SyncStep>>,
              List<SyncStep>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Keeps what the active context chose available offline: runs the
/// [SyncSteps], then fetches every listing, task, comment and subtask the
/// choice names into the response cache, where reads find it when the
/// server cannot be reached.
///
/// It runs when asked ([syncNow]) and, for a remote instance, on its own:
/// when the context becomes active, every [syncEvery] and when the network
/// comes back, unless a phone is on mobile data, in battery saver or low on
/// battery. A local instance is on this device and is never prefetched.

@ProviderFor(OfflineSync)
final offlineSyncProvider = OfflineSyncProvider._();

/// Keeps what the active context chose available offline: runs the
/// [SyncSteps], then fetches every listing, task, comment and subtask the
/// choice names into the response cache, where reads find it when the
/// server cannot be reached.
///
/// It runs when asked ([syncNow]) and, for a remote instance, on its own:
/// when the context becomes active, every [syncEvery] and when the network
/// comes back, unless a phone is on mobile data, in battery saver or low on
/// battery. A local instance is on this device and is never prefetched.
final class OfflineSyncProvider
    extends $NotifierProvider<OfflineSync, OfflineSyncState> {
  /// Keeps what the active context chose available offline: runs the
  /// [SyncSteps], then fetches every listing, task, comment and subtask the
  /// choice names into the response cache, where reads find it when the
  /// server cannot be reached.
  ///
  /// It runs when asked ([syncNow]) and, for a remote instance, on its own:
  /// when the context becomes active, every [syncEvery] and when the network
  /// comes back, unless a phone is on mobile data, in battery saver or low on
  /// battery. A local instance is on this device and is never prefetched.
  OfflineSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineSyncHash();

  @$internal
  @override
  OfflineSync create() => OfflineSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflineSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflineSyncState>(value),
    );
  }
}

String _$offlineSyncHash() => r'c8b39d16a8a979138b3e0915f0e25f946813b5dc';

/// Keeps what the active context chose available offline: runs the
/// [SyncSteps], then fetches every listing, task, comment and subtask the
/// choice names into the response cache, where reads find it when the
/// server cannot be reached.
///
/// It runs when asked ([syncNow]) and, for a remote instance, on its own:
/// when the context becomes active, every [syncEvery] and when the network
/// comes back, unless a phone is on mobile data, in battery saver or low on
/// battery. A local instance is on this device and is never prefetched.

abstract class _$OfflineSync extends $Notifier<OfflineSyncState> {
  OfflineSyncState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OfflineSyncState, OfflineSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OfflineSyncState, OfflineSyncState>,
              OfflineSyncState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// When the oldest copy a screen is drawing in place of the unreachable
/// server was kept, null while everything shown came from the server.

@ProviderFor(savedCopySince)
final savedCopySinceProvider = SavedCopySinceProvider._();

/// When the oldest copy a screen is drawing in place of the unreachable
/// server was kept, null while everything shown came from the server.

final class SavedCopySinceProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  /// When the oldest copy a screen is drawing in place of the unreachable
  /// server was kept, null while everything shown came from the server.
  SavedCopySinceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedCopySinceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedCopySinceHash();

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    return savedCopySince(ref);
  }
}

String _$savedCopySinceHash() => r'90d5a3cef03afc5e6cc23fea055f7721bff056de';
