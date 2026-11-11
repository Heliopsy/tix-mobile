// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  const up = '%F0%9F%91%8D';
  const hooray = '%F0%9F%8E%89';

  setUp(() {
    server = FakeTix();
    server.comments['infra-1'] = [
      {
        'id': 'c1',
        'task_id': 'id-infra-1',
        'author_actor_id': 'a1',
        'body': 'Deployed.',
        'created_at': '2026-10-30T09:00:00Z',
        'updated_at': '2026-10-30T09:00:00Z',
        'reactions': [
          {
            'emoji': '👍',
            'count': 2,
            'actor_ids': ['a1', 'me'],
          },
          {
            'emoji': '🚀',
            'count': 1,
            'actor_ids': ['a1'],
          },
        ],
      },
    ];
  });

  Finder chip(String emoji) => find.byKey(Key('comment.c1.reaction.$emoji'));

  ReactionChip chipOf(WidgetTester tester, String emoji) =>
      tester.widget<ReactionChip>(chip(emoji));

  Finder picker() => find.byKey(const Key('reaction.picker'));

  testWidgets("chips show emoji and count, the reader's highlighted", (
    tester,
  ) async {
    await pumpTask(tester, server);
    final mine = chipOf(tester, '👍');
    expect((mine.emoji, mine.count, mine.mine), ('👍', 2, true));
    expect(mine.label, '👍, 2, you reacted');
    final rocket = chipOf(tester, '🚀');
    expect((rocket.count, rocket.mine), (1, false));
    expect(rocket.label, '🚀, 1');
    expect(
      find.descendant(
        of: chip('👍'),
        matching: find.bySemanticsLabel('👍, 2, you reacted'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a comment without reactions shows no chips', (tester) async {
    server.comments['infra-1']!.single.remove('reactions');
    await pumpTask(tester, server);
    expect(find.byType(ReactionChip), findsNothing);
    expect(find.byKey(const Key('comment.c1.react')), findsOneWidget);
  });

  testWidgets('tapping a chip takes the reaction away', (tester) async {
    await pumpTask(tester, server);
    await press(tester, chip('👍'));
    expect(count(server, 'DELETE', '/api/v1/comments/c1/reactions/$up'), 1);
    expect(chipOf(tester, '👍').count, 1);
    expect(chipOf(tester, '👍').mine, isFalse);
  });

  testWidgets('the picker offers the quick row and adds one', (tester) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('comment.c1.react')));
    expect(
      find.descendant(of: picker(), matching: find.byType(ReactionOption)),
      findsNWidgets(8),
    );
    expect(
      tester
          .widget<ReactionOption>(find.byKey(const Key('reaction.pick.👍')))
          .mine,
      isTrue,
    );
    await press(tester, find.byKey(const Key('reaction.pick.🎉')));
    expect(picker(), findsNothing);
    expect(count(server, 'PUT', '/api/v1/comments/c1/reactions/$hooray'), 1);
    expect(chipOf(tester, '🎉').mine, isTrue);
    expect(chipOf(tester, '🎉').count, 1);
  });

  testWidgets('any one emoji can be typed into the picker', (tester) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('comment.c1.react')));
    final send = find.byKey(const Key('reaction.other.send'));
    final field = find.byKey(const Key('reaction.other'));
    await tester.enterText(field, 'ok');
    await tester.pump();
    expect(tester.widget<TixButton>(send).onPressed, isNull);
    await tester.enterText(field, ' 👩‍💻 ');
    await tester.pump();
    await press(tester, send);
    expect(
      count(
        server,
        'PUT',
        '/api/v1/comments/c1/reactions/${Uri.encodeComponent('👩‍💻')}',
      ),
      1,
    );
    expect(chipOf(tester, '👩‍💻').mine, isTrue);
  });

  testWidgets('a long press on the comment opens the picker', (tester) async {
    await pumpTask(tester, server);
    final author = find.descendant(
      of: find.byKey(const Key('comment.c1')),
      matching: find.text('Raj'),
    );
    await tester.ensureVisible(author);
    await tester.longPress(author);
    await tester.pumpAndSettle();
    expect(picker(), findsOneWidget);
  });

  testWidgets('a refusal restores the chip and says why', (tester) async {
    server.failures['DELETE /api/v1/comments/c1/reactions/$up'] = FakeResponse(
      403,
      envelope('forbidden', 'not allowed'),
    );
    await pumpTask(tester, server);
    await press(tester, chip('👍'));
    expect(chipOf(tester, '👍').count, 2);
    expect(chipOf(tester, '👍').mine, isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('an older server hides the add button after refusing', (
    tester,
  ) async {
    server.comments['infra-1']!.single.remove('reactions');
    server.reactionsSupported = false;
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('comment.c1.react')));
    await press(tester, find.byKey(const Key('reaction.pick.👀')));
    expect(find.byType(ReactionChip), findsNothing);
    expect(toast('This server does not support reactions.'), findsOneWidget);
    expect(find.byKey(const Key('comment.c1.react')), findsNothing);
  });
}
