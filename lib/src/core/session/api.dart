// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

export 'package:tix_mobile/src/data/api/tix_api.dart' show TixApiFactory;

part 'api.g.dart';

/// How API clients are built; tests swap in one with a fake adapter.
@Riverpod(keepAlive: true)
TixApiFactory tixApiFactory(Ref ref) =>
    (baseUrl, credential) => TixApi(baseUrl: baseUrl, credential: credential);
