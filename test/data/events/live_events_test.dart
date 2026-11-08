// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/events/live_events.dart';

import '../../helpers/fake_events.dart';
import '../../helpers/fake_tix.dart';

const config = LiveConfig(
  socketBackoff: Backoff(max: Duration(seconds: 1), jitter: 0),
  probeJitter: 0,
  pollBackoff: Backoff(
    first: Duration(seconds: 5),
    max: Duration(seconds: 5),
    jitter: 0,
  ),
);

/// One [LiveEvents] against a [FakeTix] and [FakeEventSockets], recording
/// what it reports.
class Rig {
  Rig({Credential credential = const BearerCredential('tok'), int? refuse}) {
    sockets.refuse = refuse;
    live = LiveEvents(
      baseUrl: 'https://tix.example',
      headers: credential.headers,
      poller: TixEventPoller(server.factory('https://tix.example', credential)),
      connector: sockets.connect,
      config: config,
      random: Random(1),
    );
    live.updates.listen(updates.add);
    live.statuses.listen((s) => modes.add(s.mode));
  }

  final server = FakeTix();
  final sockets = FakeEventSockets();
  late final LiveEvents live;
  final updates = <EventStreamUpdate>[];
  final modes = <LiveMode>[];

  List<int> get seqs => [
    for (final u in updates)
      if (u is EventReceived) u.event.seq,
  ];

  int get gaps => updates.whereType<EventsMissed>().length;

  LiveMode get mode => live.status.mode;

  /// Breaks the live socket after [lastSeq] and refuses every upgrade with
  /// 502, as a proxy that cannot carry WebSockets does, until polling starts.
  void breakSocket(FakeAsync async, {int lastSeq = 7}) {
    async.flushMicrotasks();
    sockets.last
      ..ack()
      ..event(lastSeq, 'task.created');
    async.flushMicrotasks();
    sockets.refuse = 502;
    unawaited(sockets.last.drop());
    async.elapse(const Duration(milliseconds: 2500));
  }
}

void main() {
  test('falls back to polling after three failures, from the cursor', () {
    fakeAsync((async) {
      final r = Rig()..breakSocket(async);
      expect(r.mode, LiveMode.polling);
      expect(r.server.polls, hasLength(1));
      final poll = r.server.polls.single.uri.queryParameters;
      expect(poll['since_seq'], '7');
      expect(poll['wait'], '25s');
      expect(poll['limit'], '200');
      expect(r.server.polls.single.headers['Authorization'], 'Bearer tok');
      r.server
        ..addEvent(7, 'task.created')
        ..addEvent(8, 'task.updated');
      async.elapse(const Duration(seconds: 1));
      expect(r.seqs, [7, 8]);
      expect(r.gaps, 0);
      expect(r.live.cursor, 8);
      expect(r.modes, contains(LiveMode.websocket));
    });
  });

  test('two failures keep the WebSocket', () {
    fakeAsync((async) {
      final r = Rig();
      async.flushMicrotasks();
      r.sockets.last.ack();
      async.flushMicrotasks();
      r.sockets.refuse = 502;
      unawaited(r.sockets.last.drop());
      async.elapse(const Duration(milliseconds: 1500));
      expect(r.sockets.sockets, hasLength(1));
      expect(r.mode, LiveMode.connecting);
      expect(r.server.polls, isEmpty);
    });
  });

  test('failures older than the window do not add up', () {
    fakeAsync((async) {
      final r = Rig();
      async.flushMicrotasks();
      for (var i = 0; i < 4; i++) {
        r.sockets.last.ack();
        async.flushMicrotasks();
        unawaited(r.sockets.last.drop());
        async.elapse(const Duration(minutes: 1, seconds: 1));
      }
      expect(r.server.polls, isEmpty);
      expect(r.sockets.sockets, hasLength(5));
    });
  });

  test('goes back to the WebSocket with the cursor, delivering once', () {
    fakeAsync((async) {
      final r = Rig()..breakSocket(async);
      r.server.addEvent(9, 'task.updated');
      async.elapse(const Duration(seconds: 1));
      expect(r.live.cursor, 9);
      r.sockets.refuse = null;
      final before = r.sockets.sockets.length;
      async.elapse(const Duration(minutes: 2));
      expect(r.sockets.sockets, hasLength(before + 1));
      final probe = r.sockets.last;
      expect(probe.sent.single['since_seq'], 9);
      r.server.addEvent(10, 'task.updated');
      async.elapse(const Duration(seconds: 1));
      expect(r.mode, LiveMode.polling);
      expect(r.seqs, [7, 9, 10]);
      probe
        ..ack()
        ..event(10, 'task.updated')
        ..event(11, 'task.updated');
      async.flushMicrotasks();
      expect(r.mode, LiveMode.websocket);
      expect(r.seqs, [7, 9, 10, 11]);
      final polls = r.server.polls.length;
      r.server.addEvent(12, 'task.updated');
      async.elapse(const Duration(minutes: 10));
      expect(r.server.polls, hasLength(polls));
      expect(r.seqs, isNot(contains(12)));
      expect(r.gaps, 0);
    });
  });

  test('a failed probe keeps polling and tries again later', () {
    fakeAsync((async) {
      final r = Rig()..breakSocket(async);
      final opened = r.sockets.sockets.length;
      async.elapse(const Duration(minutes: 2));
      expect(r.mode, LiveMode.polling);
      expect(r.sockets.sockets, hasLength(opened));
      r.sockets.refuse = 403;
      async.elapse(const Duration(minutes: 2));
      expect(r.mode, LiveMode.polling);
      r.sockets.refuse = null;
      async.elapse(const Duration(minutes: 2));
      r.sockets.last.ack();
      async.flushMicrotasks();
      expect(r.mode, LiveMode.websocket);
      expect(r.gaps, 0);
    });
  });

  test('a 403 on the WebSocket is unavailable and never retried', () {
    fakeAsync((async) {
      final r = Rig(refuse: 403);
      async.elapse(const Duration(minutes: 10));
      expect(r.mode, LiveMode.unavailable);
      expect(r.server.polls, isEmpty);
    });
  });

  test('a 403 on the poll is unavailable and never retried', () {
    fakeAsync((async) {
      final r = Rig();
      r.server.pollAnswer = FakeResponse(
        403,
        envelope('forbidden', 'event:subscribe'),
      );
      r.breakSocket(async);
      expect(r.mode, LiveMode.unavailable);
      final opened = r.sockets.sockets.length;
      async.elapse(const Duration(minutes: 10));
      expect(r.server.polls, hasLength(1));
      expect(r.sockets.sockets, hasLength(opened));
    });
  });

  test('an expired poll cursor reports a gap and starts from now', () {
    fakeAsync((async) {
      final r = Rig();
      r.server.oldestRetained = 40;
      r.breakSocket(async);
      async.elapse(const Duration(seconds: 1));
      expect(r.gaps, 1);
      expect(r.server.polls, hasLength(2));
      expect(r.server.polls[1].uri.queryParameters['since_seq'], isNull);
      expect(r.mode, LiveMode.polling);
    });
  });

  test('a server refusing a 25 s wait is polled with a shorter one', () {
    fakeAsync((async) {
      final r = Rig();
      r.server.maxWait = 15;
      r.breakSocket(async);
      async.elapse(const Duration(seconds: 1));
      expect(r.server.polls, hasLength(2));
      expect(r.server.polls.last.uri.queryParameters['wait'], '10s');
      expect(r.mode, LiveMode.polling);
      r.server.addEvent(8, 'task.updated');
      async.elapse(const Duration(seconds: 1));
      expect(r.seqs, [7, 8]);
    });
  });

  test('the cursor follows next_seq past events filtered out', () {
    fakeAsync((async) {
      final r = Rig()..breakSocket(async);
      r.server.pollAnswer = const FakeResponse(200, {
        'events': <Object?>[],
        'next_seq': 30,
      });
      r.server.addEvent(8, 'task.updated');
      async.elapse(const Duration(seconds: 1));
      r.server.pollAnswer = null;
      async.elapse(const Duration(seconds: 30));
      expect(r.live.cursor, 30);
      expect(r.server.polls.last.uri.queryParameters['since_seq'], '30');
    });
  });

  test('a server without the endpoint is refreshed on a timer', () {
    fakeAsync((async) {
      final r = Rig();
      r.server.pollSupported = false;
      r.breakSocket(async);
      expect(r.mode, LiveMode.refreshing);
      expect(r.gaps, 1);
      async.elapse(const Duration(seconds: 45));
      expect(r.gaps, 2);
      async.elapse(const Duration(seconds: 90));
      expect(r.gaps, 4);
      expect(r.server.polls, hasLength(1));
      r.sockets.refuse = null;
      async.elapse(const Duration(minutes: 2));
      final before = r.gaps;
      r.sockets.last.ack();
      async.flushMicrotasks();
      expect(r.mode, LiveMode.websocket);
      expect(r.gaps, before + 1);
      expect(r.sockets.last.sent.single.containsKey('since_seq'), isFalse);
      final gaps = r.gaps;
      async.elapse(const Duration(minutes: 5));
      expect(r.gaps, gaps);
    });
  });

  test('pausing cancels the poll and resuming polls from the cursor', () {
    fakeAsync((async) {
      final r = Rig()..breakSocket(async);
      expect(r.server.polls, hasLength(1));
      r.live.pause();
      r.server.addEvent(8, 'task.updated');
      async.elapse(const Duration(minutes: 10));
      expect(r.seqs, [7]);
      expect(r.server.polls, hasLength(1));
      r.live.reconnectNow();
      async.elapse(Duration.zero);
      expect(r.server.polls[1].uri.queryParameters['since_seq'], '7');
      async.elapse(const Duration(seconds: 1));
      expect(r.seqs, [7, 8]);
    });
  });

  test('network failures read as offline and recovery probes at once', () {
    fakeAsync((async) {
      final r = Rig();
      async.flushMicrotasks();
      r.sockets.last.ack();
      async.flushMicrotasks();
      r.sockets.fail = true;
      unawaited(r.sockets.last.drop());
      async.elapse(const Duration(milliseconds: 1500));
      expect(r.mode, LiveMode.offline);
      r.server.pollOffline = true;
      async.elapse(const Duration(seconds: 3));
      expect(r.mode, LiveMode.offline);
      r.server.pollOffline = false;
      r.sockets.fail = false;
      final opened = r.sockets.sockets.length;
      async.elapse(const Duration(seconds: 30));
      expect(r.mode, LiveMode.polling);
      expect(r.sockets.sockets, hasLength(opened + 1));
      expect(r.live.status.lastError, isA<TixException>());
    });
  });

  test('closing stops everything', () {
    fakeAsync((async) {
      final r = Rig()..breakSocket(async);
      unawaited(r.live.close());
      async.elapse(const Duration(minutes: 10));
      expect(r.mode, LiveMode.closed);
      expect(r.server.polls, hasLength(1));
    });
  });

  test('a sign-in polls with its cookie, not a bearer token', () {
    fakeAsync((async) {
      final r = Rig(credential: const SessionCredential('sess-x'));
      r.server.sessions['sess-x'] = (email: 'ana@example.com', tenant: 'x');
      r.breakSocket(async);
      final sent = r.server.polls.single.headers;
      expect(sent['Cookie'], 'tix_session=sess-x');
      expect(sent.containsKey('Authorization'), isFalse);
      expect(r.mode, LiveMode.polling);
    });
  });
}
