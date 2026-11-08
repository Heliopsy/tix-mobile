// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

/// A session tix minted for a sign-in or a switch.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String token,
    @Default('') String actorId,
    @Default('') String tenantId,
    DateTime? expiresAt,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}

/// What a sign-in still needs: a `code`, an `enrol`ment or a
/// `password_change`.
@freezed
abstract class AuthChallenge with _$AuthChallenge {
  const factory AuthChallenge({
    required String kind,
    @Default('') String ticket,
  }) = _AuthChallenge;

  factory AuthChallenge.fromJson(Map<String, dynamic> json) =>
      _$AuthChallengeFromJson(json);
}

/// The answer of `POST /auth/login` and `POST /auth/switch`.
@freezed
abstract class LoginResult with _$LoginResult {
  const factory LoginResult({AuthSession? session, AuthChallenge? challenge}) =
      _LoginResult;

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);
}

/// One step of `POST /auth/login`.
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    String? email,
    String? password,
    String? ticket,
    String? code,
    @Default('cli') String surface,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
