// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tix_mobile/src/data/models/membership.dart';
import 'package:tix_mobile/src/data/models/tenant_icon.dart';

part 'connection.freezed.dart';
part 'connection.g.dart';

/// How a connection proves who it is.
enum ConnectionKind {
  /// An API token, pinned by tix to the tenant it was minted in.
  token,

  /// An email and password sign-in, holding a session.
  @JsonValue('sign_in')
  signIn,
}

/// One identity on an instance. Its secret lives in secure storage.
@freezed
abstract class Connection with _$Connection {
  const factory Connection({
    required String id,
    required String instanceId,
    required ConnectionKind kind,
    required DateTime createdAt,
    @Default('') String label,
    @Default('') String handle,
    @Default('') String email,
    @Default('') String tenantKey,
    @Default('') String tenantName,
    @Default(TenantIcon()) TenantIcon tenantIcon,
    @Default(true) bool pinned,
    @Default(<Membership>[]) List<Membership> memberships,
    DateTime? lastUsedAt,
  }) = _Connection;

  const Connection._();

  factory Connection.fromJson(Map<String, dynamic> json) =>
      _$ConnectionFromJson(json);

  /// Whether the switcher may move this connection between tenants.
  bool get switchable => kind == ConnectionKind.signIn && !pinned;

  /// The tenant's name when known, else its key.
  String get tenantLabel => tenantName.isNotEmpty ? tenantName : tenantKey;

  /// The context this connection targets now.
  ContextRef get ref => ContextRef(connectionId: id, tenantKey: tenantKey);
}

/// A context: a connection and the tenant it targets.
@freezed
abstract class ContextRef with _$ContextRef {
  const factory ContextRef({
    required String connectionId,
    @Default('') String tenantKey,
  }) = _ContextRef;

  factory ContextRef.fromJson(Map<String, dynamic> json) =>
      _$ContextRefFromJson(json);
}
