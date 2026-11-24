// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/transport.dart';
import 'package:tix_mobile/src/data/models/dav.dart';

/// CalDAV setup: whether the server answers it, and the caller's app
/// passwords. Written by hand until the vendored OpenAPI document has the
/// routes (tix 0.69.0); `just gen` then replaces this group with `api.dav`.
class DavOps {
  /// Sends through [_t].
  const DavOps(this._t);

  final TixTransport _t;

  /// Whether CalDAV is served, its address and the caller's user name.
  ///
  /// `GET /api/v1/dav` (`dav.info`).
  Future<DavInfo> info() async =>
      DavInfo.fromJson(await _t.json('GET', '/api/v1/dav'));

  /// The caller's app passwords, revoked ones included, without secrets.
  /// The route takes no cursor; its one page is the whole list.
  ///
  /// `GET /api/v1/dav/passwords` (`dav.password.list`).
  Future<List<DavPassword>> passwordList() async {
    final body = await _t.json('GET', '/api/v1/dav/passwords');
    final items = body['items'];
    return [
      if (items is List)
        for (final item in items)
          if (item is Map<String, dynamic>) DavPassword.fromJson(item),
    ];
  }

  /// Issues an app password; its secret is in this answer only.
  ///
  /// `POST /api/v1/dav/passwords` (`dav.password.create`).
  Future<IssuedDavPassword> passwordCreate(CreateDavPasswordInput body) async =>
      IssuedDavPassword.fromJson(
        await _t.json('POST', '/api/v1/dav/passwords', body: body.toJson()),
      );

  /// Revokes the app password [id]; revoking one twice is no error.
  ///
  /// `DELETE /api/v1/dav/passwords/{id}` (`dav.password.revoke`).
  Future<void> passwordRevoke(String id) =>
      _t.empty('DELETE', '/api/v1/dav/passwords/${_t.segment(id)}');
}
