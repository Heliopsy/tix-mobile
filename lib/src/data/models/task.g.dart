// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  ref: json['ref'] as String,
  title: json['title'] as String,
  status: json['status'] as String? ?? '',
  body: json['body'] as String? ?? '',
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  projectId: json['project_id'] as String? ?? '',
  assigneeActorId: json['assignee_actor_id'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  blocked: json['blocked'] as bool? ?? false,
  starred: json['starred'] as bool? ?? false,
  version: (json['version'] as num?)?.toInt() ?? 0,
  dueAt: json['due_at'] == null
      ? null
      : DateTime.parse(json['due_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'ref': instance.ref,
  'title': instance.title,
  'status': instance.status,
  'body': instance.body,
  'priority': instance.priority,
  'project_id': instance.projectId,
  'assignee_actor_id': instance.assigneeActorId,
  'tags': instance.tags,
  'blocked': instance.blocked,
  'starred': instance.starred,
  'version': instance.version,
  'due_at': ?instance.dueAt?.toIso8601String(),
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'completed_at': ?instance.completedAt?.toIso8601String(),
};

_CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    _CreateTaskRequest(
      title: json['title'] as String,
      projectRef: json['project_ref'] as String?,
      parse: json['parse'] as bool? ?? false,
    );

Map<String, dynamic> _$CreateTaskRequestToJson(_CreateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'project_ref': ?instance.projectRef,
      'parse': instance.parse,
    };
