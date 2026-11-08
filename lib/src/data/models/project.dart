// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

/// A tix project, the container tasks live in.
@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String key,
    @Default('') String name,
    @Default('') String description,
    @Default('') String color,
    @Default('') String icon,
    DateTime? archivedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
