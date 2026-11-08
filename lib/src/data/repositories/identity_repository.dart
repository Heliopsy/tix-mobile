// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/actor.dart';

/// Who the active credential is, for deciding what to offer.
class IdentityRepository {
  /// Reads through [_api], keeping the answer in [_cache].
  IdentityRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  /// The actor the credential authenticates as (`identity.whoami`).
  Future<Actor> me() =>
      _cache.remember('whoami', _api.identity.whoami(), (a) => a.toJson());

  /// The last answer of [me], null when never read.
  Future<Actor?> cachedMe() =>
      _cache.peek('whoami', (j) => Actor.fromJson(j! as Map<String, dynamic>));
}
