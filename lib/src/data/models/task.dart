// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// A tix task, the central record.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String ref,
    required String title,
    @Default('') String status,
    @Default('') String body,
    @Default(0) int priority,
    @Default('') String projectId,
    @Default('') String assigneeActorId,
    @Default(<String>[]) List<String> tags,
    @Default(false) bool blocked,
    @Default(false) bool starred,
    @Default(0) int version,
    DateTime? dueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

/// The body of `POST /tasks`, sent as a quick-add line when [parse] is true.
@freezed
abstract class CreateTaskRequest with _$CreateTaskRequest {
  const factory CreateTaskRequest({
    required String title,
    String? projectRef,
    @Default(false) bool parse,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);
}
