// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'models.gen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_APIToken _$APITokenFromJson(Map<String, dynamic> json) => _APIToken(
  actorId: json['actor_id'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expires_at'],
    const TixDateTime().fromJson,
  ),
  id: json['id'] as String? ?? '',
  lastUsedAt: _$JsonConverterFromJson<String, DateTime>(
    json['last_used_at'],
    const TixDateTime().fromJson,
  ),
  name: json['name'] as String? ?? '',
  projectId: json['project_id'] as String? ?? '',
  revokedAt: _$JsonConverterFromJson<String, DateTime>(
    json['revoked_at'],
    const TixDateTime().fromJson,
  ),
  scopes:
      (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tenantId: json['tenant_id'] as String? ?? '',
);

Map<String, dynamic> _$APITokenToJson(_APIToken instance) => <String, dynamic>{
  'actor_id': instance.actorId,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'expires_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.expiresAt,
    const TixDateTime().toJson,
  ),
  'id': instance.id,
  'last_used_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.lastUsedAt,
    const TixDateTime().toJson,
  ),
  'name': instance.name,
  'project_id': instance.projectId,
  'revoked_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.revokedAt,
    const TixDateTime().toJson,
  ),
  'scopes': instance.scopes,
  'tenant_id': instance.tenantId,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_AcceptInviteInput _$AcceptInviteInputFromJson(Map<String, dynamic> json) =>
    _AcceptInviteInput(
      code: json['code'] as String?,
      displayName: json['display_name'] as String?,
      password: json['password'] as String?,
      surface: $enumDecodeNullable(
        _$SurfaceEnumMap,
        json['surface'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$AcceptInviteInputToJson(_AcceptInviteInput instance) =>
    <String, dynamic>{
      'code': ?instance.code,
      'display_name': ?instance.displayName,
      'password': ?instance.password,
      'surface': ?_$SurfaceEnumMap[instance.surface],
    };

const _$SurfaceEnumMap = {
  Surface.web: 'web',
  Surface.cli: 'cli',
  Surface.ssh: 'ssh',
};

_AccountLogEntry _$AccountLogEntryFromJson(Map<String, dynamic> json) =>
    _AccountLogEntry(
      action: json['action'] as String? ?? '',
      byEmail: json['by_email'] as String? ?? '',
      byGlobalAdmin: json['by_global_admin'] as bool? ?? false,
      byUserId: json['by_user_id'] as String? ?? '',
      detail:
          json['detail'] as Map<String, dynamic>? ?? const <String, Object?>{},
      occurredAt: _$JsonConverterFromJson<String, DateTime>(
        json['occurred_at'],
        const TixDateTime().fromJson,
      ),
      seq: (json['seq'] as num?)?.toInt() ?? 0,
      tenantKey: json['tenant_key'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      via: json['via'] as String? ?? '',
    );

Map<String, dynamic> _$AccountLogEntryToJson(_AccountLogEntry instance) =>
    <String, dynamic>{
      'action': instance.action,
      'by_email': instance.byEmail,
      'by_global_admin': instance.byGlobalAdmin,
      'by_user_id': instance.byUserId,
      'detail': instance.detail,
      'occurred_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.occurredAt,
        const TixDateTime().toJson,
      ),
      'seq': instance.seq,
      'tenant_key': instance.tenantKey,
      'user_id': instance.userId,
      'via': instance.via,
    };

_AccountMembership _$AccountMembershipFromJson(Map<String, dynamic> json) =>
    _AccountMembership(
      actorId: json['actor_id'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      host: json['host'] as String? ?? '',
      role: $enumDecodeNullable(
        _$RoleEnumMap,
        json['role'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      tenantId: json['tenant_id'] as String? ?? '',
      tenantKey: json['tenant_key'] as String? ?? '',
      tenantName: json['tenant_name'] as String? ?? '',
    );

Map<String, dynamic> _$AccountMembershipToJson(_AccountMembership instance) =>
    <String, dynamic>{
      'actor_id': instance.actorId,
      'handle': instance.handle,
      'host': instance.host,
      'role': ?_$RoleEnumMap[instance.role],
      'tenant_id': instance.tenantId,
      'tenant_key': instance.tenantKey,
      'tenant_name': instance.tenantName,
    };

const _$RoleEnumMap = {
  Role.viewer: 'viewer',
  Role.member: 'member',
  Role.admin: 'admin',
};

_Actor _$ActorFromJson(Map<String, dynamic> json) => _Actor(
  accountId: json['account_id'] as String? ?? '',
  displayName: json['display_name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  globalAdmin: json['global_admin'] as bool? ?? false,
  handle: json['handle'] as String? ?? '',
  id: json['id'] as String? ?? '',
  kind: $enumDecodeNullable(
    _$ActorKindEnumMap,
    json['kind'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  memberships:
      (json['memberships'] as List<dynamic>?)
          ?.map((e) => AccountMembership.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AccountMembership>[],
  projectId: json['project_id'] as String? ?? '',
  role: $enumDecodeNullable(
    _$RoleEnumMap,
    json['role'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  scopes:
      (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  secondFactorDue: _$JsonConverterFromJson<String, DateTime>(
    json['second_factor_due'],
    const TixDateTime().fromJson,
  ),
  secondFactorEnrollmentRequired:
      json['second_factor_enrollment_required'] as bool? ?? false,
  tenantId: json['tenant_id'] as String? ?? '',
  tenantKey: json['tenant_key'] as String? ?? '',
  tenantName: json['tenant_name'] as String? ?? '',
  theme: json['theme'] == null
      ? null
      : Theme.fromJson(json['theme'] as Map<String, dynamic>),
  tokenId: json['token_id'] as String? ?? '',
);

Map<String, dynamic> _$ActorToJson(_Actor instance) => <String, dynamic>{
  'account_id': instance.accountId,
  'display_name': instance.displayName,
  'email': instance.email,
  'global_admin': instance.globalAdmin,
  'handle': instance.handle,
  'id': instance.id,
  'kind': ?_$ActorKindEnumMap[instance.kind],
  'memberships': instance.memberships.map((e) => e.toJson()).toList(),
  'project_id': instance.projectId,
  'role': ?_$RoleEnumMap[instance.role],
  'scopes': instance.scopes,
  'second_factor_due': ?_$JsonConverterToJson<String, DateTime>(
    instance.secondFactorDue,
    const TixDateTime().toJson,
  ),
  'second_factor_enrollment_required': instance.secondFactorEnrollmentRequired,
  'tenant_id': instance.tenantId,
  'tenant_key': instance.tenantKey,
  'tenant_name': instance.tenantName,
  'theme': ?instance.theme?.toJson(),
  'token_id': instance.tokenId,
};

const _$ActorKindEnumMap = {
  ActorKind.user: 'user',
  ActorKind.agent: 'agent',
  ActorKind.system: 'system',
};

_AddDomainInput _$AddDomainInputFromJson(Map<String, dynamic> json) =>
    _AddDomainInput(
      certMode: json['cert_mode'] as String?,
      certPath: json['cert_path'] as String?,
      hostname: json['hostname'] as String?,
      keyPath: json['key_path'] as String?,
    );

Map<String, dynamic> _$AddDomainInputToJson(_AddDomainInput instance) =>
    <String, dynamic>{
      'cert_mode': ?instance.certMode,
      'cert_path': ?instance.certPath,
      'hostname': ?instance.hostname,
      'key_path': ?instance.keyPath,
    };

_AddMemberRequest _$AddMemberRequestFromJson(Map<String, dynamic> json) =>
    _AddMemberRequest(
      actorId: json['actor_id'] as String?,
      role: $enumDecodeNullable(
        _$RoleEnumMap,
        json['role'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$AddMemberRequestToJson(_AddMemberRequest instance) =>
    <String, dynamic>{
      'actor_id': ?instance.actorId,
      'role': ?_$RoleEnumMap[instance.role],
    };

_AddTenantMemberInput _$AddTenantMemberInputFromJson(
  Map<String, dynamic> json,
) => _AddTenantMemberInput(
  email: json['email'] as String?,
  handle: json['handle'] as String?,
  role: $enumDecodeNullable(
    _$RoleEnumMap,
    json['role'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
);

Map<String, dynamic> _$AddTenantMemberInputToJson(
  _AddTenantMemberInput instance,
) => <String, dynamic>{
  'email': ?instance.email,
  'handle': ?instance.handle,
  'role': ?_$RoleEnumMap[instance.role],
};

_ApplyWorkflowTemplateInput _$ApplyWorkflowTemplateInputFromJson(
  Map<String, dynamic> json,
) => _ApplyWorkflowTemplateInput(
  as: json['as'] as String?,
  onCollision: $enumDecodeNullable(
    _$CollisionPolicyEnumMap,
    json['on_collision'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
);

Map<String, dynamic> _$ApplyWorkflowTemplateInputToJson(
  _ApplyWorkflowTemplateInput instance,
) => <String, dynamic>{
  'as': ?instance.as,
  'on_collision': ?_$CollisionPolicyEnumMap[instance.onCollision],
};

const _$CollisionPolicyEnumMap = {
  CollisionPolicy.skip: 'skip',
  CollisionPolicy.rename: 'rename',
  CollisionPolicy.replace: 'replace',
};

_Artifact _$ArtifactFromJson(Map<String, dynamic> json) => _Artifact(
  actorId: json['actor_id'] as String? ?? '',
  blob: json['blob'] as String? ?? '',
  contentType: json['content_type'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  id: json['id'] as String? ?? '',
  kind: $enumDecodeNullable(
    _$ArtifactKindEnumMap,
    json['kind'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  name: json['name'] as String? ?? '',
  payload:
      json['payload'] as Map<String, dynamic>? ?? const <String, Object?>{},
  taskId: json['task_id'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
);

Map<String, dynamic> _$ArtifactToJson(_Artifact instance) => <String, dynamic>{
  'actor_id': instance.actorId,
  'blob': instance.blob,
  'content_type': instance.contentType,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'id': instance.id,
  'kind': ?_$ArtifactKindEnumMap[instance.kind],
  'name': instance.name,
  'payload': instance.payload,
  'task_id': instance.taskId,
  'tenant_id': instance.tenantId,
};

const _$ArtifactKindEnumMap = {
  ArtifactKind.result: 'result',
  ArtifactKind.log: 'log',
  ArtifactKind.file: 'file',
  ArtifactKind.metric: 'metric',
};

_ArtifactInput _$ArtifactInputFromJson(Map<String, dynamic> json) =>
    _ArtifactInput(
      blob: json['blob'] as String?,
      contentType: json['content_type'] as String?,
      kind: $enumDecodeNullable(
        _$ArtifactKindEnumMap,
        json['kind'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      leaseToken: json['lease_token'] as String?,
      name: json['name'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ArtifactInputToJson(_ArtifactInput instance) =>
    <String, dynamic>{
      'blob': ?instance.blob,
      'content_type': ?instance.contentType,
      'kind': ?_$ArtifactKindEnumMap[instance.kind],
      'lease_token': ?instance.leaseToken,
      'name': ?instance.name,
      'payload': ?instance.payload,
    };

_ArtifactLimits _$ArtifactLimitsFromJson(Map<String, dynamic> json) =>
    _ArtifactLimits(
      allowedTypes:
          (json['allowed_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      maxBytes: (json['max_bytes'] as num?)?.toInt() ?? 0,
      serverAllowedTypes:
          (json['server_allowed_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      serverMaxBytes: (json['server_max_bytes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ArtifactLimitsToJson(_ArtifactLimits instance) =>
    <String, dynamic>{
      'allowed_types': instance.allowedTypes,
      'max_bytes': instance.maxBytes,
      'server_allowed_types': instance.serverAllowedTypes,
      'server_max_bytes': instance.serverMaxBytes,
    };

_AuditEntry _$AuditEntryFromJson(Map<String, dynamic> json) => _AuditEntry(
  action: json['action'] as String? ?? '',
  actorId: json['actor_id'] as String? ?? '',
  after: json['after'],
  before: json['before'],
  occurredAt: _$JsonConverterFromJson<String, DateTime>(
    json['occurred_at'],
    const TixDateTime().fromJson,
  ),
  seq: (json['seq'] as num?)?.toInt() ?? 0,
  source: $enumDecodeNullable(
    _$SourceEnumMap,
    json['source'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  subjectId: json['subject_id'] as String? ?? '',
  subjectType: json['subject_type'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
  via: json['via'] == null
      ? null
      : Via.fromJson(json['via'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuditEntryToJson(_AuditEntry instance) =>
    <String, dynamic>{
      'action': instance.action,
      'actor_id': instance.actorId,
      'after': ?instance.after,
      'before': ?instance.before,
      'occurred_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.occurredAt,
        const TixDateTime().toJson,
      ),
      'seq': instance.seq,
      'source': ?_$SourceEnumMap[instance.source],
      'subject_id': instance.subjectId,
      'subject_type': instance.subjectType,
      'tenant_id': instance.tenantId,
      'via': ?instance.via?.toJson(),
    };

const _$SourceEnumMap = {
  Source.cli: 'cli',
  Source.api: 'api',
  Source.web: 'web',
  Source.tui: 'tui',
  Source.system: 'system',
};

_BulkOutcome _$BulkOutcomeFromJson(Map<String, dynamic> json) => _BulkOutcome(
  applied: json['applied'] as bool? ?? false,
  code: json['code'] as String? ?? '',
  copyRef: json['copy_ref'] as String? ?? '',
  error: json['error'] as String? ?? '',
  movedRef: json['moved_ref'] as String? ?? '',
  ref: json['ref'] as String? ?? '',
);

Map<String, dynamic> _$BulkOutcomeToJson(_BulkOutcome instance) =>
    <String, dynamic>{
      'applied': instance.applied,
      'code': instance.code,
      'copy_ref': instance.copyRef,
      'error': instance.error,
      'moved_ref': instance.movedRef,
      'ref': instance.ref,
    };

_BulkResult _$BulkResultFromJson(Map<String, dynamic> json) => _BulkResult(
  action: $enumDecodeNullable(
    _$BulkActionEnumMap,
    json['action'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  applied: (json['applied'] as num?)?.toInt() ?? 0,
  outcomes:
      (json['outcomes'] as List<dynamic>?)
          ?.map((e) => BulkOutcome.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BulkOutcome>[],
  refused: (json['refused'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BulkResultToJson(_BulkResult instance) =>
    <String, dynamic>{
      'action': ?_$BulkActionEnumMap[instance.action],
      'applied': instance.applied,
      'outcomes': instance.outcomes.map((e) => e.toJson()).toList(),
      'refused': instance.refused,
    };

const _$BulkActionEnumMap = {
  BulkAction.move: 'move',
  BulkAction.priority: 'priority',
  BulkAction.tagAdd: 'tag_add',
  BulkAction.tagRemove: 'tag_remove',
  BulkAction.assign: 'assign',
  BulkAction.star: 'star',
  BulkAction.unstar: 'unstar',
  BulkAction.copy: 'copy',
  BulkAction.moveProject: 'move_project',
  BulkAction.delete: 'delete',
  BulkAction.restore: 'restore',
};

_BulkTaskInput _$BulkTaskInputFromJson(Map<String, dynamic> json) =>
    _BulkTaskInput(
      action: $enumDecodeNullable(
        _$BulkActionEnumMap,
        json['action'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      assigneeActorId: json['assignee_actor_id'] as String?,
      cascade: json['cascade'] as bool?,
      priority: (json['priority'] as num?)?.toInt(),
      projectRef: json['project_ref'] as String?,
      refs: (json['refs'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tag: json['tag'] as String?,
      to: json['to'] as String?,
    );

Map<String, dynamic> _$BulkTaskInputToJson(_BulkTaskInput instance) =>
    <String, dynamic>{
      'action': ?_$BulkActionEnumMap[instance.action],
      'assignee_actor_id': ?instance.assigneeActorId,
      'cascade': ?instance.cascade,
      'priority': ?instance.priority,
      'project_ref': ?instance.projectRef,
      'refs': ?instance.refs,
      'tag': ?instance.tag,
      'to': ?instance.to,
    };

_BundleExportInput _$BundleExportInputFromJson(Map<String, dynamic> json) =>
    _BundleExportInput(
      kinds: (json['kinds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      name: json['name'] as String?,
      projectRefs: (json['project_refs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      webhookIds: (json['webhook_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      workflowKeys: (json['workflow_keys'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BundleExportInputToJson(_BundleExportInput instance) =>
    <String, dynamic>{
      'kinds': ?instance.kinds,
      'name': ?instance.name,
      'project_refs': ?instance.projectRefs,
      'webhook_ids': ?instance.webhookIds,
      'workflow_keys': ?instance.workflowKeys,
    };

_BundleResult _$BundleResultFromJson(Map<String, dynamic> json) =>
    _BundleResult(
      bundleName: json['bundle_name'] as String? ?? '',
      bundleVersion: (json['bundle_version'] as num?)?.toInt() ?? 0,
      outcomes:
          (json['outcomes'] as List<dynamic>?)
              ?.map((e) => ComponentOutcome.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ComponentOutcome>[],
      preview: json['preview'] as bool? ?? false,
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$BundleResultToJson(_BundleResult instance) =>
    <String, dynamic>{
      'bundle_name': instance.bundleName,
      'bundle_version': instance.bundleVersion,
      'outcomes': instance.outcomes.map((e) => e.toJson()).toList(),
      'preview': instance.preview,
      'warnings': instance.warnings,
    };

_CalendarFeed _$CalendarFeedFromJson(Map<String, dynamic> json) =>
    _CalendarFeed(
      actorId: json['actor_id'] as String? ?? '',
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      filter: json['filter'] as String? ?? '',
      id: json['id'] as String? ?? '',
      revokedAt: _$JsonConverterFromJson<String, DateTime>(
        json['revoked_at'],
        const TixDateTime().fromJson,
      ),
      tenantId: json['tenant_id'] as String? ?? '',
    );

Map<String, dynamic> _$CalendarFeedToJson(_CalendarFeed instance) =>
    <String, dynamic>{
      'actor_id': instance.actorId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'filter': instance.filter,
      'id': instance.id,
      'revoked_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.revokedAt,
        const TixDateTime().toJson,
      ),
      'tenant_id': instance.tenantId,
    };

_CalendarFeedInput _$CalendarFeedInputFromJson(Map<String, dynamic> json) =>
    _CalendarFeedInput(filter: json['filter'] as String?);

Map<String, dynamic> _$CalendarFeedInputToJson(_CalendarFeedInput instance) =>
    <String, dynamic>{'filter': ?instance.filter};

_ChannelDelivery _$ChannelDeliveryFromJson(Map<String, dynamic> json) =>
    _ChannelDelivery(
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      channelId: json['channel_id'] as String? ?? '',
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      id: json['id'] as String? ?? '',
      itemId: json['item_id'] as String? ?? '',
      lastError: json['last_error'] as String? ?? '',
      lastStatusCode: (json['last_status_code'] as num?)?.toInt() ?? 0,
      nextAttemptAt: _$JsonConverterFromJson<String, DateTime>(
        json['next_attempt_at'],
        const TixDateTime().fromJson,
      ),
      status: $enumDecodeNullable(
        _$DeliveryStatusEnumMap,
        json['status'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$ChannelDeliveryToJson(_ChannelDelivery instance) =>
    <String, dynamic>{
      'attempts': instance.attempts,
      'channel_id': instance.channelId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'id': instance.id,
      'item_id': instance.itemId,
      'last_error': instance.lastError,
      'last_status_code': instance.lastStatusCode,
      'next_attempt_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.nextAttemptAt,
        const TixDateTime().toJson,
      ),
      'status': ?_$DeliveryStatusEnumMap[instance.status],
    };

const _$DeliveryStatusEnumMap = {
  DeliveryStatus.pending: 'pending',
  DeliveryStatus.delivered: 'delivered',
  DeliveryStatus.failed: 'failed',
};

_Check _$CheckFromJson(Map<String, dynamic> json) => _Check(
  error: json['error'] as String? ?? '',
  name: json['name'] as String? ?? '',
  ok: json['ok'] as bool? ?? false,
);

Map<String, dynamic> _$CheckToJson(_Check instance) => <String, dynamic>{
  'error': instance.error,
  'name': instance.name,
  'ok': instance.ok,
};

_CheckItemInput _$CheckItemInputFromJson(Map<String, dynamic> json) =>
    _CheckItemInput(
      done: json['done'] as bool?,
      item: (json['item'] as num?)?.toInt(),
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CheckItemInputToJson(_CheckItemInput instance) =>
    <String, dynamic>{
      'done': ?instance.done,
      'item': ?instance.item,
      'version': ?instance.version,
    };

_Checklist _$ChecklistFromJson(Map<String, dynamic> json) => _Checklist(
  done: (json['done'] as num?)?.toInt() ?? 0,
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ChecklistToJson(_Checklist instance) =>
    <String, dynamic>{'done': instance.done, 'total': instance.total};

_Claim _$ClaimFromJson(Map<String, dynamic> json) => _Claim(
  lease: json['lease'] == null
      ? null
      : LeaseGrant.fromJson(json['lease'] as Map<String, dynamic>),
  leaseExpiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['lease_expires_at'],
    const TixDateTime().fromJson,
  ),
  leaseToken: json['lease_token'] as String? ?? '',
  task: json['task'] == null
      ? null
      : Task.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClaimToJson(_Claim instance) => <String, dynamic>{
  'lease': ?instance.lease?.toJson(),
  'lease_expires_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.leaseExpiresAt,
    const TixDateTime().toJson,
  ),
  'lease_token': instance.leaseToken,
  'task': ?instance.task?.toJson(),
};

_ClaimInput _$ClaimInputFromJson(Map<String, dynamic> json) => _ClaimInput(
  actorId: json['actor_id'] as String?,
  ttl: json['ttl'] as String?,
);

Map<String, dynamic> _$ClaimInputToJson(_ClaimInput instance) =>
    <String, dynamic>{'actor_id': ?instance.actorId, 'ttl': ?instance.ttl};

_ClaimNextInput _$ClaimNextInputFromJson(Map<String, dynamic> json) =>
    _ClaimNextInput(
      actorId: json['actor_id'] as String?,
      projectRefs: (json['project_refs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      ttl: json['ttl'] as String?,
    );

Map<String, dynamic> _$ClaimNextInputToJson(_ClaimNextInput instance) =>
    <String, dynamic>{
      'actor_id': ?instance.actorId,
      'project_refs': ?instance.projectRefs,
      'statuses': ?instance.statuses,
      'tags': ?instance.tags,
      'ttl': ?instance.ttl,
    };

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  authorActorId: json['author_actor_id'] as String? ?? '',
  body: json['body'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  deletedAt: _$JsonConverterFromJson<String, DateTime>(
    json['deleted_at'],
    const TixDateTime().fromJson,
  ),
  id: json['id'] as String? ?? '',
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Reaction>[],
  taskId: json['task_id'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updated_at'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'author_actor_id': instance.authorActorId,
  'body': instance.body,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'deleted_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.deletedAt,
    const TixDateTime().toJson,
  ),
  'id': instance.id,
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'task_id': instance.taskId,
  'tenant_id': instance.tenantId,
  'updated_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const TixDateTime().toJson,
  ),
};

_CommentRequest _$CommentRequestFromJson(Map<String, dynamic> json) =>
    _CommentRequest(body: json['body'] as String?);

Map<String, dynamic> _$CommentRequestToJson(_CommentRequest instance) =>
    <String, dynamic>{'body': ?instance.body};

_ComponentOutcome _$ComponentOutcomeFromJson(Map<String, dynamic> json) =>
    _ComponentOutcome(
      action: $enumDecodeNullable(
        _$ComponentActionEnumMap,
        json['action'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      key: json['key'] as String? ?? '',
      kind: $enumDecodeNullable(
        _$ComponentKindEnumMap,
        json['kind'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      newKey: json['new_key'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );

Map<String, dynamic> _$ComponentOutcomeToJson(_ComponentOutcome instance) =>
    <String, dynamic>{
      'action': ?_$ComponentActionEnumMap[instance.action],
      'key': instance.key,
      'kind': ?_$ComponentKindEnumMap[instance.kind],
      'new_key': instance.newKey,
      'reason': instance.reason,
    };

const _$ComponentActionEnumMap = {
  ComponentAction.created: 'created',
  ComponentAction.updated: 'updated',
  ComponentAction.renamed: 'renamed',
  ComponentAction.skipped: 'skipped',
};

const _$ComponentKindEnumMap = {
  ComponentKind.workflow: 'workflow',
  ComponentKind.fieldDef: 'field_def',
  ComponentKind.tag: 'tag',
  ComponentKind.projectTemplate: 'project_template',
  ComponentKind.webhook: 'webhook',
};

_LiveConnection _$LiveConnectionFromJson(Map<String, dynamic> json) =>
    _LiveConnection(
      actorHandle: json['actor_handle'] as String? ?? '',
      actorId: json['actor_id'] as String? ?? '',
      fingerprint: json['fingerprint'] as String? ?? '',
      id: json['id'] as String? ?? '',
      remote: json['remote'] as String? ?? '',
      since: _$JsonConverterFromJson<String, DateTime>(
        json['since'],
        const TixDateTime().fromJson,
      ),
      surface: $enumDecodeNullable(
        _$ConnectionSurfaceEnumMap,
        json['surface'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      tenantId: json['tenant_id'] as String? ?? '',
    );

Map<String, dynamic> _$LiveConnectionToJson(_LiveConnection instance) =>
    <String, dynamic>{
      'actor_handle': instance.actorHandle,
      'actor_id': instance.actorId,
      'fingerprint': instance.fingerprint,
      'id': instance.id,
      'remote': instance.remote,
      'since': ?_$JsonConverterToJson<String, DateTime>(
        instance.since,
        const TixDateTime().toJson,
      ),
      'surface': ?_$ConnectionSurfaceEnumMap[instance.surface],
      'tenant_id': instance.tenantId,
    };

const _$ConnectionSurfaceEnumMap = {
  ConnectionSurface.events: 'events',
  ConnectionSurface.ssh: 'ssh',
};

_ConnectionCounts _$ConnectionCountsFromJson(Map<String, dynamic> json) =>
    _ConnectionCounts(
      events: (json['events'] as num?)?.toInt() ?? 0,
      process: (json['process'] as num?)?.toInt() ?? 0,
      ssh: (json['ssh'] as num?)?.toInt() ?? 0,
      tenant: (json['tenant'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ConnectionCountsToJson(_ConnectionCounts instance) =>
    <String, dynamic>{
      'events': instance.events,
      'process': instance.process,
      'ssh': instance.ssh,
      'tenant': instance.tenant,
    };

_ConnectionList _$ConnectionListFromJson(Map<String, dynamic> json) =>
    _ConnectionList(
      connections:
          (json['connections'] as List<dynamic>?)
              ?.map((e) => LiveConnection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LiveConnection>[],
      counts: json['counts'] == null
          ? null
          : ConnectionCounts.fromJson(json['counts'] as Map<String, dynamic>),
      serverId: json['server_id'] as String? ?? '',
    );

Map<String, dynamic> _$ConnectionListToJson(_ConnectionList instance) =>
    <String, dynamic>{
      'connections': instance.connections.map((e) => e.toJson()).toList(),
      'counts': ?instance.counts?.toJson(),
      'server_id': instance.serverId,
    };

_CopyTaskInput _$CopyTaskInputFromJson(Map<String, dynamic> json) =>
    _CopyTaskInput(
      keepStatus: json['keep_status'] as bool?,
      link: json['link'] as bool?,
      projectRef: json['project_ref'] as String?,
      title: json['title'] as String?,
      withComments: json['with_comments'] as bool?,
      withDependencies: json['with_dependencies'] as bool?,
      withSubtasks: json['with_subtasks'] as bool?,
    );

Map<String, dynamic> _$CopyTaskInputToJson(_CopyTaskInput instance) =>
    <String, dynamic>{
      'keep_status': ?instance.keepStatus,
      'link': ?instance.link,
      'project_ref': ?instance.projectRef,
      'title': ?instance.title,
      'with_comments': ?instance.withComments,
      'with_dependencies': ?instance.withDependencies,
      'with_subtasks': ?instance.withSubtasks,
    };

_CreateInviteInput _$CreateInviteInputFromJson(Map<String, dynamic> json) =>
    _CreateInviteInput(
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      expiresIn: json['expires_in'] as String?,
      handle: json['handle'] as String?,
      role: $enumDecodeNullable(
        _$RoleEnumMap,
        json['role'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$CreateInviteInputToJson(_CreateInviteInput instance) =>
    <String, dynamic>{
      'display_name': ?instance.displayName,
      'email': ?instance.email,
      'expires_in': ?instance.expiresIn,
      'handle': ?instance.handle,
      'role': ?_$RoleEnumMap[instance.role],
    };

_CreateProjectInput _$CreateProjectInputFromJson(Map<String, dynamic> json) =>
    _CreateProjectInput(
      color: json['color'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      iconFile: json['icon_file'] == null
          ? null
          : ProjectIconFile.fromJson(json['icon_file'] as Map<String, dynamic>),
      iconName: json['icon_name'] as String?,
      key: json['key'] as String?,
      name: json['name'] as String?,
      workflowKey: json['workflow_key'] as String?,
      workflowTemplate: json['workflow_template'] as String?,
    );

Map<String, dynamic> _$CreateProjectInputToJson(_CreateProjectInput instance) =>
    <String, dynamic>{
      'color': ?instance.color,
      'description': ?instance.description,
      'icon': ?instance.icon,
      'icon_file': ?instance.iconFile?.toJson(),
      'icon_name': ?instance.iconName,
      'key': ?instance.key,
      'name': ?instance.name,
      'workflow_key': ?instance.workflowKey,
      'workflow_template': ?instance.workflowTemplate,
    };

_CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    _CreateTaskRequest(
      assigneeActorId: json['assignee_actor_id'] as String?,
      body: json['body'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      dependsOn: (json['depends_on'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dueAt: _$JsonConverterFromJson<String, DateTime>(
        json['due_at'],
        const TixDateTime().fromJson,
      ),
      lease: json['lease'] as String?,
      parentRef: json['parent_ref'] as String?,
      parse: json['parse'] as bool?,
      priority: (json['priority'] as num?)?.toInt(),
      projectRef: json['project_ref'] as String?,
      recurrence: json['recurrence'] as String?,
      status: json['status'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$CreateTaskRequestToJson(_CreateTaskRequest instance) =>
    <String, dynamic>{
      'assignee_actor_id': ?instance.assigneeActorId,
      'body': ?instance.body,
      'custom_fields': ?instance.customFields,
      'depends_on': ?instance.dependsOn,
      'due_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.dueAt,
        const TixDateTime().toJson,
      ),
      'lease': ?instance.lease,
      'parent_ref': ?instance.parentRef,
      'parse': ?instance.parse,
      'priority': ?instance.priority,
      'project_ref': ?instance.projectRef,
      'recurrence': ?instance.recurrence,
      'status': ?instance.status,
      'tags': ?instance.tags,
      'title': ?instance.title,
    };

_CreateTenantInput _$CreateTenantInputFromJson(Map<String, dynamic> json) =>
    _CreateTenantInput(
      admins: (json['admins'] as List<dynamic>?)
          ?.map((e) => TenantAdminInput.fromJson(e as Map<String, dynamic>))
          .toList(),
      key: json['key'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CreateTenantInputToJson(_CreateTenantInput instance) =>
    <String, dynamic>{
      'admins': ?instance.admins?.map((e) => e.toJson()).toList(),
      'key': ?instance.key,
      'name': ?instance.name,
    };

_CreateTokenInput _$CreateTokenInputFromJson(Map<String, dynamic> json) =>
    _CreateTokenInput(
      actorId: json['actor_id'] as String?,
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expires_at'],
        const TixDateTime().fromJson,
      ),
      name: json['name'] as String?,
      projectId: json['project_id'] as String?,
      scopes: (json['scopes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateTokenInputToJson(_CreateTokenInput instance) =>
    <String, dynamic>{
      'actor_id': ?instance.actorId,
      'expires_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const TixDateTime().toJson,
      ),
      'name': ?instance.name,
      'project_id': ?instance.projectId,
      'scopes': ?instance.scopes,
    };

_CreateUserInput _$CreateUserInputFromJson(Map<String, dynamic> json) =>
    _CreateUserInput(
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      handle: json['handle'] as String?,
      password: json['password'] as String?,
      requirePasswordChange: json['require_password_change'] as bool?,
      role: $enumDecodeNullable(
        _$RoleEnumMap,
        json['role'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$CreateUserInputToJson(_CreateUserInput instance) =>
    <String, dynamic>{
      'display_name': ?instance.displayName,
      'email': ?instance.email,
      'handle': ?instance.handle,
      'password': ?instance.password,
      'require_password_change': ?instance.requirePasswordChange,
      'role': ?_$RoleEnumMap[instance.role],
    };

_CreatedAdmin _$CreatedAdminFromJson(Map<String, dynamic> json) =>
    _CreatedAdmin(
      email: json['email'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      passwordGenerated: json['password_generated'] as bool? ?? false,
      userId: json['user_id'] as String? ?? '',
    );

Map<String, dynamic> _$CreatedAdminToJson(_CreatedAdmin instance) =>
    <String, dynamic>{
      'email': instance.email,
      'handle': instance.handle,
      'password_generated': instance.passwordGenerated,
      'user_id': instance.userId,
    };

_CreatedTenant _$CreatedTenantFromJson(Map<String, dynamic> json) =>
    _CreatedTenant(
      admins:
          (json['admins'] as List<dynamic>?)
              ?.map((e) => CreatedAdmin.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CreatedAdmin>[],
      artifactMaxBytes: (json['artifact_max_bytes'] as num?)?.toInt() ?? 0,
      artifactTypes:
          (json['artifact_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      deletedAt: _$JsonConverterFromJson<String, DateTime>(
        json['deleted_at'],
        const TixDateTime().fromJson,
      ),
      id: json['id'] as String? ?? '',
      initialCredentials:
          (json['initial_credentials'] as List<dynamic>?)
              ?.map(
                (e) => InitialCredential.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <InitialCredential>[],
      key: json['key'] as String? ?? '',
      leaseDefault: json['lease_default'] as String? ?? '',
      leaseMax: json['lease_max'] as String? ?? '',
      mfaGrace: json['mfa_grace'] as String? ?? '',
      mfaPolicy: json['mfa_policy'] as String? ?? '',
      mfaRequiredAt: _$JsonConverterFromJson<String, DateTime>(
        json['mfa_required_at'],
        const TixDateTime().fromJson,
      ),
      name: json['name'] as String? ?? '',
      requireTotpCli: json['require_totp_cli'] as bool? ?? false,
      requireTotpSsh: json['require_totp_ssh'] as bool? ?? false,
      requireTotpWeb: json['require_totp_web'] as bool? ?? false,
      sessionIdleTimeout: json['session_idle_timeout'] as String? ?? '',
      sessionRememberOff: json['session_remember_off'] as bool? ?? false,
      sessionRememberTtl: json['session_remember_ttl'] as String? ?? '',
      sessionTtl: json['session_ttl'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      timeFormat: json['time_format'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      trashOff: json['trash_off'] as bool? ?? false,
      updatedAt: _$JsonConverterFromJson<String, DateTime>(
        json['updated_at'],
        const TixDateTime().fromJson,
      ),
    );

Map<String, dynamic> _$CreatedTenantToJson(_CreatedTenant instance) =>
    <String, dynamic>{
      'admins': instance.admins.map((e) => e.toJson()).toList(),
      'artifact_max_bytes': instance.artifactMaxBytes,
      'artifact_types': instance.artifactTypes,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'deleted_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.deletedAt,
        const TixDateTime().toJson,
      ),
      'id': instance.id,
      'initial_credentials': instance.initialCredentials
          .map((e) => e.toJson())
          .toList(),
      'key': instance.key,
      'lease_default': instance.leaseDefault,
      'lease_max': instance.leaseMax,
      'mfa_grace': instance.mfaGrace,
      'mfa_policy': instance.mfaPolicy,
      'mfa_required_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.mfaRequiredAt,
        const TixDateTime().toJson,
      ),
      'name': instance.name,
      'require_totp_cli': instance.requireTotpCli,
      'require_totp_ssh': instance.requireTotpSsh,
      'require_totp_web': instance.requireTotpWeb,
      'session_idle_timeout': instance.sessionIdleTimeout,
      'session_remember_off': instance.sessionRememberOff,
      'session_remember_ttl': instance.sessionRememberTtl,
      'session_ttl': instance.sessionTtl,
      'theme': instance.theme,
      'time_format': instance.timeFormat,
      'timezone': instance.timezone,
      'trash_off': instance.trashOff,
      'updated_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const TixDateTime().toJson,
      ),
    };

_Dependency _$DependencyFromJson(Map<String, dynamic> json) => _Dependency(
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  dependsOn: json['depends_on'] as String? ?? '',
  taskId: json['task_id'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
);

Map<String, dynamic> _$DependencyToJson(_Dependency instance) =>
    <String, dynamic>{
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'depends_on': instance.dependsOn,
      'task_id': instance.taskId,
      'tenant_id': instance.tenantId,
    };

_DependencyRequest _$DependencyRequestFromJson(Map<String, dynamic> json) =>
    _DependencyRequest(dependsOn: json['depends_on'] as String?);

Map<String, dynamic> _$DependencyRequestToJson(_DependencyRequest instance) =>
    <String, dynamic>{'depends_on': ?instance.dependsOn};

_Domain _$DomainFromJson(Map<String, dynamic> json) => _Domain(
  certMode: json['cert_mode'] as String? ?? '',
  certPath: json['cert_path'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  hostname: json['hostname'] as String? ?? '',
  id: json['id'] as String? ?? '',
  keyPath: json['key_path'] as String? ?? '',
  shared: json['shared'] as bool? ?? false,
  tenantId: json['tenant_id'] as String? ?? '',
  verifiedAt: _$JsonConverterFromJson<String, DateTime>(
    json['verified_at'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$DomainToJson(_Domain instance) => <String, dynamic>{
  'cert_mode': instance.certMode,
  'cert_path': instance.certPath,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'hostname': instance.hostname,
  'id': instance.id,
  'key_path': instance.keyPath,
  'shared': instance.shared,
  'tenant_id': instance.tenantId,
  'verified_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.verifiedAt,
    const TixDateTime().toJson,
  ),
};

_EnrolSSHKeyInput _$EnrolSSHKeyInputFromJson(Map<String, dynamic> json) =>
    _EnrolSSHKeyInput(
      actorId: json['actor_id'] as String?,
      allTenants: json['all_tenants'] as bool?,
      label: json['label'] as String?,
      publicKey: json['public_key'] as String?,
    );

Map<String, dynamic> _$EnrolSSHKeyInputToJson(_EnrolSSHKeyInput instance) =>
    <String, dynamic>{
      'actor_id': ?instance.actorId,
      'all_tenants': ?instance.allTenants,
      'label': ?instance.label,
      'public_key': ?instance.publicKey,
    };

_ErrorBody _$ErrorBodyFromJson(Map<String, dynamic> json) => _ErrorBody(
  code: $enumDecodeNullable(
    _$KindEnumMap,
    json['code'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  details:
      json['details'] as Map<String, dynamic>? ?? const <String, Object?>{},
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$ErrorBodyToJson(_ErrorBody instance) =>
    <String, dynamic>{
      'code': ?_$KindEnumMap[instance.code],
      'details': instance.details,
      'message': instance.message,
    };

const _$KindEnumMap = {
  Kind.invalid: 'invalid',
  Kind.notFound: 'not_found',
  Kind.conflict: 'conflict',
  Kind.unauthenticated: 'unauthenticated',
  Kind.forbidden: 'forbidden',
  Kind.leaseExpired: 'lease_expired',
  Kind.noTaskAvailable: 'no_task_available',
  Kind.preconditionFailed: 'precondition_failed',
  Kind.upstream: 'upstream',
  Kind.internal: 'internal',
};

_ErrorEnvelope _$ErrorEnvelopeFromJson(Map<String, dynamic> json) =>
    _ErrorEnvelope(
      error: json['error'] == null
          ? null
          : ErrorBody.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ErrorEnvelopeToJson(_ErrorEnvelope instance) =>
    <String, dynamic>{'error': ?instance.error?.toJson()};

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  actorId: json['actor_id'] as String? ?? '',
  id: json['id'] as String? ?? '',
  occurredAt: _$JsonConverterFromJson<String, DateTime>(
    json['occurred_at'],
    const TixDateTime().fromJson,
  ),
  payload:
      json['payload'] as Map<String, dynamic>? ?? const <String, Object?>{},
  projectId: json['project_id'] as String? ?? '',
  seq: (json['seq'] as num?)?.toInt() ?? 0,
  subjectId: json['subject_id'] as String? ?? '',
  subjectType: json['subject_type'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
  type: $enumDecodeNullable(
    _$EventTypeEnumMap,
    json['type'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  via: json['via'] == null
      ? null
      : Via.fromJson(json['via'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'actor_id': instance.actorId,
  'id': instance.id,
  'occurred_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.occurredAt,
    const TixDateTime().toJson,
  ),
  'payload': instance.payload,
  'project_id': instance.projectId,
  'seq': instance.seq,
  'subject_id': instance.subjectId,
  'subject_type': instance.subjectType,
  'tenant_id': instance.tenantId,
  'type': ?_$EventTypeEnumMap[instance.type],
  'via': ?instance.via?.toJson(),
};

const _$EventTypeEnumMap = {
  EventType.taskCreated: 'task.created',
  EventType.taskUpdated: 'task.updated',
  EventType.taskTransitioned: 'task.transitioned',
  EventType.taskClaimed: 'task.claimed',
  EventType.taskReleased: 'task.released',
  EventType.taskLeaseExpired: 'task.lease_expired',
  EventType.taskReclaimed: 'task.reclaimed',
  EventType.taskDeleted: 'task.deleted',
  EventType.taskStarred: 'task.starred',
  EventType.taskUnstarred: 'task.unstarred',
  EventType.taskSnoozed: 'task.snoozed',
  EventType.taskUnsnoozed: 'task.unsnoozed',
  EventType.taskWoke: 'task.woke',
  EventType.commentAdded: 'comment.added',
  EventType.commentReacted: 'comment.reacted',
  EventType.commentUnreacted: 'comment.unreacted',
  EventType.artifactAdded: 'artifact.added',
  EventType.dependencyAdded: 'dependency.added',
  EventType.tagAdded: 'tag.added',
  EventType.projectCreated: 'project.created',
  EventType.projectUpdated: 'project.updated',
  EventType.workflowUpdated: 'workflow.updated',
  EventType.fieldUpdated: 'field.updated',
  EventType.webhookDelivered: 'webhook.delivered',
  EventType.importCompleted: 'import.completed',
  EventType.webhookPing: 'webhook.ping',
  EventType.viewArranged: 'view.arranged',
  EventType.filterSaved: 'filter.saved',
  EventType.filterUpdated: 'filter.updated',
  EventType.filterDeleted: 'filter.deleted',
  EventType.inboxUpdated: 'inbox.updated',
  EventType.templateUpdated: 'template.updated',
};

_EventPage _$EventPageFromJson(Map<String, dynamic> json) => _EventPage(
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Event>[],
  nextSeq: (json['next_seq'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$EventPageToJson(_EventPage instance) =>
    <String, dynamic>{
      'events': instance.events.map((e) => e.toJson()).toList(),
      'next_seq': instance.nextSeq,
    };

_ExportInput _$ExportInputFromJson(Map<String, dynamic> json) => _ExportInput(
  includeArtifacts: json['include_artifacts'] as bool?,
  includeComments: json['include_comments'] as bool?,
  projectRefs: (json['project_refs'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ExportInputToJson(_ExportInput instance) =>
    <String, dynamic>{
      'include_artifacts': ?instance.includeArtifacts,
      'include_comments': ?instance.includeComments,
      'project_refs': ?instance.projectRefs,
    };

_FieldDef _$FieldDefFromJson(Map<String, dynamic> json) => _FieldDef(
  defaultValue: json['default'],
  enumOptions:
      (json['enum_options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  id: json['id'] as String? ?? '',
  key: json['key'] as String? ?? '',
  label: json['label'] as String? ?? '',
  position: (json['position'] as num?)?.toInt() ?? 0,
  projectId: json['project_id'] as String? ?? '',
  required: json['required'] as bool? ?? false,
  tenantId: json['tenant_id'] as String? ?? '',
  type: $enumDecodeNullable(
    _$FieldTypeEnumMap,
    json['type'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
);

Map<String, dynamic> _$FieldDefToJson(_FieldDef instance) => <String, dynamic>{
  'default': ?instance.defaultValue,
  'enum_options': instance.enumOptions,
  'id': instance.id,
  'key': instance.key,
  'label': instance.label,
  'position': instance.position,
  'project_id': instance.projectId,
  'required': instance.required,
  'tenant_id': instance.tenantId,
  'type': ?_$FieldTypeEnumMap[instance.type],
};

const _$FieldTypeEnumMap = {
  FieldType.string: 'string',
  FieldType.text: 'text',
  FieldType.int: 'int',
  FieldType.float: 'float',
  FieldType.bool: 'bool',
  FieldType.date: 'date',
  FieldType.datetime: 'datetime',
  FieldType.enumValue: 'enum',
  FieldType.actor: 'actor',
  FieldType.json: 'json',
};

_FieldDefInput _$FieldDefInputFromJson(Map<String, dynamic> json) =>
    _FieldDefInput(
      defaultValue: json['default'],
      enumOptions: (json['enum_options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      key: json['key'] as String?,
      label: json['label'] as String?,
      position: (json['position'] as num?)?.toInt(),
      required: json['required'] as bool?,
      type: $enumDecodeNullable(
        _$FieldTypeEnumMap,
        json['type'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$FieldDefInputToJson(_FieldDefInput instance) =>
    <String, dynamic>{
      'default': ?instance.defaultValue,
      'enum_options': ?instance.enumOptions,
      'key': ?instance.key,
      'label': ?instance.label,
      'position': ?instance.position,
      'required': ?instance.required,
      'type': ?_$FieldTypeEnumMap[instance.type],
    };

_ForceReclaimInput _$ForceReclaimInputFromJson(Map<String, dynamic> json) =>
    _ForceReclaimInput(reason: json['reason'] as String?);

Map<String, dynamic> _$ForceReclaimInputToJson(_ForceReclaimInput instance) =>
    <String, dynamic>{'reason': ?instance.reason};

_GlobalAdminInput _$GlobalAdminInputFromJson(Map<String, dynamic> json) =>
    _GlobalAdminInput(email: json['email'] as String?);

Map<String, dynamic> _$GlobalAdminInputToJson(_GlobalAdminInput instance) =>
    <String, dynamic>{'email': ?instance.email};

_GroupOrderInput _$GroupOrderInputFromJson(Map<String, dynamic> json) =>
    _GroupOrderInput(
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GroupOrderInputToJson(_GroupOrderInput instance) =>
    <String, dynamic>{'groups': ?instance.groups};

_GroupPref _$GroupPrefFromJson(Map<String, dynamic> json) => _GroupPref(
  collapsed: json['collapsed'] as bool? ?? false,
  group: json['group'] as String? ?? '',
  hidden: json['hidden'] as bool? ?? false,
  position: (json['position'] as num?)?.toInt() ?? 0,
  starred: json['starred'] as bool? ?? false,
  view: json['view'] as String? ?? '',
);

Map<String, dynamic> _$GroupPrefToJson(_GroupPref instance) =>
    <String, dynamic>{
      'collapsed': instance.collapsed,
      'group': instance.group,
      'hidden': instance.hidden,
      'position': instance.position,
      'starred': instance.starred,
      'view': instance.view,
    };

_GroupPrefInput _$GroupPrefInputFromJson(Map<String, dynamic> json) =>
    _GroupPrefInput(
      collapsed: json['collapsed'] as bool?,
      hidden: json['hidden'] as bool?,
      starred: json['starred'] as bool?,
    );

Map<String, dynamic> _$GroupPrefInputToJson(_GroupPrefInput instance) =>
    <String, dynamic>{
      'collapsed': ?instance.collapsed,
      'hidden': ?instance.hidden,
      'starred': ?instance.starred,
    };

_HealthBody _$HealthBodyFromJson(Map<String, dynamic> json) => _HealthBody(
  status: json['status'] as String? ?? '',
  version: json['version'] as String? ?? '',
);

Map<String, dynamic> _$HealthBodyToJson(_HealthBody instance) =>
    <String, dynamic>{'status': instance.status, 'version': instance.version};

_HousekeepingCounts _$HousekeepingCountsFromJson(Map<String, dynamic> json) =>
    _HousekeepingCounts(
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
      done: (json['done'] as num?)?.toInt() ?? 0,
      trash: (json['trash'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$HousekeepingCountsToJson(_HousekeepingCounts instance) =>
    <String, dynamic>{
      'cancelled': instance.cancelled,
      'done': instance.done,
      'trash': instance.trash,
    };

_HousekeepingInput _$HousekeepingInputFromJson(Map<String, dynamic> json) =>
    _HousekeepingInput(
      cancelled: json['cancelled'] as String?,
      done: json['done'] as String?,
      project: json['project'] as String?,
      trash: json['trash'] as String?,
    );

Map<String, dynamic> _$HousekeepingInputToJson(_HousekeepingInput instance) =>
    <String, dynamic>{
      'cancelled': ?instance.cancelled,
      'done': ?instance.done,
      'project': ?instance.project,
      'trash': ?instance.trash,
    };

_HousekeepingPolicy _$HousekeepingPolicyFromJson(Map<String, dynamic> json) =>
    _HousekeepingPolicy(
      cancelled: (json['cancelled'] as num?)?.toInt(),
      done: (json['done'] as num?)?.toInt(),
      projectId: json['project_id'] as String? ?? '',
      trash: (json['trash'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HousekeepingPolicyToJson(_HousekeepingPolicy instance) =>
    <String, dynamic>{
      'cancelled': ?instance.cancelled,
      'done': ?instance.done,
      'project_id': instance.projectId,
      'trash': ?instance.trash,
    };

_HousekeepingResult _$HousekeepingResultFromJson(Map<String, dynamic> json) =>
    _HousekeepingResult(
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
      done: (json['done'] as num?)?.toInt() ?? 0,
      dryRun: json['dry_run'] as bool? ?? false,
      paused: json['paused'] as bool? ?? false,
      trash: (json['trash'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$HousekeepingResultToJson(_HousekeepingResult instance) =>
    <String, dynamic>{
      'cancelled': instance.cancelled,
      'done': instance.done,
      'dry_run': instance.dryRun,
      'paused': instance.paused,
      'trash': instance.trash,
    };

_HousekeepingRunInput _$HousekeepingRunInputFromJson(
  Map<String, dynamic> json,
) => _HousekeepingRunInput(
  dryRun: json['dry_run'] as bool?,
  limit: (json['limit'] as num?)?.toInt(),
  project: json['project'] as String?,
);

Map<String, dynamic> _$HousekeepingRunInputToJson(
  _HousekeepingRunInput instance,
) => <String, dynamic>{
  'dry_run': ?instance.dryRun,
  'limit': ?instance.limit,
  'project': ?instance.project,
};

_HousekeepingView _$HousekeepingViewFromJson(
  Map<String, dynamic> json,
) => _HousekeepingView(
  effective: json['effective'] == null
      ? null
      : HousekeepingPolicy.fromJson(json['effective'] as Map<String, dynamic>),
  overrideValue: json['override'] == null
      ? null
      : HousekeepingPolicy.fromJson(json['override'] as Map<String, dynamic>),
  paused: json['paused'] as bool? ?? false,
  pending: json['pending'] == null
      ? null
      : HousekeepingCounts.fromJson(json['pending'] as Map<String, dynamic>),
  project: json['project'] as String? ?? '',
  tenant: json['tenant'] == null
      ? null
      : HousekeepingPolicy.fromJson(json['tenant'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HousekeepingViewToJson(_HousekeepingView instance) =>
    <String, dynamic>{
      'effective': ?instance.effective?.toJson(),
      'override': ?instance.overrideValue?.toJson(),
      'paused': instance.paused,
      'pending': ?instance.pending?.toJson(),
      'project': instance.project,
      'tenant': ?instance.tenant?.toJson(),
    };

_ImportResult _$ImportResultFromJson(Map<String, dynamic> json) =>
    _ImportResult(
      created:
          (json['created'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      deleted:
          (json['deleted'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      dryRun: json['dry_run'] as bool? ?? false,
      skipped:
          (json['skipped'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      updated:
          (json['updated'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$ImportResultToJson(_ImportResult instance) =>
    <String, dynamic>{
      'created': instance.created,
      'deleted': instance.deleted,
      'dry_run': instance.dryRun,
      'skipped': instance.skipped,
      'updated': instance.updated,
      'warnings': instance.warnings,
    };

_InboxChannel _$InboxChannelFromJson(Map<String, dynamic> json) =>
    _InboxChannel(
      active: json['active'] as bool? ?? false,
      actorId: json['actor_id'] as String? ?? '',
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      format: $enumDecodeNullable(
        _$ChannelFormatEnumMap,
        json['format'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      id: json['id'] as String? ?? '',
      kinds:
          (json['kinds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$InboxChannelToJson(_InboxChannel instance) =>
    <String, dynamic>{
      'active': instance.active,
      'actor_id': instance.actorId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'format': ?_$ChannelFormatEnumMap[instance.format],
      'id': instance.id,
      'kinds': instance.kinds,
      'name': instance.name,
      'url': instance.url,
    };

const _$ChannelFormatEnumMap = {
  ChannelFormat.generic: 'generic',
  ChannelFormat.slack: 'slack',
  ChannelFormat.discord: 'discord',
  ChannelFormat.ntfy: 'ntfy',
};

_InboxChannelInput _$InboxChannelInputFromJson(Map<String, dynamic> json) =>
    _InboxChannelInput(
      active: json['active'] as bool?,
      format: json['format'] as String?,
      kinds: (json['kinds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      name: json['name'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$InboxChannelInputToJson(_InboxChannelInput instance) =>
    <String, dynamic>{
      'active': ?instance.active,
      'format': ?instance.format,
      'kinds': ?instance.kinds,
      'name': ?instance.name,
      'url': ?instance.url,
    };

_InboxChannelUpdate _$InboxChannelUpdateFromJson(Map<String, dynamic> json) =>
    _InboxChannelUpdate(
      active: json['active'] as bool?,
      format: json['format'] as String?,
      kinds: (json['kinds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      name: json['name'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$InboxChannelUpdateToJson(_InboxChannelUpdate instance) =>
    <String, dynamic>{
      'active': ?instance.active,
      'format': ?instance.format,
      'kinds': ?instance.kinds,
      'name': ?instance.name,
      'url': ?instance.url,
    };

_InboxCount _$InboxCountFromJson(Map<String, dynamic> json) =>
    _InboxCount(unread: (json['unread'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$InboxCountToJson(_InboxCount instance) =>
    <String, dynamic>{'unread': instance.unread};

_InboxItem _$InboxItemFromJson(Map<String, dynamic> json) => _InboxItem(
  actorHandle: json['actor_handle'] as String? ?? '',
  actorId: json['actor_id'] as String? ?? '',
  commentId: json['comment_id'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  excerpt: json['excerpt'] as String? ?? '',
  fromStatus: json['from_status'] as String? ?? '',
  id: json['id'] as String? ?? '',
  kind: $enumDecodeNullable(
    _$InboxKindEnumMap,
    json['kind'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  readAt: _$JsonConverterFromJson<String, DateTime>(
    json['read_at'],
    const TixDateTime().fromJson,
  ),
  recipientId: json['recipient_id'] as String? ?? '',
  taskGone: json['task_gone'] as bool? ?? false,
  taskId: json['task_id'] as String? ?? '',
  taskRef: json['task_ref'] as String? ?? '',
  taskTitle: json['task_title'] as String? ?? '',
  toStatus: json['to_status'] as String? ?? '',
);

Map<String, dynamic> _$InboxItemToJson(_InboxItem instance) =>
    <String, dynamic>{
      'actor_handle': instance.actorHandle,
      'actor_id': instance.actorId,
      'comment_id': instance.commentId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'excerpt': instance.excerpt,
      'from_status': instance.fromStatus,
      'id': instance.id,
      'kind': ?_$InboxKindEnumMap[instance.kind],
      'read_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.readAt,
        const TixDateTime().toJson,
      ),
      'recipient_id': instance.recipientId,
      'task_gone': instance.taskGone,
      'task_id': instance.taskId,
      'task_ref': instance.taskRef,
      'task_title': instance.taskTitle,
      'to_status': instance.toStatus,
    };

const _$InboxKindEnumMap = {
  InboxKind.mention: 'mention',
  InboxKind.assigned: 'assigned',
  InboxKind.status: 'status',
  InboxKind.comment: 'comment',
};

_InboxPrefs _$InboxPrefsFromJson(Map<String, dynamic> json) => _InboxPrefs(
  muted:
      (json['muted'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$InboxPrefsToJson(_InboxPrefs instance) =>
    <String, dynamic>{'muted': instance.muted};

_InboxPrefsInput _$InboxPrefsInputFromJson(Map<String, dynamic> json) =>
    _InboxPrefsInput(
      muted: (json['muted'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$InboxPrefsInputToJson(_InboxPrefsInput instance) =>
    <String, dynamic>{'muted': ?instance.muted};

_InboxReadAll _$InboxReadAllFromJson(Map<String, dynamic> json) =>
    _InboxReadAll(marked: (json['marked'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$InboxReadAllToJson(_InboxReadAll instance) =>
    <String, dynamic>{'marked': instance.marked};

_InitialCredential _$InitialCredentialFromJson(Map<String, dynamic> json) =>
    _InitialCredential(
      email: json['email'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );

Map<String, dynamic> _$InitialCredentialToJson(_InitialCredential instance) =>
    <String, dynamic>{
      'email': instance.email,
      'handle': instance.handle,
      'password': instance.password,
    };

_Installation _$InstallationFromJson(Map<String, dynamic> json) =>
    _Installation(
      engine: json['engine'] as String? ?? '',
      observedAt: _$JsonConverterFromJson<String, DateTime>(
        json['observed_at'],
        const TixDateTime().fromJson,
      ),
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 0,
      store: json['store'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );

Map<String, dynamic> _$InstallationToJson(_Installation instance) =>
    <String, dynamic>{
      'engine': instance.engine,
      'observed_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.observedAt,
        const TixDateTime().toJson,
      ),
      'schema_version': instance.schemaVersion,
      'store': instance.store,
      'version': instance.version,
    };

_Invite _$InviteFromJson(Map<String, dynamic> json) => _Invite(
  acceptedAt: _$JsonConverterFromJson<String, DateTime>(
    json['accepted_at'],
    const TixDateTime().fromJson,
  ),
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  email: json['email'] as String? ?? '',
  existingAccount: json['existing_account'] as bool? ?? false,
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expires_at'],
    const TixDateTime().fromJson,
  ),
  grantsMembership: json['grants_membership'] as bool? ?? false,
  id: json['id'] as String? ?? '',
  invitedBy: json['invited_by'] as String? ?? '',
  invitedByHandle: json['invited_by_handle'] as String? ?? '',
  revokedAt: _$JsonConverterFromJson<String, DateTime>(
    json['revoked_at'],
    const TixDateTime().fromJson,
  ),
  role: $enumDecodeNullable(
    _$RoleEnumMap,
    json['role'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  tenantId: json['tenant_id'] as String? ?? '',
  userId: json['user_id'] as String? ?? '',
);

Map<String, dynamic> _$InviteToJson(_Invite instance) => <String, dynamic>{
  'accepted_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.acceptedAt,
    const TixDateTime().toJson,
  ),
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'email': instance.email,
  'existing_account': instance.existingAccount,
  'expires_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.expiresAt,
    const TixDateTime().toJson,
  ),
  'grants_membership': instance.grantsMembership,
  'id': instance.id,
  'invited_by': instance.invitedBy,
  'invited_by_handle': instance.invitedByHandle,
  'revoked_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.revokedAt,
    const TixDateTime().toJson,
  ),
  'role': ?_$RoleEnumMap[instance.role],
  'tenant_id': instance.tenantId,
  'user_id': instance.userId,
};

_InvitePreview _$InvitePreviewFromJson(Map<String, dynamic> json) =>
    _InvitePreview(
      codeRequired: json['code_required'] as bool? ?? false,
      displayName: json['display_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      existingAccount: json['existing_account'] as bool? ?? false,
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expires_at'],
        const TixDateTime().fromJson,
      ),
      tenantName: json['tenant_name'] as String? ?? '',
    );

Map<String, dynamic> _$InvitePreviewToJson(_InvitePreview instance) =>
    <String, dynamic>{
      'code_required': instance.codeRequired,
      'display_name': instance.displayName,
      'email': instance.email,
      'existing_account': instance.existingAccount,
      'expires_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const TixDateTime().toJson,
      ),
      'tenant_name': instance.tenantName,
    };

_IssuedCalendarFeed _$IssuedCalendarFeedFromJson(Map<String, dynamic> json) =>
    _IssuedCalendarFeed(
      actorId: json['actor_id'] as String? ?? '',
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      filter: json['filter'] as String? ?? '',
      id: json['id'] as String? ?? '',
      path: json['path'] as String? ?? '',
      revokedAt: _$JsonConverterFromJson<String, DateTime>(
        json['revoked_at'],
        const TixDateTime().fromJson,
      ),
      tenantId: json['tenant_id'] as String? ?? '',
      token: json['token'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$IssuedCalendarFeedToJson(_IssuedCalendarFeed instance) =>
    <String, dynamic>{
      'actor_id': instance.actorId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'filter': instance.filter,
      'id': instance.id,
      'path': instance.path,
      'revoked_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.revokedAt,
        const TixDateTime().toJson,
      ),
      'tenant_id': instance.tenantId,
      'token': instance.token,
      'url': instance.url,
    };

_IssuedInboxChannel _$IssuedInboxChannelFromJson(Map<String, dynamic> json) =>
    _IssuedInboxChannel(
      active: json['active'] as bool? ?? false,
      actorId: json['actor_id'] as String? ?? '',
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      format: $enumDecodeNullable(
        _$ChannelFormatEnumMap,
        json['format'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      id: json['id'] as String? ?? '',
      kinds:
          (json['kinds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      name: json['name'] as String? ?? '',
      secret: json['secret'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$IssuedInboxChannelToJson(_IssuedInboxChannel instance) =>
    <String, dynamic>{
      'active': instance.active,
      'actor_id': instance.actorId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'format': ?_$ChannelFormatEnumMap[instance.format],
      'id': instance.id,
      'kinds': instance.kinds,
      'name': instance.name,
      'secret': instance.secret,
      'url': instance.url,
    };

_IssuedInvite _$IssuedInviteFromJson(Map<String, dynamic> json) =>
    _IssuedInvite(
      acceptedAt: _$JsonConverterFromJson<String, DateTime>(
        json['accepted_at'],
        const TixDateTime().fromJson,
      ),
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      email: json['email'] as String? ?? '',
      existingAccount: json['existing_account'] as bool? ?? false,
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expires_at'],
        const TixDateTime().fromJson,
      ),
      grantsMembership: json['grants_membership'] as bool? ?? false,
      id: json['id'] as String? ?? '',
      invitedBy: json['invited_by'] as String? ?? '',
      invitedByHandle: json['invited_by_handle'] as String? ?? '',
      path: json['path'] as String? ?? '',
      revokedAt: _$JsonConverterFromJson<String, DateTime>(
        json['revoked_at'],
        const TixDateTime().fromJson,
      ),
      role: $enumDecodeNullable(
        _$RoleEnumMap,
        json['role'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      tenantId: json['tenant_id'] as String? ?? '',
      token: json['token'] as String? ?? '',
      url: json['url'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
    );

Map<String, dynamic> _$IssuedInviteToJson(_IssuedInvite instance) =>
    <String, dynamic>{
      'accepted_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.acceptedAt,
        const TixDateTime().toJson,
      ),
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'email': instance.email,
      'existing_account': instance.existingAccount,
      'expires_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const TixDateTime().toJson,
      ),
      'grants_membership': instance.grantsMembership,
      'id': instance.id,
      'invited_by': instance.invitedBy,
      'invited_by_handle': instance.invitedByHandle,
      'path': instance.path,
      'revoked_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.revokedAt,
        const TixDateTime().toJson,
      ),
      'role': ?_$RoleEnumMap[instance.role],
      'tenant_id': instance.tenantId,
      'token': instance.token,
      'url': instance.url,
      'user_id': instance.userId,
    };

_IssuedToken _$IssuedTokenFromJson(Map<String, dynamic> json) => _IssuedToken(
  actorId: json['actor_id'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expires_at'],
    const TixDateTime().fromJson,
  ),
  id: json['id'] as String? ?? '',
  lastUsedAt: _$JsonConverterFromJson<String, DateTime>(
    json['last_used_at'],
    const TixDateTime().fromJson,
  ),
  name: json['name'] as String? ?? '',
  projectId: json['project_id'] as String? ?? '',
  revokedAt: _$JsonConverterFromJson<String, DateTime>(
    json['revoked_at'],
    const TixDateTime().fromJson,
  ),
  scopes:
      (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tenantId: json['tenant_id'] as String? ?? '',
  token: json['token'] as String? ?? '',
);

Map<String, dynamic> _$IssuedTokenToJson(_IssuedToken instance) =>
    <String, dynamic>{
      'actor_id': instance.actorId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'expires_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const TixDateTime().toJson,
      ),
      'id': instance.id,
      'last_used_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.lastUsedAt,
        const TixDateTime().toJson,
      ),
      'name': instance.name,
      'project_id': instance.projectId,
      'revoked_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.revokedAt,
        const TixDateTime().toJson,
      ),
      'scopes': instance.scopes,
      'tenant_id': instance.tenantId,
      'token': instance.token,
    };

_IssuedWebhook _$IssuedWebhookFromJson(Map<String, dynamic> json) =>
    _IssuedWebhook(
      active: json['active'] as bool? ?? false,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      eventTypes:
          (json['event_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      id: json['id'] as String? ?? '',
      secret: json['secret'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$IssuedWebhookToJson(_IssuedWebhook instance) =>
    <String, dynamic>{
      'active': instance.active,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'event_types': instance.eventTypes,
      'id': instance.id,
      'secret': instance.secret,
      'tenant_id': instance.tenantId,
      'url': instance.url,
    };

_LeaseGrant _$LeaseGrantFromJson(Map<String, dynamic> json) => _LeaseGrant(
  clamped: json['clamped'] as bool? ?? false,
  max: json['max'] as String? ?? '',
  maxSource: $enumDecodeNullable(
    _$LeaseSourceEnumMap,
    json['max_source'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  source: $enumDecodeNullable(
    _$LeaseSourceEnumMap,
    json['source'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  ttl: json['ttl'] as String? ?? '',
);

Map<String, dynamic> _$LeaseGrantToJson(_LeaseGrant instance) =>
    <String, dynamic>{
      'clamped': instance.clamped,
      'max': instance.max,
      'max_source': ?_$LeaseSourceEnumMap[instance.maxSource],
      'source': ?_$LeaseSourceEnumMap[instance.source],
      'ttl': instance.ttl,
    };

const _$LeaseSourceEnumMap = {
  LeaseSource.claim: 'claim',
  LeaseSource.task: 'task',
  LeaseSource.project: 'project',
  LeaseSource.workflow: 'workflow',
  LeaseSource.tenant: 'tenant',
  LeaseSource.deployment: 'deployment',
  LeaseSource.builtin: 'builtin',
};

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      code: json['code'] as String?,
      email: json['email'] as String?,
      newPassword: json['new_password'] as String?,
      password: json['password'] as String?,
      remember: json['remember'] as bool?,
      surface: $enumDecodeNullable(
        _$SurfaceEnumMap,
        json['surface'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      ticket: json['ticket'] as String?,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'code': ?instance.code,
      'email': ?instance.email,
      'new_password': ?instance.newPassword,
      'password': ?instance.password,
      'remember': ?instance.remember,
      'surface': ?_$SurfaceEnumMap[instance.surface],
      'ticket': ?instance.ticket,
    };

_LoginResult _$LoginResultFromJson(Map<String, dynamic> json) => _LoginResult(
  challenge: json['challenge'] == null
      ? null
      : TOTPChallenge.fromJson(json['challenge'] as Map<String, dynamic>),
  recoveryCodes:
      (json['recovery_codes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  secondFactorDue: _$JsonConverterFromJson<String, DateTime>(
    json['second_factor_due'],
    const TixDateTime().fromJson,
  ),
  session: json['session'] == null
      ? null
      : AuthSession.fromJson(json['session'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginResultToJson(_LoginResult instance) =>
    <String, dynamic>{
      'challenge': ?instance.challenge?.toJson(),
      'recovery_codes': instance.recoveryCodes,
      'second_factor_due': ?_$JsonConverterToJson<String, DateTime>(
        instance.secondFactorDue,
        const TixDateTime().toJson,
      ),
      'session': ?instance.session?.toJson(),
    };

_TenantMembership _$TenantMembershipFromJson(Map<String, dynamic> json) =>
    _TenantMembership(
      actorId: json['actor_id'] as String? ?? '',
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      role: $enumDecodeNullable(
        _$RoleEnumMap,
        json['role'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      tenantId: json['tenant_id'] as String? ?? '',
    );

Map<String, dynamic> _$TenantMembershipToJson(_TenantMembership instance) =>
    <String, dynamic>{
      'actor_id': instance.actorId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'role': ?_$RoleEnumMap[instance.role],
      'tenant_id': instance.tenantId,
    };

_MoveTaskInput _$MoveTaskInputFromJson(Map<String, dynamic> json) =>
    _MoveTaskInput(projectRef: json['project_ref'] as String?);

Map<String, dynamic> _$MoveTaskInputToJson(_MoveTaskInput instance) =>
    <String, dynamic>{'project_ref': ?instance.projectRef};

_NumberingLag _$NumberingLagFromJson(Map<String, dynamic> json) =>
    _NumberingLag(
      counter: (json['counter'] as num?)?.toInt() ?? 0,
      highest: (json['highest'] as num?)?.toInt() ?? 0,
      project: json['project'] as String? ?? '',
    );

Map<String, dynamic> _$NumberingLagToJson(_NumberingLag instance) =>
    <String, dynamic>{
      'counter': instance.counter,
      'highest': instance.highest,
      'project': instance.project,
    };

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  archivedAt: _$JsonConverterFromJson<String, DateTime>(
    json['archived_at'],
    const TixDateTime().fromJson,
  ),
  color: json['color'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  description: json['description'] as String? ?? '',
  icon: json['icon'] as String? ?? '',
  iconImage: json['icon_image'] as String? ?? '',
  iconName: json['icon_name'] as String? ?? '',
  id: json['id'] as String? ?? '',
  key: json['key'] as String? ?? '',
  leaseDefault: json['lease_default'] as String? ?? '',
  leaseMax: json['lease_max'] as String? ?? '',
  name: json['name'] as String? ?? '',
  starred: json['starred'] as bool? ?? false,
  tenantId: json['tenant_id'] as String? ?? '',
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updated_at'],
    const TixDateTime().fromJson,
  ),
  workflowId: json['workflow_id'] as String? ?? '',
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'archived_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.archivedAt,
    const TixDateTime().toJson,
  ),
  'color': instance.color,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'description': instance.description,
  'icon': instance.icon,
  'icon_image': instance.iconImage,
  'icon_name': instance.iconName,
  'id': instance.id,
  'key': instance.key,
  'lease_default': instance.leaseDefault,
  'lease_max': instance.leaseMax,
  'name': instance.name,
  'starred': instance.starred,
  'tenant_id': instance.tenantId,
  'updated_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const TixDateTime().toJson,
  ),
  'workflow_id': instance.workflowId,
};

_ProjectDeletion _$ProjectDeletionFromJson(Map<String, dynamic> json) =>
    _ProjectDeletion(
      deleteTasks: json['delete_tasks'] as bool? ?? false,
      deleted: (json['deleted'] as num?)?.toInt() ?? 0,
      dryRun: json['dry_run'] as bool? ?? false,
      moveTo: json['move_to'] as String? ?? '',
      project: json['project'] as String? ?? '',
      statuses:
          (json['statuses'] as List<dynamic>?)
              ?.map((e) => StatusMove.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <StatusMove>[],
      tasks: (json['tasks'] as num?)?.toInt() ?? 0,
      trashed: (json['trashed'] as num?)?.toInt() ?? 0,
      wouldDelete: (json['would_delete'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProjectDeletionToJson(_ProjectDeletion instance) =>
    <String, dynamic>{
      'delete_tasks': instance.deleteTasks,
      'deleted': instance.deleted,
      'dry_run': instance.dryRun,
      'move_to': instance.moveTo,
      'project': instance.project,
      'statuses': instance.statuses.map((e) => e.toJson()).toList(),
      'tasks': instance.tasks,
      'trashed': instance.trashed,
      'would_delete': instance.wouldDelete,
    };

_ProjectIconFile _$ProjectIconFileFromJson(Map<String, dynamic> json) =>
    _ProjectIconFile(
      contentType: json['content_type'] as String?,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$ProjectIconFileToJson(_ProjectIconFile instance) =>
    <String, dynamic>{
      'content_type': ?instance.contentType,
      'data': ?instance.data,
    };

_PruneInput _$PruneInputFromJson(Map<String, dynamic> json) => _PruneInput(
  dryRun: json['dry_run'] as bool?,
  limit: (json['limit'] as num?)?.toInt(),
);

Map<String, dynamic> _$PruneInputToJson(_PruneInput instance) =>
    <String, dynamic>{'dry_run': ?instance.dryRun, 'limit': ?instance.limit};

_PruneResult _$PruneResultFromJson(Map<String, dynamic> json) => _PruneResult(
  auditEntries: (json['audit_entries'] as num?)?.toInt() ?? 0,
  dryRun: json['dry_run'] as bool? ?? false,
  events: (json['events'] as num?)?.toInt() ?? 0,
  idempotencyKeys: (json['idempotency_keys'] as num?)?.toInt() ?? 0,
  retainedForSubscribers:
      (json['retained_for_subscribers'] as num?)?.toInt() ?? 0,
  webhookDeliveries: (json['webhook_deliveries'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PruneResultToJson(_PruneResult instance) =>
    <String, dynamic>{
      'audit_entries': instance.auditEntries,
      'dry_run': instance.dryRun,
      'events': instance.events,
      'idempotency_keys': instance.idempotencyKeys,
      'retained_for_subscribers': instance.retainedForSubscribers,
      'webhook_deliveries': instance.webhookDeliveries,
    };

_Reaction _$ReactionFromJson(Map<String, dynamic> json) => _Reaction(
  actorIds:
      (json['actor_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  count: (json['count'] as num?)?.toInt() ?? 0,
  emoji: json['emoji'] as String? ?? '',
);

Map<String, dynamic> _$ReactionToJson(_Reaction instance) => <String, dynamic>{
  'actor_ids': instance.actorIds,
  'count': instance.count,
  'emoji': instance.emoji,
};

_ReadyBody _$ReadyBodyFromJson(Map<String, dynamic> json) => _ReadyBody(
  checks:
      (json['checks'] as List<dynamic>?)
          ?.map((e) => Check.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Check>[],
  ready: json['ready'] as bool? ?? false,
);

Map<String, dynamic> _$ReadyBodyToJson(_ReadyBody instance) =>
    <String, dynamic>{
      'checks': instance.checks.map((e) => e.toJson()).toList(),
      'ready': instance.ready,
    };

_ReissueInviteInput _$ReissueInviteInputFromJson(Map<String, dynamic> json) =>
    _ReissueInviteInput(expiresIn: json['expires_in'] as String?);

Map<String, dynamic> _$ReissueInviteInputToJson(_ReissueInviteInput instance) =>
    <String, dynamic>{'expires_in': ?instance.expiresIn};

_ReleaseRequest _$ReleaseRequestFromJson(Map<String, dynamic> json) =>
    _ReleaseRequest(
      comment: json['comment'] as String?,
      result: json['result'] as Map<String, dynamic>?,
      status: json['status'] as String?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$ReleaseRequestToJson(_ReleaseRequest instance) =>
    <String, dynamic>{
      'comment': ?instance.comment,
      'result': ?instance.result,
      'status': ?instance.status,
      'token': ?instance.token,
    };

_RenewRequest _$RenewRequestFromJson(Map<String, dynamic> json) =>
    _RenewRequest(token: json['token'] as String?, ttl: json['ttl'] as String?);

Map<String, dynamic> _$RenewRequestToJson(_RenewRequest instance) =>
    <String, dynamic>{'token': ?instance.token, 'ttl': ?instance.ttl};

_RetentionPolicy _$RetentionPolicyFromJson(Map<String, dynamic> json) =>
    _RetentionPolicy(
      auditEntries: json['audit_entries'] as String?,
      events: json['events'] as String?,
      tenantId: json['tenant_id'] as String?,
      webhookDeliveries: json['webhook_deliveries'] as String?,
    );

Map<String, dynamic> _$RetentionPolicyToJson(_RetentionPolicy instance) =>
    <String, dynamic>{
      'audit_entries': ?instance.auditEntries,
      'events': ?instance.events,
      'tenant_id': ?instance.tenantId,
      'webhook_deliveries': ?instance.webhookDeliveries,
    };

_RotateTokenInput _$RotateTokenInputFromJson(Map<String, dynamic> json) =>
    _RotateTokenInput(
      actorId: json['actor_id'] as String?,
      grace: json['grace'] as String?,
    );

Map<String, dynamic> _$RotateTokenInputToJson(_RotateTokenInput instance) =>
    <String, dynamic>{'actor_id': ?instance.actorId, 'grace': ?instance.grace};

_RouteInput _$RouteInputFromJson(Map<String, dynamic> json) => _RouteInput(
  comment: json['comment'] as String?,
  customFields: json['custom_fields'] as Map<String, dynamic>?,
  leaseToken: json['lease_token'] as String?,
  route: (json['route'] as List<dynamic>?)?.map((e) => e as String).toList(),
  to: json['to'] as String?,
  version: (json['version'] as num?)?.toInt(),
);

Map<String, dynamic> _$RouteInputToJson(_RouteInput instance) =>
    <String, dynamic>{
      'comment': ?instance.comment,
      'custom_fields': ?instance.customFields,
      'lease_token': ?instance.leaseToken,
      'route': ?instance.route,
      'to': ?instance.to,
      'version': ?instance.version,
    };

_RouteResult _$RouteResultFromJson(Map<String, dynamic> json) => _RouteResult(
  applied:
      (json['applied'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  from: json['from'] as String? ?? '',
  reason: json['reason'] as String? ?? '',
  route:
      (json['route'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  stopped: json['stopped'] as String? ?? '',
  task: json['task'] == null
      ? null
      : Task.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RouteResultToJson(_RouteResult instance) =>
    <String, dynamic>{
      'applied': instance.applied,
      'from': instance.from,
      'reason': instance.reason,
      'route': instance.route,
      'stopped': instance.stopped,
      'task': ?instance.task?.toJson(),
    };

_RunSyncInput _$RunSyncInputFromJson(Map<String, dynamic> json) =>
    _RunSyncInput(
      dryRun: json['dry_run'] as bool?,
      full: json['full'] as bool?,
      sourceId: json['source_id'] as String?,
    );

Map<String, dynamic> _$RunSyncInputToJson(_RunSyncInput instance) =>
    <String, dynamic>{
      'dry_run': ?instance.dryRun,
      'full': ?instance.full,
      'source_id': ?instance.sourceId,
    };

_SSHChallenge _$SSHChallengeFromJson(Map<String, dynamic> json) =>
    _SSHChallenge(
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expires_at'],
        const TixDateTime().fromJson,
      ),
      namespace: json['namespace'] as String? ?? '',
      nonce: json['nonce'] as String? ?? '',
    );

Map<String, dynamic> _$SSHChallengeToJson(_SSHChallenge instance) =>
    <String, dynamic>{
      'expires_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const TixDateTime().toJson,
      ),
      'namespace': instance.namespace,
      'nonce': instance.nonce,
    };

_SSHKey _$SSHKeyFromJson(Map<String, dynamic> json) => _SSHKey(
  actorId: json['actor_id'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  enrolledIn:
      (json['enrolled_in'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  fingerprint: json['fingerprint'] as String? ?? '',
  id: json['id'] as String? ?? '',
  label: json['label'] as String? ?? '',
  lastUsedAt: _$JsonConverterFromJson<String, DateTime>(
    json['last_used_at'],
    const TixDateTime().fromJson,
  ),
  publicKey: json['public_key'] as String? ?? '',
  revokedAt: _$JsonConverterFromJson<String, DateTime>(
    json['revoked_at'],
    const TixDateTime().fromJson,
  ),
  tenantId: json['tenant_id'] as String? ?? '',
);

Map<String, dynamic> _$SSHKeyToJson(_SSHKey instance) => <String, dynamic>{
  'actor_id': instance.actorId,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'enrolled_in': instance.enrolledIn,
  'fingerprint': instance.fingerprint,
  'id': instance.id,
  'label': instance.label,
  'last_used_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.lastUsedAt,
    const TixDateTime().toJson,
  ),
  'public_key': instance.publicKey,
  'revoked_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.revokedAt,
    const TixDateTime().toJson,
  ),
  'tenant_id': instance.tenantId,
};

_SSHLoginInput _$SSHLoginInputFromJson(Map<String, dynamic> json) =>
    _SSHLoginInput(
      nonce: json['nonce'] as String?,
      publicKey: json['public_key'] as String?,
      signature: json['signature'] as String?,
      tenant: json['tenant'] as String?,
    );

Map<String, dynamic> _$SSHLoginInputToJson(_SSHLoginInput instance) =>
    <String, dynamic>{
      'nonce': ?instance.nonce,
      'public_key': ?instance.publicKey,
      'signature': ?instance.signature,
      'tenant': ?instance.tenant,
    };

_SaveTemplateInput _$SaveTemplateInputFromJson(Map<String, dynamic> json) =>
    _SaveTemplateInput(
      dueIn: json['due_in'] as String?,
      name: json['name'] as String?,
      taskRef: json['task_ref'] as String?,
      tenantWide: json['tenant_wide'] as bool?,
      withSubtasks: json['with_subtasks'] as bool?,
    );

Map<String, dynamic> _$SaveTemplateInputToJson(_SaveTemplateInput instance) =>
    <String, dynamic>{
      'due_in': ?instance.dueIn,
      'name': ?instance.name,
      'task_ref': ?instance.taskRef,
      'tenant_wide': ?instance.tenantWide,
      'with_subtasks': ?instance.withSubtasks,
    };

_SavedFilter _$SavedFilterFromJson(Map<String, dynamic> json) => _SavedFilter(
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  editable: json['editable'] as bool? ?? false,
  id: json['id'] as String? ?? '',
  mine: json['mine'] as bool? ?? false,
  name: json['name'] as String? ?? '',
  ownerId: json['owner_id'] as String? ?? '',
  position: (json['position'] as num?)?.toInt() ?? 0,
  query: json['query'] as String? ?? '',
  shared: json['shared'] as bool? ?? false,
  sort: json['sort'] as String? ?? '',
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updated_at'],
    const TixDateTime().fromJson,
  ),
  view: json['view'] as String? ?? '',
);

Map<String, dynamic> _$SavedFilterToJson(_SavedFilter instance) =>
    <String, dynamic>{
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'editable': instance.editable,
      'id': instance.id,
      'mine': instance.mine,
      'name': instance.name,
      'owner_id': instance.ownerId,
      'position': instance.position,
      'query': instance.query,
      'shared': instance.shared,
      'sort': instance.sort,
      'updated_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const TixDateTime().toJson,
      ),
      'view': instance.view,
    };

_SavedFilterInput _$SavedFilterInputFromJson(Map<String, dynamic> json) =>
    _SavedFilterInput(
      name: json['name'] as String?,
      query: json['query'] as String?,
      shared: json['shared'] as bool?,
      sort: json['sort'] as String?,
      view: json['view'] as String?,
    );

Map<String, dynamic> _$SavedFilterInputToJson(_SavedFilterInput instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'query': ?instance.query,
      'shared': ?instance.shared,
      'sort': ?instance.sort,
      'view': ?instance.view,
    };

_SavedFilterOrderInput _$SavedFilterOrderInputFromJson(
  Map<String, dynamic> json,
) => _SavedFilterOrderInput(
  filters: (json['filters'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SavedFilterOrderInputToJson(
  _SavedFilterOrderInput instance,
) => <String, dynamic>{'filters': ?instance.filters};

_SavedFilterUpdate _$SavedFilterUpdateFromJson(Map<String, dynamic> json) =>
    _SavedFilterUpdate(
      name: json['name'] as String?,
      query: json['query'] as String?,
      shared: json['shared'] as bool?,
      sort: json['sort'] as String?,
      view: json['view'] as String?,
    );

Map<String, dynamic> _$SavedFilterUpdateToJson(_SavedFilterUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'query': ?instance.query,
      'shared': ?instance.shared,
      'sort': ?instance.sort,
      'view': ?instance.view,
    };

_ServerStatus _$ServerStatusFromJson(Map<String, dynamic> json) =>
    _ServerStatus(
      address: json['address'] as String? ?? '',
      attached: json['attached'] as bool? ?? false,
      connections: (json['connections'] as num?)?.toInt(),
      heartbeatInterval: json['heartbeat_interval'] as String? ?? '',
      id: json['id'] as String? ?? '',
      lastSeenAt: _$JsonConverterFromJson<String, DateTime>(
        json['last_seen_at'],
        const TixDateTime().fromJson,
      ),
      startedAt: _$JsonConverterFromJson<String, DateTime>(
        json['started_at'],
        const TixDateTime().fromJson,
      ),
      surfaces:
          (json['surfaces'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      uptime: json['uptime'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );

Map<String, dynamic> _$ServerStatusToJson(_ServerStatus instance) =>
    <String, dynamic>{
      'address': instance.address,
      'attached': instance.attached,
      'connections': ?instance.connections,
      'heartbeat_interval': instance.heartbeatInterval,
      'id': instance.id,
      'last_seen_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.lastSeenAt,
        const TixDateTime().toJson,
      ),
      'started_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.startedAt,
        const TixDateTime().toJson,
      ),
      'surfaces': instance.surfaces,
      'uptime': instance.uptime,
      'version': instance.version,
    };

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  actorId: json['actor_id'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expires_at'],
    const TixDateTime().fromJson,
  ),
  remembered: json['remembered'] as bool? ?? false,
  tenantId: json['tenant_id'] as String? ?? '',
  token: json['token'] as String? ?? '',
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'actor_id': instance.actorId,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'expires_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const TixDateTime().toJson,
      ),
      'remembered': instance.remembered,
      'tenant_id': instance.tenantId,
      'token': instance.token,
    };

_SessionInfo _$SessionInfoFromJson(Map<String, dynamic> json) => _SessionInfo(
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  current: json['current'] as bool? ?? false,
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expires_at'],
    const TixDateTime().fromJson,
  ),
  id: json['id'] as String? ?? '',
  method: json['method'] as String? ?? '',
  remembered: json['remembered'] as bool? ?? false,
  secondFactor: json['second_factor'] as bool? ?? false,
  userAgent: json['user_agent'] as String? ?? '',
);

Map<String, dynamic> _$SessionInfoToJson(_SessionInfo instance) =>
    <String, dynamic>{
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'current': instance.current,
      'expires_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const TixDateTime().toJson,
      ),
      'id': instance.id,
      'method': instance.method,
      'remembered': instance.remembered,
      'second_factor': instance.secondFactor,
      'user_agent': instance.userAgent,
    };

_SessionPolicy _$SessionPolicyFromJson(Map<String, dynamic> json) =>
    _SessionPolicy(
      idleTimeout: json['idle_timeout'] as String? ?? '',
      rememberTtl: json['remember_ttl'] as String? ?? '',
      serverIdleTimeout: json['server_idle_timeout'] as String? ?? '',
      serverRememberTtl: json['server_remember_ttl'] as String? ?? '',
      serverTtl: json['server_ttl'] as String? ?? '',
      ttl: json['ttl'] as String? ?? '',
    );

Map<String, dynamic> _$SessionPolicyToJson(_SessionPolicy instance) =>
    <String, dynamic>{
      'idle_timeout': instance.idleTimeout,
      'remember_ttl': instance.rememberTtl,
      'server_idle_timeout': instance.serverIdleTimeout,
      'server_remember_ttl': instance.serverRememberTtl,
      'server_ttl': instance.serverTtl,
      'ttl': instance.ttl,
    };

_SnoozeInput _$SnoozeInputFromJson(Map<String, dynamic> json) => _SnoozeInput(
  until: _$JsonConverterFromJson<String, DateTime>(
    json['until'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$SnoozeInputToJson(_SnoozeInput instance) =>
    <String, dynamic>{
      'until': ?_$JsonConverterToJson<String, DateTime>(
        instance.until,
        const TixDateTime().toJson,
      ),
    };

_State _$StateFromJson(Map<String, dynamic> json) => _State(
  category: $enumDecodeNullable(
    _$StateCategoryEnumMap,
    json['category'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  key: json['key'] as String?,
  label: json['label'] as String?,
  revertOnLeaseExpiry: json['revert_on_lease_expiry'] as bool?,
  revertTo: json['revert_to'] as String?,
  terminal: json['terminal'] as bool?,
);

Map<String, dynamic> _$StateToJson(_State instance) => <String, dynamic>{
  'category': ?_$StateCategoryEnumMap[instance.category],
  'key': ?instance.key,
  'label': ?instance.label,
  'revert_on_lease_expiry': ?instance.revertOnLeaseExpiry,
  'revert_to': ?instance.revertTo,
  'terminal': ?instance.terminal,
};

const _$StateCategoryEnumMap = {
  StateCategory.todo: 'todo',
  StateCategory.inProgress: 'in_progress',
  StateCategory.blocked: 'blocked',
  StateCategory.waiting: 'waiting',
  StateCategory.done: 'done',
  StateCategory.cancelled: 'cancelled',
};

_Stats _$StatsFromJson(Map<String, dynamic> json) => _Stats(
  byCategory:
      (json['by_category'] as List<dynamic>?)
          ?.map((e) => StatsCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatsCategory>[],
  completed: (json['completed'] as num?)?.toInt() ?? 0,
  created: (json['created'] as num?)?.toInt() ?? 0,
  leaderboardMeasure: json['leaderboard_measure'] as String? ?? '',
  medianLeadTime: json['median_lead_time'] as String? ?? '',
  oldest:
      (json['oldest'] as List<dynamic>?)
          ?.map((e) => StatsAgeing.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatsAgeing>[],
  perDay:
      (json['per_day'] as List<dynamic>?)
          ?.map((e) => StatsDay.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatsDay>[],
  projectId: json['project_id'] as String? ?? '',
  projectKey: json['project_key'] as String? ?? '',
  since: _$JsonConverterFromJson<String, DateTime>(
    json['since'],
    const TixDateTime().fromJson,
  ),
  slowestLeadTime: json['slowest_lead_time'] as String? ?? '',
  topActors:
      (json['top_actors'] as List<dynamic>?)
          ?.map((e) => StatsActor.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatsActor>[],
  until: _$JsonConverterFromJson<String, DateTime>(
    json['until'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$StatsToJson(_Stats instance) => <String, dynamic>{
  'by_category': instance.byCategory.map((e) => e.toJson()).toList(),
  'completed': instance.completed,
  'created': instance.created,
  'leaderboard_measure': instance.leaderboardMeasure,
  'median_lead_time': instance.medianLeadTime,
  'oldest': instance.oldest.map((e) => e.toJson()).toList(),
  'per_day': instance.perDay.map((e) => e.toJson()).toList(),
  'project_id': instance.projectId,
  'project_key': instance.projectKey,
  'since': ?_$JsonConverterToJson<String, DateTime>(
    instance.since,
    const TixDateTime().toJson,
  ),
  'slowest_lead_time': instance.slowestLeadTime,
  'top_actors': instance.topActors.map((e) => e.toJson()).toList(),
  'until': ?_$JsonConverterToJson<String, DateTime>(
    instance.until,
    const TixDateTime().toJson,
  ),
};

_StatsActor _$StatsActorFromJson(Map<String, dynamic> json) => _StatsActor(
  actorId: json['actor_id'] as String? ?? '',
  handle: json['handle'] as String? ?? '',
  moved: (json['moved'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StatsActorToJson(_StatsActor instance) =>
    <String, dynamic>{
      'actor_id': instance.actorId,
      'handle': instance.handle,
      'moved': instance.moved,
    };

_StatsAgeing _$StatsAgeingFromJson(Map<String, dynamic> json) => _StatsAgeing(
  age: json['age'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  ref: json['ref'] as String? ?? '',
  status: json['status'] as String? ?? '',
  title: json['title'] as String? ?? '',
);

Map<String, dynamic> _$StatsAgeingToJson(_StatsAgeing instance) =>
    <String, dynamic>{
      'age': instance.age,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'ref': instance.ref,
      'status': instance.status,
      'title': instance.title,
    };

_StatsCategory _$StatsCategoryFromJson(Map<String, dynamic> json) =>
    _StatsCategory(
      category: $enumDecodeNullable(
        _$StateCategoryEnumMap,
        json['category'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StatsCategoryToJson(_StatsCategory instance) =>
    <String, dynamic>{
      'category': ?_$StateCategoryEnumMap[instance.category],
      'count': instance.count,
    };

_StatsDay _$StatsDayFromJson(Map<String, dynamic> json) => _StatsDay(
  completed: (json['completed'] as num?)?.toInt() ?? 0,
  date: json['date'] as String? ?? '',
);

Map<String, dynamic> _$StatsDayToJson(_StatsDay instance) => <String, dynamic>{
  'completed': instance.completed,
  'date': instance.date,
};

_StatusMove _$StatusMoveFromJson(Map<String, dynamic> json) => _StatusMove(
  from: json['from'] as String? ?? '',
  tasks: (json['tasks'] as num?)?.toInt() ?? 0,
  to: json['to'] as String? ?? '',
);

Map<String, dynamic> _$StatusMoveToJson(_StatusMove instance) =>
    <String, dynamic>{
      'from': instance.from,
      'tasks': instance.tasks,
      'to': instance.to,
    };

_StatusReport _$StatusReportFromJson(Map<String, dynamic> json) =>
    _StatusReport(
      answeringServer: json['answering_server'] as String? ?? '',
      installation: json['installation'] == null
          ? null
          : Installation.fromJson(json['installation'] as Map<String, dynamic>),
      secondFactor: json['second_factor'] == null
          ? null
          : TOTPReport.fromJson(json['second_factor'] as Map<String, dynamic>),
      servers:
          (json['servers'] as List<dynamic>?)
              ?.map((e) => ServerStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ServerStatus>[],
      work: json['work'] == null
          ? null
          : Work.fromJson(json['work'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StatusReportToJson(_StatusReport instance) =>
    <String, dynamic>{
      'answering_server': instance.answeringServer,
      'installation': ?instance.installation?.toJson(),
      'second_factor': ?instance.secondFactor?.toJson(),
      'servers': instance.servers.map((e) => e.toJson()).toList(),
      'work': ?instance.work?.toJson(),
    };

_SweepRequest _$SweepRequestFromJson(Map<String, dynamic> json) =>
    _SweepRequest(limit: (json['limit'] as num?)?.toInt());

Map<String, dynamic> _$SweepRequestToJson(_SweepRequest instance) =>
    <String, dynamic>{'limit': ?instance.limit};

_SweepResult _$SweepResultFromJson(Map<String, dynamic> json) =>
    _SweepResult(swept: (json['swept'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$SweepResultToJson(_SweepResult instance) =>
    <String, dynamic>{'swept': instance.swept};

_SwitchTenantInput _$SwitchTenantInputFromJson(Map<String, dynamic> json) =>
    _SwitchTenantInput(
      code: json['code'] as String?,
      surface: $enumDecodeNullable(
        _$SurfaceEnumMap,
        json['surface'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      tenant: json['tenant'] as String?,
    );

Map<String, dynamic> _$SwitchTenantInputToJson(_SwitchTenantInput instance) =>
    <String, dynamic>{
      'code': ?instance.code,
      'surface': ?_$SurfaceEnumMap[instance.surface],
      'tenant': ?instance.tenant,
    };

_SyncCredentialHint _$SyncCredentialHintFromJson(Map<String, dynamic> json) =>
    _SyncCredentialHint(
      hint: json['hint'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$SyncCredentialHintToJson(_SyncCredentialHint instance) =>
    <String, dynamic>{'hint': instance.hint, 'name': instance.name};

_SyncMappingSummary _$SyncMappingSummaryFromJson(
  Map<String, dynamic> json,
) => _SyncMappingSummary(
  fields:
      (json['fields'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  identity: json['identity'] as String? ?? '',
  project: json['project'] as String? ?? '',
  statuses:
      (json['statuses'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$SyncMappingSummaryToJson(_SyncMappingSummary instance) =>
    <String, dynamic>{
      'fields': instance.fields,
      'identity': instance.identity,
      'project': instance.project,
      'statuses': instance.statuses,
    };

_SyncOrigin _$SyncOriginFromJson(Map<String, dynamic> json) => _SyncOrigin(
  detail: json['detail'] as String? ?? '',
  from: json['from'] as String? ?? '',
);

Map<String, dynamic> _$SyncOriginToJson(_SyncOrigin instance) =>
    <String, dynamic>{'detail': instance.detail, 'from': instance.from};

_SyncResolution _$SyncResolutionFromJson(
  Map<String, dynamic> json,
) => _SyncResolution(
  credentials: json['credentials'] == null
      ? null
      : SyncOrigin.fromJson(json['credentials'] as Map<String, dynamic>),
  mapping: json['mapping'] == null
      ? null
      : SyncOrigin.fromJson(json['mapping'] as Map<String, dynamic>),
  missing:
      (json['missing'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  settings:
      (json['settings'] as List<dynamic>?)
          ?.map((e) => SyncSettingOrigin.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SyncSettingOrigin>[],
  summary: json['summary'] == null
      ? null
      : SyncMappingSummary.fromJson(json['summary'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SyncResolutionToJson(_SyncResolution instance) =>
    <String, dynamic>{
      'credentials': ?instance.credentials?.toJson(),
      'mapping': ?instance.mapping?.toJson(),
      'missing': instance.missing,
      'settings': instance.settings.map((e) => e.toJson()).toList(),
      'summary': ?instance.summary?.toJson(),
    };

_SyncResult _$SyncResultFromJson(Map<String, dynamic> json) => _SyncResult(
  created:
      (json['created'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  cursor: json['cursor'] as String? ?? '',
  deleted:
      (json['deleted'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  dryRun: json['dry_run'] as bool? ?? false,
  skipped:
      (json['skipped'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  source: json['source'] as String? ?? '',
  system: json['system'] as String? ?? '',
  unmatchedUsers:
      (json['unmatched_users'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  updated:
      (json['updated'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  warnings:
      (json['warnings'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$SyncResultToJson(_SyncResult instance) =>
    <String, dynamic>{
      'created': instance.created,
      'cursor': instance.cursor,
      'deleted': instance.deleted,
      'dry_run': instance.dryRun,
      'skipped': instance.skipped,
      'source': instance.source,
      'system': instance.system,
      'unmatched_users': instance.unmatchedUsers,
      'updated': instance.updated,
      'warnings': instance.warnings,
    };

_SyncSettingOrigin _$SyncSettingOriginFromJson(Map<String, dynamic> json) =>
    _SyncSettingOrigin(
      from: json['from'] as String? ?? '',
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      variable: json['variable'] as String? ?? '',
    );

Map<String, dynamic> _$SyncSettingOriginToJson(_SyncSettingOrigin instance) =>
    <String, dynamic>{
      'from': instance.from,
      'key': instance.key,
      'value': instance.value,
      'variable': instance.variable,
    };

_SyncSource _$SyncSourceFromJson(Map<String, dynamic> json) => _SyncSource(
  config:
      (json['config'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  credentials:
      (json['credentials'] as List<dynamic>?)
          ?.map((e) => SyncCredentialHint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SyncCredentialHint>[],
  cursor: json['cursor'] as String? ?? '',
  id: json['id'] as String? ?? '',
  lastRunAt: _$JsonConverterFromJson<String, DateTime>(
    json['last_run_at'],
    const TixDateTime().fromJson,
  ),
  lastStatus: json['last_status'] as String? ?? '',
  mapping: json['mapping'] as String? ?? '',
  mappingPath: json['mapping_path'] as String? ?? '',
  name: json['name'] as String? ?? '',
  resolved: json['resolved'] == null
      ? null
      : SyncResolution.fromJson(json['resolved'] as Map<String, dynamic>),
  system: json['system'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
);

Map<String, dynamic> _$SyncSourceToJson(_SyncSource instance) =>
    <String, dynamic>{
      'config': instance.config,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'credentials': instance.credentials.map((e) => e.toJson()).toList(),
      'cursor': instance.cursor,
      'id': instance.id,
      'last_run_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.lastRunAt,
        const TixDateTime().toJson,
      ),
      'last_status': instance.lastStatus,
      'mapping': instance.mapping,
      'mapping_path': instance.mappingPath,
      'name': instance.name,
      'resolved': ?instance.resolved?.toJson(),
      'system': instance.system,
      'tenant_id': instance.tenantId,
    };

_SyncSourceInput _$SyncSourceInputFromJson(Map<String, dynamic> json) =>
    _SyncSourceInput(
      check: json['check'] as bool?,
      clearCredentials: json['clear_credentials'] as bool?,
      clearMapping: json['clear_mapping'] as bool?,
      config: json['config'] as Map<String, dynamic>?,
      id: json['id'] as String?,
      keepSettings: json['keep_settings'] as bool?,
      mapping: json['mapping'] as String?,
      mappingPath: json['mapping_path'] as String?,
      name: json['name'] as String?,
      password: json['password'] as String?,
      system: json['system'] as String?,
      token: json['token'] as String?,
      user: json['user'] as String?,
    );

Map<String, dynamic> _$SyncSourceInputToJson(_SyncSourceInput instance) =>
    <String, dynamic>{
      'check': ?instance.check,
      'clear_credentials': ?instance.clearCredentials,
      'clear_mapping': ?instance.clearMapping,
      'config': ?instance.config,
      'id': ?instance.id,
      'keep_settings': ?instance.keepSettings,
      'mapping': ?instance.mapping,
      'mapping_path': ?instance.mappingPath,
      'name': ?instance.name,
      'password': ?instance.password,
      'system': ?instance.system,
      'token': ?instance.token,
      'user': ?instance.user,
    };

_TOTPChallenge _$TOTPChallengeFromJson(Map<String, dynamic> json) =>
    _TOTPChallenge(
      enrolment: json['enrolment'] == null
          ? null
          : TOTPEnrolment.fromJson(json['enrolment'] as Map<String, dynamic>),
      kind: $enumDecodeNullable(
        _$TOTPChallengeKindEnumMap,
        json['kind'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      ticket: json['ticket'] as String? ?? '',
    );

Map<String, dynamic> _$TOTPChallengeToJson(_TOTPChallenge instance) =>
    <String, dynamic>{
      'enrolment': ?instance.enrolment?.toJson(),
      'kind': ?_$TOTPChallengeKindEnumMap[instance.kind],
      'ticket': instance.ticket,
    };

const _$TOTPChallengeKindEnumMap = {
  TOTPChallengeKind.code: 'code',
  TOTPChallengeKind.enrol: 'enrol',
  TOTPChallengeKind.passwordChange: 'password_change',
};

_TOTPCodeRequest _$TOTPCodeRequestFromJson(Map<String, dynamic> json) =>
    _TOTPCodeRequest(code: json['code'] as String?);

Map<String, dynamic> _$TOTPCodeRequestToJson(_TOTPCodeRequest instance) =>
    <String, dynamic>{'code': ?instance.code};

_TOTPEnrolment _$TOTPEnrolmentFromJson(Map<String, dynamic> json) =>
    _TOTPEnrolment(
      account: json['account'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      secret: json['secret'] as String? ?? '',
      uri: json['uri'] as String? ?? '',
    );

Map<String, dynamic> _$TOTPEnrolmentToJson(_TOTPEnrolment instance) =>
    <String, dynamic>{
      'account': instance.account,
      'issuer': instance.issuer,
      'secret': instance.secret,
      'uri': instance.uri,
    };

_TOTPRecoveryCodes _$TOTPRecoveryCodesFromJson(Map<String, dynamic> json) =>
    _TOTPRecoveryCodes(
      codes:
          (json['codes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    );

Map<String, dynamic> _$TOTPRecoveryCodesToJson(_TOTPRecoveryCodes instance) =>
    <String, dynamic>{'codes': instance.codes};

_TOTPReport _$TOTPReportFromJson(Map<String, dynamic> json) => _TOTPReport(
  admins: (json['admins'] as num?)?.toInt() ?? 0,
  enrolledAdmins: (json['enrolled_admins'] as num?)?.toInt() ?? 0,
  enrolments: (json['enrolments'] as num?)?.toInt() ?? 0,
  keyConfigured: json['key_configured'] as bool? ?? false,
  policy: json['policy'] as String? ?? '',
  requireCli: json['require_cli'] as bool? ?? false,
  requireSsh: json['require_ssh'] as bool? ?? false,
  requireWeb: json['require_web'] as bool? ?? false,
  tenantKey: json['tenant_key'] as String? ?? '',
  unrecoverable: json['unrecoverable'] as bool? ?? false,
);

Map<String, dynamic> _$TOTPReportToJson(_TOTPReport instance) =>
    <String, dynamic>{
      'admins': instance.admins,
      'enrolled_admins': instance.enrolledAdmins,
      'enrolments': instance.enrolments,
      'key_configured': instance.keyConfigured,
      'policy': instance.policy,
      'require_cli': instance.requireCli,
      'require_ssh': instance.requireSsh,
      'require_web': instance.requireWeb,
      'tenant_key': instance.tenantKey,
      'unrecoverable': instance.unrecoverable,
    };

_TOTPStatus _$TOTPStatusFromJson(Map<String, dynamic> json) => _TOTPStatus(
  confirmedAt: _$JsonConverterFromJson<String, DateTime>(
    json['confirmed_at'],
    const TixDateTime().fromJson,
  ),
  enrolled: json['enrolled'] as bool? ?? false,
  enrollmentDue: _$JsonConverterFromJson<String, DateTime>(
    json['enrollment_due'],
    const TixDateTime().fromJson,
  ),
  enrollmentRequired: json['enrollment_required'] as bool? ?? false,
  pending: json['pending'] as bool? ?? false,
  policy: json['policy'] as String? ?? '',
  recoveryCodesLeft: (json['recovery_codes_left'] as num?)?.toInt() ?? 0,
  requiredCli: json['required_cli'] as bool? ?? false,
  requiredSsh: json['required_ssh'] as bool? ?? false,
  requiredWeb: json['required_web'] as bool? ?? false,
  verificationLockEnd: _$JsonConverterFromJson<String, DateTime>(
    json['verification_lock_end'],
    const TixDateTime().fromJson,
  ),
  verificationLocked: json['verification_locked'] as bool? ?? false,
);

Map<String, dynamic> _$TOTPStatusToJson(_TOTPStatus instance) =>
    <String, dynamic>{
      'confirmed_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.confirmedAt,
        const TixDateTime().toJson,
      ),
      'enrolled': instance.enrolled,
      'enrollment_due': ?_$JsonConverterToJson<String, DateTime>(
        instance.enrollmentDue,
        const TixDateTime().toJson,
      ),
      'enrollment_required': instance.enrollmentRequired,
      'pending': instance.pending,
      'policy': instance.policy,
      'recovery_codes_left': instance.recoveryCodesLeft,
      'required_cli': instance.requiredCli,
      'required_ssh': instance.requiredSsh,
      'required_web': instance.requiredWeb,
      'verification_lock_end': ?_$JsonConverterToJson<String, DateTime>(
        instance.verificationLockEnd,
        const TixDateTime().toJson,
      ),
      'verification_locked': instance.verificationLocked,
    };

_Tag _$TagFromJson(Map<String, dynamic> json) => _Tag(
  color: json['color'] as String? ?? '',
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  projectId: json['project_id'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
);

Map<String, dynamic> _$TagToJson(_Tag instance) => <String, dynamic>{
  'color': instance.color,
  'id': instance.id,
  'name': instance.name,
  'project_id': instance.projectId,
  'tenant_id': instance.tenantId,
};

_TagRequest _$TagRequestFromJson(Map<String, dynamic> json) =>
    _TagRequest(name: json['name'] as String?);

Map<String, dynamic> _$TagRequestToJson(_TagRequest instance) =>
    <String, dynamic>{'name': ?instance.name};

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  assigneeActorId: json['assignee_actor_id'] as String? ?? '',
  blocked: json['blocked'] as bool? ?? false,
  body: json['body'] as String? ?? '',
  checklist: json['checklist'] == null
      ? null
      : Checklist.fromJson(json['checklist'] as Map<String, dynamic>),
  claimCount: (json['claim_count'] as num?)?.toInt() ?? 0,
  claimedAt: _$JsonConverterFromJson<String, DateTime>(
    json['claimed_at'],
    const TixDateTime().fromJson,
  ),
  claimedByActorId: json['claimed_by_actor_id'] as String? ?? '',
  completedAt: _$JsonConverterFromJson<String, DateTime>(
    json['completed_at'],
    const TixDateTime().fromJson,
  ),
  copiedFromId: json['copied_from_id'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  creatorActorId: json['creator_actor_id'] as String? ?? '',
  customFields:
      json['custom_fields'] as Map<String, dynamic>? ??
      const <String, Object?>{},
  deletedAt: _$JsonConverterFromJson<String, DateTime>(
    json['deleted_at'],
    const TixDateTime().fromJson,
  ),
  dependsOn:
      (json['depends_on'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  dueAt: _$JsonConverterFromJson<String, DateTime>(
    json['due_at'],
    const TixDateTime().fromJson,
  ),
  id: json['id'] as String? ?? '',
  lease: json['lease'] as String? ?? '',
  leaseExpiredAt: _$JsonConverterFromJson<String, DateTime>(
    json['lease_expired_at'],
    const TixDateTime().fromJson,
  ),
  leaseExpiredByActorId: json['lease_expired_by_actor_id'] as String? ?? '',
  leaseExpiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['lease_expires_at'],
    const TixDateTime().fromJson,
  ),
  parentId: json['parent_id'] as String? ?? '',
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  projectId: json['project_id'] as String? ?? '',
  recurrence: json['recurrence'] as String? ?? '',
  recurrenceNextId: json['recurrence_next_id'] as String? ?? '',
  ref: json['ref'] as String? ?? '',
  seq: (json['seq'] as num?)?.toInt() ?? 0,
  snoozedByActorId: json['snoozed_by_actor_id'] as String? ?? '',
  snoozedUntil: _$JsonConverterFromJson<String, DateTime>(
    json['snoozed_until'],
    const TixDateTime().fromJson,
  ),
  starred: json['starred'] as bool? ?? false,
  startedAt: _$JsonConverterFromJson<String, DateTime>(
    json['started_at'],
    const TixDateTime().fromJson,
  ),
  status: json['status'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tenantId: json['tenant_id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updated_at'],
    const TixDateTime().fromJson,
  ),
  version: (json['version'] as num?)?.toInt() ?? 0,
  waitingOn:
      (json['waiting_on'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  webUrl: json['web_url'] as String? ?? '',
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'assignee_actor_id': instance.assigneeActorId,
  'blocked': instance.blocked,
  'body': instance.body,
  'checklist': ?instance.checklist?.toJson(),
  'claim_count': instance.claimCount,
  'claimed_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.claimedAt,
    const TixDateTime().toJson,
  ),
  'claimed_by_actor_id': instance.claimedByActorId,
  'completed_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.completedAt,
    const TixDateTime().toJson,
  ),
  'copied_from_id': instance.copiedFromId,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'creator_actor_id': instance.creatorActorId,
  'custom_fields': instance.customFields,
  'deleted_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.deletedAt,
    const TixDateTime().toJson,
  ),
  'depends_on': instance.dependsOn,
  'due_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.dueAt,
    const TixDateTime().toJson,
  ),
  'id': instance.id,
  'lease': instance.lease,
  'lease_expired_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.leaseExpiredAt,
    const TixDateTime().toJson,
  ),
  'lease_expired_by_actor_id': instance.leaseExpiredByActorId,
  'lease_expires_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.leaseExpiresAt,
    const TixDateTime().toJson,
  ),
  'parent_id': instance.parentId,
  'priority': instance.priority,
  'project_id': instance.projectId,
  'recurrence': instance.recurrence,
  'recurrence_next_id': instance.recurrenceNextId,
  'ref': instance.ref,
  'seq': instance.seq,
  'snoozed_by_actor_id': instance.snoozedByActorId,
  'snoozed_until': ?_$JsonConverterToJson<String, DateTime>(
    instance.snoozedUntil,
    const TixDateTime().toJson,
  ),
  'starred': instance.starred,
  'started_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.startedAt,
    const TixDateTime().toJson,
  ),
  'status': instance.status,
  'tags': instance.tags,
  'tenant_id': instance.tenantId,
  'title': instance.title,
  'updated_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const TixDateTime().toJson,
  ),
  'version': instance.version,
  'waiting_on': instance.waitingOn,
  'web_url': instance.webUrl,
};

_TaskExportInput _$TaskExportInputFromJson(Map<String, dynamic> json) =>
    _TaskExportInput(
      columns: (json['columns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dates: json['dates'] as String?,
      delimiter: json['delimiter'] as String?,
      excludeFinished: json['exclude_finished'] as bool?,
      excludeSubtasks: json['exclude_subtasks'] as bool?,
      format: json['format'] as String?,
      includeTrashed: json['include_trashed'] as bool?,
      projectRef: json['project_ref'] as String?,
      query: json['query'] as String?,
      timeFormat: json['time_format'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$TaskExportInputToJson(_TaskExportInput instance) =>
    <String, dynamic>{
      'columns': ?instance.columns,
      'dates': ?instance.dates,
      'delimiter': ?instance.delimiter,
      'exclude_finished': ?instance.excludeFinished,
      'exclude_subtasks': ?instance.excludeSubtasks,
      'format': ?instance.format,
      'include_trashed': ?instance.includeTrashed,
      'project_ref': ?instance.projectRef,
      'query': ?instance.query,
      'time_format': ?instance.timeFormat,
      'timezone': ?instance.timezone,
    };

_TaskImportColumn _$TaskImportColumnFromJson(Map<String, dynamic> json) =>
    _TaskImportColumn(
      header: json['header'] as String? ?? '',
      sample:
          (json['sample'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      suggested: json['suggested'] as bool? ?? false,
      target: json['target'] as String? ?? '',
    );

Map<String, dynamic> _$TaskImportColumnToJson(_TaskImportColumn instance) =>
    <String, dynamic>{
      'header': instance.header,
      'sample': instance.sample,
      'suggested': instance.suggested,
      'target': instance.target,
    };

_TaskImportError _$TaskImportErrorFromJson(Map<String, dynamic> json) =>
    _TaskImportError(
      line: (json['line'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$TaskImportErrorToJson(_TaskImportError instance) =>
    <String, dynamic>{'line': instance.line, 'message': instance.message};

_TaskImportInput _$TaskImportInputFromJson(Map<String, dynamic> json) =>
    _TaskImportInput(
      content: json['content'] as String?,
      dryRun: json['dry_run'] as bool?,
      filename: json['filename'] as String?,
      format: json['format'] as String?,
      mapping: json['mapping'] as String?,
      mode: json['mode'] as String?,
      preview: (json['preview'] as num?)?.toInt(),
      projectRef: json['project_ref'] as String?,
    );

Map<String, dynamic> _$TaskImportInputToJson(_TaskImportInput instance) =>
    <String, dynamic>{
      'content': ?instance.content,
      'dry_run': ?instance.dryRun,
      'filename': ?instance.filename,
      'format': ?instance.format,
      'mapping': ?instance.mapping,
      'mode': ?instance.mode,
      'preview': ?instance.preview,
      'project_ref': ?instance.projectRef,
    };

_TaskImportResult _$TaskImportResultFromJson(Map<String, dynamic> json) =>
    _TaskImportResult(
      columns:
          (json['columns'] as List<dynamic>?)
              ?.map((e) => TaskImportColumn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TaskImportColumn>[],
      committed: json['committed'] as bool? ?? false,
      confident: json['confident'] as bool? ?? false,
      created: (json['created'] as num?)?.toInt() ?? 0,
      dryRun: json['dry_run'] as bool? ?? false,
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => TaskImportError.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TaskImportError>[],
      failed: (json['failed'] as num?)?.toInt() ?? 0,
      format: json['format'] as String? ?? '',
      mapping: json['mapping'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
      preview:
          (json['preview'] as List<dynamic>?)
              ?.map((e) => TaskImportRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TaskImportRow>[],
      rows: (json['rows'] as num?)?.toInt() ?? 0,
      skipped: (json['skipped'] as num?)?.toInt() ?? 0,
      source: json['source'] as String? ?? '',
      updated: (json['updated'] as num?)?.toInt() ?? 0,
      values:
          (json['values'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>)
                  .map(
                    (e) => TaskImportValue.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
            ),
          ) ??
          const <String, List<TaskImportValue>>{},
    );

Map<String, dynamic> _$TaskImportResultToJson(_TaskImportResult instance) =>
    <String, dynamic>{
      'columns': instance.columns.map((e) => e.toJson()).toList(),
      'committed': instance.committed,
      'confident': instance.confident,
      'created': instance.created,
      'dry_run': instance.dryRun,
      'errors': instance.errors.map((e) => e.toJson()).toList(),
      'failed': instance.failed,
      'format': instance.format,
      'mapping': instance.mapping,
      'mode': instance.mode,
      'preview': instance.preview.map((e) => e.toJson()).toList(),
      'rows': instance.rows,
      'skipped': instance.skipped,
      'source': instance.source,
      'updated': instance.updated,
      'values': instance.values.map(
        (k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()),
      ),
    };

_TaskImportRow _$TaskImportRowFromJson(Map<String, dynamic> json) =>
    _TaskImportRow(
      action: json['action'] as String? ?? '',
      assignee: json['assignee'] as String? ?? '',
      due: _$JsonConverterFromJson<String, DateTime>(
        json['due'],
        const TixDateTime().fromJson,
      ),
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      externalId: json['external_id'] as String? ?? '',
      line: (json['line'] as num?)?.toInt() ?? 0,
      parent: json['parent'] as String? ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
      ref: json['ref'] as String? ?? '',
      status: json['status'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$TaskImportRowToJson(_TaskImportRow instance) =>
    <String, dynamic>{
      'action': instance.action,
      'assignee': instance.assignee,
      'due': ?_$JsonConverterToJson<String, DateTime>(
        instance.due,
        const TixDateTime().toJson,
      ),
      'errors': instance.errors,
      'external_id': instance.externalId,
      'line': instance.line,
      'parent': instance.parent,
      'priority': instance.priority,
      'reason': instance.reason,
      'ref': instance.ref,
      'status': instance.status,
      'tags': instance.tags,
      'title': instance.title,
    };

_TaskImportValue _$TaskImportValueFromJson(Map<String, dynamic> json) =>
    _TaskImportValue(
      count: (json['count'] as num?)?.toInt() ?? 0,
      mapped: json['mapped'] as String? ?? '',
      suggested: json['suggested'] as bool? ?? false,
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$TaskImportValueToJson(_TaskImportValue instance) =>
    <String, dynamic>{
      'count': instance.count,
      'mapped': instance.mapped,
      'suggested': instance.suggested,
      'value': instance.value,
    };

_TaskMove _$TaskMoveFromJson(Map<String, dynamic> json) => _TaskMove(
  droppedFields:
      (json['dropped_fields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  fromProject: json['from_project'] as String? ?? '',
  fromRef: json['from_ref'] as String? ?? '',
  fromStatus: json['from_status'] as String? ?? '',
  project: json['project'] as String? ?? '',
  statusKept: json['status_kept'] as bool? ?? false,
  task: json['task'] == null
      ? null
      : Task.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskMoveToJson(_TaskMove instance) => <String, dynamic>{
  'dropped_fields': instance.droppedFields,
  'from_project': instance.fromProject,
  'from_ref': instance.fromRef,
  'from_status': instance.fromStatus,
  'project': instance.project,
  'status_kept': instance.statusKept,
  'task': ?instance.task?.toJson(),
};

_TaskTemplate _$TaskTemplateFromJson(Map<String, dynamic> json) =>
    _TaskTemplate(
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      creatorActorId: json['creator_actor_id'] as String? ?? '',
      dueIn: json['due_in'] as String? ?? '',
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      projectKey: json['project_key'] as String? ?? '',
      task: json['task'] == null
          ? null
          : TemplateTask.fromJson(json['task'] as Map<String, dynamic>),
      tenantId: json['tenant_id'] as String? ?? '',
      updatedAt: _$JsonConverterFromJson<String, DateTime>(
        json['updated_at'],
        const TixDateTime().fromJson,
      ),
      uses: (json['uses'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TaskTemplateToJson(_TaskTemplate instance) =>
    <String, dynamic>{
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'creator_actor_id': instance.creatorActorId,
      'due_in': instance.dueIn,
      'id': instance.id,
      'name': instance.name,
      'project_id': instance.projectId,
      'project_key': instance.projectKey,
      'task': ?instance.task?.toJson(),
      'tenant_id': instance.tenantId,
      'updated_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const TixDateTime().toJson,
      ),
      'uses': instance.uses,
    };

_TemplateTask _$TemplateTaskFromJson(Map<String, dynamic> json) =>
    _TemplateTask(
      body: json['body'] as String? ?? '',
      customFields:
          json['custom_fields'] as Map<String, dynamic>? ??
          const <String, Object?>{},
      lease: json['lease'] as String? ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      recurrence: json['recurrence'] as String? ?? '',
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map((e) => TemplateTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TemplateTask>[],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$TemplateTaskToJson(_TemplateTask instance) =>
    <String, dynamic>{
      'body': instance.body,
      'custom_fields': instance.customFields,
      'lease': instance.lease,
      'priority': instance.priority,
      'recurrence': instance.recurrence,
      'subtasks': instance.subtasks.map((e) => e.toJson()).toList(),
      'tags': instance.tags,
      'title': instance.title,
    };

_Tenant _$TenantFromJson(Map<String, dynamic> json) => _Tenant(
  artifactMaxBytes: (json['artifact_max_bytes'] as num?)?.toInt() ?? 0,
  artifactTypes:
      (json['artifact_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  deletedAt: _$JsonConverterFromJson<String, DateTime>(
    json['deleted_at'],
    const TixDateTime().fromJson,
  ),
  id: json['id'] as String? ?? '',
  key: json['key'] as String? ?? '',
  leaseDefault: json['lease_default'] as String? ?? '',
  leaseMax: json['lease_max'] as String? ?? '',
  mfaGrace: json['mfa_grace'] as String? ?? '',
  mfaPolicy: json['mfa_policy'] as String? ?? '',
  mfaRequiredAt: _$JsonConverterFromJson<String, DateTime>(
    json['mfa_required_at'],
    const TixDateTime().fromJson,
  ),
  name: json['name'] as String? ?? '',
  requireTotpCli: json['require_totp_cli'] as bool? ?? false,
  requireTotpSsh: json['require_totp_ssh'] as bool? ?? false,
  requireTotpWeb: json['require_totp_web'] as bool? ?? false,
  sessionIdleTimeout: json['session_idle_timeout'] as String? ?? '',
  sessionRememberOff: json['session_remember_off'] as bool? ?? false,
  sessionRememberTtl: json['session_remember_ttl'] as String? ?? '',
  sessionTtl: json['session_ttl'] as String? ?? '',
  theme: json['theme'] as String? ?? '',
  timeFormat: json['time_format'] as String? ?? '',
  timezone: json['timezone'] as String? ?? '',
  trashOff: json['trash_off'] as bool? ?? false,
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updated_at'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$TenantToJson(_Tenant instance) => <String, dynamic>{
  'artifact_max_bytes': instance.artifactMaxBytes,
  'artifact_types': instance.artifactTypes,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'deleted_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.deletedAt,
    const TixDateTime().toJson,
  ),
  'id': instance.id,
  'key': instance.key,
  'lease_default': instance.leaseDefault,
  'lease_max': instance.leaseMax,
  'mfa_grace': instance.mfaGrace,
  'mfa_policy': instance.mfaPolicy,
  'mfa_required_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.mfaRequiredAt,
    const TixDateTime().toJson,
  ),
  'name': instance.name,
  'require_totp_cli': instance.requireTotpCli,
  'require_totp_ssh': instance.requireTotpSsh,
  'require_totp_web': instance.requireTotpWeb,
  'session_idle_timeout': instance.sessionIdleTimeout,
  'session_remember_off': instance.sessionRememberOff,
  'session_remember_ttl': instance.sessionRememberTtl,
  'session_ttl': instance.sessionTtl,
  'theme': instance.theme,
  'time_format': instance.timeFormat,
  'timezone': instance.timezone,
  'trash_off': instance.trashOff,
  'updated_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const TixDateTime().toJson,
  ),
};

_TenantAdminInput _$TenantAdminInputFromJson(Map<String, dynamic> json) =>
    _TenantAdminInput(
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      handle: json['handle'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$TenantAdminInputToJson(_TenantAdminInput instance) =>
    <String, dynamic>{
      'display_name': ?instance.displayName,
      'email': ?instance.email,
      'handle': ?instance.handle,
      'password': ?instance.password,
    };

_TenantUser _$TenantUserFromJson(Map<String, dynamic> json) => _TenantUser(
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  disabledAt: _$JsonConverterFromJson<String, DateTime>(
    json['disabled_at'],
    const TixDateTime().fromJson,
  ),
  displayName: json['display_name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  globalAdmin: json['global_admin'] as bool? ?? false,
  id: json['id'] as String? ?? '',
  removed: json['removed'] as bool? ?? false,
  requirePasswordChange: json['require_password_change'] as bool? ?? false,
  role: $enumDecodeNullable(
    _$RoleEnumMap,
    json['role'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  ssoProvider: json['sso_provider'] as String? ?? '',
  ssoSubject: json['sso_subject'] as String? ?? '',
  totpEnrolled: json['totp_enrolled'] as bool? ?? false,
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updated_at'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$TenantUserToJson(_TenantUser instance) =>
    <String, dynamic>{
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'disabled_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.disabledAt,
        const TixDateTime().toJson,
      ),
      'display_name': instance.displayName,
      'email': instance.email,
      'global_admin': instance.globalAdmin,
      'id': instance.id,
      'removed': instance.removed,
      'require_password_change': instance.requirePasswordChange,
      'role': ?_$RoleEnumMap[instance.role],
      'sso_provider': instance.ssoProvider,
      'sso_subject': instance.ssoSubject,
      'totp_enrolled': instance.totpEnrolled,
      'updated_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const TixDateTime().toJson,
      ),
    };

_Theme _$ThemeFromJson(Map<String, dynamic> json) => _Theme(
  accent: json['accent'] as String? ?? '',
  accentDark: json['accent_dark'] as String? ?? '',
  accentSoft: json['accent_soft'] as String? ?? '',
  accentSoftDark: json['accent_soft_dark'] as String? ?? '',
  builtIn: json['built_in'] as bool? ?? false,
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$ThemeToJson(_Theme instance) => <String, dynamic>{
  'accent': instance.accent,
  'accent_dark': instance.accentDark,
  'accent_soft': instance.accentSoft,
  'accent_soft_dark': instance.accentSoftDark,
  'built_in': instance.builtIn,
  'name': instance.name,
};

_TimePrefs _$TimePrefsFromJson(Map<String, dynamic> json) => _TimePrefs(
  timeFormat: json['time_format'] as String? ?? '',
  timezone: json['timezone'] as String? ?? '',
);

Map<String, dynamic> _$TimePrefsToJson(_TimePrefs instance) =>
    <String, dynamic>{
      'time_format': instance.timeFormat,
      'timezone': instance.timezone,
    };

_TimePrefsInput _$TimePrefsInputFromJson(Map<String, dynamic> json) =>
    _TimePrefsInput(
      timeFormat: json['time_format'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$TimePrefsInputToJson(_TimePrefsInput instance) =>
    <String, dynamic>{
      'time_format': ?instance.timeFormat,
      'timezone': ?instance.timezone,
    };

_TimeSettings _$TimeSettingsFromJson(Map<String, dynamic> json) =>
    _TimeSettings(
      effective: json['effective'] == null
          ? null
          : TimePrefs.fromJson(json['effective'] as Map<String, dynamic>),
      formatSource: json['format_source'] as String? ?? '',
      global: json['global'] == null
          ? null
          : TimePrefs.fromJson(json['global'] as Map<String, dynamic>),
      personal: json['personal'] as bool? ?? false,
      tenant: json['tenant'] == null
          ? null
          : TimePrefs.fromJson(json['tenant'] as Map<String, dynamic>),
      timezoneSource: json['timezone_source'] as String? ?? '',
      user: json['user'] == null
          ? null
          : TimePrefs.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimeSettingsToJson(_TimeSettings instance) =>
    <String, dynamic>{
      'effective': ?instance.effective?.toJson(),
      'format_source': instance.formatSource,
      'global': ?instance.global?.toJson(),
      'personal': instance.personal,
      'tenant': ?instance.tenant?.toJson(),
      'timezone_source': instance.timezoneSource,
      'user': ?instance.user?.toJson(),
    };

_Transition _$TransitionFromJson(Map<String, dynamic> json) => _Transition(
  from: json['from'] as String?,
  requiresComment: json['requires_comment'] as bool?,
  requiresScope: $enumDecodeNullable(
    _$ScopeEnumMap,
    json['requires_scope'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  to: json['to'] as String?,
);

Map<String, dynamic> _$TransitionToJson(_Transition instance) =>
    <String, dynamic>{
      'from': ?instance.from,
      'requires_comment': ?instance.requiresComment,
      'requires_scope': ?_$ScopeEnumMap[instance.requiresScope],
      'to': ?instance.to,
    };

const _$ScopeEnumMap = {
  Scope.all: '*',
  Scope.taskRead: 'task:read',
  Scope.taskWrite: 'task:write',
  Scope.taskTransition: 'task:transition',
  Scope.taskClaim: 'task:claim',
  Scope.taskDelete: 'task:delete',
  Scope.taskReclaim: 'task:reclaim',
  Scope.taskApprove: 'task:approve',
  Scope.projectRead: 'project:read',
  Scope.projectWrite: 'project:write',
  Scope.workflowRead: 'workflow:read',
  Scope.workflowWrite: 'workflow:write',
  Scope.commentWrite: 'comment:write',
  Scope.artifactWrite: 'artifact:write',
  Scope.eventSubscribe: 'event:subscribe',
  Scope.userAdmin: 'user:admin',
  Scope.totpAdmin: 'totp:admin',
  Scope.tokenAdmin: 'token:admin',
  Scope.webhookAdmin: 'webhook:admin',
  Scope.tenantAdmin: 'tenant:admin',
  Scope.syncAdmin: 'sync:admin',
  Scope.globalAdmin: 'global:admin',
  Scope.auditRead: 'audit:read',
  Scope.accountRead: 'account:read',
  Scope.export: 'export',
  Scope.import: 'import',
};

_TransitionInput _$TransitionInputFromJson(Map<String, dynamic> json) =>
    _TransitionInput(
      comment: json['comment'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      leaseToken: json['lease_token'] as String?,
      to: json['to'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TransitionInputToJson(_TransitionInput instance) =>
    <String, dynamic>{
      'comment': ?instance.comment,
      'custom_fields': ?instance.customFields,
      'lease_token': ?instance.leaseToken,
      'to': ?instance.to,
      'version': ?instance.version,
    };

_TrashStatus _$TrashStatusFromJson(Map<String, dynamic> json) => _TrashStatus(
  enabled: json['enabled'] as bool? ?? false,
  held: (json['held'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TrashStatusToJson(_TrashStatus instance) =>
    <String, dynamic>{'enabled': instance.enabled, 'held': instance.held};

_UpdateDomainInput _$UpdateDomainInputFromJson(Map<String, dynamic> json) =>
    _UpdateDomainInput(shared: json['shared'] as bool?);

Map<String, dynamic> _$UpdateDomainInputToJson(_UpdateDomainInput instance) =>
    <String, dynamic>{'shared': ?instance.shared};

_UpdateProjectInput _$UpdateProjectInputFromJson(Map<String, dynamic> json) =>
    _UpdateProjectInput(
      color: json['color'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      iconFile: json['icon_file'] == null
          ? null
          : ProjectIconFile.fromJson(json['icon_file'] as Map<String, dynamic>),
      iconName: json['icon_name'] as String?,
      key: json['key'] as String?,
      leaseDefault: json['lease_default'] as String?,
      leaseMax: json['lease_max'] as String?,
      name: json['name'] as String?,
      workflowKey: json['workflow_key'] as String?,
    );

Map<String, dynamic> _$UpdateProjectInputToJson(_UpdateProjectInput instance) =>
    <String, dynamic>{
      'color': ?instance.color,
      'description': ?instance.description,
      'icon': ?instance.icon,
      'icon_file': ?instance.iconFile?.toJson(),
      'icon_name': ?instance.iconName,
      'key': ?instance.key,
      'lease_default': ?instance.leaseDefault,
      'lease_max': ?instance.leaseMax,
      'name': ?instance.name,
      'workflow_key': ?instance.workflowKey,
    };

_UpdateTaskInput _$UpdateTaskInputFromJson(Map<String, dynamic> json) =>
    _UpdateTaskInput(
      assigneeActorId: json['assignee_actor_id'] as String?,
      body: json['body'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      lease: json['lease'] as String?,
      parentRef: json['parent_ref'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      recurrence: json['recurrence'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      title: json['title'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateTaskInputToJson(_UpdateTaskInput instance) =>
    <String, dynamic>{
      'assignee_actor_id': ?instance.assigneeActorId,
      'body': ?instance.body,
      'custom_fields': ?instance.customFields,
      'lease': ?instance.lease,
      'parent_ref': ?instance.parentRef,
      'priority': ?instance.priority,
      'recurrence': ?instance.recurrence,
      'tags': ?instance.tags,
      'title': ?instance.title,
      'version': ?instance.version,
    };

_UpdateTemplateInput _$UpdateTemplateInputFromJson(Map<String, dynamic> json) =>
    _UpdateTemplateInput(
      body: json['body'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      dueIn: json['due_in'] as String?,
      name: json['name'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      projectRef: json['project_ref'] as String?,
      recurrence: json['recurrence'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$UpdateTemplateInputToJson(
  _UpdateTemplateInput instance,
) => <String, dynamic>{
  'body': ?instance.body,
  'custom_fields': ?instance.customFields,
  'due_in': ?instance.dueIn,
  'name': ?instance.name,
  'priority': ?instance.priority,
  'project_ref': ?instance.projectRef,
  'recurrence': ?instance.recurrence,
  'tags': ?instance.tags,
  'title': ?instance.title,
};

_UpdateTenantInput _$UpdateTenantInputFromJson(Map<String, dynamic> json) =>
    _UpdateTenantInput(
      artifactMaxBytes: (json['artifact_max_bytes'] as num?)?.toInt(),
      artifactTypes: (json['artifact_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      leaseDefault: json['lease_default'] as String?,
      leaseMax: json['lease_max'] as String?,
      mfaGrace: json['mfa_grace'] as String?,
      mfaPolicy: json['mfa_policy'] as String?,
      name: json['name'] as String?,
      requireTotpCli: json['require_totp_cli'] as bool?,
      requireTotpSsh: json['require_totp_ssh'] as bool?,
      requireTotpWeb: json['require_totp_web'] as bool?,
      sessionIdleTimeout: json['session_idle_timeout'] as String?,
      sessionRememberTtl: json['session_remember_ttl'] as String?,
      sessionTtl: json['session_ttl'] as String?,
      theme: json['theme'] as String?,
      timeFormat: json['time_format'] as String?,
      timezone: json['timezone'] as String?,
      trashOff: json['trash_off'] as bool?,
    );

Map<String, dynamic> _$UpdateTenantInputToJson(_UpdateTenantInput instance) =>
    <String, dynamic>{
      'artifact_max_bytes': ?instance.artifactMaxBytes,
      'artifact_types': ?instance.artifactTypes,
      'lease_default': ?instance.leaseDefault,
      'lease_max': ?instance.leaseMax,
      'mfa_grace': ?instance.mfaGrace,
      'mfa_policy': ?instance.mfaPolicy,
      'name': ?instance.name,
      'require_totp_cli': ?instance.requireTotpCli,
      'require_totp_ssh': ?instance.requireTotpSsh,
      'require_totp_web': ?instance.requireTotpWeb,
      'session_idle_timeout': ?instance.sessionIdleTimeout,
      'session_remember_ttl': ?instance.sessionRememberTtl,
      'session_ttl': ?instance.sessionTtl,
      'theme': ?instance.theme,
      'time_format': ?instance.timeFormat,
      'timezone': ?instance.timezone,
      'trash_off': ?instance.trashOff,
    };

_UpdateUserInput _$UpdateUserInputFromJson(Map<String, dynamic> json) =>
    _UpdateUserInput(
      disabled: json['disabled'] as bool?,
      displayName: json['display_name'] as String?,
      password: json['password'] as String?,
      requirePasswordChange: json['require_password_change'] as bool?,
      role: $enumDecodeNullable(
        _$RoleEnumMap,
        json['role'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$UpdateUserInputToJson(_UpdateUserInput instance) =>
    <String, dynamic>{
      'disabled': ?instance.disabled,
      'display_name': ?instance.displayName,
      'password': ?instance.password,
      'require_password_change': ?instance.requirePasswordChange,
      'role': ?_$RoleEnumMap[instance.role],
    };

_UseTemplateInput _$UseTemplateInputFromJson(Map<String, dynamic> json) =>
    _UseTemplateInput(
      dueIn: json['due_in'] as String?,
      projectRef: json['project_ref'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$UseTemplateInputToJson(_UseTemplateInput instance) =>
    <String, dynamic>{
      'due_in': ?instance.dueIn,
      'project_ref': ?instance.projectRef,
      'title': ?instance.title,
    };

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  disabledAt: _$JsonConverterFromJson<String, DateTime>(
    json['disabled_at'],
    const TixDateTime().fromJson,
  ),
  displayName: json['display_name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  globalAdmin: json['global_admin'] as bool? ?? false,
  id: json['id'] as String? ?? '',
  removed: json['removed'] as bool? ?? false,
  requirePasswordChange: json['require_password_change'] as bool? ?? false,
  ssoProvider: json['sso_provider'] as String? ?? '',
  ssoSubject: json['sso_subject'] as String? ?? '',
  totpEnrolled: json['totp_enrolled'] as bool? ?? false,
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updated_at'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'disabled_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.disabledAt,
    const TixDateTime().toJson,
  ),
  'display_name': instance.displayName,
  'email': instance.email,
  'global_admin': instance.globalAdmin,
  'id': instance.id,
  'removed': instance.removed,
  'require_password_change': instance.requirePasswordChange,
  'sso_provider': instance.ssoProvider,
  'sso_subject': instance.ssoSubject,
  'totp_enrolled': instance.totpEnrolled,
  'updated_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const TixDateTime().toJson,
  ),
};

_Via _$ViaFromJson(Map<String, dynamic> json) => _Via(
  clientAddr: json['client_addr'] as String? ?? '',
  host: json['host'] as String? ?? '',
  job: json['job'] as String? ?? '',
  keyFingerprint: json['key_fingerprint'] as String? ?? '',
  kind: json['kind'] as String? ?? '',
  origin: json['origin'] as String? ?? '',
  osUser: json['os_user'] as String? ?? '',
  session: json['session'] as String? ?? '',
  tokenId: json['token_id'] as String? ?? '',
  tokenName: json['token_name'] as String? ?? '',
  userAgent: json['user_agent'] as String? ?? '',
);

Map<String, dynamic> _$ViaToJson(_Via instance) => <String, dynamic>{
  'client_addr': instance.clientAddr,
  'host': instance.host,
  'job': instance.job,
  'key_fingerprint': instance.keyFingerprint,
  'kind': instance.kind,
  'origin': instance.origin,
  'os_user': instance.osUser,
  'session': instance.session,
  'token_id': instance.tokenId,
  'token_name': instance.tokenName,
  'user_agent': instance.userAgent,
};

_WakeResult _$WakeResultFromJson(Map<String, dynamic> json) =>
    _WakeResult(woken: (json['woken'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$WakeResultToJson(_WakeResult instance) =>
    <String, dynamic>{'woken': instance.woken};

_WebhookDelivery _$WebhookDeliveryFromJson(Map<String, dynamic> json) =>
    _WebhookDelivery(
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      endpointId: json['endpoint_id'] as String? ?? '',
      eventSeq: (json['event_seq'] as num?)?.toInt() ?? 0,
      id: json['id'] as String? ?? '',
      lastError: json['last_error'] as String? ?? '',
      lastStatusCode: (json['last_status_code'] as num?)?.toInt() ?? 0,
      nextAttemptAt: _$JsonConverterFromJson<String, DateTime>(
        json['next_attempt_at'],
        const TixDateTime().fromJson,
      ),
      status: $enumDecodeNullable(
        _$DeliveryStatusEnumMap,
        json['status'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      tenantId: json['tenant_id'] as String? ?? '',
    );

Map<String, dynamic> _$WebhookDeliveryToJson(_WebhookDelivery instance) =>
    <String, dynamic>{
      'attempts': instance.attempts,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'endpoint_id': instance.endpointId,
      'event_seq': instance.eventSeq,
      'id': instance.id,
      'last_error': instance.lastError,
      'last_status_code': instance.lastStatusCode,
      'next_attempt_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.nextAttemptAt,
        const TixDateTime().toJson,
      ),
      'status': ?_$DeliveryStatusEnumMap[instance.status],
      'tenant_id': instance.tenantId,
    };

_WebhookEndpoint _$WebhookEndpointFromJson(Map<String, dynamic> json) =>
    _WebhookEndpoint(
      active: json['active'] as bool? ?? false,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['created_at'],
        const TixDateTime().fromJson,
      ),
      eventTypes:
          (json['event_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$WebhookEndpointToJson(_WebhookEndpoint instance) =>
    <String, dynamic>{
      'active': instance.active,
      'created_at': ?_$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const TixDateTime().toJson,
      ),
      'event_types': instance.eventTypes,
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'url': instance.url,
    };

_WebhookInput _$WebhookInputFromJson(Map<String, dynamic> json) =>
    _WebhookInput(
      active: json['active'] as bool?,
      eventTypes: (json['event_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      id: json['id'] as String?,
      secret: json['secret'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$WebhookInputToJson(_WebhookInput instance) =>
    <String, dynamic>{
      'active': ?instance.active,
      'event_types': ?instance.eventTypes,
      'id': ?instance.id,
      'secret': ?instance.secret,
      'url': ?instance.url,
    };

_Work _$WorkFromJson(Map<String, dynamic> json) => _Work(
  claimed: (json['claimed'] as num?)?.toInt() ?? 0,
  leasesExpiredUnswept: (json['leases_expired_unswept'] as num?)?.toInt() ?? 0,
  numberingBehind:
      (json['numbering_behind'] as List<dynamic>?)
          ?.map((e) => NumberingLag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <NumberingLag>[],
  projects: (json['projects'] as num?)?.toInt() ?? 0,
  tasks: (json['tasks'] as num?)?.toInt() ?? 0,
  tenants: (json['tenants'] as num?)?.toInt() ?? 0,
  webhooksFailed: (json['webhooks_failed'] as num?)?.toInt() ?? 0,
  webhooksPending: (json['webhooks_pending'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WorkToJson(_Work instance) => <String, dynamic>{
  'claimed': instance.claimed,
  'leases_expired_unswept': instance.leasesExpiredUnswept,
  'numbering_behind': instance.numberingBehind.map((e) => e.toJson()).toList(),
  'projects': instance.projects,
  'tasks': instance.tasks,
  'tenants': instance.tenants,
  'webhooks_failed': instance.webhooksFailed,
  'webhooks_pending': instance.webhooksPending,
};

_Workflow _$WorkflowFromJson(Map<String, dynamic> json) => _Workflow(
  builtin: json['builtin'] as bool? ?? false,
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const TixDateTime().fromJson,
  ),
  definition: json['definition'] == null
      ? null
      : WorkflowDefinition.fromJson(json['definition'] as Map<String, dynamic>),
  id: json['id'] as String? ?? '',
  key: json['key'] as String? ?? '',
  name: json['name'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updated_at'],
    const TixDateTime().fromJson,
  ),
);

Map<String, dynamic> _$WorkflowToJson(_Workflow instance) => <String, dynamic>{
  'builtin': instance.builtin,
  'created_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const TixDateTime().toJson,
  ),
  'definition': ?instance.definition?.toJson(),
  'id': instance.id,
  'key': instance.key,
  'name': instance.name,
  'tenant_id': instance.tenantId,
  'updated_at': ?_$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const TixDateTime().toJson,
  ),
};

_WorkflowDefinition _$WorkflowDefinitionFromJson(Map<String, dynamic> json) =>
    _WorkflowDefinition(
      defaultLease: json['default_lease'] as String?,
      initial: json['initial'] as String?,
      states: (json['states'] as List<dynamic>?)
          ?.map((e) => State.fromJson(e as Map<String, dynamic>))
          .toList(),
      transitions: (json['transitions'] as List<dynamic>?)
          ?.map((e) => Transition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkflowDefinitionToJson(_WorkflowDefinition instance) =>
    <String, dynamic>{
      'default_lease': ?instance.defaultLease,
      'initial': ?instance.initial,
      'states': ?instance.states?.map((e) => e.toJson()).toList(),
      'transitions': ?instance.transitions?.map((e) => e.toJson()).toList(),
    };

_WorkflowInput _$WorkflowInputFromJson(Map<String, dynamic> json) =>
    _WorkflowInput(
      definition: json['definition'] == null
          ? null
          : WorkflowDefinition.fromJson(
              json['definition'] as Map<String, dynamic>,
            ),
      key: json['key'] as String?,
      migrate: (json['migrate'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$WorkflowInputToJson(_WorkflowInput instance) =>
    <String, dynamic>{
      'definition': ?instance.definition?.toJson(),
      'key': ?instance.key,
      'migrate': ?instance.migrate,
      'name': ?instance.name,
    };

_WorkflowTemplate _$WorkflowTemplateFromJson(Map<String, dynamic> json) =>
    _WorkflowTemplate(
      definition: json['definition'] == null
          ? null
          : WorkflowDefinition.fromJson(
              json['definition'] as Map<String, dynamic>,
            ),
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => FieldDefInput.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FieldDefInput>[],
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      states: json['states'] as String? ?? '',
    );

Map<String, dynamic> _$WorkflowTemplateToJson(_WorkflowTemplate instance) =>
    <String, dynamic>{
      'definition': ?instance.definition?.toJson(),
      'fields': instance.fields.map((e) => e.toJson()).toList(),
      'key': instance.key,
      'name': instance.name,
      'purpose': instance.purpose,
      'states': instance.states,
    };
