// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show AccountMembership;

part 'membership.freezed.dart';
part 'membership.g.dart';

/// One tenant a signed-in person belongs to, from `whoami`'s `memberships`.
@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    required String tenantKey,
    @Default('') String tenantName,
    @Default('') String tenantId,
    @Default('') String actorId,
    @Default('') String handle,
    @Default('') String role,
    @Default('') String host,
  }) = _Membership;

  const Membership._();

  /// The membership `whoami` reported as [m].
  factory Membership.fromAccount(AccountMembership m) => Membership(
    tenantKey: m.tenantKey,
    tenantName: m.tenantName,
    tenantId: m.tenantId,
    actorId: m.actorId,
    handle: m.handle,
    role: m.role?.value ?? '',
    host: m.host,
  );

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);

  /// Whether this tenant is served at its own address rather than at
  /// [instanceHost], so switching to it here would be refused.
  bool servedElsewhere(String instanceHost) =>
      host.isNotEmpty && host.toLowerCase() != instanceHost.toLowerCase();
}
