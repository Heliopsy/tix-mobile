// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  tenantKey: json['tenant_key'] as String,
  tenantName: json['tenant_name'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
  actorId: json['actor_id'] as String? ?? '',
  handle: json['handle'] as String? ?? '',
  role: json['role'] as String? ?? '',
  host: json['host'] as String? ?? '',
  icon: json['icon'] == null
      ? const TenantIcon()
      : TenantIcon.fromJson(json['icon'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'tenant_key': instance.tenantKey,
      'tenant_name': instance.tenantName,
      'tenant_id': instance.tenantId,
      'actor_id': instance.actorId,
      'handle': instance.handle,
      'role': instance.role,
      'host': instance.host,
      'icon': instance.icon.toJson(),
    };
