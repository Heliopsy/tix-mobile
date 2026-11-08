// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/events/event_poll.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late TixEventPoller poller;

  setUp(() {
    server = FakeTix();
    poller = TixEventPoller(
      server
          .factory('https://tix.example', const BearerCredential('tok'))
          .transport,
    );
  });

  test('reads the events after the cursor and the next cursor', () async {
    server
      ..addEvent(4, 'task.created')
      ..addEvent(5, 'task.updated')
      ..addEvent(6, 'comment.added');
    final page = await poller.poll(sinceSeq: 4, types: ['task.*'], limit: 2);
    expect(page.events.map((e) => e.seq), [5, 6]);
    expect(page.nextSeq, 6);
    final q = server.polls.single.uri.queryParameters;
    expect(q, {'since_seq': '4', 'types': 'task.*', 'limit': '2'});
  });

  test('without a cursor it starts at the newest event', () async {
    server.addEvent(12, 'task.created');
    final page = await poller.poll(
      sinceSeq: 0,
      wait: const Duration(seconds: 25),
    );
    expect(page.events, isEmpty);
    expect(page.nextSeq, 12);
    final q = server.polls.single.uri.queryParameters;
    expect(q.containsKey('since_seq'), isFalse);
    expect(q['wait'], '25s');
  });

  for (final status in [404, 405]) {
    test('$status means an older server', () async {
      server.pollAnswer = FakeResponse(status, envelope('not_found', 'route'));
      await expectLater(
        poller.poll(sinceSeq: 1),
        throwsA(isA<EventPollUnsupported>()),
      );
    });
  }

  test('a refusal stays a TixException', () async {
    server.pollAnswer = FakeResponse(403, envelope('forbidden', 'scope'));
    await expectLater(
      poller.poll(sinceSeq: 1),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.forbidden,
        ),
      ),
    );
  });

  test('an answer that is not a page is not tix', () async {
    server.pollAnswer = const FakeResponse(200, {'items': <Object?>[]});
    await expectLater(
      poller.poll(sinceSeq: 1),
      throwsA(
        isA<TixException>().having((e) => e.kind, 'kind', TixErrorKind.notTix),
      ),
    );
  });

  test('cancelling abandons the wait', () async {
    final cancel = CancelToken();
    final pending = poller.poll(
      sinceSeq: 1,
      wait: const Duration(seconds: 25),
      cancel: cancel,
    );
    cancel.cancel();
    await expectLater(pending, throwsA(isA<TixException>()));
  });
}
