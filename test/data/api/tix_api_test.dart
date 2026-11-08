// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/auth.dart';
import 'package:tix_mobile/src/data/models/task.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late TixApi api;

  setUp(() {
    server = FakeTix();
    api = server.factory(
      'https://tix.example/sub',
      const BearerCredential('tok'),
    );
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
      final wrong = server.factory(
        'https://tix.example',
        const BearerCredential('nope'),
      );
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

  group('sign-in', () {
    test('login posts the email, password and cli surface', () async {
      final result = await server
          .factory('https://tix.example', null)
          .login(const LoginRequest(email: 'ana@example.com', password: 'pw'));
      expect(result.session!.token, startsWith('sess-'));
      expect(result.challenge, isNull);
      final sent = server.requests.single;
      expect(sent.uri.path, '/api/v1/auth/login');
      expect(sent.data, {
        'email': 'ana@example.com',
        'password': 'pw',
        'surface': 'cli',
      });
      expect(sent.headers.containsKey('Authorization'), isFalse);
    });

    test('a code challenge carries its ticket', () async {
      server.requireCode = true;
      final result = await server
          .factory('https://tix.example', null)
          .login(const LoginRequest(email: 'ana@example.com', password: 'pw'));
      expect(result.session, isNull);
      expect(result.challenge!.kind, 'code');
      expect(result.challenge!.ticket, 'ticket-1');
    });

    test('a session is sent as the tix_session cookie, never bearer', () async {
      final session = server.startSession('ana@example.com', 'default');
      final me = await server
          .factory('https://tix.example', SessionCredential(session))
          .whoami();
      expect(me.memberships.single.tenantKey, 'default');
      final sent = server.requests.single;
      expect(sent.headers['Cookie'], 'tix_session=$session');
      expect(sent.headers.containsKey('Authorization'), isFalse);
    });

    test('switch posts the tenant and the code, logout ends it', () async {
      server
        ..tenants['acme'] = (name: 'Acme', host: '')
        ..accounts['ana@example.com'] = FakeAccount(
          password: 'pw',
          tenants: ['default', 'acme'],
        );
      final session = server.startSession('ana@example.com', 'default');
      final api = server.factory(
        'https://tix.example',
        SessionCredential(session),
      );
      final result = await api.switchTenant('acme', code: '1');
      expect(server.requests.single.data, {
        'tenant': 'acme',
        'code': '1',
        'surface': 'cli',
      });
      expect(server.sessions.containsKey(session), isFalse);
      final next = result.session!.token;
      await server
          .factory('https://tix.example', SessionCredential(next))
          .logout();
      expect(server.sessions.containsKey(next), isFalse);
    });

    test('logout maps a refusal', () async {
      await expectLater(
        server
            .factory('https://tix.example', const SessionCredential('gone'))
            .logout(),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.unauthenticated,
          ),
        ),
      );
    });

    test('credentials compare by kind and secret and hide it', () {
      expect(const BearerCredential('a'), const BearerCredential('a'));
      expect(const BearerCredential('a'), isNot(const SessionCredential('a')));
      expect(
        const BearerCredential('a').hashCode,
        const BearerCredential('a').hashCode,
      );
      expect(
        const SessionCredential('s3cret').toString(),
        isNot(contains('s3cret')),
      );
    });
  });
}
