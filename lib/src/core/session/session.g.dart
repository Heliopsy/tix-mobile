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

String _$sessionControllerHash() => r'2274ed4acdb176167a0d7e1ce90ec6a4cf5c67a0';

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
///
/// A local instance's client wakes its engine before every request, so an
/// engine stopped while idle comes back on its own. Kept alive so live
/// updates, which outlive every screen, share it.

@ProviderFor(sessionApi)
final sessionApiProvider = SessionApiProvider._();

/// The API client for the active session.
///
/// A local instance's client wakes its engine before every request, so an
/// engine stopped while idle comes back on its own. Kept alive so live
/// updates, which outlive every screen, share it.

final class SessionApiProvider
    extends $FunctionalProvider<TixApi, TixApi, TixApi>
    with $Provider<TixApi> {
  /// The API client for the active session.
  ///
  /// A local instance's client wakes its engine before every request, so an
  /// engine stopped while idle comes back on its own. Kept alive so live
  /// updates, which outlive every screen, share it.
  SessionApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionApiProvider',
        isAutoDispose: false,
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

String _$sessionApiHash() => r'3faedeaa65ed91ca6e28e72528b6575fde4a3838';

/// The background work running per connection, stopped before a forgotten
/// connection's files are deleted.

@ProviderFor(connectionJobs)
final connectionJobsProvider = ConnectionJobsProvider._();

/// The background work running per connection, stopped before a forgotten
/// connection's files are deleted.

final class ConnectionJobsProvider
    extends $FunctionalProvider<ConnectionJobs, ConnectionJobs, ConnectionJobs>
    with $Provider<ConnectionJobs> {
  /// The background work running per connection, stopped before a forgotten
  /// connection's files are deleted.
  ConnectionJobsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionJobsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionJobsHash();

  @$internal
  @override
  $ProviderElement<ConnectionJobs> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectionJobs create(Ref ref) {
    return connectionJobs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionJobs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionJobs>(value),
    );
  }
}

String _$connectionJobsHash() => r'6d03adf5a2af6d256ed900a0b7a503b5a17ddedf';

/// The cache scope of the active context, null with no session.
///
/// A connection reaches one tenant unless it is a switchable sign-in, so
/// only that kind names its tenant in the scope. The rest leave it empty,
/// which keeps the scope stable while a background `whoami` fills in the
/// tenant's key.

@ProviderFor(activeCacheScope)
final activeCacheScopeProvider = ActiveCacheScopeProvider._();

/// The cache scope of the active context, null with no session.
///
/// A connection reaches one tenant unless it is a switchable sign-in, so
/// only that kind names its tenant in the scope. The rest leave it empty,
/// which keeps the scope stable while a background `whoami` fills in the
/// tenant's key.

final class ActiveCacheScopeProvider
    extends $FunctionalProvider<CacheScope?, CacheScope?, CacheScope?>
    with $Provider<CacheScope?> {
  /// The cache scope of the active context, null with no session.
  ///
  /// A connection reaches one tenant unless it is a switchable sign-in, so
  /// only that kind names its tenant in the scope. The rest leave it empty,
  /// which keeps the scope stable while a background `whoami` fills in the
  /// tenant's key.
  ActiveCacheScopeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCacheScopeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCacheScopeHash();

  @$internal
  @override
  $ProviderElement<CacheScope?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheScope? create(Ref ref) {
    return activeCacheScope(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheScope? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheScope?>(value),
    );
  }
}

String _$activeCacheScopeHash() => r'c470c85327aa8ff9df5c2559b4d3ee31df840cf8';

/// The response cache of the active context. Reads are best effort, so a
/// cache that cannot be opened behaves as an empty one.

@ProviderFor(responseCache)
final responseCacheProvider = ResponseCacheProvider._();

/// The response cache of the active context. Reads are best effort, so a
/// cache that cannot be opened behaves as an empty one.

final class ResponseCacheProvider
    extends $FunctionalProvider<ResponseCache, ResponseCache, ResponseCache>
    with $Provider<ResponseCache> {
  /// The response cache of the active context. Reads are best effort, so a
  /// cache that cannot be opened behaves as an empty one.
  ResponseCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'responseCacheProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$responseCacheHash();

  @$internal
  @override
  $ProviderElement<ResponseCache> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResponseCache create(Ref ref) {
    return responseCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResponseCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResponseCache>(value),
    );
  }
}

String _$responseCacheHash() => r'c5f322dab90f541372a7ee09d6d4661419f3131c';

/// The outbox, conflicts and drafts of the active context, kept beside its
/// cache under `sync/`.

@ProviderFor(syncStore)
final syncStoreProvider = SyncStoreProvider._();

/// The outbox, conflicts and drafts of the active context, kept beside its
/// cache under `sync/`.

final class SyncStoreProvider
    extends $FunctionalProvider<SyncStore, SyncStore, SyncStore>
    with $Provider<SyncStore> {
  /// The outbox, conflicts and drafts of the active context, kept beside its
  /// cache under `sync/`.
  SyncStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStoreHash();

  @$internal
  @override
  $ProviderElement<SyncStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncStore create(Ref ref) {
    return syncStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStore>(value),
    );
  }
}

String _$syncStoreHash() => r'8d90f69a46e05686f21357c848c4cdcbd368877f';

/// Every context's [SyncStore], kept for the life of the app so a context
/// left and come back to finds the same one.

@ProviderFor(syncStores)
final syncStoresProvider = SyncStoresProvider._();

/// Every context's [SyncStore], kept for the life of the app so a context
/// left and come back to finds the same one.

final class SyncStoresProvider
    extends $FunctionalProvider<SyncStores, SyncStores, SyncStores>
    with $Provider<SyncStores> {
  /// Every context's [SyncStore], kept for the life of the app so a context
  /// left and come back to finds the same one.
  SyncStoresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStoresProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStoresHash();

  @$internal
  @override
  $ProviderElement<SyncStores> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncStores create(Ref ref) {
    return syncStores(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStores value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStores>(value),
    );
  }
}

String _$syncStoresHash() => r'ccf3b66cad1c375f261cf9f59d2d7ab77b9dfe82';

/// Whether the active context's server is known to be out of reach, so
/// writes go straight to the outbox instead of waiting for a timeout. The
/// outbox replay (`core/offline/outbox.dart`) keeps it current.

@ProviderFor(ServerOffline)
final serverOfflineProvider = ServerOfflineProvider._();

/// Whether the active context's server is known to be out of reach, so
/// writes go straight to the outbox instead of waiting for a timeout. The
/// outbox replay (`core/offline/outbox.dart`) keeps it current.
final class ServerOfflineProvider
    extends $NotifierProvider<ServerOffline, bool> {
  /// Whether the active context's server is known to be out of reach, so
  /// writes go straight to the outbox instead of waiting for a timeout. The
  /// outbox replay (`core/offline/outbox.dart`) keeps it current.
  ServerOfflineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverOfflineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverOfflineHash();

  @$internal
  @override
  ServerOffline create() => ServerOffline();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$serverOfflineHash() => r'b829a43a9a05d6801110ca586e183dec30d206e4';

/// Whether the active context's server is known to be out of reach, so
/// writes go straight to the outbox instead of waiting for a timeout. The
/// outbox replay (`core/offline/outbox.dart`) keeps it current.

abstract class _$ServerOffline extends $Notifier<bool> {
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

/// Writes made while the server cannot be reached, for the active context.

@ProviderFor(outbox)
final outboxProvider = OutboxProvider._();

/// Writes made while the server cannot be reached, for the active context.

final class OutboxProvider extends $FunctionalProvider<Outbox, Outbox, Outbox>
    with $Provider<Outbox> {
  /// Writes made while the server cannot be reached, for the active context.
  OutboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxHash();

  @$internal
  @override
  $ProviderElement<Outbox> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Outbox create(Ref ref) {
    return outbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Outbox value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Outbox>(value),
    );
  }
}

String _$outboxHash() => r'e8afaa0cba8128f147888fd36acae5945501f3a9';

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

String _$tasksRepositoryHash() => r'1c12db88d3bd82b80915e80f7f69da644bdf02bc';

/// What the task screen reads and changes, for the active session.

@ProviderFor(taskDetailRepository)
final taskDetailRepositoryProvider = TaskDetailRepositoryProvider._();

/// What the task screen reads and changes, for the active session.

final class TaskDetailRepositoryProvider
    extends
        $FunctionalProvider<
          TaskDetailRepository,
          TaskDetailRepository,
          TaskDetailRepository
        >
    with $Provider<TaskDetailRepository> {
  /// What the task screen reads and changes, for the active session.
  TaskDetailRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskDetailRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskDetailRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskDetailRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaskDetailRepository create(Ref ref) {
    return taskDetailRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskDetailRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskDetailRepository>(value),
    );
  }
}

String _$taskDetailRepositoryHash() =>
    r'422712685ac06d7152519463bb51c9fd18a8a6bf';

/// Listings, quick and bulk actions and workflows for the active session.

@ProviderFor(taskListRepository)
final taskListRepositoryProvider = TaskListRepositoryProvider._();

/// Listings, quick and bulk actions and workflows for the active session.

final class TaskListRepositoryProvider
    extends
        $FunctionalProvider<
          TaskListRepository,
          TaskListRepository,
          TaskListRepository
        >
    with $Provider<TaskListRepository> {
  /// Listings, quick and bulk actions and workflows for the active session.
  TaskListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskListRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskListRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskListRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaskListRepository create(Ref ref) {
    return taskListRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskListRepository>(value),
    );
  }
}

String _$taskListRepositoryHash() =>
    r'dafd267ebc6ac291d11b85acc0290fd9600012a3';

/// View arrangements and saved filters for the active session.

@ProviderFor(viewPrefsRepository)
final viewPrefsRepositoryProvider = ViewPrefsRepositoryProvider._();

/// View arrangements and saved filters for the active session.

final class ViewPrefsRepositoryProvider
    extends
        $FunctionalProvider<
          ViewPrefsRepository,
          ViewPrefsRepository,
          ViewPrefsRepository
        >
    with $Provider<ViewPrefsRepository> {
  /// View arrangements and saved filters for the active session.
  ViewPrefsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewPrefsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewPrefsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ViewPrefsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ViewPrefsRepository create(Ref ref) {
    return viewPrefsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewPrefsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewPrefsRepository>(value),
    );
  }
}

String _$viewPrefsRepositoryHash() =>
    r'457916fcc7421ccd7812933e9cd6d4e73596cbcd';

/// Counts resets of the reader's view arrangements made away from the views,
/// such as from Settings. Views watch it, so an open board or My work reads
/// its arrangement again without either feature importing the other.

@ProviderFor(ArrangementResets)
final arrangementResetsProvider = ArrangementResetsProvider._();

/// Counts resets of the reader's view arrangements made away from the views,
/// such as from Settings. Views watch it, so an open board or My work reads
/// its arrangement again without either feature importing the other.
final class ArrangementResetsProvider
    extends $NotifierProvider<ArrangementResets, int> {
  /// Counts resets of the reader's view arrangements made away from the views,
  /// such as from Settings. Views watch it, so an open board or My work reads
  /// its arrangement again without either feature importing the other.
  ArrangementResetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'arrangementResetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$arrangementResetsHash();

  @$internal
  @override
  ArrangementResets create() => ArrangementResets();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$arrangementResetsHash() => r'ecb976ccdb1aa1e85769b03cd41bfdd663b6ca8f';

/// Counts resets of the reader's view arrangements made away from the views,
/// such as from Settings. Views watch it, so an open board or My work reads
/// its arrangement again without either feature importing the other.

abstract class _$ArrangementResets extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The inbox, personal channels and the summary for the active session.

@ProviderFor(inboxRepository)
final inboxRepositoryProvider = InboxRepositoryProvider._();

/// The inbox, personal channels and the summary for the active session.

final class InboxRepositoryProvider
    extends
        $FunctionalProvider<InboxRepository, InboxRepository, InboxRepository>
    with $Provider<InboxRepository> {
  /// The inbox, personal channels and the summary for the active session.
  InboxRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxRepositoryHash();

  @$internal
  @override
  $ProviderElement<InboxRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InboxRepository create(Ref ref) {
    return inboxRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxRepository>(value),
    );
  }
}

String _$inboxRepositoryHash() => r'6fd361e8fb5c9f4b72a4fec2c66a8ec3a5ffef3d';

/// Who the active credential is, for the active session.

@ProviderFor(identityRepository)
final identityRepositoryProvider = IdentityRepositoryProvider._();

/// Who the active credential is, for the active session.

final class IdentityRepositoryProvider
    extends
        $FunctionalProvider<
          IdentityRepository,
          IdentityRepository,
          IdentityRepository
        >
    with $Provider<IdentityRepository> {
  /// Who the active credential is, for the active session.
  IdentityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityRepositoryHash();

  @$internal
  @override
  $ProviderElement<IdentityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IdentityRepository create(Ref ref) {
    return identityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityRepository>(value),
    );
  }
}

String _$identityRepositoryHash() =>
    r'cb010e13c4ce381b2ac97c3cf10b7cbb5522efdf';

/// Project administration and custom fields, for the active session.

@ProviderFor(projectsRepository)
final projectsRepositoryProvider = ProjectsRepositoryProvider._();

/// Project administration and custom fields, for the active session.

final class ProjectsRepositoryProvider
    extends
        $FunctionalProvider<
          ProjectsRepository,
          ProjectsRepository,
          ProjectsRepository
        >
    with $Provider<ProjectsRepository> {
  /// Project administration and custom fields, for the active session.
  ProjectsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProjectsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectsRepository create(Ref ref) {
    return projectsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectsRepository>(value),
    );
  }
}

String _$projectsRepositoryHash() =>
    r'78b1b709fcdeadec70d323419b3d0403b91b6bdb';

/// The tenant's workflows, for the active session.

@ProviderFor(workflowsRepository)
final workflowsRepositoryProvider = WorkflowsRepositoryProvider._();

/// The tenant's workflows, for the active session.

final class WorkflowsRepositoryProvider
    extends
        $FunctionalProvider<
          WorkflowsRepository,
          WorkflowsRepository,
          WorkflowsRepository
        >
    with $Provider<WorkflowsRepository> {
  /// The tenant's workflows, for the active session.
  WorkflowsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workflowsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workflowsRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkflowsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkflowsRepository create(Ref ref) {
    return workflowsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkflowsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkflowsRepository>(value),
    );
  }
}

String _$workflowsRepositoryHash() =>
    r'9df84a2a32c991ad01e6c3d998f22b9f2ed15b3e';
