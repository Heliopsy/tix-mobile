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

String _$watchFeedHash() => r'95288c5f4a492268efffaa0b5734a579d007b727';

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

/// The tenant's actors by id, to put a name to who caused an event. The
/// event itself carries only the actor's id and handle.

@ProviderFor(watchActors)
final watchActorsProvider = WatchActorsProvider._();

/// The tenant's actors by id, to put a name to who caused an event. The
/// event itself carries only the actor's id and handle.

final class WatchActorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Actor>>,
          Map<String, Actor>,
          FutureOr<Map<String, Actor>>
        >
    with
        $FutureModifier<Map<String, Actor>>,
        $FutureProvider<Map<String, Actor>> {
  /// The tenant's actors by id, to put a name to who caused an event. The
  /// event itself carries only the actor's id and handle.
  WatchActorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchActorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchActorsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, Actor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, Actor>> create(Ref ref) {
    return watchActors(ref);
  }
}

String _$watchActorsHash() => r'61e32885a18724c34a00e2b59558a9efd0908ea7';

/// The comments on the task [taskRef], read when Watch shows a comment on
/// it, since a `comment.added` event carries no text.

@ProviderFor(watchTaskComments)
final watchTaskCommentsProvider = WatchTaskCommentsFamily._();

/// The comments on the task [taskRef], read when Watch shows a comment on
/// it, since a `comment.added` event carries no text.

final class WatchTaskCommentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Comment>>,
          List<Comment>,
          FutureOr<List<Comment>>
        >
    with $FutureModifier<List<Comment>>, $FutureProvider<List<Comment>> {
  /// The comments on the task [taskRef], read when Watch shows a comment on
  /// it, since a `comment.added` event carries no text.
  WatchTaskCommentsProvider._({
    required WatchTaskCommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchTaskCommentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTaskCommentsHash();

  @override
  String toString() {
    return r'watchTaskCommentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Comment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Comment>> create(Ref ref) {
    final argument = this.argument as String;
    return watchTaskComments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTaskCommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTaskCommentsHash() => r'637138f36f902a9803be73a629959115d6236fb5';

/// The comments on the task [taskRef], read when Watch shows a comment on
/// it, since a `comment.added` event carries no text.

final class WatchTaskCommentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Comment>>, String> {
  WatchTaskCommentsFamily._()
    : super(
        retry: null,
        name: r'watchTaskCommentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The comments on the task [taskRef], read when Watch shows a comment on
  /// it, since a `comment.added` event carries no text.

  WatchTaskCommentsProvider call(String taskRef) =>
      WatchTaskCommentsProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'watchTaskCommentsProvider';
}

/// The comment [commentId] on [taskRef], null once it is gone.

@ProviderFor(watchComment)
final watchCommentProvider = WatchCommentFamily._();

/// The comment [commentId] on [taskRef], null once it is gone.

final class WatchCommentProvider
    extends
        $FunctionalProvider<AsyncValue<Comment?>, Comment?, FutureOr<Comment?>>
    with $FutureModifier<Comment?>, $FutureProvider<Comment?> {
  /// The comment [commentId] on [taskRef], null once it is gone.
  WatchCommentProvider._({
    required WatchCommentFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'watchCommentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchCommentHash();

  @override
  String toString() {
    return r'watchCommentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Comment?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Comment?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return watchComment(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchCommentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchCommentHash() => r'9580699d2fc55b6801e65485e80f14088425c11f';

/// The comment [commentId] on [taskRef], null once it is gone.

final class WatchCommentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Comment?>, (String, String)> {
  WatchCommentFamily._()
    : super(
        retry: null,
        name: r'watchCommentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The comment [commentId] on [taskRef], null once it is gone.

  WatchCommentProvider call(String taskRef, String commentId) =>
      WatchCommentProvider._(argument: (taskRef, commentId), from: this);

  @override
  String toString() => r'watchCommentProvider';
}
