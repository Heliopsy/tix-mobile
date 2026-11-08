// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/task.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late TixApi api;

  setUp(() {
    server = FakeTix();
    api = server.factory('https://tix.example/sub', 'tok');
  });

  test('health is read without a token from the server root', () async {
    final health = await server
        .factory('https://tix.example/sub', null)
        .health();
    expect(health.version, 'v1.2.3');
    final sent = server.requests.single;
    expect(sent.uri.toString(), 'https://tix.example/sub/healthz');
    expect(sent.headers.containsKey('Authorization'), isFalse);
  });

  test('whoami sends the bearer token under /api/v1', () async {
    final me = await api.whoami();
    expect(me.handle, 'ana');
    final sent = server.requests.single;
    expect(sent.uri.path, '/sub/api/v1/whoami');
    expect(sent.headers['Authorization'], 'Bearer tok');
  });

  test(
    'projects pass the cursor back and stop on an empty next_cursor',
    () async {
      server.pageSize = 1;
      final first = await api.projects();
      expect(first.items.map((p) => p.key), ['infra']);
      expect(first.nextCursor, '1');
      final second = await api.projects(cursor: first.nextCursor);
      expect(second.items.map((p) => p.key), ['web']);
      expect(second.hasMore, isFalse);
      expect(server.requests.first.uri.queryParameters, {'limit': '50'});
      expect(server.requests.last.uri.queryParameters['cursor'], '1');
    },
  );

  test('tasks are filtered by project and parsed', () async {
    final page = await api.tasks(project: 'infra');
    expect(server.requests.single.uri.queryParameters['project'], 'infra');
    final task = page.items.first;
    expect(task.ref, 'infra-1');
    expect(task.priority, 1);
    expect(task.tags, ['auth']);
    expect(task.dueAt, DateTime.utc(2026, 11, 20));
    expect(task.assigneeActorId, 'a1');
  });

  test('task and actor escape their path segment', () async {
    await expectLater(api.task('a/b'), throwsA(isA<TixException>()));
    expect(server.requests.single.uri.toString(), endsWith('/tasks/a%2Fb'));
    final actor = await api.actor('a1');
    expect(actor.label, 'Raj');
  });

  test('createTask posts the quick-add line with parse set', () async {
    final task = await api.createTask(
      const CreateTaskRequest(
        title: 'Ship it !high',
        projectRef: 'web',
        parse: true,
      ),
    );
    expect(task.ref, 'web-1');
    expect(server.requests.single.data, {
      'title': 'Ship it !high',
      'project_ref': 'web',
      'parse': true,
    });
  });

  group('errors', () {
    test('the envelope becomes a typed exception', () async {
      server.override = const FakeResponse(409, {
        'error': {
          'code': 'conflict',
          'message': 'stale version',
          'details': {'version': 3},
        },
      });
      final error = await api.whoami().then<Object?>(
        (_) => null,
        onError: (Object e) => e,
      );
      expect(error, isA<TixException>());
      final e = error! as TixException;
      expect(e.kind, TixErrorKind.conflict);
      expect(e.message, 'stale version');
      expect(e.status, 409);
      expect(e.requestId, 'req-1');
      expect(e.details, {'version': 3});
    });

    test('a refused token is unauthenticated', () async {
      final wrong = server.factory('https://tix.example', 'nope');
      await expectLater(
        wrong.whoami(),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.unauthenticated,
          ),
        ),
      );
    });

    test('a non-JSON answer is not tix', () async {
      server.override = const FakeResponse(200, '<html></html>', 'text/html');
      await expectLater(
        api.health(),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.notTix,
          ),
        ),
      );
    });

    test('a connection failure is a network error', () async {
      final api = TixApi(
        baseUrl: 'https://tix.example',
        adapter: FakeAdapter(
          (o) => throw DioException.connectionError(
            requestOptions: o,
            reason: 'refused',
          ),
        ),
      );
      await expectLater(
        api.health(),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.network,
          ),
        ),
      );
    });
  });
}
