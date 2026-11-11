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
  const up = '%F0%9F%91%8D';

  setUp(() async {
    server = FakeTix();
    server.comments['infra-1'] = [
      {
        'id': 'c1',
        'body': 'first',
        'author_actor_id': 'a1',
        'reactions': [
          {
            'emoji': '👍',
            'count': 1,
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

  Comment now() => c.read(provider).value!.single;

  List<String> emoji() => [for (final r in now().reactions) r.emoji];

  test('the listing keeps the reactions', () {
    expect(now().reactions.single.emoji, '👍');
    expect(now().reactions.single.count, 1);
    expect(now().reactedBy('👍', 'a1'), isTrue);
    expect(now().reactedBy('👍', 'me'), isFalse);
  });

  test('a toggle draws at once, sends the emoji encoded and keeps the '
      'answer', () async {
    final done = c.read(provider.notifier).toggleReaction('c1', '👍', me: 'me');
    expect(now().reactions.single.count, 2);
    expect(now().reactedBy('👍', 'me'), isTrue);
    await done;
    final put = server.requests.last;
    expect(put.method, 'PUT');
    expect(put.uri.path, '/api/v1/comments/c1/reactions/$up');
    expect(now().reactions.single.actorIds, ['a1', 'me']);
    expect(c.read(reactionCapabilityProvider), ReactionSupport.supported);

    await c.read(provider.notifier).toggleReaction('c1', '👍', me: 'me');
    expect(server.requests.last.method, 'DELETE');
    expect(now().reactions.single.count, 1);
    expect(now().reactedBy('👍', 'me'), isFalse);
  });

  test('a refusal puts the comment back and rethrows', () async {
    server.failures['PUT /api/v1/comments/c1/reactions/%F0%9F%9A%80'] =
        FakeResponse(403, envelope('forbidden', 'not allowed'));
    final done = c.read(provider.notifier).toggleReaction('c1', '🚀', me: 'me');
    expect(emoji(), ['👍', '🚀']);
    await expectLater(
      done,
      throwsA(isA<TixException>().having((e) => e.status, 'status', 403)),
    );
    expect(emoji(), ['👍']);
    expect(c.read(reactionCapabilityProvider), ReactionSupport.unknown);
  });

  test('a missing comment is an ordinary error', () async {
    server.failures['PUT /api/v1/comments/c1/reactions/%F0%9F%91%80'] =
        FakeResponse(404, envelope('not_found', 'comment "c1"'));
    await expectLater(
      c.read(provider.notifier).toggleReaction('c1', '👀', me: 'me'),
      throwsA(isA<TixException>()),
    );
    expect(c.read(reactionCapabilityProvider), ReactionSupport.unknown);
  });

  test('an older server is remembered as without reactions', () async {
    server.reactionsSupported = false;
    await expectLater(
      c.read(provider.notifier).toggleReaction('c1', '❤️', me: 'me'),
      throwsA(isA<ReactionsUnsupported>()),
    );
    expect(emoji(), ['👍']);
    expect(c.read(reactionCapabilityProvider), ReactionSupport.unsupported);
  });

  test('405 counts as a missing route too', () async {
    server.failures['DELETE /api/v1/comments/c1/reactions/$up'] = FakeResponse(
      405,
      envelope('invalid', 'method not allowed'),
    );
    await c.read(provider.notifier).toggleReaction('c1', '👍', me: 'me');
    await expectLater(
      c.read(provider.notifier).toggleReaction('c1', '👍', me: 'me'),
      throwsA(isA<ReactionsUnsupported>()),
    );
    expect(now().reactedBy('👍', 'me'), isTrue);
  });

  group('offerReactions', () {
    const bare = Comment(id: 'x');
    const reacted = Comment(
      id: 'y',
      reactions: [
        Reaction(emoji: '👍', count: 1, actorIds: ['a1']),
      ],
    );

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
