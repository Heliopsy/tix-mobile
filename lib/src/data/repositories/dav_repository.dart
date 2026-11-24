// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/dav.dart';

export 'package:tix_mobile/src/data/models/dav.dart';

/// CalDAV for other apps: whether the server serves it, and the caller's
/// app passwords.
///
/// Nothing here touches the response cache. An issued password exists in
/// the one answer that carries it, and listings stay off disk too, so a
/// field tix adds later cannot leak one there.
class DavRepository {
  /// Talks through [_api].
  DavRepository(this._api);

  final TixApi _api;

  /// What the server answers about CalDAV, or null when it has no such
  /// route (a tix before 0.69.0).
  Future<DavInfo?> info() async {
    try {
      return await _api.appDav.info();
    } on TixException catch (e) {
      if (e.status == 404 || e.status == 405) return null;
      rethrow;
    }
  }

  /// The caller's app passwords, revoked ones included.
  Future<List<DavPassword>> passwords() => _api.appDav.passwordList();

  /// Issues an app password called [name]. Null fields leave tix's defaults:
  /// Assigned to me, writing once the server does, never expiring.
  Future<IssuedDavPassword> create({
    required String name,
    String? collections,
    bool? readOnly,
    DateTime? expiresAt,
  }) => _api.appDav.passwordCreate(
    CreateDavPasswordInput(
      name: name.trim(),
      collections: collections,
      readOnly: readOnly,
      expiresAt: expiresAt?.toUtc(),
    ),
  );

  /// Revokes the app password [id].
  Future<void> revoke(String id) => _api.appDav.passwordRevoke(id);
}
