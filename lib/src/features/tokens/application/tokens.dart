// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
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
