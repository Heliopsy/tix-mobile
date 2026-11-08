// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'people.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tenant's users a page at a time, each with its role, again whenever
/// a user, membership or invite changes.

@ProviderFor(Users)
final usersProvider = UsersProvider._();

/// The tenant's users a page at a time, each with its role, again whenever
/// a user, membership or invite changes.
final class UsersProvider extends $AsyncNotifierProvider<Users, PeopleView> {
  /// The tenant's users a page at a time, each with its role, again whenever
  /// a user, membership or invite changes.
  UsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersHash();

  @$internal
  @override
  Users create() => Users();
}

String _$usersHash() => r'f940855e6ce3f07037c5a6cc353638d7ef83866e';

/// The tenant's users a page at a time, each with its role, again whenever
/// a user, membership or invite changes.

abstract class _$Users extends $AsyncNotifier<PeopleView> {
  FutureOr<PeopleView> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PeopleView>, PeopleView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PeopleView>, PeopleView>,
              AsyncValue<PeopleView>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The tenant's invites that are neither accepted nor revoked.

@ProviderFor(Invites)
final invitesProvider = InvitesProvider._();

/// The tenant's invites that are neither accepted nor revoked.
final class InvitesProvider
    extends $AsyncNotifierProvider<Invites, List<Invite>> {
  /// The tenant's invites that are neither accepted nor revoked.
  InvitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitesHash();

  @$internal
  @override
  Invites create() => Invites();
}

String _$invitesHash() => r'3883af67a79abd6b9b3bb0a7e8acc604b3d4e3dd';

/// The tenant's invites that are neither accepted nor revoked.

abstract class _$Invites extends $AsyncNotifier<List<Invite>> {
  FutureOr<List<Invite>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Invite>>, List<Invite>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Invite>>, List<Invite>>,
              AsyncValue<List<Invite>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Actors that hold no membership of this tenant, who can be given one.

@ProviderFor(nonMembers)
final nonMembersProvider = NonMembersProvider._();

/// Actors that hold no membership of this tenant, who can be given one.

final class NonMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Actor>>,
          List<Actor>,
          FutureOr<List<Actor>>
        >
    with $FutureModifier<List<Actor>>, $FutureProvider<List<Actor>> {
  /// Actors that hold no membership of this tenant, who can be given one.
  NonMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nonMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nonMembersHash();

  @$internal
  @override
  $FutureProviderElement<List<Actor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Actor>> create(Ref ref) {
    return nonMembers(ref);
  }
}

String _$nonMembersHash() => r'3251dbf04dc50741fe63bf55d0f6330a4fcf603e';
