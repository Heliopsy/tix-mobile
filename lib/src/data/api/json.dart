// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';

/// An RFC 3339 instant: read as tix writes it, always sent in UTC so the
/// string carries its offset.
class TixDateTime implements JsonConverter<DateTime, String> {
  /// The converter.
  const TixDateTime();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}
