// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_context.freezed.dart';
part 'server_context.g.dart';

/// A saved server, like a `tix ctx` entry. The token lives in secure storage.
@freezed
abstract class ServerContext with _$ServerContext {
  const factory ServerContext({
    required String id,
    required String name,
    required String baseUrl,
    @Default('') String handle,
  }) = _ServerContext;

  factory ServerContext.fromJson(Map<String, dynamic> json) =>
      _$ServerContextFromJson(json);
}
