// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';

import '../../helpers/fake_tix.dart';

/// Dry-run rows exactly as tix (the commit in tix.lock, `tix demo seed`)
/// answered `POST /projects/web/tasks/import` with `format: lines`.
final realRows = <String, Map<String, Object?>>{
  'Fix login !high #auth #ui @tom due:fri status:doing': {
    'action': 'create',
    'ref': 'web-14',
    'title': 'Fix login',
    'status': 'doing',
    'priority': 2,
    'assignee': 'tom',
    'tags': ['auth', 'ui'],
    'due': '2026-11-13T00:00:00Z',
  },
  'Fix login !high @nobody': {
    'action': 'error',
    'title': 'Fix login',
    'errors': ['assignee "nobody" is not a tix actor; map it to a handle'],
  },
  'x !!': {
    'action': 'create',
    'title': 'x !!',
    'status': 'todo',
    'priority': 3,
  },
  'Fix !low ^web-3': {
    'action': 'create',
    'title': 'Fix',
    'status': 'todo',
    'priority': 4,
    'parent': 'web-3',
  },
};

void main() {
  late FakeTix server;
  late TasksRepository repo;

  setUp(() {
    server = FakeTix()..previews.addAll(realRows);
    repo = TasksRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(MemoryCacheStore(), const CacheScope('c1', '')),
    );
  });

  test('preview dry-runs a plain title and the line in one import', () async {
    final p = await repo.preview(
      'web',
      'Fix login !high #auth #ui @tom due:fri status:doing',
    );
    final sent = server.requests.single;
    expect(sent.uri.path, '/api/v1/projects/web/tasks/import');
    expect(sent.body, {
      'content': 'x\nFix login !high #auth #ui @tom due:fri status:doing',
      'format': 'lines',
      'dry_run': true,
      'preview': 2,
    });
    expect(p.line.title, 'Fix login');
    expect(p.priority, 2);
    expect(p.status, 'doing');
    expect(p.line.tags, ['auth', 'ui']);
    expect(p.line.assignee, 'tom');
    expect(p.line.due, DateTime.utc(2026, 11, 13));
    expect(p.refusal, isNull);
  });

  test('defaults the server fills in are not reported as set', () async {
    final p = await repo.preview('web', 'x !!');
    expect(p.priority, isNull);
    expect(p.status, isNull);
    expect(p.line.title, 'x !!');
    final parent = await repo.preview('web', 'Fix !low ^web-3');
    expect(parent.priority, 4);
    expect(parent.line.parent, 'web-3');
  });

  test('a refused line carries the reason and no attributes', () async {
    final p = await repo.preview('web', 'Fix login !high @nobody');
    expect(p.refused, isTrue);
    expect(p.refusal, contains('"nobody" is not a tix actor'));
    expect(p.priority, isNull);
  });

  test('a forbidden dry run is a forbidden error', () async {
    server.importForbidden = true;
    await expectLater(
      repo.preview('web', 'a'),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.forbidden,
        ),
      ),
    );
  });

  test('tags and actors are read for completions', () async {
    expect((await repo.tags()).map((t) => t.name), ['auth', 'ops', 'backend']);
    final actors = await repo.actors();
    expect(actors.map((a) => a.handle), containsAll(['ana', 'raj']));
    expect(
      server.requestsTo('/api/v1/actors').single.uri.queryParameters['limit'],
      '500',
    );
  });
}
