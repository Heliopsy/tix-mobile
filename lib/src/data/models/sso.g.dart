// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'sso.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SsoProviderOption _$SsoProviderOptionFromJson(Map<String, dynamic> json) =>
    _SsoProviderOption(
      key: json['key'] as String,
      displayName: json['display_name'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
    );

Map<String, dynamic> _$SsoProviderOptionToJson(_SsoProviderOption instance) =>
    <String, dynamic>{
      'key': instance.key,
      'display_name': instance.displayName,
      'kind': instance.kind,
    };

_SignInOptions _$SignInOptionsFromJson(Map<String, dynamic> json) =>
    _SignInOptions(
      passwordLogin: json['password_login'] as String? ?? 'allowed',
      providers:
          (json['providers'] as List<dynamic>?)
              ?.map(
                (e) => SsoProviderOption.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <SsoProviderOption>[],
      appSignIn: json['app_sign_in'] as bool? ?? false,
    );

Map<String, dynamic> _$SignInOptionsToJson(_SignInOptions instance) =>
    <String, dynamic>{
      'password_login': instance.passwordLogin,
      'providers': instance.providers.map((e) => e.toJson()).toList(),
      'app_sign_in': instance.appSignIn,
    };

_SsoExchangeInput _$SsoExchangeInputFromJson(Map<String, dynamic> json) =>
    _SsoExchangeInput(
      code: json['code'] as String,
      codeVerifier: json['code_verifier'] as String,
    );

Map<String, dynamic> _$SsoExchangeInputToJson(_SsoExchangeInput instance) =>
    <String, dynamic>{
      'code': instance.code,
      'code_verifier': instance.codeVerifier,
    };
