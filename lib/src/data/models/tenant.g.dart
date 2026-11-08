// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tenant _$TenantFromJson(Map<String, dynamic> json) => _Tenant(
  id: json['id'] as String,
  key: json['key'] as String? ?? '',
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$TenantToJson(_Tenant instance) => <String, dynamic>{
  'id': instance.id,
  'key': instance.key,
  'name': instance.name,
};
