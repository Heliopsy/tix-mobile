// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'offline.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the active context is a local instance, which offline mode
/// leaves alone.

@ProviderFor(offlineIsLocal)
final offlineIsLocalProvider = OfflineIsLocalProvider._();

/// Whether the active context is a local instance, which offline mode
/// leaves alone.

final class OfflineIsLocalProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the active context is a local instance, which offline mode
  /// leaves alone.
  OfflineIsLocalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineIsLocalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineIsLocalHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return offlineIsLocal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$offlineIsLocalHash() => r'6dc038abc30a70d6c66c4d9f9a1f64ee2e2222f2';

/// What the active context keeps available offline.

@ProviderFor(OfflineChoices)
final offlineChoicesProvider = OfflineChoicesProvider._();

/// What the active context keeps available offline.
final class OfflineChoicesProvider
    extends $NotifierProvider<OfflineChoices, OfflineChoice> {
  /// What the active context keeps available offline.
  OfflineChoicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineChoicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineChoicesHash();

  @$internal
  @override
  OfflineChoices create() => OfflineChoices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflineChoice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflineChoice>(value),
    );
  }
}

String _$offlineChoicesHash() => r'9bfb626e5a6d34532d9b68df3c55293ecebed3d7';

/// What the active context keeps available offline.

abstract class _$OfflineChoices extends $Notifier<OfflineChoice> {
  OfflineChoice build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OfflineChoice, OfflineChoice>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OfflineChoice, OfflineChoice>,
              OfflineChoice,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Every unarchived project the reader can keep offline, in the server's
/// order. The first page is read through the cache, so the list still shows
/// offline once it has been synced.

@ProviderFor(offlineProjects)
final offlineProjectsProvider = OfflineProjectsProvider._();

/// Every unarchived project the reader can keep offline, in the server's
/// order. The first page is read through the cache, so the list still shows
/// offline once it has been synced.

final class OfflineProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          FutureOr<List<Project>>
        >
    with $FutureModifier<List<Project>>, $FutureProvider<List<Project>> {
  /// Every unarchived project the reader can keep offline, in the server's
  /// order. The first page is read through the cache, so the list still shows
  /// offline once it has been synced.
  OfflineProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineProjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Project>> create(Ref ref) {
    return offlineProjects(ref);
  }
}

String _$offlineProjectsHash() => r'3737ee62ee0baf689cc0afce9c66fce758feeff4';

/// How many bytes the active context's offline copies take, entries
/// waiting to be sent included.

@ProviderFor(offlineStorage)
final offlineStorageProvider = OfflineStorageProvider._();

/// How many bytes the active context's offline copies take, entries
/// waiting to be sent included.

final class OfflineStorageProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many bytes the active context's offline copies take, entries
  /// waiting to be sent included.
  OfflineStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineStorageHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return offlineStorage(ref);
  }
}

String _$offlineStorageHash() => r'd13b90ad4158b901096eff8b5ee1928883c9cbf3';
