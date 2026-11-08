// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'server_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServerContext _$ServerContextFromJson(Map<String, dynamic> json) =>
    _ServerContext(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['base_url'] as String,
      handle: json['handle'] as String? ?? '',
    );

Map<String, dynamic> _$ServerContextToJson(_ServerContext instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'base_url': instance.baseUrl,
      'handle': instance.handle,
    };
