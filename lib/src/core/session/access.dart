// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/access.dart';

export 'package:tix_mobile/src/data/models/access.dart';

part 'access.g.dart';

/// What the active credential may do: the last `whoami` kept for the
/// context at once, then the server's answer.
@riverpod
class CurrentAccess extends _$CurrentAccess {
  @override
  Future<Access> build() async {
    final repo = ref.watch(identityRepositoryProvider);
    final me = await cachedFirst(
      ref: ref,
      cached: repo.cachedMe(),
      fresh: repo.me,
      onFresh: (a) => state = AsyncData(Access(a)),
    );
    return Access(me);
  }
}
