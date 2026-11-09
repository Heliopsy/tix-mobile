// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/repositories/bundle_repository.dart';
import 'package:tix_mobile/src/data/repositories/server_info_repository.dart';

part 'server_info.g.dart';

/// The installation's status, for the active session.
@riverpod
ServerInfoRepository serverInfoRepository(Ref ref) => ServerInfoRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// Bundles and snapshot imports for the active session. It has no cache:
/// every answer is about one file.
@riverpod
BundleRepository bundleRepository(Ref ref) =>
    BundleRepository(ref.watch(sessionApiProvider));
