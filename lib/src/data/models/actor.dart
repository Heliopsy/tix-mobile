// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tix_mobile/src/data/models/membership.dart';

part 'actor.freezed.dart';
part 'actor.g.dart';

/// An identity on a tix server: a person, an agent or the system.
@freezed
abstract class Actor with _$Actor {
  const factory Actor({
    required String id,
    @Default('') String handle,
    @Default('') String kind,
    @Default('') String displayName,
    @Default('') String email,
    @Default('') String tenantId,
    @Default('') String tenantKey,
    @Default('') String tenantName,
    @Default('') String accountId,
    @Default(<Membership>[]) List<Membership> memberships,
  }) = _Actor;

  const Actor._();

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);

  /// The name to show for this actor: display name, else handle, else id.
  String get label => displayName.isNotEmpty
      ? displayName
      : handle.isNotEmpty
      ? handle
      : id;
}
