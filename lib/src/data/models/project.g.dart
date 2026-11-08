// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  key: json['key'] as String,
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  color: json['color'] as String? ?? '',
  icon: json['icon'] as String? ?? '',
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'key': instance.key,
  'name': instance.name,
  'description': instance.description,
  'color': instance.color,
  'icon': instance.icon,
  'archived_at': ?instance.archivedAt?.toIso8601String(),
};
