// SPDX-License-Identifier: AGPL-3.0-or-later

/// One action over many tasks, and what it did to each.
library;

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show BulkAction, BulkOutcome, BulkResult, BulkTaskInput;

/// The tasks a bulk request names.
extension BulkTargets on BulkTaskInput {
  /// The references, empty when none.
  List<String> get targets => refs ?? const [];
}

/// The refusals in a bulk answer.
extension BulkRefusals on BulkResult {
  /// The outcomes the action was refused for.
  List<BulkOutcome> get refusals => [
    for (final o in outcomes)
      if (!o.applied) o,
  ];
}

/// The open work in a statistics report.
extension StatsOpen on Stats {
  /// Tasks in a category that is not finished.
  int get open => byCategory
      .where(
        (c) =>
            c.category != StateCategory.done &&
            c.category != StateCategory.cancelled,
      )
      .fold(0, (sum, c) => sum + c.count);
}
