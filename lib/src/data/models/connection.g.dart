// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Connection _$ConnectionFromJson(Map<String, dynamic> json) => _Connection(
  id: json['id'] as String,
  instanceId: json['instance_id'] as String,
  kind: $enumDecode(_$ConnectionKindEnumMap, json['kind']),
  createdAt: DateTime.parse(json['created_at'] as String),
  label: json['label'] as String? ?? '',
  handle: json['handle'] as String? ?? '',
  email: json['email'] as String? ?? '',
  tenantKey: json['tenant_key'] as String? ?? '',
  tenantName: json['tenant_name'] as String? ?? '',
  pinned: json['pinned'] as bool? ?? true,
  memberships:
      (json['memberships'] as List<dynamic>?)
          ?.map((e) => Membership.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Membership>[],
  lastUsedAt: json['last_used_at'] == null
      ? null
      : DateTime.parse(json['last_used_at'] as String),
);

Map<String, dynamic> _$ConnectionToJson(_Connection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'instance_id': instance.instanceId,
      'kind': _$ConnectionKindEnumMap[instance.kind]!,
      'created_at': instance.createdAt.toIso8601String(),
      'label': instance.label,
      'handle': instance.handle,
      'email': instance.email,
      'tenant_key': instance.tenantKey,
      'tenant_name': instance.tenantName,
      'pinned': instance.pinned,
      'memberships': instance.memberships.map((e) => e.toJson()).toList(),
      'last_used_at': ?instance.lastUsedAt?.toIso8601String(),
    };

const _$ConnectionKindEnumMap = {
  ConnectionKind.token: 'token',
  ConnectionKind.signIn: 'sign_in',
};

_ContextRef _$ContextRefFromJson(Map<String, dynamic> json) => _ContextRef(
  connectionId: json['connection_id'] as String,
  tenantKey: json['tenant_key'] as String? ?? '',
);

Map<String, dynamic> _$ContextRefToJson(_ContextRef instance) =>
    <String, dynamic>{
      'connection_id': instance.connectionId,
      'tenant_key': instance.tenantKey,
    };
