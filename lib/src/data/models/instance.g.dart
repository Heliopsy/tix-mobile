// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Instance _$InstanceFromJson(Map<String, dynamic> json) => _Instance(
  id: json['id'] as String,
  name: json['name'] as String,
  kind: $enumDecode(_$InstanceKindEnumMap, json['kind']),
  createdAt: DateTime.parse(json['created_at'] as String),
  baseUrl: json['base_url'] as String? ?? '',
  dbPath: json['db_path'] as String? ?? '',
  lastUsedAt: json['last_used_at'] == null
      ? null
      : DateTime.parse(json['last_used_at'] as String),
);

Map<String, dynamic> _$InstanceToJson(_Instance instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'kind': _$InstanceKindEnumMap[instance.kind]!,
  'created_at': instance.createdAt.toIso8601String(),
  'base_url': instance.baseUrl,
  'db_path': instance.dbPath,
  'last_used_at': ?instance.lastUsedAt?.toIso8601String(),
};

const _$InstanceKindEnumMap = {
  InstanceKind.remote: 'remote',
  InstanceKind.local: 'local',
};
