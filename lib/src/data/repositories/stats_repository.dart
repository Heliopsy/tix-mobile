// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Stats;
import 'package:tix_mobile/src/data/api/tix_api.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show StateCategory, Stats, StatsActor, StatsAgeing, StatsCategory, StatsDay;

/// The tenant's numbers: throughput, lead times, where the work is and who
/// moved it.
class StatsRepository {
  /// Reads through [_api].
  StatsRepository(this._api);

  final TixApi _api;

  /// The figures for the [days] ending now, for [project] or the whole
  /// tenant when it is empty (`stats.read`).
  Future<Stats> read({required int days, String project = ''}) => _api.stats
      .read(project: project.isEmpty ? null : project, window: '${days * 24}h');
}
