// SPDX-License-Identifier: AGPL-3.0-or-later

/// Reactions on comments, written by hand until `tix.lock` pins a tix release
/// whose OpenAPI document describes them (`ReactionSummary`, `Reaction`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Comment;

part 'reaction.freezed.dart';
part 'reaction.g.dart';

/// tix's fixed set of reactions, in the order it lists them.
@JsonEnum(valueField: 'wire')
enum Reaction {
  /// 👍
  thumbsUp('thumbs_up', '👍'),

  /// 👎
  thumbsDown('thumbs_down', '👎'),

  /// 😄
  laugh('laugh', '😄'),

  /// 🎉
  hooray('hooray', '🎉'),

  /// 😕
  confused('confused', '😕'),

  /// ❤️
  heart('heart', '❤️'),

  /// 🚀
  rocket('rocket', '🚀'),

  /// 👀
  eyes('eyes', '👀');

  Reaction(this.wire, this.emoji);

  /// The name on the wire and in the path.
  final String wire;

  /// The glyph.
  final String emoji;
}

/// One reaction on a comment and who made it.
@freezed
abstract class ReactionSummary with _$ReactionSummary {
  /// Creates a summary of [reaction].
  const factory ReactionSummary({
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    Reaction? reaction,
    @Default('') String emoji,
    @Default(0) int count,
    @Default(false) bool reacted,
    @Default(<String>[]) List<String> actorIds,
  }) = _ReactionSummary;

  /// Reads a summary object.
  factory ReactionSummary.fromJson(Map<String, dynamic> json) =>
      _$ReactionSummaryFromJson(json);
}

/// A comment with its reactions.
@immutable
class ReactedComment {
  /// [comment] with [reactions], null when the server sent none.
  const ReactedComment(this.comment, {this.reactions});

  /// Reads a comment object, keeping its `reactions` field.
  factory ReactedComment.fromJson(Map<String, dynamic> json) {
    final raw = json['reactions'];
    return ReactedComment(
      Comment.fromJson(json),
      reactions: raw is List<Object?>
          ? [
              for (final r in raw)
                if (r is Map<String, dynamic>) ReactionSummary.fromJson(r),
            ].where((r) => r.reaction != null && r.count > 0).toList()
          : null,
    );
  }

  /// The comment.
  final Comment comment;

  /// The reactions with a count, in tix's order; null when the field was
  /// absent, which an older server and a comment nobody reacted to share.
  final List<ReactionSummary>? reactions;

  /// The comment's id.
  String get id => comment.id;

  /// The reactions to draw, empty when there are none.
  List<ReactionSummary> get shown => reactions ?? const [];

  /// Whether the reader has made [reaction].
  bool reacted(Reaction reaction) =>
      shown.any((r) => r.reaction == reaction && r.reacted);

  /// The comment as tix writes it.
  Map<String, Object?> toJson() => {
    ...comment.toJson(),
    if (reactions case final r?) 'reactions': [for (final s in r) s.toJson()],
  };

  /// This comment with the reader's [reaction] added, or removed when
  /// [add] is false, the way the server would answer. [actorId] is the
  /// reader's, when known.
  ReactedComment toggled(
    Reaction reaction, {
    required bool add,
    String? actorId,
  }) {
    final byReaction = {for (final r in shown) r.reaction: r};
    final was = byReaction[reaction];
    if ((was?.reacted ?? false) == add) return this;
    final ids = [...?was?.actorIds];
    if (actorId != null) {
      ids.remove(actorId);
      if (add) ids.add(actorId);
    }
    byReaction[reaction] = ReactionSummary(
      reaction: reaction,
      emoji: reaction.emoji,
      count: (was?.count ?? 0) + (add ? 1 : -1),
      reacted: add,
      actorIds: ids,
    );
    return ReactedComment(
      comment,
      reactions: [
        for (final r in Reaction.values)
          if (byReaction[r] case final s? when s.count > 0) s,
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReactedComment &&
      other.comment == comment &&
      const DeepCollectionEquality().equals(other.reactions, reactions);

  @override
  int get hashCode =>
      Object.hash(comment, const DeepCollectionEquality().hash(reactions));
}
