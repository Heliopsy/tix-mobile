// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late ProviderContainer c;
  final provider = taskCommentsProvider('infra-1');
  const up = '%F0%9F%91%8D';
  const rocket = '%F0%9F%9A%80';
  const eyes = '%F0%9F%91%80';

  setUp(() async {
    server = FakeTix();
    server.comments['infra-1'] = [
      {
        'id': 'c1',
        'task_id': 'id-infra-1',
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

  List<String> reactionCalls() => [
    for (final r in server.requests)
      if (r.uri.path.contains('/reactions/'))
        '${r.method} ${r.uri.path.split('/').last}',
  ];

  Future<void> toggle(String emoji) =>
      c.read(provider.notifier).toggleReaction('c1', emoji, me: 'me');

  test('a toggle draws at once and keeps the answer', () async {
    final gate = server.gate = Completer<void>();
    final done = toggle('👍');
    expect(now().reactions.single.count, 2);
    expect(now().reactedBy('👍', 'me'), isTrue);
    gate.complete();
    server.gate = null;
    await done;
    expect(reactionCalls(), ['PUT $up']);
    expect(now().reactions.single.actorIds, ['a1', 'me']);

    await toggle('👍');
    expect(reactionCalls().last, 'DELETE $up');
    expect(now().reactedBy('👍', 'me'), isFalse);
  });

  test('a refusal puts the chip back and rethrows', () async {
    server.failures['PUT /api/v1/comments/c1/reactions/$rocket'] = FakeResponse(
      403,
      envelope('forbidden', 'not allowed'),
    );
    final done = toggle('🚀');
    expect(emoji(), ['👍', '🚀']);
    await expectLater(
      done,
      throwsA(isA<TixException>().having((e) => e.status, 'status', 403)),
    );
    expect(emoji(), ['👍']);
    expect(c.read(reactionSupportProvider), isTrue);
  });

  test('a 404 for the comment keeps reactions on and reloads', () async {
    server.failures['PUT /api/v1/comments/c1/reactions/$eyes'] = FakeResponse(
      404,
      envelope('not_found', 'comment "c1" not found'),
    );
    final reads = server.requestsTo('/api/v1/tasks/infra-1/comments').length;
    await expectLater(
      toggle('👀'),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.notFound,
        ),
      ),
    );
    expect(c.read(reactionSupportProvider), isTrue);
    await c.read(provider.future);
    expect(
      server.requestsTo('/api/v1/tasks/infra-1/comments').length,
      greaterThan(reads),
    );
    expect(emoji(), ['👍']);
  });

  test('404 no such route means a server without reactions', () async {
    server.reactionsMissing = true;
    await expectLater(toggle('❤️'), throwsA(isA<ReactionsUnsupported>()));
    expect(emoji(), ['👍']);
    expect(c.read(reactionSupportProvider), isFalse);
  });

  test('a 404 without a tix error means a missing route too', () async {
    server.failures['PUT /api/v1/comments/c1/reactions/$rocket'] =
        const FakeResponse(404, '404 page not found', 'text/plain');
    await expectLater(toggle('🚀'), throwsA(isA<ReactionsUnsupported>()));
    expect(c.read(reactionSupportProvider), isFalse);
  });

  test('405 means a missing route too', () async {
    server.failures['PUT /api/v1/comments/c1/reactions/$rocket'] = FakeResponse(
      405,
      envelope('invalid', 'method not allowed'),
    );
    await expectLater(toggle('🚀'), throwsA(isA<ReactionsUnsupported>()));
    expect(c.read(reactionSupportProvider), isFalse);
  });

  test('toggles on a comment go out one at a time, in order', () async {
    final gate = server.gate = Completer<void>();
    final first = toggle('🚀');
    final second = toggle('👀');
    expect(emoji(), ['👍', '🚀', '👀']);
    await pumpEventQueue();
    expect(reactionCalls(), ['PUT $rocket']);
    gate.complete();
    server.gate = null;
    await Future.wait([first, second]);
    expect(reactionCalls(), ['PUT $rocket', 'PUT $eyes']);
    expect(emoji(), ['👍', '🚀', '👀']);
  });

  test('a second tap on a pending chip is ignored', () async {
    final gate = server.gate = Completer<void>();
    final first = c
        .read(provider.notifier)
        .toggleReaction('c1', '🚀', me: 'me');
    final again = c
        .read(provider.notifier)
        .toggleReaction('c1', '🚀', me: 'me');
    expect(await again, isFalse);
    gate.complete();
    server.gate = null;
    expect(await first, isTrue);
    expect(reactionCalls(), ['PUT $rocket']);
    expect(now().reactedBy('🚀', 'me'), isTrue);
  });

  group('withReaction', () {
    const comment = Comment(
      id: 'x',
      reactions: [
        Reaction(emoji: '👍', count: 1, actorIds: ['me']),
        Reaction(emoji: '🎉', count: 1, actorIds: ['a1']),
      ],
    );

    List<String> order(Comment c) => [for (final r in c.reactions) r.emoji];

    test('a new emoji goes last', () {
      expect(order(comment.withReaction('🚀', add: true, me: 'me')), [
        '👍',
        '🎉',
        '🚀',
      ]);
    });

    test('an emoji nobody reacts with any more goes', () {
      expect(order(comment.withReaction('👍', add: false, me: 'me')), ['🎉']);
    });

    test('joining keeps the place and counts the reader', () {
      final joined = comment.withReaction('🎉', add: true, me: 'me');
      expect(order(joined), ['👍', '🎉']);
      expect(joined.reactions.last.count, 2);
      expect(joined.reactedBy('🎉', 'me'), isTrue);
    });
  });
}
