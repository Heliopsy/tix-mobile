// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

part 'api.g.dart';

/// Builds a [TixApi] for a server root and an optional token.
typedef TixApiFactory = TixApi Function(String baseUrl, String? token);

/// How API clients are built; tests swap in one with a fake adapter.
@Riverpod(keepAlive: true)
TixApiFactory tixApiFactory(Ref ref) =>
    (baseUrl, token) => TixApi(baseUrl: baseUrl, token: token);
