// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/page.dart';

export 'package:tix_mobile/src/data/models/people.dart';

/// Who the credential is, and the tenant's users, memberships and invites.
///
/// Only the first page of users is cached. Invites are never
/// cached: an issued invite carries its link, and the listing is kept off
/// disk so a later field cannot put one there.
class PeopleRepository {
  /// Reads and writes through [_api], keeping copies in [_cache].
  PeopleRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  static const _usersKey = 'people/users';

  /// One page of the tenant's users (`user.list`); the first is cached.
  Future<Page<User>> users({String? cursor}) {
    final fresh = _api.user.list(cursor: cursor);
    if (cursor != null) return fresh;
    return _cache.remember(
      _usersKey,
      fresh,
      (p) => p.toJson((u) => u.toJson()),
    );
  }

  /// The first page of users as last read.
  Future<Page<User>?> cachedUsers() => _cache.peek(
    _usersKey,
    (j) => Page.fromJson(
      j! as Map<String, dynamic>,
      (e) => User.fromJson(e! as Map<String, dynamic>),
    ),
  );

  /// The role each actor's membership grants (`member.list`), or null when
  /// the credential may not read memberships (it needs `tenant:admin`).
  Future<Map<String, Role?>?> roles() async {
    try {
      final page = await _api.member.list();
      return {for (final m in page.items) m.actorId: m.role};
    } on TixException catch (e) {
      if (e.kind == TixErrorKind.forbidden) return null;
      rethrow;
    }
  }

  /// Every membership of the tenant (`member.list`).
  Future<List<TenantMembership>> members() async =>
      (await _api.member.list()).items;

  /// Creates an account that signs in with [password] (`user.create`).
  Future<User> createUser({
    required String email,
    required String password,
    required Role role,
    String displayName = '',
    bool requirePasswordChange = true,
  }) => _api.user.create(
    CreateUserInput(
      email: email.trim(),
      password: password,
      role: role,
      displayName: displayName.trim().isEmpty ? null : displayName.trim(),
      requirePasswordChange: requirePasswordChange,
    ),
  );

  /// Changes what [change] sets on the account [id] (`user.update`).
  Future<User> updateUser(String id, UpdateUserInput change) =>
      _api.user.update(id, change);

  /// Deletes the account [id] and its membership (`user.delete`).
  Future<void> deleteUser(String id) => _api.user.delete(id);

  /// The tenant's pending and expired invites (`invite.list`).
  Future<List<Invite>> invites() async => (await _api.invite.list()).items;

  /// Invites [email] with [role], the link lasting [expiresIn] such as `7d`
  /// (`invite.create`). The link is in the answer and nowhere else.
  Future<IssuedInvite> invite({
    required String email,
    required Role role,
    required String expiresIn,
    String displayName = '',
  }) => _api.invite.create(
    CreateInviteInput(
      email: email.trim(),
      role: role,
      expiresIn: expiresIn,
      displayName: displayName.trim().isEmpty ? null : displayName.trim(),
    ),
  );

  /// Replaces the invite [id]'s link with a new one (`invite.reissue`).
  Future<IssuedInvite> reissueInvite(String id, {String? expiresIn}) =>
      _api.invite.reissue(
        id,
        body: expiresIn == null
            ? null
            : ReissueInviteInput(expiresIn: expiresIn),
      );

  /// Stops the invite [id]'s link (`invite.revoke`).
  Future<void> revokeInvite(String id) => _api.invite.revoke(id);

  /// Gives the actor [actorId] [role] in this tenant (`member.add`).
  Future<TenantMembership> addMember(String actorId, Role role) =>
      _api.member.add(AddMemberRequest(actorId: actorId, role: role));

  /// Ends the actor [actorId]'s membership (`member.remove`).
  Future<void> removeMember(String actorId) => _api.member.remove(actorId);

  /// Every actor of the tenant (`actor.list`), each page in turn.
  Future<List<Actor>> actors() async {
    final out = <Actor>[];
    String? cursor;
    do {
      final page = await _api.actor.list(cursor: cursor, limit: 200);
      out.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null);
    return out;
  }
}
