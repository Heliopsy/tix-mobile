// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'watch.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What Watch is narrowed to.

@ProviderFor(WatchFilter)
final watchFilterProvider = WatchFilterProvider._();

/// What Watch is narrowed to.
final class WatchFilterProvider
    extends $NotifierProvider<WatchFilter, WatchQuery> {
  /// What Watch is narrowed to.
  WatchFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchFilterHash();

  @$internal
  @override
  WatchFilter create() => WatchFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchQuery>(value),
    );
  }
}

String _$watchFilterHash() => r'c788d59098746b6a15ddea9f8495b4f4f0d3309e';

/// What Watch is narrowed to.

abstract class _$WatchFilter extends $Notifier<WatchQuery> {
  WatchQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WatchQuery, WatchQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WatchQuery, WatchQuery>,
              WatchQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The active context's events as they arrive, over the connection live
/// updates already hold. Changing the projects, types or replay point
/// subscribes again; the actor filter does not.

@ProviderFor(WatchFeed)
final watchFeedProvider = WatchFeedProvider._();

/// The active context's events as they arrive, over the connection live
/// updates already hold. Changing the projects, types or replay point
/// subscribes again; the actor filter does not.
final class WatchFeedProvider extends $NotifierProvider<WatchFeed, WatchState> {
  /// The active context's events as they arrive, over the connection live
  /// updates already hold. Changing the projects, types or replay point
  /// subscribes again; the actor filter does not.
  WatchFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchFeedHash();

  @$internal
  @override
  WatchFeed create() => WatchFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchState>(value),
    );
  }
}

String _$watchFeedHash() => r'52b133a53fcf762c306edbb253312d995dba45ae';

/// The active context's events as they arrive, over the connection live
/// updates already hold. Changing the projects, types or replay point
/// subscribes again; the actor filter does not.

abstract class _$WatchFeed extends $Notifier<WatchState> {
  WatchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WatchState, WatchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WatchState, WatchState>,
              WatchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The events Watch shows: the feed through the actor filter.

@ProviderFor(watchVisible)
final watchVisibleProvider = WatchVisibleProvider._();

/// The events Watch shows: the feed through the actor filter.

final class WatchVisibleProvider
    extends $FunctionalProvider<List<TixEvent>, List<TixEvent>, List<TixEvent>>
    with $Provider<List<TixEvent>> {
  /// The events Watch shows: the feed through the actor filter.
  WatchVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchVisibleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchVisibleHash();

  @$internal
  @override
  $ProviderElement<List<TixEvent>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TixEvent> create(Ref ref) {
    return watchVisible(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TixEvent> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TixEvent>>(value),
    );
  }
}

String _$watchVisibleHash() => r'bfc9a8b859dbfab9f4ff0dcc6455a2e187b79632';

/// How many events the actor filter keeps of those held while paused.

@ProviderFor(watchHeldCount)
final watchHeldCountProvider = WatchHeldCountProvider._();

/// How many events the actor filter keeps of those held while paused.

final class WatchHeldCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many events the actor filter keeps of those held while paused.
  WatchHeldCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchHeldCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchHeldCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return watchHeldCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$watchHeldCountHash() => r'fc726d19f1fe411ea8b13d1d6848bf2dd38a1cba';

/// The tenant's projects, for the filter and to name a project by its id.

@ProviderFor(watchProjects)
final watchProjectsProvider = WatchProjectsProvider._();

/// The tenant's projects, for the filter and to name a project by its id.

final class WatchProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          FutureOr<List<Project>>
        >
    with $FutureModifier<List<Project>>, $FutureProvider<List<Project>> {
  /// The tenant's projects, for the filter and to name a project by its id.
  WatchProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchProjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Project>> create(Ref ref) {
    return watchProjects(ref);
  }
}

String _$watchProjectsHash() => r'ec88293e84882ad205f734e60d66f093674092ed';
