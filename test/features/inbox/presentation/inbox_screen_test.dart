// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/inbox/presentation/inbox_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeEventSockets sockets;
  late FakeNotes notes;

  setUp(() {
    sockets = FakeEventSockets();
    notes = FakeNotes();
  });

  Future<void> pump(
    WidgetTester tester,
    FakeTix server, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const InboxScreen(),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: sockets.connect,
        notes: notes,
      ),
    );
  }

  Finder row(String id) => find.byKey(Key('inbox.item.$id'));

  Finder inRow(String id, Finder f) =>
      find.descendant(of: row(id), matching: f);

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then items grouped by day', (tester) async {
        final server = FakeTix()
          ..withSummary()
          ..gate = Completer<void>();
        await pump(tester, server, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        expect(row('i1'), findsNothing);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(SkeletonList), findsNothing);
        expect(inRow('i1', find.text('@raj mentioned you')), findsOneWidget);
        expect(
          inRow('i1', find.text('@ana can you look at this?')),
          findsOneWidget,
        );
        expect(inRow('i2', find.text('@raj moved it')), findsOneWidget);
        expect(inRow('i2', find.byType(StatusPill)), findsNWidgets(2));
        expect(find.text('TODAY'), findsOneWidget);
        expect(find.text('YESTERDAY'), findsOneWidget);
        if (size == desktop) expect(find.text('EARLIER'), findsOneWidget);
        expect(find.text('2 unread'), findsOneWidget);
        expect(find.byKey(const Key('inbox.summary')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('inbox.summary.overdue')),
            matching: find.text('1'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('empty', (tester) async {
        await pump(tester, FakeTix()..inbox.clear(), size: size);
        expect(find.text('Nothing here yet.'), findsOneWidget);
        expect(find.text('All caught up'), findsOneWidget);
        final markAll = tester.widget(find.byKey(const Key('inbox.readAll')));
        expect(
          markAll is TixIconButton
              ? markAll.onPressed
              : (markAll as TixButton).onPressed,
          isNull,
        );
      }, skip: false);

      testWidgets('error', (tester) async {
        final server = FakeTix()
          ..failing['/api/v1/inbox'] = FakeResponse(
            500,
            envelope('internal', 'x'),
          );
        await pump(tester, server, size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
        expect(row('i1'), findsNothing);
      });
    });
  }

  testWidgets('tapping an item marks it read and opens its task', (
    tester,
  ) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(inRow('i1', find.text('@raj mentioned you')));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-1'), findsOneWidget);
    expect(server.requestsTo('/api/v1/inbox/i1/read').single.method, 'PUT');
  });

  testWidgets('a deleted task says so and only marks the item', (tester) async {
    final server = FakeTix();
    server.inbox.first['task_gone'] = true;
    await pump(tester, server);
    expect(
      inRow('i1', find.text('A task that has been deleted')),
      findsOneWidget,
    );
    await tester.tap(inRow('i1', find.text('@raj mentioned you')));
    await tester.pumpAndSettle();
    expect(find.textContaining('route:'), findsNothing);
    expect(server.requestsTo('/api/v1/inbox/i1/read'), hasLength(1));
  });

  testWidgets('swiping an unread item marks it read at once', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    expect(find.text('2 unread'), findsOneWidget);
    await tester.drag(row('i1'), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/inbox/i1/read').single.method, 'PUT');
    expect(find.text('1 unread'), findsOneWidget);
    expect(server.inbox.first['read_at'], isNotNull);
  });

  testWidgets('the menu marks a read item unread', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('inbox.menu.i2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inbox.action.read')), findsNothing);
    await tester.tap(find.byKey(const Key('inbox.action.unread')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/inbox/i2/read').single.method, 'DELETE');
    expect(find.text('3 unread'), findsOneWidget);
  });

  testWidgets('a refused mark rolls back and says why', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    server.failing['/api/v1/inbox/i1/read'] = FakeResponse(
      400,
      envelope('invalid', 'nope'),
    );
    await tester.tap(find.byKey(const Key('inbox.menu.i1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inbox.action.read')));
    await tester.pumpAndSettle();
    expect(find.text('2 unread'), findsOneWidget);
    expect(find.textContaining('nope'), findsOneWidget);
  });

  testWidgets('the menu stops a kind on the server, with undo', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('inbox.menu.i1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inbox.action.mute')));
    await tester.pumpAndSettle();
    expect(server.inboxMuted, ['mention']);
    await tester.tap(find.byKey(const Key('toast.action')));
    await tester.pumpAndSettle();
    expect(server.inboxMuted, isEmpty);
  });

  testWidgets('mark all read clears the count and says how many', (
    tester,
  ) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('inbox.readAll')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/inbox/read-all'), hasLength(1));
    expect(find.text('All caught up'), findsOneWidget);
    expect(find.text('Marked 2 items read'), findsOneWidget);
    expect(notes.cancelledAll, 1);
  });

  testWidgets('a kind filter narrows the rows', (tester) async {
    await pump(tester, FakeTix());
    await tester.ensureVisible(find.byKey(const Key('inbox.kind.assigned')));
    await tester.tap(find.byKey(const Key('inbox.kind.assigned')));
    await tester.pumpAndSettle();
    expect(row('i3'), findsOneWidget);
    expect(row('i1'), findsNothing);
    expect(row('i2'), findsNothing);
  });

  testWidgets('unread asks the server for unread items', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.text('Unread  2'));
    await tester.pumpAndSettle();
    expect(row('i2'), findsNothing);
    expect(row('i1'), findsOneWidget);
    expect(
      server.requestsTo('/api/v1/inbox').last.uri.queryParameters['unread'],
      'true',
    );
  });

  testWidgets('a live item appears at the top and the screen says updated', (
    tester,
  ) async {
    final server = FakeTix();
    await pump(tester, server);
    server.inbox.insert(
      0,
      inboxJson(
        'i9',
        kind: 'comment',
        actor: 'kim',
        created: '2026-11-01T11:58:00Z',
      ),
    );
    sockets.last
      ..ack()
      ..event(1, 'inbox.updated', subjectId: 'me');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(inRow('i9', find.text('@kim commented')), findsOneWidget);
    expect(find.text('3 unread'), findsOneWidget);
    final mark = tester.widget<UpdatedMark>(find.byType(UpdatedMark));
    expect(mark.visible, isTrue);
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(
      tester.widget<UpdatedMark>(find.byType(UpdatedMark)).visible,
      isFalse,
    );
  });

  testWidgets('the offer to turn notifications on asks permission', (
    tester,
  ) async {
    await pump(tester, FakeTix());
    expect(find.byKey(const Key('inbox.nudge')), findsOneWidget);
    await tester.tap(find.byKey(const Key('inbox.nudge.on')));
    await tester.pumpAndSettle();
    expect(notes.asked, 1);
    expect(find.byKey(const Key('inbox.nudge')), findsNothing);
  });

  testWidgets('a refused permission says notifications are blocked', (
    tester,
  ) async {
    notes.grant = false;
    await pump(tester, FakeTix());
    await tester.tap(find.byKey(const Key('inbox.nudge.on')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('inbox.nudge')),
        matching: find.text('Notifications are blocked for tix.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a failing summary leaves the inbox', (tester) async {
    final server = FakeTix()
      ..failing['/api/v1/stats'] = FakeResponse(
        403,
        envelope('forbidden', 'x'),
      );
    await pump(tester, server);
    expect(find.byKey(const Key('inbox.summary')), findsNothing);
    expect(row('i1'), findsOneWidget);
  });

  testWidgets('the tune button opens notification settings', (tester) async {
    await pump(tester, FakeTix());
    await tester.tap(find.byKey(const Key('inbox.settings')));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/notifications'), findsOneWidget);
  });
}
