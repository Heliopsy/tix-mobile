// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
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
  Rig({
    Credential credential = const BearerCredential('tok'),
    int? refuse,
    void Function()? onRefresh,
    LiveConfig config = config,
    EventPoller? poller,
    DateTime Function() now = DateTime.now,
  }) {
    sockets.refuse = refuse;
    live = LiveEvents(
      baseUrl: 'https://tix.example',
      headers: credential.headers,
      poller:
          poller ??
          TixEventPoller(server.factory('https://tix.example', credential)),
      connector: sockets.connect,
      config: config,
      onRefresh: onRefresh,
      random: Random(1),
      now: now,
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

  /// Opens the WebSocket and has it acknowledged.
  void open(FakeAsync async) {
    async.flushMicrotasks();
    sockets.last.ack();
    async.flushMicrotasks();
  }

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

  group('asleep with a local engine', () {
    test('sleeping cancels the poll and attempts nothing at all', () {
      fakeAsync((async) {
        final r = Rig()..breakSocket(async);
        expect(r.server.polls, hasLength(1));
        final opened = r.sockets.sockets.length;
        r.live.sleep();
        expect(r.mode, LiveMode.paused);
        r.sockets.refuse = null;
        r.server.addEvent(8, 'task.updated');
        async.elapse(const Duration(hours: 1));
        r.live.reconnectNow();
        async.elapse(const Duration(minutes: 10));
        expect(r.server.polls, hasLength(1));
        expect(r.sockets.sockets, hasLength(opened));
        expect(r.mode, LiveMode.paused);
        expect(r.seqs, [7]);
      });
    });

    test('a sleeping WebSocket is let go, not retried', () {
      fakeAsync((async) {
        final r = Rig();
        async.flushMicrotasks();
        final socket = r.sockets.last..ack();
        async.flushMicrotasks();
        expect(r.mode, LiveMode.websocket);
        r.live.sleep();
        socket.event(8, 'task.updated');
        unawaited(socket.drop());
        async.elapse(const Duration(hours: 1));
        expect(r.seqs, isEmpty);
        expect(r.mode, LiveMode.paused);
        expect(r.sockets.sockets, hasLength(1));
        expect(r.server.polls, isEmpty);
      });
    });

    test('waking subscribes over the WebSocket from the cursor', () {
      fakeAsync((async) {
        final r = Rig()..breakSocket(async);
        r.live.sleep();
        r.sockets.refuse = null;
        async.elapse(const Duration(minutes: 10));
        final opened = r.sockets.sockets.length;
        r.live.wake();
        expect(r.mode, LiveMode.connecting);
        async.flushMicrotasks();
        expect(r.sockets.sockets, hasLength(opened + 1));
        expect(r.sockets.last.sent.single['since_seq'], 7);
        r.sockets.last
          ..ack()
          ..event(8, 'task.updated');
        async.flushMicrotasks();
        expect(r.mode, LiveMode.websocket);
        expect(r.seqs, [7, 8]);
        expect(r.server.polls, hasLength(1));
        expect(r.gaps, 0);
      });
    });

    test('a refresh tick says so before it reports the gap', () {
      fakeAsync((async) {
        final gapsAtTick = <int>[];
        late final Rig r;
        r = Rig(onRefresh: () => gapsAtTick.add(r.gaps));
        r.server.pollSupported = false;
        r.breakSocket(async);
        expect(r.mode, LiveMode.refreshing);
        expect(gapsAtTick, isEmpty);
        async.elapse(const Duration(seconds: 45));
        expect(gapsAtTick, [1]);
        expect(r.gaps, 2);
        r.live.sleep();
        async.elapse(const Duration(minutes: 10));
        expect(gapsAtTick, [1]);
        expect(r.gaps, 2);
      });
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

  group('diagnostics', () {
    final start = DateTime.utc(2026, 11, 9, 10);

    test('after falling back to polling', () {
      fakeAsync((async) {
        final r = Rig(now: async.getClock(start).now);
        async.flushMicrotasks();
        r.sockets.last
          ..ack()
          ..event(7, 'task.created');
        async.flushMicrotasks();
        expect(r.live.diagnostics.lastEventAt, start);
        r.sockets.refuse = 502;
        unawaited(r.sockets.last.drop());
        async.elapse(const Duration(milliseconds: 1500));
        final failing = r.live.diagnostics;
        expect(failing.windowFailures, 2);
        expect(failing.consecutiveFailures, 2);
        expect(failing.failuresBeforeFallback, 3);
        expect(failing.nextRetryAt, isNotNull);
        expect(failing.nextRetryAt!.isAfter(async.getClock(start).now()), true);
        async.elapse(const Duration(seconds: 1));
        expect(r.live.diagnostics.consecutiveFailures, 3);
        r.server.addEvent(8, 'task.updated');
        async.elapse(const Duration(seconds: 1));
        final d = r.live.diagnostics;
        expect(d.mode, LiveMode.polling);
        expect(d.transport, LiveTransport.poll);
        expect(d.host, 'https://tix.example');
        expect(d.windowFailures, 0);
        expect(d.consecutiveFailures, 0);
        expect(d.pollUnsupported, isFalse);
        expect(d.lastContactAt, isNotNull);
        expect(d.nextRetryAt, isNull);
        expect(d.nextProbeAt, d.modeSince.add(const Duration(minutes: 2)));
        expect(d.lastError?.kind, LiveErrorKind.upgradeRefused);
        expect(d.lastError?.httpStatus, 502);
        expect(d.lastError?.type, 'WebSocketException');
        expect(d.lastError?.source, LiveErrorSource.websocket);
        final errors = [
          for (final h in d.history)
            if (h.error != null) h.error!.kind,
        ];
        expect(errors, [
          LiveErrorKind.closed,
          LiveErrorKind.upgradeRefused,
          LiveErrorKind.upgradeRefused,
        ]);
        expect(
          [
            for (final h in d.history)
              if (h.error == null) h.mode,
          ],
          [LiveMode.websocket, LiveMode.connecting, LiveMode.polling],
        );
      });
    });

    test('a server without the poll endpoint says so', () {
      fakeAsync((async) {
        final r = Rig();
        r.server.pollSupported = false;
        r.breakSocket(async);
        final d = r.live.diagnostics;
        expect(d.pollUnsupported, isTrue);
        expect(d.transport, LiveTransport.refresh);
      });
    });

    test('a poll that times out is offline, with the next try', () {
      fakeAsync((async) {
        final poller = _ScriptedPoller()
          ..failures.add(
            const TixException(
              TixErrorKind.timeout,
              cause: DioExceptionType.receiveTimeout,
            ),
          );
        final r = Rig(poller: poller, now: async.getClock(start).now)
          ..breakSocket(async);
        final fellBack = start.add(const Duration(seconds: 2));
        final d = r.live.diagnostics;
        expect(d.mode, LiveMode.offline);
        expect(d.transport, LiveTransport.poll);
        expect(d.lastError?.kind, LiveErrorKind.timeout);
        expect(d.lastError?.source, LiveErrorSource.poll);
        expect(d.lastError?.type, 'TixException (receiveTimeout)');
        expect(d.lastError?.tixKind, TixErrorKind.timeout);
        expect(d.lastError?.at, fellBack);
        expect(d.consecutiveFailures, 4);
        expect(d.nextRetryAt, fellBack.add(const Duration(seconds: 5)));
        async.elapse(const Duration(seconds: 5));
        expect(r.mode, LiveMode.polling);
        expect(r.live.diagnostics.consecutiveFailures, 0);
        expect(r.live.diagnostics.nextRetryAt, isNull);
      });
    });

    test('a WebSocket that times out reads as offline', () {
      fakeAsync((async) {
        final r = Rig()..open(async);
        r.sockets.error = TimeoutException(
          'no answer',
          const Duration(seconds: 30),
        );
        unawaited(r.sockets.last.drop());
        async.elapse(const Duration(milliseconds: 1500));
        expect(r.mode, LiveMode.offline);
        final e = r.live.diagnostics.lastError!;
        expect(e.kind, LiveErrorKind.timeout);
        expect(e.type, 'TimeoutException');
        expect(e.message, 'no answer');
      });
    });

    test('a socket error keeps the OS error and code', () {
      fakeAsync((async) {
        final r = Rig()..open(async);
        r.sockets.error = const SocketException(
          'Failed host lookup',
          osError: OSError('No address associated with hostname', 7),
        );
        unawaited(r.sockets.last.drop());
        async.elapse(const Duration(milliseconds: 1500));
        final e = r.live.diagnostics.lastError!;
        expect(r.mode, LiveMode.offline);
        expect(e.kind, LiveErrorKind.unreachable);
        expect(e.type, 'SocketException');
        expect(e.osErrorCode, 7);
        expect(e.osErrorMessage, 'No address associated with hostname');
      });
    });

    test('a WebSocket closed by a proxy keeps its code and reason', () {
      fakeAsync((async) {
        final r = Rig()..open(async);
        unawaited(r.sockets.last.drop(code: 1001, reason: 'idle timeout'));
        async.flushMicrotasks();
        final e = r.live.diagnostics.lastError!;
        expect(e.kind, LiveErrorKind.closed);
        expect(e.closeCode, 1001);
        expect(e.closeReason, 'idle timeout');
      });
    });

    test('the history keeps the latest entries only', () {
      fakeAsync((async) {
        final r = Rig(
          config: const LiveConfig(
            socketBackoff: Backoff(max: Duration(seconds: 1), jitter: 0),
            failuresBeforeFallback: 1000,
            historySize: 5,
          ),
          now: async.getClock(start).now,
        );
        async.flushMicrotasks();
        r.sockets.fail = true;
        unawaited(r.sockets.last.drop());
        async.elapse(const Duration(seconds: 30));
        final history = r.live.diagnostics.history;
        expect(history, hasLength(5));
        expect(history.first.at.isAfter(start), isTrue);
        expect(history.last.error?.kind, LiveErrorKind.unreachable);
      });
    });

    test('nothing that looks like a credential is kept', () {
      fakeAsync((async) {
        const secret = 'tok-do-not-leak-7f3a';
        final r = Rig(credential: const BearerCredential(secret))..open(async);
        r.sockets.error = const WebSocketException(
          'not upgraded: wss://tix.example/api/v1/events?access_token=$secret '
          'Authorization: Bearer $secret',
          502,
        );
        unawaited(r.sockets.last.drop());
        async.elapse(const Duration(milliseconds: 1500));
        final report = r.live.diagnostics.toReport(app: '1.0.0');
        expect(report, isNot(contains(secret)));
        expect(report, isNot(contains('access_token')));
        expect(report, contains('wss://tix.example/api/v1/events'));
        expect(report, contains('upgradeRefused'));
        expect(report, contains('HTTP 502'));
      });
    });

    test('reconnect now tries the WebSocket again after a refusal', () {
      fakeAsync((async) {
        final r = Rig(refuse: 403);
        async.flushMicrotasks();
        expect(r.mode, LiveMode.unavailable);
        expect(r.live.diagnostics.lastError?.kind, LiveErrorKind.refused);
        r.sockets.refuse = null;
        r.live.retryNow();
        expect(r.mode, LiveMode.connecting);
        async.flushMicrotasks();
        r.sockets.last.ack();
        async.flushMicrotasks();
        expect(r.mode, LiveMode.websocket);
      });
    });

    test('reconnect now skips the wait before the next attempt', () {
      fakeAsync((async) {
        final r = Rig(
          config: const LiveConfig(
            socketBackoff: Backoff(first: Duration(minutes: 1), jitter: 0),
          ),
        )..open(async);
        unawaited(r.sockets.last.drop());
        async.flushMicrotasks();
        expect(r.sockets.attempts, 1);
        r.live.retryNow();
        async.flushMicrotasks();
        expect(r.sockets.attempts, 2);
      });
    });
  });

  group('tails', () {
    List<int> seqsOf(List<TailUpdate> got) => [
      for (final u in got)
        if (u is TailEvent) u.event.seq,
    ];

    test('ride the open WebSocket instead of a second one', () {
      fakeAsync((async) {
        final r = Rig()..open(async);
        final got = <TailUpdate>[];
        final tail = r.live.tail(types: const ['task.*']);
        tail.updates.listen(got.add);
        async.flushMicrotasks();
        expect(r.sockets.sockets, hasLength(1));
        final sub = r.sockets.last.subscribes(tail.id).single;
        expect(sub['filter'], {
          'types': ['task.*'],
        });
        r.sockets.last
          ..ack(tail.id)
          ..event(3, 'task.created', id: tail.id);
        async.flushMicrotasks();
        expect(got.whereType<TailLive>(), hasLength(1));
        expect(seqsOf(got), [3]);
        unawaited(tail.close());
        async.flushMicrotasks();
        expect(r.sockets.last.sent.last, {
          'type': 'unsubscribe',
          'id': tail.id,
        });
      });
    });

    test('start after the app cursor unless told to replay', () {
      fakeAsync((async) {
        final r = Rig()..open(async);
        r.sockets.last.event(12, 'task.created');
        async.flushMicrotasks();
        final follow = r.live.tail();
        final replay = r.live.tail(since: 4);
        async.flushMicrotasks();
        expect(r.sockets.last.subscribes(follow.id).single['since_seq'], 12);
        expect(r.sockets.last.subscribes(replay.id).single['since_seq'], 4);
      });
    });

    test('are polled with their filter while live updates poll', () {
      fakeAsync((async) {
        final r = Rig()..breakSocket(async);
        final got = <TailUpdate>[];
        r.live.tail(types: const ['comment.*']).updates.listen(got.add);
        async.elapse(const Duration(milliseconds: 10));
        final tailPolls = [
          for (final p in r.server.polls)
            if (p.uri.queryParametersAll['types'] != null) p,
        ];
        expect(tailPolls, isNotEmpty);
        expect(tailPolls.first.uri.queryParametersAll['types'], ['comment.*']);
        expect(tailPolls.first.uri.queryParameters.containsKey('wait'), false);
        expect(got.whereType<TailLive>(), hasLength(1));
        r.server
          ..addEvent(8, 'task.updated')
          ..addEvent(9, 'comment.added');
        async.elapse(const Duration(seconds: 1));
        expect(seqsOf(got), [9]);
        expect(r.seqs, containsAll([8, 9]));
      });
    });

    test('are told when the connection is refused', () {
      fakeAsync((async) {
        final r = Rig(refuse: 403);
        final got = <TailUpdate>[];
        r.live.tail().updates.listen(got.add);
        async.elapse(const Duration(seconds: 1));
        expect(r.mode, LiveMode.unavailable);
        final refusal = got.whereType<TailRefused>().single;
        expect(refusal.credential, isTrue);
        final after = <TailUpdate>[];
        r.live.tail().updates.listen(after.add);
        async.flushMicrotasks();
        expect(after.whereType<TailRefused>().single.code, 'forbidden');
      });
    });

    test('move to the WebSocket from their cursor when it works again', () {
      fakeAsync((async) {
        final r = Rig()..breakSocket(async);
        final got = <TailUpdate>[];
        final tail = r.live.tail(types: const ['task.*']);
        tail.updates.listen(got.add);
        r.server.addEvent(9, 'task.updated');
        async.elapse(const Duration(seconds: 1));
        expect(seqsOf(got), [9]);
        r.sockets.refuse = null;
        async.elapse(const Duration(minutes: 2));
        final probe = r.sockets.last;
        expect(probe.subscribes(tail.id), isEmpty);
        probe.ack('s1');
        async.flushMicrotasks();
        expect(r.mode, LiveMode.websocket);
        expect(probe.subscribes(tail.id).single['since_seq'], 9);
      });
    });

    test('cannot be served while refreshing on a timer', () {
      fakeAsync((async) {
        final r = Rig();
        r.server.pollSupported = false;
        r.breakSocket(async);
        expect(r.mode, LiveMode.refreshing);
        final got = <TailUpdate>[];
        r.live.tail().updates.listen(got.add);
        async.flushMicrotasks();
        expect(got.single, isA<TailUnsupported>());
      });
    });
  });
}

/// A poller that fails with each of [failures] in turn, then answers
/// empty pages.
class _ScriptedPoller implements EventPoller {
  final failures = <TixException>[];
  var _seq = 0;

  @override
  Future<EventPollPage> poll({
    required int sinceSeq,
    List<String> types = const [],
    List<String> projectIds = const [],
    Duration wait = Duration.zero,
    int limit = 200,
    CancelToken? cancel,
  }) async {
    if (failures.isNotEmpty) throw failures.removeAt(0);
    _seq = max(_seq, sinceSeq);
    return EventPollPage(events: const [], nextSeq: _seq);
  }
}
