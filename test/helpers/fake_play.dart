// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/update/play_updates.dart';
import 'package:tix_mobile/src/data/update/play_feed.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

/// A Google Play that answers [answer], or fails with [failure], and
/// records what it is asked.
class FakePlayUpdates implements PlayUpdates {
  /// Answers [answer]; [started] is what start reports.
  FakePlayUpdates({this.answer, this.started = PlayStart.flexible});

  /// Play's answer, null for no Play.
  PlayUpdateInfo? answer;

  /// Thrown by [info] when set.
  UpdateException? failure;

  /// What [start] reports.
  PlayStart started;

  /// How often [info] ran.
  @visibleForTesting
  int asks = 0;

  /// How often [start] ran.
  @visibleForTesting
  int starts = 0;

  @override
  Future<PlayUpdateInfo?> info() async {
    asks++;
    if (failure case final f?) throw f;
    return answer;
  }

  @override
  Future<PlayStart> start() async {
    starts++;
    return started;
  }
}
