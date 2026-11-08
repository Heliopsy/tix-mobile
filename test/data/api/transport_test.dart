// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/task.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeAdapter adapter;
  late FakeResponse Function(String path) answer;

  TixApi api({String? tenant}) => TixApi(
    baseUrl: 'https://tix.example',
    credential: const BearerCredential('tok'),
    tenant: tenant,
    adapter: adapter,
  );

  setUp(() {
    answer = (_) =>
        const FakeResponse(200, {'items': <Object?>[], 'next_cursor': ''});
    adapter = FakeAdapter((o) => answer(o.uri.path));
  });

  test('lists repeat, instants are UTC, absent values stay out', () async {
    await api().task.list(
      status: ['todo', 'doing'],
      priority: [1, 2],
      rootOnly: true,
      dueBefore: DateTime.utc(2026, 5),
      fieldFilters: {'severity': 'high'},
    );
    final uri = adapter.requests.single.uri;
    expect(uri.queryParametersAll['status'], ['todo', 'doing']);
    expect(uri.queryParametersAll['priority'], ['1', '2']);
    expect(uri.queryParameters['root_only'], 'true');
    expect(uri.queryParameters['due_before'], '2026-05-01T00:00:00.000Z');
    expect(uri.queryParameters['field.severity'], 'high');
    expect(uri.queryParameters.containsKey('cursor'), isFalse);
  });

  test('X-Tix-Tenant is sent only when named, X-Tix-Client never', () async {
    await api(tenant: 'acme').project.list();
    await api().project.list();
    expect(adapter.requests.first.headers['X-Tix-Tenant'], 'acme');
    expect(adapter.requests.last.headers.containsKey('X-Tix-Tenant'), isFalse);
    expect(adapter.requests.last.headers.containsKey('X-Tix-Client'), isFalse);
  });

  test('no content answers void, and null where content is optional', () async {
    answer = (_) => const FakeResponse(204, '');
    await api().task.star('a/b');
    expect(adapter.requests.single.uri.path, '/api/v1/tasks/a%2Fb/star');
    expect(adapter.requests.single.method, 'PUT');
    expect(await api().project.delete('web'), isNull);
    answer = (_) => const FakeResponse(200, {'project': 'web'});
    expect(await api().project.delete('web'), isNotNull);
  });

  test('a PATCH sends only the fields given', () async {
    answer = (_) => FakeResponse(200, taskJson('web-1'));
    await api().task.update('web-1', const UpdateTaskInput(title: 'x'));
    expect(adapter.requests.single.body, {'title': 'x'});
  });

  test('text, files and raw bodies', () async {
    answer = (_) => const FakeResponse(200, 'BEGIN:VCALENDAR', 'text/calendar');
    expect(await api().calendar.read('f.ics'), 'BEGIN:VCALENDAR');
    expect(adapter.requests.last.headers['Accept'], 'text/calendar');
    answer = (_) => const FakeResponse(200, 'PNG', 'image/png');
    expect(await api().project.icon('web'), 'PNG'.codeUnits);
    answer = (_) => const FakeResponse(200, <String, Object?>{});
    await api().snapshot.import('{"a":1}\n');
    expect(adapter.requests.last.contentType, 'application/x-ndjson');
    expect(adapter.requests.last.data, '{"a":1}\n');
  });

  test('NDJSON streams one item per line', () async {
    answer = (_) => FakeResponse(
      200,
      '${[taskJson('a-1'), taskJson('a-2')].map(jsonEncode).join('\n')}\n',
      'application/x-ndjson',
    );
    final refs = await api().task.listStream().map((t) => t.ref).toList();
    expect(refs, ['a-1', 'a-2']);
    expect(adapter.requests.single.headers['Accept'], 'application/x-ndjson');
  });

  test('a failed stream still yields the typed envelope', () async {
    answer = (_) => FakeResponse(403, envelope('forbidden', 'task:read'));
    await expectLater(
      api().task.listStream().toList(),
      throwsA(
        isA<TixException>()
            .having((e) => e.kind, 'kind', TixErrorKind.forbidden)
            .having((e) => e.message, 'message', 'task:read'),
      ),
    );
  });

  test('a non-object answer where one is expected is not tix', () async {
    answer = (_) => const FakeResponse(200, [1, 2]);
    await expectLater(
      api().task.show('a-1'),
      throwsA(
        isA<TixException>().having((e) => e.kind, 'kind', TixErrorKind.notTix),
      ),
    );
    answer = (_) => const FakeResponse(200, {'not': 'a list'});
    await expectLater(api().task.export('web'), throwsA(isA<TixException>()));
  });
}
