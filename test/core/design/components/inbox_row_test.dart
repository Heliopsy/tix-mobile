// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';

import '../../../helpers/design.dart';

void main() {
  final now = DateTime.utc(2026, 11, 2, 12);

  Widget row(InboxItem item, {VoidCallback? onTap, VoidCallback? onMenu}) =>
      InboxRow(item: item, now: now, onTap: onTap ?? () {}, onMenu: onMenu);

  testWidgets('says who did what to which task, and when', (tester) async {
    var taps = 0;
    var menus = 0;
    await pumpComponent(
      tester,
      row(
        InboxItem(
          id: 'a',
          kind: InboxKind.mention,
          actorHandle: 'raj',
          taskRef: 'infra-4',
          taskTitle: 'Cut over',
          excerpt: 'look at this',
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
        onTap: () => taps++,
        onMenu: () => menus++,
      ),
    );
    expect(find.text('@raj mentioned you'), findsOneWidget);
    expect(find.text('look at this'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.byType(RefText), findsOneWidget);
    await tester.tap(find.text('@raj mentioned you'));
    await tester.tap(find.byKey(const Key('inbox.menu.a')));
    expect((taps, menus), (1, 1));
  });

  testWidgets('an unread row reads as unread and draws heavier', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpComponent(
      tester,
      row(
        InboxItem(
          id: 'a',
          kind: InboxKind.assigned,
          taskRef: 'web-1',
          createdAt: now,
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('unread')), findsOneWidget);
    final style = tester
        .widget<Text>(find.text('Somebody assigned you'))
        .style!;
    expect(style.fontWeight, FontWeight.w600);
    handle.dispose();
  });

  testWidgets(
    'an assignment leaves its excerpt off; a move shows both states',
    (tester) async {
      await pumpComponent(
        tester,
        Column(
          children: [
            row(
              InboxItem(
                id: 'a',
                kind: InboxKind.assigned,
                taskRef: 'web-1',
                excerpt: 'title text',
                readAt: now,
              ),
            ),
            row(
              InboxItem(
                id: 'b',
                kind: InboxKind.status,
                taskRef: 'web-2',
                fromStatus: 'todo',
                toStatus: 'done',
                readAt: now,
              ),
            ),
          ],
        ),
      );
      expect(find.text('title text'), findsNothing);
      expect(find.byType(StatusPill), findsNWidgets(2));
    },
  );

  testWidgets('a deleted task is named as such', (tester) async {
    await pumpComponent(
      tester,
      row(const InboxItem(id: 'a', taskRef: 'web-1', taskGone: true)),
    );
    expect(find.text('A task that has been deleted'), findsOneWidget);
    expect(find.byType(RefText), findsNothing);
  });

  testWidgets('times: hours today, the time yesterday, the date before', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      Column(
        children: [
          row(
            InboxItem(
              id: 'a',
              taskRef: 'w-1',
              createdAt: now.subtract(const Duration(hours: 3)),
            ),
          ),
          row(
            InboxItem(
              id: 'b',
              taskRef: 'w-2',
              createdAt: now.subtract(const Duration(days: 1)),
            ),
          ),
          row(
            InboxItem(
              id: 'c',
              taskRef: 'w-3',
              createdAt: DateTime.utc(2026, 10, 1, 12),
            ),
          ),
          row(InboxItem(id: 'd', taskRef: 'w-4', createdAt: now)),
        ],
      ),
    );
    expect(find.text('3 h'), findsOneWidget);
    expect(find.text('now'), findsOneWidget);
    expect(find.text('Oct 1'), findsOneWidget);
  });

  testWidgets('does not overflow at twice the text size', (tester) async {
    await pumpComponent(
      tester,
      row(
        InboxItem(
          id: 'a',
          kind: InboxKind.comment,
          actorHandle: 'someone-with-a-long-handle',
          taskRef: 'infrastructure-1234',
          taskTitle:
              'A very long title that wraps over more than one line on a phone',
          excerpt:
              'And an excerpt that is long enough to wrap as well, twice over.',
          createdAt: now,
        ),
        onMenu: () {},
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
