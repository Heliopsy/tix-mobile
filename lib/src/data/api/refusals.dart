// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/data/api/credential.dart';

/// Tells [onRefused] about every `401` answered to [credential], then lets
/// the failure carry on to the caller unchanged.
class RefusalInterceptor extends Interceptor {
  /// Reports refusals of [credential] to [onRefused].
  RefusalInterceptor(this.credential, this.onRefused);

  /// What the client presents.
  final Credential credential;

  /// Called with [credential] each time the server answers `401`.
  final void Function(Credential credential) onRefused;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) onRefused(credential);
    handler.next(err);
  }
}
