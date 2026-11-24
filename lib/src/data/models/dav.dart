// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dav.freezed.dart';
part 'dav.g.dart';

// Written by hand until the vendored OpenAPI document carries `dav.info` and
// `dav.password.*` (tix 0.69.0); `just gen` then produces `DAVInfo`,
// `DAVPassword`, `IssuedDAVPassword` and `CreateDAVPasswordInput`, and these
// go.

/// Which lists an app password shows: tix's `DAVCollections`.
abstract final class DavCollections {
  /// Assigned to me, tix's default.
  static const assigned = 'assigned';

  /// One list per project the person can read.
  static const projects = 'projects';

  /// Both, so a task assigned to the person shows twice.
  static const all = 'all';
}

/// Whether this server answers CalDAV and what other apps are set up with
/// (`GET /api/v1/dav`).
@freezed
abstract class DavInfo with _$DavInfo {
  /// Creates the answer.
  const factory DavInfo({
    @Default(false) bool enabled,
    @Default('') String path,
    @Default('') String url,
    @Default('') String username,
    @Default(false) bool write,
    @Default('') String reason,
    @Default(<String>[]) List<String> collections,
  }) = _DavInfo;

  const DavInfo._();

  /// Reads `dav.info`; a null list reads as none.
  factory DavInfo.fromJson(Map<String, dynamic> json) => _$DavInfoFromJson({
    ...json,
    'collections': json['collections'] ?? <String>[],
  });

  /// The address other apps use: [url], or [path] on [baseUrl] when the
  /// server does not know its own address.
  String addressOn(String baseUrl) {
    if (url.isNotEmpty) return url;
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$base${path.isEmpty ? '/dav/' : path}';
  }
}

/// One of the caller's app passwords, without its secret.
@freezed
abstract class DavPassword with _$DavPassword {
  /// Creates the metadata.
  const factory DavPassword({
    required String id,
    @Default('') String name,
    @Default('') String actorId,
    @Default(DavCollections.assigned) String collections,
    @Default(false) bool readOnly,
    @Default(<String>[]) List<String> scopes,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
  }) = _DavPassword;

  /// Reads a `dav.password.list` item; a null list reads as none.
  factory DavPassword.fromJson(Map<String, dynamic> json) =>
      _$DavPasswordFromJson({...json, 'scopes': json['scopes'] ?? <String>[]});
}

/// An app password as `dav.password.create` issues it: the only answer that
/// carries [password].
@freezed
abstract class IssuedDavPassword with _$IssuedDavPassword {
  /// Creates the answer.
  const factory IssuedDavPassword({
    required String id,
    required String password,
    @Default('') String name,
    @Default('') String username,
    @Default('') String url,
    @Default('') String path,
    @Default(DavCollections.assigned) String collections,
    @Default(false) bool readOnly,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) = _IssuedDavPassword;

  const IssuedDavPassword._();

  /// Reads `dav.password.create`.
  factory IssuedDavPassword.fromJson(Map<String, dynamic> json) =>
      _$IssuedDavPasswordFromJson(json);

  /// The address other apps use, as [DavInfo.addressOn] reads it.
  String addressOn(String baseUrl) =>
      DavInfo(url: url, path: path).addressOn(baseUrl);

  @override
  String toString() => 'IssuedDavPassword($id, $name)';
}

/// The body of `POST /api/v1/dav/passwords`.
@freezed
abstract class CreateDavPasswordInput with _$CreateDavPasswordInput {
  /// Creates the body; null fields are left out, so tix's defaults apply.
  const factory CreateDavPasswordInput({
    required String name,
    String? collections,
    bool? readOnly,
    DateTime? expiresAt,
  }) = _CreateDavPasswordInput;

  /// Reads the body.
  factory CreateDavPasswordInput.fromJson(Map<String, dynamic> json) =>
      _$CreateDavPasswordInputFromJson(json);
}
