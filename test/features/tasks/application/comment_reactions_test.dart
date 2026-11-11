// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late ProviderContainer c;
  final provider = taskCommentsProvider('infra-1');

  setUp(() async {
    server = FakeTix();
    server.comments['infra-1'] = [
      {
        'id': 'c1',
        'body': 'first',
        'author_actor_id': 'a1',
        'reactions': [
          {
            'reaction': 'thumbs_up',
            'emoji': '👍',
            'count': 1,
            'reacted': false,
            'actor_ids': ['a1'],
          },
        ],
      },
    ];
    c = await signedInContainer(server);
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await c.read(provider.future);
  });

  ReactedComment now() => c.read(provider).value!.single;

  test('the listing keeps the reactions', () {
    expect(now().shown.single.reaction, Reaction.thumbsUp);
    expect(now().shown.single.count, 1);
  });

  test('a toggle draws at once and keeps the server answer', () async {
    final done = c
        .read(provider.notifier)
        .toggleReaction('c1', Reaction.thumbsUp);
    expect(now().shown.single.count, 2);
    expect(now().reacted(Reaction.thumbsUp), isTrue);
    await done;
    final put = server.requests.last;
    expect(put.method, 'PUT');
    expect(put.uri.path, '/api/v1/comments/c1/reactions/thumbs_up');
    expect(now().shown.single.actorIds, ['a1', 'me']);
    expect(c.read(reactionCapabilityProvider), ReactionSupport.supported);

    await c.read(provider.notifier).toggleReaction('c1', Reaction.thumbsUp);
    expect(server.requests.last.method, 'DELETE');
    expect(now().shown.single.count, 1);
    expect(now().reacted(Reaction.thumbsUp), isFalse);
  });

  test('a refusal puts the comment back and rethrows', () async {
    server.failures['PUT /api/v1/comments/c1/reactions/rocket'] = FakeResponse(
      403,
      envelope('forbidden', 'not allowed'),
    );
    final done = c
        .read(provider.notifier)
        .toggleReaction('c1', Reaction.rocket);
    expect(now().shown.map((r) => r.reaction), [
      Reaction.thumbsUp,
      Reaction.rocket,
    ]);
    await expectLater(
      done,
      throwsA(isA<TixException>().having((e) => e.status, 'status', 403)),
    );
    expect(now().shown.map((r) => r.reaction), [Reaction.thumbsUp]);
    expect(c.read(reactionCapabilityProvider), ReactionSupport.unknown);
  });

  test('a missing comment is an ordinary error', () async {
    server.failures['PUT /api/v1/comments/c1/reactions/eyes'] = FakeResponse(
      404,
      envelope('not_found', 'comment "c1"'),
    );
    await expectLater(
      c.read(provider.notifier).toggleReaction('c1', Reaction.eyes),
      throwsA(isA<TixException>()),
    );
    expect(c.read(reactionCapabilityProvider), ReactionSupport.unknown);
  });

  test('an older server is remembered as without reactions', () async {
    server.reactionsSupported = false;
    await expectLater(
      c.read(provider.notifier).toggleReaction('c1', Reaction.heart),
      throwsA(isA<ReactionsUnsupported>()),
    );
    expect(now().shown.map((r) => r.reaction), [Reaction.thumbsUp]);
    expect(c.read(reactionCapabilityProvider), ReactionSupport.unsupported);
  });

  test('405 counts as a missing route too', () async {
    server.failures['DELETE /api/v1/comments/c1/reactions/thumbs_up'] =
        FakeResponse(405, envelope('invalid', 'method not allowed'));
    await c.read(provider.notifier).toggleReaction('c1', Reaction.thumbsUp);
    await expectLater(
      c.read(provider.notifier).toggleReaction('c1', Reaction.thumbsUp),
      throwsA(isA<ReactionsUnsupported>()),
    );
    expect(now().reacted(Reaction.thumbsUp), isTrue);
  });

  group('offerReactions', () {
    const bare = ReactedComment(Comment(id: 'x'));
    const reacted = ReactedComment(Comment(id: 'y'), reactions: []);

    test('offers until refused', () {
      expect(offerReactions(ReactionSupport.unknown, [bare]), isTrue);
      expect(offerReactions(ReactionSupport.supported, [bare]), isTrue);
      expect(offerReactions(ReactionSupport.unsupported, [bare]), isFalse);
    });

    test('a comment carrying reactions proves support', () {
      expect(
        offerReactions(ReactionSupport.unsupported, [bare, reacted]),
        isTrue,
      );
    });
  });

  test('reaction events refresh the thread', () {
    expect(
      EventTopics.comments,
      containsAll(['comment.added', 'comment.reacted', 'comment.unreacted']),
    );
  });
}
