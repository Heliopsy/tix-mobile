// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'outbox_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutboxEntry _$OutboxEntryFromJson(Map<String, dynamic> json) => _OutboxEntry(
  id: json['id'] as String,
  seq: (json['seq'] as num).toInt(),
  op: $enumDecode(_$OutboxOpEnumMap, json['op']),
  target: json['target'] as String,
  idempotencyKey: json['idempotency_key'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  baseVersion: (json['base_version'] as num?)?.toInt(),
  base: json['base'] as Map<String, dynamic>? ?? const <String, Object?>{},
  values: json['values'] as Map<String, dynamic>? ?? const <String, Object?>{},
  state:
      $enumDecodeNullable(_$OutboxStateEnumMap, json['state']) ??
      OutboxState.pending,
  errorCode: json['error_code'] as String? ?? '',
  errorMessage: json['error_message'] as String? ?? '',
  draftRef: json['draft_ref'] as String? ?? '',
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  firstSentAt: json['first_sent_at'] == null
      ? null
      : DateTime.parse(json['first_sent_at'] as String),
);

Map<String, dynamic> _$OutboxEntryToJson(_OutboxEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seq': instance.seq,
      'op': _$OutboxOpEnumMap[instance.op]!,
      'target': instance.target,
      'idempotency_key': instance.idempotencyKey,
      'created_at': instance.createdAt.toIso8601String(),
      'base_version': ?instance.baseVersion,
      'base': instance.base,
      'values': instance.values,
      'state': _$OutboxStateEnumMap[instance.state]!,
      'error_code': instance.errorCode,
      'error_message': instance.errorMessage,
      'draft_ref': instance.draftRef,
      'attempts': instance.attempts,
      'first_sent_at': ?instance.firstSentAt?.toIso8601String(),
    };

const _$OutboxOpEnumMap = {
  OutboxOp.update: 'update',
  OutboxOp.check: 'check',
  OutboxOp.move: 'move',
  OutboxOp.star: 'star',
  OutboxOp.unstar: 'unstar',
  OutboxOp.snooze: 'snooze',
  OutboxOp.create: 'create',
  OutboxOp.comment: 'comment',
  OutboxOp.tagAdd: 'tagAdd',
  OutboxOp.tagRemove: 'tagRemove',
  OutboxOp.dependencyAdd: 'dependencyAdd',
  OutboxOp.artifactAdd: 'artifactAdd',
  OutboxOp.restore: 'restore',
};

const _$OutboxStateEnumMap = {
  OutboxState.pending: 'pending',
  OutboxState.failed: 'failed',
  OutboxState.conflict: 'conflict',
  OutboxState.needsCheck: 'needsCheck',
};

_FieldConflict _$FieldConflictFromJson(Map<String, dynamic> json) =>
    _FieldConflict(
      field: json['field'] as String,
      base: json['base'],
      mine: json['mine'],
      theirs: json['theirs'],
    );

Map<String, dynamic> _$FieldConflictToJson(_FieldConflict instance) =>
    <String, dynamic>{
      'field': instance.field,
      'base': ?instance.base,
      'mine': ?instance.mine,
      'theirs': ?instance.theirs,
    };

_ConflictRecord _$ConflictRecordFromJson(Map<String, dynamic> json) =>
    _ConflictRecord(
      id: json['id'] as String,
      entryId: json['entry_id'] as String,
      taskRef: json['task_ref'] as String,
      kind: $enumDecode(_$ConflictKindEnumMap, json['kind']),
      createdAt: DateTime.parse(json['created_at'] as String),
      taskTitle: json['task_title'] as String? ?? '',
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => FieldConflict.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FieldConflict>[],
      reason: json['reason'] as String? ?? '',
      wanted: json['wanted'] as String? ?? '',
      theirsVersion: (json['theirs_version'] as num?)?.toInt(),
      resolution: $enumDecodeNullable(_$ResolutionEnumMap, json['resolution']),
      auto: json['auto'] as bool? ?? false,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
    );

Map<String, dynamic> _$ConflictRecordToJson(_ConflictRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entry_id': instance.entryId,
      'task_ref': instance.taskRef,
      'kind': _$ConflictKindEnumMap[instance.kind]!,
      'created_at': instance.createdAt.toIso8601String(),
      'task_title': instance.taskTitle,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
      'reason': instance.reason,
      'wanted': instance.wanted,
      'theirs_version': ?instance.theirsVersion,
      'resolution': ?_$ResolutionEnumMap[instance.resolution],
      'auto': instance.auto,
      'resolved_at': ?instance.resolvedAt?.toIso8601String(),
    };

const _$ConflictKindEnumMap = {
  ConflictKind.fields: 'fields',
  ConflictKind.deleted: 'deleted',
  ConflictKind.invalidMove: 'invalidMove',
};

const _$ResolutionEnumMap = {
  Resolution.mine: 'mine',
  Resolution.theirs: 'theirs',
  Resolution.edited: 'edited',
  Resolution.restored: 'restored',
  Resolution.discarded: 'discarded',
};

_SyncSnapshot _$SyncSnapshotFromJson(Map<String, dynamic> json) =>
    _SyncSnapshot(
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => OutboxEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <OutboxEntry>[],
      conflicts:
          (json['conflicts'] as List<dynamic>?)
              ?.map((e) => ConflictRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ConflictRecord>[],
      drafts:
          (json['drafts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      nextDraft: (json['next_draft'] as num?)?.toInt() ?? 1,
      nextSeq: (json['next_seq'] as num?)?.toInt() ?? 1,
      idempotency: json['idempotency'] as bool?,
    );

Map<String, dynamic> _$SyncSnapshotToJson(_SyncSnapshot instance) =>
    <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'conflicts': instance.conflicts.map((e) => e.toJson()).toList(),
      'drafts': instance.drafts,
      'next_draft': instance.nextDraft,
      'next_seq': instance.nextSeq,
      'idempotency': ?instance.idempotency,
    };
