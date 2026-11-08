// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The saved instances and connections.

@ProviderFor(instancesRepository)
final instancesRepositoryProvider = InstancesRepositoryProvider._();

/// The saved instances and connections.

final class InstancesRepositoryProvider
    extends
        $FunctionalProvider<
          InstancesRepository,
          InstancesRepository,
          InstancesRepository
        >
    with $Provider<InstancesRepository> {
  /// The saved instances and connections.
  InstancesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'instancesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instancesRepositoryHash();

  @$internal
  @override
  $ProviderElement<InstancesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InstancesRepository create(Ref ref) {
    return instancesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstancesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstancesRepository>(value),
    );
  }
}

String _$instancesRepositoryHash() =>
    r'b2d50ab3dc5683629e13e83047ad11d52489fe5a';

/// Server checks, sign-in and tenant switches.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Server checks, sign-in and tenant switches.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Server checks, sign-in and tenant switches.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'4686c63ff368de2d2809164c53a981223ac96509';

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

String _$sessionControllerHash() => r'682d2c1352117aded9286280b4a763a22dd97d84';

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

/// The saved contexts, refreshed whenever the session changes.

@ProviderFor(contextDirectory)
final contextDirectoryProvider = ContextDirectoryProvider._();

/// The saved contexts, refreshed whenever the session changes.

final class ContextDirectoryProvider
    extends
        $FunctionalProvider<
          ContextDirectory,
          ContextDirectory,
          ContextDirectory
        >
    with $Provider<ContextDirectory> {
  /// The saved contexts, refreshed whenever the session changes.
  ContextDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextDirectoryHash();

  @$internal
  @override
  $ProviderElement<ContextDirectory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContextDirectory create(Ref ref) {
    return contextDirectory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContextDirectory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContextDirectory>(value),
    );
  }
}

String _$contextDirectoryHash() => r'575aa0c3d9005ff43775aa1e31481c62660a75f0';

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

String _$sessionApiHash() => r'd2d66389916b5d81e7b2160c39e498ad23f77d50';

/// Projects and tasks for the active session.

@ProviderFor(tasksRepository)
final tasksRepositoryProvider = TasksRepositoryProvider._();

/// Projects and tasks for the active session.

final class TasksRepositoryProvider
    extends
        $FunctionalProvider<TasksRepository, TasksRepository, TasksRepository>
    with $Provider<TasksRepository> {
  /// Projects and tasks for the active session.
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
