// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The saved servers.

@ProviderFor(contextsRepository)
final contextsRepositoryProvider = ContextsRepositoryProvider._();

/// The saved servers.

final class ContextsRepositoryProvider
    extends
        $FunctionalProvider<
          ContextsRepository,
          ContextsRepository,
          ContextsRepository
        >
    with $Provider<ContextsRepository> {
  /// The saved servers.
  ContextsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContextsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContextsRepository create(Ref ref) {
    return contextsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContextsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContextsRepository>(value),
    );
  }
}

String _$contextsRepositoryHash() =>
    r'ece57fc908f764e77ae81bf80ee4361cddbdca1a';

/// The active session: null until someone connects.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// The active session: null until someone connects.
final class SessionControllerProvider
    extends $AsyncNotifierProvider<SessionController, Session?> {
  /// The active session: null until someone connects.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();
}

String _$sessionControllerHash() => r'a179e48e0f9e5d035483f6afd0cc6e191fa06bef';

/// The active session: null until someone connects.

abstract class _$SessionController extends $AsyncNotifier<Session?> {
  FutureOr<Session?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Session?>, Session?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Session?>, Session?>,
              AsyncValue<Session?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Every saved context, refreshed whenever the session changes.

@ProviderFor(savedContexts)
final savedContextsProvider = SavedContextsProvider._();

/// Every saved context, refreshed whenever the session changes.

final class SavedContextsProvider
    extends
        $FunctionalProvider<
          List<ServerContext>,
          List<ServerContext>,
          List<ServerContext>
        >
    with $Provider<List<ServerContext>> {
  /// Every saved context, refreshed whenever the session changes.
  SavedContextsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedContextsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedContextsHash();

  @$internal
  @override
  $ProviderElement<List<ServerContext>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ServerContext> create(Ref ref) {
    return savedContexts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ServerContext> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ServerContext>>(value),
    );
  }
}

String _$savedContextsHash() => r'ac1abaa5ae8605d9bb4648451902af895e086f3a';

/// The API client for the active session.

@ProviderFor(sessionApi)
final sessionApiProvider = SessionApiProvider._();

/// The API client for the active session.

final class SessionApiProvider
    extends $FunctionalProvider<TixApi, TixApi, TixApi>
    with $Provider<TixApi> {
  /// The API client for the active session.
  SessionApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionApiHash();

  @$internal
  @override
  $ProviderElement<TixApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TixApi create(Ref ref) {
    return sessionApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TixApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TixApi>(value),
    );
  }
}

String _$sessionApiHash() => r'bec878317baf5c77c728ebb7e53b21968b75b6bd';

/// Projects and tasks on the active server; rebuilt when the session changes.

@ProviderFor(tasksRepository)
final tasksRepositoryProvider = TasksRepositoryProvider._();

/// Projects and tasks on the active server; rebuilt when the session changes.

final class TasksRepositoryProvider
    extends
        $FunctionalProvider<TasksRepository, TasksRepository, TasksRepository>
    with $Provider<TasksRepository> {
  /// Projects and tasks on the active server; rebuilt when the session changes.
  TasksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksRepositoryHash();

  @$internal
  @override
  $ProviderElement<TasksRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TasksRepository create(Ref ref) {
    return tasksRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TasksRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TasksRepository>(value),
    );
  }
}

String _$tasksRepositoryHash() => r'd331437a90a2c203b484bf4caa76785b3e062f18';
