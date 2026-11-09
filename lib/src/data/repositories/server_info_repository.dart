// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/server_info.dart';

export 'package:tix_mobile/src/data/models/server_info.dart';

/// The installation's health.
class ServerInfoRepository {
  /// Reads through [_api], keeping copies in [_cache].
  ServerInfoRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  /// The installation, its servers, the tenant's work and its second factor
  /// (`status.read`).
  Future<StatusReport> status() =>
      _cache.remember('status', _api.status.read(), (r) => r.toJson());

  /// The status as last read.
  Future<StatusReport?> cachedStatus() => _cache.peek(
    'status',
    (j) => StatusReport.fromJson(j! as Map<String, dynamic>),
  );
}
