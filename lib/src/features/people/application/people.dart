// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/repositories/people_repository.dart';

part 'people.g.dart';

/// The tenant's users with their roles.
@immutable
class PeopleView {
  /// [people] loaded so far; [rolesKnown] is false when the credential may
  /// not read memberships, so no role can be shown.
  const PeopleView({required this.people, required this.rolesKnown});

  /// The accounts loaded so far.
  final Paged<Person> people;

  /// Whether the roles come from the memberships.
  final bool rolesKnown;

  /// How many accounts loaded so far are active, and how many disabled.
  (int, int) get counts {
    final off = people.items.where((p) => p.disabled).length;
    return (people.items.length - off, off);
  }
}

/// The tenant's users a page at a time, each with its role, again whenever
/// a user, membership or invite changes.
@riverpod
class Users extends _$Users {
  Map<String, Role?>? _roles;

  @override
  Future<PeopleView> build() async {
    final repo = ref.watch(peopleRepositoryProvider);
    refreshOn(ref, EventTopics.people);
    final roles = repo.roles();
    final page = await cachedFirst(
      ref: ref,
      cached: repo.cachedUsers(),
      fresh: repo.users,
      onFresh: (p) async {
        final r = await roles;
        if (ref.mounted) state = AsyncData(_view(p, r));
      },
    );
    return _view(page, await roles);
  }

  PeopleView _view(Page<User> page, Map<String, Role?>? roles) {
    _roles = roles;
    return PeopleView(
      people: Paged(items: _people(page.items), cursor: page.nextCursor),
      rolesKnown: roles != null,
    );
  }

  List<Person> _people(List<User> users) => [
    for (final u in users) Person(u, _roles?[u.id]),
  ];

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    await loadNextPage<Person>(
      current: current.people,
      fetch: (cursor) async {
        final page = await ref
            .read(peopleRepositoryProvider)
            .users(cursor: cursor);
        return Page(items: _people(page.items), nextCursor: page.nextCursor);
      },
      emit: (next) => state = AsyncData(
        PeopleView(people: next, rolesKnown: current.rolesKnown),
      ),
      idOf: (p) => p.user.id,
    );
  }

  /// Creates an account that signs in with a password.
  Future<void> create({
    required String email,
    required String password,
    required Role role,
    String displayName = '',
    bool requirePasswordChange = true,
  }) async {
    await ref
        .read(peopleRepositoryProvider)
        .createUser(
          email: email,
          password: password,
          role: role,
          displayName: displayName,
          requirePasswordChange: requirePasswordChange,
        );
    if (ref.mounted) ref.invalidateSelf();
  }

  /// Applies [change] to [person], keeping the row in place.
  Future<Person> change(Person person, UpdateUserInput change) async {
    final user = await ref
        .read(peopleRepositoryProvider)
        .updateUser(person.user.id, change);
    final role = change.role ?? person.role;
    final updated = Person(user, role);
    _roles = {...?_roles, user.id: role};
    final current = ref.mounted ? state.value : null;
    if (current != null) {
      state = AsyncData(
        PeopleView(
          people: current.people.copyWith(
            items: [
              for (final p in current.people.items)
                if (p.user.id == user.id) updated else p,
            ],
          ),
          rolesKnown: current.rolesKnown,
        ),
      );
    }
    return updated;
  }

  /// Deletes [person]'s account.
  Future<void> delete(Person person) async {
    await ref.read(peopleRepositoryProvider).deleteUser(person.user.id);
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      PeopleView(
        people: current.people.copyWith(
          items: [
            for (final p in current.people.items)
              if (p.user.id != person.user.id) p,
          ],
        ),
        rolesKnown: current.rolesKnown,
      ),
    );
  }

  /// Gives the actor [actorId] [role] in this tenant.
  Future<void> addMember(String actorId, Role role) async {
    await ref.read(peopleRepositoryProvider).addMember(actorId, role);
    if (ref.mounted) ref.invalidateSelf();
  }

  /// Ends [person]'s membership, keeping the account.
  Future<void> removeMember(Person person) async {
    await ref.read(peopleRepositoryProvider).removeMember(person.user.id);
    if (ref.mounted) ref.invalidateSelf();
  }
}

/// The tenant's invites that are neither accepted nor revoked.
@riverpod
class Invites extends _$Invites {
  @override
  Future<List<Invite>> build() async {
    final repo = ref.watch(peopleRepositoryProvider);
    refreshOn(ref, EventTopics.people);
    return await repo.invites();
  }

  /// Invites [email]; the answer carries the link, which is returned to
  /// the caller and kept nowhere.
  Future<IssuedInvite> invite({
    required String email,
    required Role role,
    required String expiresIn,
    String displayName = '',
  }) async {
    final issued = await ref
        .read(peopleRepositoryProvider)
        .invite(
          email: email,
          role: role,
          expiresIn: expiresIn,
          displayName: displayName,
        );
    if (ref.mounted) {
      ref
        ..invalidateSelf()
        ..invalidate(usersProvider);
    }
    return issued;
  }

  /// Replaces [invite]'s link; the new one is returned and kept nowhere.
  Future<IssuedInvite> reissue(Invite invite) async {
    final issued = await ref
        .read(peopleRepositoryProvider)
        .reissueInvite(invite.id);
    if (ref.mounted) ref.invalidateSelf();
    return issued;
  }

  /// Stops [invite]'s link.
  Future<void> revoke(Invite invite) async {
    await ref.read(peopleRepositoryProvider).revokeInvite(invite.id);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final i in state.value ?? const <Invite>[])
        if (i.id != invite.id) i,
    ]);
  }
}

/// Actors that hold no membership of this tenant, who can be given one.
@riverpod
Future<List<Actor>> nonMembers(Ref ref) async {
  final repo = ref.watch(peopleRepositoryProvider);
  final members = {for (final m in await repo.members()) m.actorId};
  return [
    for (final a in await repo.actors())
      if (!members.contains(a.id) && a.kind != ActorKind.system) a,
  ];
}
