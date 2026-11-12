// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/repositories/token_repository.dart';

part 'tokens.g.dart';

/// The tokens of [actorId], or the whole tenant's when null, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// token's value goes straight back to the sheet that shows it.
@riverpod
class Tokens extends _$Tokens {
  @override
  Future<List<APIToken>> build(String? actorId) async {
    final repo = ref.watch(tokenRepositoryProvider);
    refreshOn(ref, EventTopics.tokens);
    final list = await repo.tokens(actorId: actorId);
    return [...list]..sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
  }

  /// Issues a token for [actorId] (the caller when null) and returns it with
  /// its value, which the caller shows once and drops.
  Future<IssuedToken> issue({
    required String name,
    required List<String> scopes,
    DateTime? expiresAt,
  }) async {
    final issued = await ref
        .read(tokenRepositoryProvider)
        .issue(
          name: name,
          scopes: scopes,
          expiresAt: expiresAt,
          actorId: actorId,
        );
    if (ref.mounted) ref.invalidateSelf();
    return issued;
  }

  /// Rotates [token], the old value working for [grace] beside the new one.
  ///
  /// The token this app's remote token connection presents is rotated
  /// through that connection, which stores the new value in place of the
  /// old; any other goes straight to the server, and its value comes back.
  Future<TokenRotation> rotate(APIToken token, {required String grace}) async {
    final connectionId = _ownConnection(token);
    if (connectionId != null) {
      final unsaved = await ref
          .read(sessionControllerProvider.notifier)
          .rotateToken(connectionId, grace: grace);
      if (ref.mounted) ref.invalidateSelf();
      return TokenRotation(name: token.name, value: unsaved, connection: true);
    }
    final issued = await ref
        .read(tokenRepositoryProvider)
        .rotate(token.id, grace: grace);
    if (ref.mounted) ref.invalidateSelf();
    return TokenRotation(name: token.name, value: issued.token);
  }

  /// The id of the connection that signs in with [token], if this app's
  /// active one does.
  String? _ownConnection(APIToken token) {
    final me = ref.read(currentAccessProvider).value?.me;
    final session = ref.read(sessionControllerProvider).value;
    if (me == null || session == null || me.tokenId != token.id) return null;
    if (session.connection.kind != ConnectionKind.token ||
        session.instance.kind != InstanceKind.remote) {
      return null;
    }
    return session.connection.id;
  }

  /// Revokes [token].
  Future<void> revoke(APIToken token) async {
    await ref.read(tokenRepositoryProvider).revoke(token.id);
    if (ref.mounted) ref.invalidateSelf();
  }
}

/// Actors by id, to name a token's owner.
@riverpod
Future<Map<String, Actor>> tokenOwners(Ref ref) async {
  final actors = await ref.watch(peopleRepositoryProvider).actors();
  return {for (final a in actors) a.id: a};
}

/// What a rotation leaves for the screen to say.
class TokenRotation {
  /// [name] was rotated; [value] is the new token to show once, if any.
  const TokenRotation({
    required this.name,
    required this.value,
    this.connection = false,
  });

  /// The token's name.
  final String name;

  /// The new value, to show once and drop. Null when this app stored it.
  final String? value;

  /// Whether it was the token this app connects with.
  final bool connection;
}
