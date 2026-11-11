// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/reaction.dart';

void main() {
  Map<String, dynamic> comment([Object? reactions]) => {
    'id': 'c1',
    'body': 'hello',
    'author_actor_id': 'a1',
    'reactions': ?reactions,
  };

  group('ReactedComment.fromJson', () {
    test('an absent field reads as null', () {
      final c = ReactedComment.fromJson(comment());
      expect(c.comment.body, 'hello');
      expect(c.reactions, isNull);
      expect(c.shown, isEmpty);
    });

    test('reads each summary, by name', () {
      final c = ReactedComment.fromJson(
        comment([
          {
            'reaction': 'thumbs_up',
            'emoji': '👍',
            'count': 2,
            'reacted': true,
            'actor_ids': ['me', 'a1'],
          },
          {'reaction': 'rocket', 'emoji': '🚀', 'count': 1, 'actor_ids': null},
        ]),
      );
      expect(c.reactions!.map((r) => r.reaction), [
        Reaction.thumbsUp,
        Reaction.rocket,
      ]);
      expect(c.reactions!.first.actorIds, ['me', 'a1']);
      expect(c.reactions!.last.reacted, isFalse);
      expect(c.reactions!.last.actorIds, isEmpty);
      expect(c.reacted(Reaction.thumbsUp), isTrue);
      expect(c.reacted(Reaction.rocket), isFalse);
    });

    test('drops a reaction it does not know and a zero count', () {
      final c = ReactedComment.fromJson(
        comment([
          {'reaction': 'party_parrot', 'emoji': '🦜', 'count': 3},
          {'reaction': 'eyes', 'emoji': '👀', 'count': 0},
        ]),
      );
      expect(c.reactions, isEmpty);
    });

    test('round-trips through toJson, as the cache keeps it', () {
      final json = comment([
        {
          'reaction': 'heart',
          'emoji': '❤️',
          'count': 1,
          'reacted': true,
          'actor_ids': ['me'],
        },
      ]);
      final c = ReactedComment.fromJson(json);
      expect(ReactedComment.fromJson(c.toJson()), c);
      expect(c.toJson()['reactions'], isA<List<Object?>>());
      expect(
        ReactedComment.fromJson(comment()).toJson().containsKey('reactions'),
        isFalse,
      );
    });
  });

  group('toggled', () {
    final base = ReactedComment.fromJson(
      comment([
        {
          'reaction': 'thumbs_up',
          'emoji': '👍',
          'count': 2,
          'reacted': false,
          'actor_ids': ['a1', 'a2'],
        },
        {
          'reaction': 'eyes',
          'emoji': '👀',
          'count': 1,
          'reacted': true,
          'actor_ids': ['me'],
        },
      ]),
    );

    test('adding counts the reader in, in tix order', () {
      final c = base.toggled(Reaction.hooray, add: true, actorId: 'me');
      expect(c.shown.map((r) => r.reaction), [
        Reaction.thumbsUp,
        Reaction.hooray,
        Reaction.eyes,
      ]);
      final h = c.shown[1];
      expect((h.count, h.reacted, h.emoji), (1, true, '🎉'));
      expect(h.actorIds, ['me']);
    });

    test('adding to an existing one bumps its count', () {
      final c = base.toggled(Reaction.thumbsUp, add: true, actorId: 'me');
      expect(c.shown.first.count, 3);
      expect(c.shown.first.actorIds, ['a1', 'a2', 'me']);
    });

    test('removing the last one drops the chip', () {
      final c = base.toggled(Reaction.eyes, add: false, actorId: 'me');
      expect(c.shown.map((r) => r.reaction), [Reaction.thumbsUp]);
    });

    test('a toggle that changes nothing returns the same comment', () {
      expect(base.toggled(Reaction.eyes, add: true), same(base));
      expect(base.toggled(Reaction.rocket, add: false), same(base));
    });
  });
}
