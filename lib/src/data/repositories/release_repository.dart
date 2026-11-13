// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/release.dart';

export 'package:tix_mobile/src/data/models/release.dart';

/// The server's release check.
class ReleaseRepository {
  /// Reads through [_api].
  ReleaseRepository(this._api);

  final TixApi _api;

  /// What the server knows about its version and the newest release
  /// (`server.release`).
  Future<ReleaseBody> read() => _api.server.release();
}
