// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'instance.freezed.dart';
part 'instance.g.dart';

/// Where an instance runs.
enum InstanceKind {
  /// A tix server at an address.
  remote,

  /// A database file on this device, served by the embedded engine.
  local,
}

/// A tix server the app knows about.
@freezed
abstract class Instance with _$Instance {
  const factory Instance({
    required String id,
    required String name,
    required InstanceKind kind,
    required DateTime createdAt,
    @Default('') String baseUrl,
    @Default('') String dbPath,
    DateTime? lastUsedAt,
  }) = _Instance;

  const Instance._();

  factory Instance.fromJson(Map<String, dynamic> json) =>
      _$InstanceFromJson(json);

  /// The address or path a person recognises this instance by.
  String get location => kind == InstanceKind.remote ? baseUrl : dbPath;

  /// The host of a remote instance, empty for a local one.
  String get host =>
      kind == InstanceKind.remote ? Uri.tryParse(baseUrl)?.host ?? '' : '';
}
