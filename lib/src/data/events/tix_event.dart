// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/json.dart';

part 'tix_event.freezed.dart';
part 'tix_event.g.dart';

/// One entry of tix's event log, as `GET /api/v1/events` delivers it.
///
/// The OpenAPI document does not describe the WebSocket messages, so this is
/// written from tix's docs/api.md ("The event stream").
@freezed
abstract class TixEvent with _$TixEvent {
  /// Creates an event.
  const factory TixEvent({
    /// The per-tenant sequence number, monotonic: the resume cursor.
    required int seq,
    required String type,
    @Default('') String id,
    @Default('') String tenantId,
    @Default('') String projectId,
    @Default('') String subjectType,
    @Default('') String subjectId,
    @Default('') String actorId,
    @Default(<String, Object?>{}) Map<String, Object?> payload,
    Via? via,
    @TixDateTime() DateTime? occurredAt,
  }) = _TixEvent;

  /// Reads an event object.
  factory TixEvent.fromJson(Map<String, dynamic> json) =>
      _$TixEventFromJson(json);
}

/// tix's closed vocabulary of event types. A subscription pattern outside it
/// is refused by the server.
abstract final class TixEventTypes {
  /// Every type tix sends.
  static const all = [
    'task.created',
    'task.updated',
    'task.transitioned',
    'task.claimed',
    'task.released',
    'task.lease_expired',
    'task.reclaimed',
    'task.deleted',
    'task.starred',
    'task.unstarred',
    'task.snoozed',
    'task.unsnoozed',
    'task.woke',
    'comment.added',
    'artifact.added',
    'dependency.added',
    'tag.added',
    'project.created',
    'project.updated',
    'workflow.updated',
    'field.updated',
    'webhook.delivered',
    'import.completed',
    'view.arranged',
    'filter.saved',
    'filter.updated',
    'filter.deleted',
    'inbox.updated',
    'template.updated',
    'webhook.ping',
  ];

  /// Whether [type] matches [pattern], a glob where `*` is any run of
  /// characters, as the server matches a subscription filter.
  static bool matches(String pattern, String type) {
    final re = RegExp('^${pattern.split('*').map(RegExp.escape).join('.*')}\$');
    return re.hasMatch(type);
  }
}
