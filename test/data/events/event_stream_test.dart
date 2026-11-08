// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/events/event_stream.dart';

import '../../helpers/fake_events.dart';

void main() {
  late FakeEventSockets sockets;
  late TixEventStream stream;
  late List<EventStreamUpdate> updates;
  StreamSubscription<EventStreamUpdate>? sub;

  void start() => sub = stream.updates.listen(updates.add);

  const fast = Backoff(
    first: Duration(milliseconds: 10),
    max: Duration(milliseconds: 40),
    jitter: 0,
  );

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  List<int> seqs() => [
    for (final u in updates)
      if (u is EventReceived) u.event.seq,
  ];

  List<EventStreamState> states() => [
    for (final u in updates)
      if (u is EventStreamStatus) u.state,
  ];

  setUp(() {
    sockets = FakeEventSockets();
    updates = [];
    stream = TixEventStream(
      baseUrl: 'https://tix.example/sub/',
      headers: const {'Authorization': 'Bearer tok'},
      connector: sockets.connect,
      backoff: fast,
      random: Random(1),
    );
  });

  tearDown(() async {
    await sub?.cancel();
    sub = null;
    await stream.close();
  });

  test('connects to wss under the base path with the credential', () async {
    start();
    await settle();
    final s = sockets.last;
    expect(s.url.toString(), 'wss://tix.example/sub/api/v1/events');
    expect(s.headers, {'Authorization': 'Bearer tok'});
    expect(s.sent.single, {'type': 'subscribe', 'id': 's1'});
    s.ack();
    await settle();
    expect(stream.state, EventStreamState.live);
    expect(TixEventStream.eventsUrl('http://127.0.0.1:9').scheme, 'ws');
  });

  test('delivers events in order, once, and follows the cursor', () async {
    start();
    await settle();
    sockets.last
      ..ack()
      ..event(1, 'task.created')
      ..event(2, 'task.updated')
      ..event(2, 'task.updated')
      ..event(1, 'task.created');
    await settle();
    expect(seqs(), [1, 2]);
    expect(stream.cursor, 2);
    final first = updates.whereType<EventReceived>().first.event;
    expect(first.subjectId, 'id-infra-1');
    expect(first.occurredAt, DateTime.utc(2026, 11, 8, 10));
  });

  test('reconnects with backoff and resumes after the cursor', () async {
    start();
    await settle();
    sockets.last
      ..ack()
      ..event(5, 'task.created');
    await settle();
    await sockets.last.drop();
    await settle();
    expect(stream.state, EventStreamState.retrying);
    final retry = updates.whereType<EventStreamStatus>().last;
    expect(retry.retryIn, const Duration(milliseconds: 10));
    final next = await sockets.opened.first;
    await settle();
    expect(next.sent.single['since_seq'], 5);
    next
      ..ack()
      ..event(6, 'task.updated');
    await settle();
    expect(seqs(), [5, 6]);
    expect(updates.whereType<EventsMissed>(), isEmpty);
  });

  test('backoff doubles up to its cap', () {
    final r = Random(1);
    expect(fast.delay(1, r), const Duration(milliseconds: 10));
    expect(fast.delay(2, r), const Duration(milliseconds: 20));
    expect(fast.delay(9, r), const Duration(milliseconds: 40));
    final jittered = const Backoff().delay(1, Random(1));
    expect(jittered, greaterThanOrEqualTo(const Duration(seconds: 1)));
    expect(jittered, lessThanOrEqualTo(const Duration(milliseconds: 1200)));
  });

  test('a failed connection is retried', () async {
    sockets.fail = true;
    start();
    await settle();
    expect(states(), [EventStreamState.connecting, EventStreamState.retrying]);
    sockets.fail = false;
    final s = await sockets.opened.first;
    await settle();
    expect(s.sent.single['type'], 'subscribe');
  });

  test('reconnecting without a cursor reports a gap', () async {
    start();
    await settle();
    sockets.last.ack();
    await settle();
    await sockets.last.drop();
    final next = await sockets.opened.first;
    await settle();
    expect(next.sent.single.containsKey('since_seq'), isFalse);
    next.ack();
    await settle();
    expect(updates.whereType<EventsMissed>(), hasLength(1));
  });

  test('an expired cursor reports a gap and goes live again', () async {
    start();
    await settle();
    sockets.last
      ..ack()
      ..event(3, 'task.created');
    await settle();
    await sockets.last.drop();
    final next = await sockets.opened.first;
    await settle();
    next.push({
      'type': 'error',
      'id': 's1',
      'error': {
        'code': 'invalid',
        'message': 'cursor 3 is no longer available; the oldest is 4000',
      },
    });
    await settle();
    expect(next.sent.last, {'type': 'subscribe', 'id': 's1'});
    next
      ..ack()
      ..event(4001, 'task.updated');
    await settle();
    expect(updates.whereType<EventsMissed>(), hasLength(1));
    expect(seqs(), [3, 4001]);
  });

  test('a refused credential is unavailable and never retried', () async {
    sockets.refuse = 403;
    start();
    await settle();
    expect(stream.state, EventStreamState.unavailable);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(sockets.sockets, isEmpty);
    expect(states(), [
      EventStreamState.connecting,
      EventStreamState.unavailable,
    ]);
  });

  test('a refused subscription closes and stays down', () async {
    start();
    await settle();
    sockets.last.push({
      'type': 'error',
      'id': 's1',
      'error': {'code': 'forbidden', 'message': 'event:subscribe'},
    });
    await settle();
    expect(stream.state, EventStreamState.unavailable);
    expect(sockets.last.closed, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(sockets.sockets, hasLength(1));
  });

  test('reconnectNow skips the wait', () async {
    final slow = TixEventStream(
      baseUrl: 'http://127.0.0.1:1',
      headers: const {},
      connector: sockets.connect,
      backoff: const Backoff(first: Duration(hours: 1)),
    );
    addTearDown(slow.close);
    sockets.fail = true;
    final seen = <EventStreamUpdate>[];
    final s = slow.updates.listen(seen.add);
    addTearDown(s.cancel);
    await settle();
    expect(slow.state, EventStreamState.retrying);
    sockets.fail = false;
    slow.reconnectNow();
    await settle();
    expect(sockets.sockets, hasLength(1));
  });

  test('the type filter is sent and closing stops everything', () async {
    final filtered = TixEventStream(
      baseUrl: 'http://127.0.0.1:1',
      headers: const {},
      connector: sockets.connect,
      types: const ['task.*'],
    );
    final s = filtered.updates.listen((_) {});
    await settle();
    expect(sockets.last.sent.single['filter'], {
      'types': ['task.*'],
    });
    await filtered.close();
    await s.cancel();
    expect(sockets.last.closed, isTrue);
    expect(filtered.state, EventStreamState.closed);
  });

  test('glob patterns match like the server', () {
    expect(TixEventTypes.matches('task.*', 'task.created'), isTrue);
    expect(TixEventTypes.matches('task.*', 'comment.added'), isFalse);
    expect(TixEventTypes.matches('comment.added', 'comment.added'), isTrue);
    expect(TixEventTypes.matches('*', 'inbox.updated'), isTrue);
    expect(TixEventTypes.all, contains('template.updated'));
  });
}
