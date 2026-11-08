// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/session/server_info.dart';
import 'package:tix_mobile/src/data/models/server_info.dart';

export 'package:tix_mobile/src/data/models/server_info.dart';

part 'status.g.dart';

/// The installation's health and the tenant's work, as `tix status` reports
/// them: the last answer at once, then the server's.
@riverpod
class StatusReportState extends _$StatusReportState {
  @override
  Future<StatusReport> build() {
    final repo = ref.watch(serverInfoRepositoryProvider);
    return cachedFirst(
      ref: ref,
      cached: repo.cachedStatus(),
      fresh: repo.status,
      onFresh: (v) => state = AsyncData(v),
    );
  }
}
