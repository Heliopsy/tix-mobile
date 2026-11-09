// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'outbox_entry.freezed.dart';
part 'outbox_entry.g.dart';

/// What a queued write does.
enum OutboxOp {
  /// `PATCH /tasks/{ref}` with some of the task's attributes.
  update,

  /// Ticks or clears one checklist item (`task.check`).
  check,

  /// Moves the task by its workflow's route (`task.route`).
  move,

  /// Stars the task for the reader.
  star,

  /// Takes the reader's star off.
  unstar,

  /// Snoozes the task, or wakes it when `until` is absent.
  snooze,

  /// Creates a task (quick add, a subtask).
  create,

  /// Adds a comment.
  comment,

  /// Puts a tag on the task.
  tagAdd,

  /// Takes a tag off the task.
  tagRemove,

  /// Records that the task waits for another.
  dependencyAdd,

  /// Attaches an artifact.
  artifactAdd,

  /// Brings the task back from the trash before the writes after it.
  restore;

  /// Whether the write only adds and so never conflicts with someone
  /// else's change: two people commenting, tagging or starring both win.
  bool get additive => switch (this) {
    comment || tagAdd || tagRemove || star || unstar => true,
    dependencyAdd || artifactAdd => true,
    _ => false,
  };
}

/// Where a queued write stands.
enum OutboxState {
  /// Waiting for the server.
  pending,

  /// The server refused it (403, 422, 400): the reason is kept, and the
  /// person edits or discards it.
  failed,

  /// Waiting for the person: the same attribute changed on the server, the
  /// task is gone, or the move is no longer allowed.
  conflict,

  /// A create whose answer was lost on a server that cannot say whether it
  /// already happened: it is looked up before it is sent again, and the
  /// person decides when that is not clear.
  needsCheck,
}

/// One write made while the server could not be reached, kept until it is
/// sent.
@freezed
abstract class OutboxEntry with _$OutboxEntry {
  /// Creates an entry.
  const factory OutboxEntry({
    /// A client id, unique on this device.
    required String id,

    /// The order writes were made in; replay keeps it per task.
    required int seq,
    required OutboxOp op,

    /// The task written to: its reference, or a draft's `key-draftN`.
    required String target,

    /// Sent as `Idempotency-Key`, so a retry after a lost answer is not
    /// applied twice.
    required String idempotencyKey,
    required DateTime createdAt,

    /// The task's version when the person made the change.
    int? baseVersion,

    /// The task as the person saw it, as tix's JSON.
    @Default(<String, Object?>{}) Map<String, Object?> base,

    /// What is sent: the changed attributes, a comment's body, a tag's name.
    @Default(<String, Object?>{}) Map<String, Object?> values,

    @Default(OutboxState.pending) OutboxState state,

    /// The server's error code and message for a refused or conflicting
    /// write.
    @Default('') String errorCode,
    @Default('') String errorMessage,

    /// For a create, the draft reference the app showed until it is sent.
    @Default('') String draftRef,
    @Default(0) int attempts,

    /// When a send under [idempotencyKey] first may have reached the server
    /// (it timed out or its answer was unreadable), null while none did.
    /// tix forgets a key a day after it first sees it.
    DateTime? firstSentAt,
  }) = _OutboxEntry;

  /// Reads a stored entry.
  factory OutboxEntry.fromJson(Map<String, dynamic> json) =>
      _$OutboxEntryFromJson(json);
}

/// How a conflict is settled when it is found during replay.
enum ConflictPolicy {
  /// Keep the write waiting and ask.
  ask,

  /// Send the person's value over the server's.
  keepMine,

  /// Keep the server's value and drop the person's.
  keepTheirs,
}

/// Why a write could not simply be sent.
enum ConflictKind {
  /// Someone changed the same attributes on the server.
  fields,

  /// The task was deleted on the server.
  deleted,

  /// The workflow no longer allows the move.
  invalidMove,
}

/// How a conflict ended.
enum Resolution {
  /// The person's values were sent.
  mine,

  /// The server's values were kept.
  theirs,

  /// The person wrote other values.
  edited,

  /// A deleted task was restored and the write applied.
  restored,

  /// The write was dropped.
  discarded,
}

/// One attribute both sides changed.
@freezed
abstract class FieldConflict with _$FieldConflict {
  /// Creates a field conflict.
  const factory FieldConflict({
    /// The attribute, as its JSON key; a custom field is `custom_fields.key`.
    required String field,
    Object? base,
    Object? mine,
    Object? theirs,
  }) = _FieldConflict;

  /// Reads a stored field conflict.
  factory FieldConflict.fromJson(Map<String, dynamic> json) =>
      _$FieldConflictFromJson(json);
}

/// A conflict found during replay, open or settled. Settled ones stay in
/// the history so they can be reviewed and reversed.
@freezed
abstract class ConflictRecord with _$ConflictRecord {
  /// Creates a record.
  const factory ConflictRecord({
    required String id,

    /// The write it came from, while that write waits.
    required String entryId,
    required String taskRef,
    required ConflictKind kind,
    required DateTime createdAt,
    @Default('') String taskTitle,
    @Default(<FieldConflict>[]) List<FieldConflict> fields,

    /// The server's reason, for a refused move.
    @Default('') String reason,

    /// The status the person moved to, for a refused move.
    @Default('') String wanted,

    /// The task's version on the server when it was found.
    int? theirsVersion,
    Resolution? resolution,

    /// Whether the policy settled it rather than the person.
    @Default(false) bool auto,
    DateTime? resolvedAt,
  }) = _ConflictRecord;

  /// Reads a stored record.
  factory ConflictRecord.fromJson(Map<String, dynamic> json) =>
      _$ConflictRecordFromJson(json);
}

/// Everything waiting to sync for one context.
@freezed
abstract class SyncSnapshot with _$SyncSnapshot {
  /// Creates a snapshot.
  const factory SyncSnapshot({
    @Default(<OutboxEntry>[]) List<OutboxEntry> entries,
    @Default(<ConflictRecord>[]) List<ConflictRecord> conflicts,

    /// Each sent draft's real reference, so links to a draft still work.
    @Default(<String, String>{}) Map<String, String> drafts,

    /// The next draft number.
    @Default(1) int nextDraft,

    /// The next write's order.
    @Default(1) int nextSeq,

    /// Whether the server honours `Idempotency-Key`, null until known.
    bool? idempotency,
  }) = _SyncSnapshot;

  /// Reads a stored snapshot.
  factory SyncSnapshot.fromJson(Map<String, dynamic> json) =>
      _$SyncSnapshotFromJson(json);
}
