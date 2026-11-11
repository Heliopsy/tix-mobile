// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

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
            'reaction': 'thumbs_up',
            'emoji': '👍',
            'count': 2,
            'reacted': true,
            'actor_ids': ['a1', 'me'],
          },
          {
            'reaction': 'rocket',
            'emoji': '🚀',
            'count': 1,
            'reacted': false,
            'actor_ids': ['a1'],
          },
        ],
      },
    ];
  });

  Finder chip(String name) => find.byKey(Key('comment.c1.reaction.$name'));

  ReactionChip chipOf(WidgetTester tester, String name) =>
      tester.widget<ReactionChip>(chip(name));

  Finder picker() => find.byKey(const Key('reaction.picker'));

  testWidgets("chips show emoji and count, the reader's highlighted", (
    tester,
  ) async {
    await pumpTask(tester, server);
    final up = chipOf(tester, 'thumbs_up');
    expect((up.emoji, up.count, up.mine), ('👍', 2, true));
    expect(up.label, 'thumbs up, 2, you reacted');
    final rocket = chipOf(tester, 'rocket');
    expect((rocket.count, rocket.mine), (1, false));
    expect(rocket.label, 'rocket, 1');
    expect(
      find.descendant(
        of: chip('thumbs_up'),
        matching: find.bySemanticsLabel('thumbs up, 2, you reacted'),
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
    await press(tester, chip('thumbs_up'));
    expect(
      count(server, 'DELETE', '/api/v1/comments/c1/reactions/thumbs_up'),
      1,
    );
    expect(chipOf(tester, 'thumbs_up').count, 1);
    expect(chipOf(tester, 'thumbs_up').mine, isFalse);
  });

  testWidgets('the add button opens the picker of eight and adds', (
    tester,
  ) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('comment.c1.react')));
    expect(
      find.descendant(of: picker(), matching: find.byType(ReactionOption)),
      findsNWidgets(8),
    );
    final mine = tester.widget<ReactionOption>(
      find.byKey(const Key('reaction.pick.thumbs_up')),
    );
    expect(mine.mine, isTrue);
    await press(tester, find.byKey(const Key('reaction.pick.hooray')));
    expect(picker(), findsNothing);
    expect(count(server, 'PUT', '/api/v1/comments/c1/reactions/hooray'), 1);
    expect(chipOf(tester, 'hooray').mine, isTrue);
    expect(chipOf(tester, 'hooray').count, 1);
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
    server.failures['DELETE /api/v1/comments/c1/reactions/thumbs_up'] =
        FakeResponse(403, envelope('forbidden', 'not allowed'));
    await pumpTask(tester, server);
    await press(tester, chip('thumbs_up'));
    expect(chipOf(tester, 'thumbs_up').count, 2);
    expect(chipOf(tester, 'thumbs_up').mine, isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('an older server hides the add button after refusing', (
    tester,
  ) async {
    server.comments['infra-1']!.single.remove('reactions');
    server.reactionsSupported = false;
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('comment.c1.react')));
    await press(tester, find.byKey(const Key('reaction.pick.eyes')));
    expect(find.byType(ReactionChip), findsNothing);
    expect(toast('This server does not support reactions.'), findsOneWidget);
    expect(find.byKey(const Key('comment.c1.react')), findsNothing);
  });
}
