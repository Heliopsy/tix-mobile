// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart' show TaskImportRow;

/// What the server makes of a quick-add line, from a dry run of tix's
/// import, beside what it makes of a bare title in the same project, so the
/// defaults it fills in can be told from what the line set.
@immutable
class QuickPreview {
  /// Pairs [line] with [plain].
  const QuickPreview({required this.line, required this.plain});

  /// The line as the server would create it.
  final TaskImportRow line;

  /// A bare title as the server would create it.
  final TaskImportRow plain;

  /// Whether the server would refuse the line.
  bool get refused => line.action == 'error' || line.errors.isNotEmpty;

  /// The priority the line sets, or null when it is the default.
  int? get priority => line.priority == 0 || line.priority == plain.priority
      ? null
      : line.priority;

  /// The status the line sets, or null when it is the initial one.
  String? get status =>
      line.status.isEmpty || line.status == plain.status ? null : line.status;

  /// Why the server would refuse the line, or null.
  String? get refusal => line.errors.isEmpty ? null : line.errors.first;
}
