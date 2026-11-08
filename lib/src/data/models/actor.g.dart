// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'actor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Actor _$ActorFromJson(Map<String, dynamic> json) => _Actor(
  id: json['id'] as String,
  handle: json['handle'] as String? ?? '',
  kind: json['kind'] as String? ?? '',
  displayName: json['display_name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
  tenantKey: json['tenant_key'] as String? ?? '',
  tenantName: json['tenant_name'] as String? ?? '',
);

Map<String, dynamic> _$ActorToJson(_Actor instance) => <String, dynamic>{
  'id': instance.id,
  'handle': instance.handle,
  'kind': instance.kind,
  'display_name': instance.displayName,
  'email': instance.email,
  'tenant_id': instance.tenantId,
  'tenant_key': instance.tenantKey,
  'tenant_name': instance.tenantName,
};
