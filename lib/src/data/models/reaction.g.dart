// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReactionSummary _$ReactionSummaryFromJson(Map<String, dynamic> json) =>
    _ReactionSummary(
      reaction: $enumDecodeNullable(
        _$ReactionEnumMap,
        json['reaction'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      emoji: json['emoji'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      reacted: json['reacted'] as bool? ?? false,
      actorIds:
          (json['actor_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$ReactionSummaryToJson(_ReactionSummary instance) =>
    <String, dynamic>{
      'reaction': ?_$ReactionEnumMap[instance.reaction],
      'emoji': instance.emoji,
      'count': instance.count,
      'reacted': instance.reacted,
      'actor_ids': instance.actorIds,
    };

const _$ReactionEnumMap = {
  Reaction.thumbsUp: 'thumbs_up',
  Reaction.thumbsDown: 'thumbs_down',
  Reaction.laugh: 'laugh',
  Reaction.hooray: 'hooray',
  Reaction.confused: 'confused',
  Reaction.heart: 'heart',
  Reaction.rocket: 'rocket',
  Reaction.eyes: 'eyes',
};
