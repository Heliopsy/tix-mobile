// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'tix_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TixEvent _$TixEventFromJson(Map<String, dynamic> json) => _TixEvent(
  seq: (json['seq'] as num).toInt(),
  type: json['type'] as String,
  id: json['id'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
  projectId: json['project_id'] as String? ?? '',
  subjectType: json['subject_type'] as String? ?? '',
  subjectId: json['subject_id'] as String? ?? '',
  actorId: json['actor_id'] as String? ?? '',
  payload:
      json['payload'] as Map<String, dynamic>? ?? const <String, Object?>{},
  via: json['via'] == null
      ? null
      : Via.fromJson(json['via'] as Map<String, dynamic>),
  occurredAt: _$JsonConverterFromJson<String, DateTime>(
    json['occurred_at'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$TixEventToJson(_TixEvent instance) => <String, dynamic>{
  'seq': instance.seq,
  'type': instance.type,
  'id': instance.id,
  'tenant_id': instance.tenantId,
  'project_id': instance.projectId,
  'subject_type': instance.subjectType,
  'subject_id': instance.subjectId,
  'actor_id': instance.actorId,
  'payload': instance.payload,
  'via': ?instance.via?.toJson(),
  'occurred_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.occurredAt,
    const TixDateTime().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
