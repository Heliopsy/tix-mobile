// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'dav.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DavInfo _$DavInfoFromJson(Map<String, dynamic> json) => _DavInfo(
  enabled: json['enabled'] as bool? ?? false,
  path: json['path'] as String? ?? '',
  url: json['url'] as String? ?? '',
  username: json['username'] as String? ?? '',
  write: json['write'] as bool? ?? false,
  reason: json['reason'] as String? ?? '',
  collections:
      (json['collections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$DavInfoToJson(_DavInfo instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'path': instance.path,
  'url': instance.url,
  'username': instance.username,
  'write': instance.write,
  'reason': instance.reason,
  'collections': instance.collections,
};

_DavPassword _$DavPasswordFromJson(Map<String, dynamic> json) => _DavPassword(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  actorId: json['actor_id'] as String? ?? '',
  collections: json['collections'] as String? ?? DavCollections.assigned,
  readOnly: json['read_only'] as bool? ?? false,
  scopes:
      (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  lastUsedAt: json['last_used_at'] == null
      ? null
      : DateTime.parse(json['last_used_at'] as String),
  revokedAt: json['revoked_at'] == null
      ? null
      : DateTime.parse(json['revoked_at'] as String),
);

Map<String, dynamic> _$DavPasswordToJson(_DavPassword instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'actor_id': instance.actorId,
      'collections': instance.collections,
      'read_only': instance.readOnly,
      'scopes': instance.scopes,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'expires_at': ?instance.expiresAt?.toIso8601String(),
      'last_used_at': ?instance.lastUsedAt?.toIso8601String(),
      'revoked_at': ?instance.revokedAt?.toIso8601String(),
    };

_IssuedDavPassword _$IssuedDavPasswordFromJson(Map<String, dynamic> json) =>
    _IssuedDavPassword(
      id: json['id'] as String,
      password: json['password'] as String,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      url: json['url'] as String? ?? '',
      path: json['path'] as String? ?? '',
      collections: json['collections'] as String? ?? DavCollections.assigned,
      readOnly: json['read_only'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$IssuedDavPasswordToJson(_IssuedDavPassword instance) =>
    <String, dynamic>{
      'id': instance.id,
      'password': instance.password,
      'name': instance.name,
      'username': instance.username,
      'url': instance.url,
      'path': instance.path,
      'collections': instance.collections,
      'read_only': instance.readOnly,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'expires_at': ?instance.expiresAt?.toIso8601String(),
    };

_CreateDavPasswordInput _$CreateDavPasswordInputFromJson(
  Map<String, dynamic> json,
) => _CreateDavPasswordInput(
  name: json['name'] as String,
  collections: json['collections'] as String?,
  readOnly: json['read_only'] as bool?,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$CreateDavPasswordInputToJson(
  _CreateDavPasswordInput instance,
) => <String, dynamic>{
  'name': instance.name,
  'collections': ?instance.collections,
  'read_only': ?instance.readOnly,
  'expires_at': ?instance.expiresAt?.toIso8601String(),
};
