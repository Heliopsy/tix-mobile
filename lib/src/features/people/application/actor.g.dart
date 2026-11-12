// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'actor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One actor's page, for the active session.

@ProviderFor(actorRepository)
final actorRepositoryProvider = ActorRepositoryProvider._();

/// One actor's page, for the active session.

final class ActorRepositoryProvider
    extends
        $FunctionalProvider<ActorRepository, ActorRepository, ActorRepository>
    with $Provider<ActorRepository> {
  /// One actor's page, for the active session.
  ActorRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'actorRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$actorRepositoryHash();

  @$internal
  @override
  $ProviderElement<ActorRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ActorRepository create(Ref ref) {
    return actorRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActorRepository>(value),
    );
  }
}

String _$actorRepositoryHash() => r'818dbcff76370199d4f3b123aa3b63e2803e9d6c';

/// The actor [ref] names, an id or a handle.

@ProviderFor(actorProfile)
final actorProfileProvider = ActorProfileFamily._();

/// The actor [ref] names, an id or a handle.

final class ActorProfileProvider
    extends $FunctionalProvider<AsyncValue<Actor>, Actor, FutureOr<Actor>>
    with $FutureModifier<Actor>, $FutureProvider<Actor> {
  /// The actor [ref] names, an id or a handle.
  ActorProfileProvider._({
    required ActorProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'actorProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actorProfileHash();

  @override
  String toString() {
    return r'actorProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Actor> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Actor> create(Ref ref) {
    final argument = this.argument as String;
    return actorProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActorProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actorProfileHash() => r'61363b51dfd6b9a41c5af1aba38c27df7aa336a2';

/// The actor [ref] names, an id or a handle.

final class ActorProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Actor>, String> {
  ActorProfileFamily._()
    : super(
        retry: null,
        name: r'actorProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The actor [ref] names, an id or a handle.

  ActorProfileProvider call(String actorRef) =>
      ActorProfileProvider._(argument: actorRef, from: this);

  @override
  String toString() => r'actorProfileProvider';
}

/// The first tasks assigned to the actor [actorId].

@ProviderFor(actorTasks)
final actorTasksProvider = ActorTasksFamily._();

/// The first tasks assigned to the actor [actorId].

final class ActorTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<Page<Task>>,
          Page<Task>,
          FutureOr<Page<Task>>
        >
    with $FutureModifier<Page<Task>>, $FutureProvider<Page<Task>> {
  /// The first tasks assigned to the actor [actorId].
  ActorTasksProvider._({
    required ActorTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'actorTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actorTasksHash();

  @override
  String toString() {
    return r'actorTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Page<Task>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Page<Task>> create(Ref ref) {
    final argument = this.argument as String;
    return actorTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActorTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actorTasksHash() => r'a06f806e8a4f367272ad7788984f6ba99f7d5584';

/// The first tasks assigned to the actor [actorId].

final class ActorTasksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Page<Task>>, String> {
  ActorTasksFamily._()
    : super(
        retry: null,
        name: r'actorTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The first tasks assigned to the actor [actorId].

  ActorTasksProvider call(String actorId) =>
      ActorTasksProvider._(argument: actorId, from: this);

  @override
  String toString() => r'actorTasksProvider';
}

/// The API tokens of the actor [actorId], newest first.

@ProviderFor(actorTokens)
final actorTokensProvider = ActorTokensFamily._();

/// The API tokens of the actor [actorId], newest first.

final class ActorTokensProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<APIToken>>,
          List<APIToken>,
          FutureOr<List<APIToken>>
        >
    with $FutureModifier<List<APIToken>>, $FutureProvider<List<APIToken>> {
  /// The API tokens of the actor [actorId], newest first.
  ActorTokensProvider._({
    required ActorTokensFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'actorTokensProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actorTokensHash();

  @override
  String toString() {
    return r'actorTokensProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<APIToken>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<APIToken>> create(Ref ref) {
    final argument = this.argument as String;
    return actorTokens(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActorTokensProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actorTokensHash() => r'ad5e3f5a86ce8a4955c8f516475dadb870f642f3';

/// The API tokens of the actor [actorId], newest first.

final class ActorTokensFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<APIToken>>, String> {
  ActorTokensFamily._()
    : super(
        retry: null,
        name: r'actorTokensProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The API tokens of the actor [actorId], newest first.

  ActorTokensProvider call(String actorId) =>
      ActorTokensProvider._(argument: actorId, from: this);

  @override
  String toString() => r'actorTokensProvider';
}

/// The SSH keys enrolled for the actor [actorId].

@ProviderFor(actorKeys)
final actorKeysProvider = ActorKeysFamily._();

/// The SSH keys enrolled for the actor [actorId].

final class ActorKeysProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SSHKey>>,
          List<SSHKey>,
          FutureOr<List<SSHKey>>
        >
    with $FutureModifier<List<SSHKey>>, $FutureProvider<List<SSHKey>> {
  /// The SSH keys enrolled for the actor [actorId].
  ActorKeysProvider._({
    required ActorKeysFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'actorKeysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actorKeysHash();

  @override
  String toString() {
    return r'actorKeysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SSHKey>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SSHKey>> create(Ref ref) {
    final argument = this.argument as String;
    return actorKeys(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActorKeysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actorKeysHash() => r'0cb9023f642f5d3c4eeb0f199698761b6235d422';

/// The SSH keys enrolled for the actor [actorId].

final class ActorKeysFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SSHKey>>, String> {
  ActorKeysFamily._()
    : super(
        retry: null,
        name: r'actorKeysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The SSH keys enrolled for the actor [actorId].

  ActorKeysProvider call(String actorId) =>
      ActorKeysProvider._(argument: actorId, from: this);

  @override
  String toString() => r'actorKeysProvider';
}

/// The newest audit entries the actor [actorId] made.

@ProviderFor(actorRecent)
final actorRecentProvider = ActorRecentFamily._();

/// The newest audit entries the actor [actorId] made.

final class ActorRecentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuditEntry>>,
          List<AuditEntry>,
          FutureOr<List<AuditEntry>>
        >
    with $FutureModifier<List<AuditEntry>>, $FutureProvider<List<AuditEntry>> {
  /// The newest audit entries the actor [actorId] made.
  ActorRecentProvider._({
    required ActorRecentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'actorRecentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actorRecentHash();

  @override
  String toString() {
    return r'actorRecentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AuditEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AuditEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return actorRecent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActorRecentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actorRecentHash() => r'f22947d5b46e1f1a184c189714cbb58a32372232';

/// The newest audit entries the actor [actorId] made.

final class ActorRecentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AuditEntry>>, String> {
  ActorRecentFamily._()
    : super(
        retry: null,
        name: r'actorRecentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The newest audit entries the actor [actorId] made.

  ActorRecentProvider call(String actorId) =>
      ActorRecentProvider._(argument: actorId, from: this);

  @override
  String toString() => r'actorRecentProvider';
}
