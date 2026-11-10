// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/data/events/event_stream.dart';
import 'package:tix_mobile/src/features/watch/application/watch.dart';
import 'package:tix_mobile/src/features/watch/presentation/watch_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;

  setUp(() {
    server = FakeTix();
    sockets = FakeEventSockets();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    Size size = phone,
    EventSocketConnector? events,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const WatchScreen(),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: events ?? sockets.connect,
      ),
    );
  }

  /// Acknowledges the app's subscription and Watch's tail [id].
  Future<void> live(WidgetTester tester, [String id = 'w1']) async {
    sockets.last
      ..ack('s1')
      ..ack(id);
    await tester.pumpAndSettle();
  }

  void emit(
    int seq,
    String type, {
    String id = 'w1',
    String actor = 'pax',
    Map<String, Object?> payload = const {},
  }) => sockets.last.event(
    seq,
    type,
    id: id,
    actorId: '01${actor.toUpperCase()}',
    payload: {'actor_handle': actor, ...payload},
  );

  Finder inRow(int seq, Finder f) =>
      find.descendant(of: find.byKey(Key('watch.$seq')), matching: f);

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('connecting, then waiting for events', (tester) async {
        await pump(tester, size: size);
        expect(find.byKey(const Key('watch.connecting')), findsOneWidget);
        expect(find.byKey(const Key('watch.empty')), findsNothing);
        await live(tester);
        expect(find.byKey(const Key('watch.connecting')), findsNothing);
        expect(find.byKey(const Key('watch.empty')), findsOneWidget);
      });

      testWidgets('events arrive newest first, one line each', (tester) async {
        await pump(tester, size: size);
        await live(tester);
        emit(41, 'task.created', payload: {'ref': 'infra-1', 'title': 'Fix'});
        emit(
          42,
          'task.transitioned',
          payload: {'ref': 'infra-1', 'from': 'todo', 'to': 'doing'},
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('watch.empty')), findsNothing);
        expect(
          tester.getTopLeft(find.byKey(const Key('watch.42'))).dy,
          lessThan(tester.getTopLeft(find.byKey(const Key('watch.41'))).dy),
        );
        expect(inRow(42, find.text('#000042')), findsOneWidget);
        expect(inRow(42, find.text('@pax')), findsOneWidget);
        expect(inRow(42, find.text('task.transitioned')), findsOneWidget);
        expect(
          inRow(42, find.textContaining('infra-1  todo → doing')),
          findsOneWidget,
        );
      });

      testWidgets('a server refusal explains the scope and leaves a way back', (
        tester,
      ) async {
        await pump(tester, size: size, events: refusingEventSocket);
        expect(find.byKey(const Key('watch.refused')), findsOneWidget);
        expect(find.textContaining('event:subscribe'), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);
        expect(find.byKey(const Key('watch.list')), findsNothing);
      });
    });
  }

  testWidgets('a task row opens the task', (tester) async {
    await pump(tester);
    await live(tester);
    emit(5, 'comment.added', payload: {'ref': 'infra-1'});
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.5')));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-1'), findsOneWidget);
  });

  testWidgets('a row with no screen opens its details and payload', (
    tester,
  ) async {
    await pump(tester, size: desktop);
    await live(tester);
    emit(6, 'filter.saved', payload: {'name': 'Mine'});
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.6')));
    await tester.pumpAndSettle();
    final detail = find.byKey(const Key('watch.detail.6'));
    expect(detail, findsOneWidget);
    expect(
      find.descendant(
        of: detail,
        matching: find.textContaining('"name": "Mine"'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('watch.detail.open')), findsNothing);
  });

  testWidgets('pausing holds new events and counts them', (tester) async {
    await pump(tester);
    await live(tester);
    emit(1, 'task.created');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.pause')));
    await tester.pumpAndSettle();
    emit(2, 'task.updated');
    emit(3, 'task.updated');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.2')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('watch.paused')),
        matching: find.text('Paused, 2 new events.'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('watch.resume')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.paused')), findsNothing);
    expect(find.byKey(const Key('watch.3')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('watch.3'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('watch.1'))).dy),
    );
  });

  testWidgets('keeps the latest 500 events', (tester) async {
    final container = await pump(tester);
    await live(tester);
    for (var i = 1; i <= watchCap + 5; i++) {
      emit(i, 'task.updated');
    }
    await tester.pumpAndSettle();
    final events = container.read(watchFeedProvider).events;
    expect(events, hasLength(watchCap));
    expect(events.first.seq, watchCap + 5);
    expect(events.last.seq, 6);
  });

  testWidgets('the actor filter is applied here, without resubscribing', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    emit(1, 'task.created');
    emit(2, 'task.created', actor: 'ana');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.filters')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('watch.actors')), '@ana');
    await tester.tap(find.byKey(const Key('watch.apply')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.1')), findsNothing);
    expect(find.byKey(const Key('watch.2')), findsOneWidget);
    expect(sockets.last.subscribes('w2'), isEmpty);
    expect(sockets.sockets, hasLength(1));
  });

  testWidgets('a type prefix goes to the server as a new subscription', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    await tester.tap(find.byKey(const Key('watch.type.task.*')));
    await tester.pumpAndSettle();
    final sub = sockets.last.subscribes('w2').single;
    expect(sub['filter'], {
      'types': ['task.*'],
    });
    expect(sockets.last.sent, contains({'type': 'unsubscribe', 'id': 'w1'}));
    expect(sockets.sockets, hasLength(1));
    expect(find.byKey(const Key('watch.filtering')), findsOneWidget);
  });

  testWidgets('a refused filter says why and keeps the connection', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    sockets.last.push({
      'type': 'error',
      'id': 'w1',
      'error': {'code': 'forbidden', 'message': 'not your project'},
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.refused')), findsOneWidget);
    expect(find.textContaining('not your project'), findsOneWidget);
  });

  testWidgets('an invalid filter is shown above the list with a way out', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    sockets.last.push({
      'type': 'error',
      'id': 'w1',
      'error': {'code': 'invalid', 'message': 'unknown event type bogus'},
    });
    await tester.pumpAndSettle();
    final notice = find.byKey(const Key('watch.filterRefused'));
    expect(notice, findsOneWidget);
    expect(
      find.descendant(
        of: notice,
        matching: find.text('unknown event type bogus'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('watch.refused')), findsNothing);
  });

  testWidgets('replay sends the cursor and says when it expired', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    await tester.tap(find.byKey(const Key('watch.filters')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('watch.since')), '3');
    await tester.tap(find.byKey(const Key('watch.apply')));
    await tester.pumpAndSettle();
    expect(sockets.last.subscribes('w2').single['since_seq'], 3);
    sockets.last.push({
      'type': 'error',
      'id': 'w2',
      'error': {
        'code': 'invalid',
        'message':
            'cursor 3 is no longer available; the oldest retained event is 40',
      },
    });
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('watch.expired')),
        matching: find.textContaining('Events after #3'),
      ),
      findsOneWidget,
    );
    expect(sockets.last.subscribes('w2'), hasLength(2));
    sockets.last.ack('w2');
    emit(41, 'task.created', id: 'w2');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.41')), findsOneWidget);
  });
}
