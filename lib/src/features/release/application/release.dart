// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/repositories/release_repository.dart';

export 'package:tix_mobile/src/data/repositories/release_repository.dart';

part 'release.g.dart';

/// The server's release check, for the active session.
@riverpod
ReleaseRepository releaseRepository(Ref ref) =>
    ReleaseRepository(ref.watch(sessionApiProvider));

/// What the active server knows about its version and the newest release.
@riverpod
Future<ServerRelease> serverRelease(Ref ref) =>
    ref.watch(releaseRepositoryProvider).read();
