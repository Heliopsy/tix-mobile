// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'health.freezed.dart';
part 'health.g.dart';

/// The answer of `GET /healthz`.
@freezed
abstract class Health with _$Health {
  const factory Health({
    @Default('') String status,
    @Default('') String version,
  }) = _Health;

  factory Health.fromJson(Map<String, dynamic> json) => _$HealthFromJson(json);
}
