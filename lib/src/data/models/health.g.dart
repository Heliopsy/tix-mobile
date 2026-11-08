// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Health _$HealthFromJson(Map<String, dynamic> json) => _Health(
  status: json['status'] as String? ?? '',
  version: json['version'] as String? ?? '',
);

Map<String, dynamic> _$HealthToJson(_Health instance) => <String, dynamic>{
  'status': instance.status,
  'version': instance.version,
};
