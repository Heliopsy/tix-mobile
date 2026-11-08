// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  token: json['token'] as String,
  actorId: json['actor_id'] as String? ?? '',
  tenantId: json['tenant_id'] as String? ?? '',
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'token': instance.token,
      'actor_id': instance.actorId,
      'tenant_id': instance.tenantId,
      'expires_at': ?instance.expiresAt?.toIso8601String(),
    };

_AuthChallenge _$AuthChallengeFromJson(Map<String, dynamic> json) =>
    _AuthChallenge(
      kind: json['kind'] as String,
      ticket: json['ticket'] as String? ?? '',
    );

Map<String, dynamic> _$AuthChallengeToJson(_AuthChallenge instance) =>
    <String, dynamic>{'kind': instance.kind, 'ticket': instance.ticket};

_LoginResult _$LoginResultFromJson(Map<String, dynamic> json) => _LoginResult(
  session: json['session'] == null
      ? null
      : AuthSession.fromJson(json['session'] as Map<String, dynamic>),
  challenge: json['challenge'] == null
      ? null
      : AuthChallenge.fromJson(json['challenge'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginResultToJson(_LoginResult instance) =>
    <String, dynamic>{
      'session': ?instance.session?.toJson(),
      'challenge': ?instance.challenge?.toJson(),
    };

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      email: json['email'] as String?,
      password: json['password'] as String?,
      ticket: json['ticket'] as String?,
      code: json['code'] as String?,
      surface: json['surface'] as String? ?? 'cli',
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'email': ?instance.email,
      'password': ?instance.password,
      'ticket': ?instance.ticket,
      'code': ?instance.code,
      'surface': instance.surface,
    };
