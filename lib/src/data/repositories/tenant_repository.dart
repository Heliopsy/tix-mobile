// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

/// The theme a tenant names, read from the server and remembered per
/// context so the next start opens in the tenant's colour at once.
class TenantRepository {
  /// Reads through [_api] and remembers in [_store].
  TenantRepository(this._api, this._store);

  final TixApi _api;
  final KeyValueStore _store;

  static String _key(String context) => 'accent.$context';

  /// The theme last seen for [context], empty when none was.
  String rememberedTheme(String context) => _store.read(_key(context)) ?? '';

  /// The theme tenant [tenant] names, empty when it names none, or null
  /// when this credential may not read the tenant (it needs
  /// `tenant:admin`).
  Future<String?> theme(String tenant) async {
    try {
      return (await _api.tenant.show(tenant)).theme;
    } on TixException catch (e) {
      if (e.kind == TixErrorKind.forbidden || e.kind == TixErrorKind.notFound) {
        return null;
      }
      rethrow;
    }
  }

  /// Remembers [theme] for [context].
  Future<void> remember(String context, String theme) => theme.isEmpty
      ? _store.delete(_key(context))
      : _store.write(_key(context), theme);
}
