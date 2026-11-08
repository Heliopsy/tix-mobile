// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant.freezed.dart';
part 'tenant.g.dart';

/// The answer of `GET /tenants/{ref}`, as much of it as the app reads.
@freezed
abstract class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    @Default('') String key,
    @Default('') String name,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}
