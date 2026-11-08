// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

export 'package:tix_mobile/src/data/models/people.dart';

/// API tokens: listed, issued and revoked.
///
/// Nothing here touches the response cache. An issued token's value exists
/// in the one answer that carries it, and listings are kept off disk too, so
/// a field tix adds later cannot leak one there.
class TokenRepository {
  /// Talks through [_api].
  TokenRepository(this._api);

  final TixApi _api;

  /// The tokens of [actorId], or every token of the tenant when null and
  /// the credential holds `tenant:admin` (`token.list`).
  Future<List<APIToken>> tokens({String? actorId}) async =>
      (await _api.token.list(actorId: actorId)).items;

  /// Issues a token called [name] with [scopes], ending at [expiresAt] or
  /// never (`token.create`). Its value is in the answer and nowhere else.
  Future<IssuedToken> issue({
    required String name,
    required List<String> scopes,
    DateTime? expiresAt,
    String? actorId,
  }) => _api.token.create(
    CreateTokenInput(
      name: name.trim(),
      scopes: scopes,
      expiresAt: expiresAt,
      actorId: actorId,
    ),
  );

  /// Revokes the token [id] (`token.revoke`).
  Future<void> revoke(String id) => _api.token.revoke(id);
}
