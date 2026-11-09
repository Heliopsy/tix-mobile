// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/invite_link.dart';
import 'package:tix_mobile/src/data/repositories/auth_repository.dart';
import 'package:tix_mobile/src/data/repositories/bundle_repository.dart';
import 'package:tix_mobile/src/data/repositories/server_info_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';
import 'package:tix_mobile/src/data/repositories/view_prefs_repository.dart';

import '../../helpers/fake_parity.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeParity parity;
  late TixApi api;
  late ResponseCache cache;

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
    api = server.factory('https://tix.example', const BearerCredential('tok'));
    cache = ResponseCache(MemoryCacheStore(), const CacheScope('c1', ''));
  });

  RequestOptions last() => server.requests.last;

  Matcher kind(TixErrorKind k) =>
      throwsA(isA<TixException>().having((e) => e.kind, 'kind', k));

  group('task detail', () {
    late TaskDetailRepository repo;
    setUp(() => repo = TaskDetailRepository(api, cache));

    test('transition sends one move with its comment', () async {
      final t = await repo.transition('infra-1', 'doing', comment: 'on it');
      expect(last().method, 'POST');
      expect(last().uri.path, '/api/v1/tasks/infra-1/transition');
      expect(last().body, {'to': 'doing', 'comment': 'on it'});
      expect(t.status, 'doing');
      await repo.transition('infra-1', 'done', comment: '');
      expect(last().body, {'to': 'done'});
    });

    test('lease reads the length and where it came from', () async {
      final lease = await repo.lease('infra-1');
      expect(last().uri.path, '/api/v1/tasks/infra-1/lease');
      expect(lease.ttl, '2h0m0s');
      expect(lease.source, LeaseSource.project);
      expect(lease.maxSource, LeaseSource.tenant);
    });

    test('task tags read what the server has now', () async {
      server.task('infra-1')!['tags'] = ['auth', 'urgent'];
      expect(await repo.taskTags('infra-1'), ['auth', 'urgent']);
      expect(last().uri.path, '/api/v1/tasks/infra-1/tags');
    });
  });

  test('a saved filter is read by name', () async {
    server.filters.add({'id': 'f1', 'name': 'Mine', 'query': 'assignee:me'});
    final repo = ViewPrefsRepository(api, cache);
    expect((await repo.filter('mine')).query, 'assignee:me');
    expect(last().uri.path, '/api/v1/filters/mine');
    await expectLater(repo.filter('nope'), kind(TixErrorKind.notFound));
  });

  group('server info', () {
    late ServerInfoRepository repo;
    setUp(() => repo = ServerInfoRepository(api, cache));

    test('status is read and kept for the next first draw', () async {
      final report = await repo.status();
      expect(report.installation?.version, 'v0.50.0');
      expect(report.servers, hasLength(2));
      expect((await repo.cachedStatus())?.work?.tasks, 17);
    });

    test('time reads every level and sets only what is named', () async {
      expect((await repo.time()).formatSource, 'tenant');
      final next = await repo.setTime(format: 'long');
      expect(last().method, 'PATCH');
      expect(last().uri.path, '/api/v1/me/time');
      expect(last().body, {'time_format': 'long'});
      expect(next.effective?.timeFormat, 'long');
      await repo.setTime(timezone: '');
      expect(last().body, {'timezone': ''});
    });
  });

  group('bundles', () {
    late BundleRepository repo;
    setUp(() => repo = BundleRepository(api));

    test('export names the kinds and the label', () async {
      final bytes = await repo.export(
        kinds: [ComponentKind.workflow, ComponentKind.fieldDef],
        name: 'Team setup',
      );
      expect(last().uri.path, '/api/v1/bundles/export');
      expect(last().body, {
        'kinds': ['workflow', 'field_def'],
        'name': 'Team setup',
      });
      // tix serves NDJSON as application/vnd.tix.bundle+json, which Dio
      // would try to decode as one JSON value; the file comes out as written.
      expect(
        utf8.decode(bytes),
        '{"record":"header","header":{"name":"Team setup"}}\n'
        '{"record":"component","kinds":2}\n',
      );
      server.failures['POST /api/v1/bundles/export'] = FakeResponse(
        403,
        envelope('forbidden', 'needs workflow:read'),
      );
      await expectLater(
        repo.export(),
        throwsA(
          isA<TixException>()
              .having((e) => e.kind, 'kind', TixErrorKind.forbidden)
              .having((e) => e.message, 'message', 'needs workflow:read'),
        ),
      );
      server.failures.clear();
      await repo.export();
      expect(last().body, {'kinds': <String>[]});
    });

    test('import previews, then applies with the collision rule', () async {
      final plan = await repo.import('{}', preview: true);
      expect(plan.preview, isTrue);
      expect(plan.outcomes.first.action, ComponentAction.created);
      expect(parity.bundleImports.last, {'preview': 'true', 'body': '{}'});
      await repo.import(
        '{}',
        preview: false,
        onCollision: BundleCollision.rename,
        projectRef: 'infra',
      );
      expect(parity.bundleImports.last, {
        'preview': 'false',
        'on_collision': 'rename',
        'project_ref': 'infra',
        'body': '{}',
      });
      expect(
        last().headers['content-type'] ?? last().contentType,
        contains('application/vnd.tix.bundle+json'),
      );
    });

    test('snapshot import sends the mode and the dry run', () async {
      final r = await repo.importSnapshot(
        '{"kind":"task"}\n',
        mode: SnapshotImportMode.replace,
        dryRun: true,
      );
      expect(r.dryRun, isTrue);
      expect(r.deleted, {'task': 1});
      expect(parity.snapshotImports.last['mode'], 'replace');
      expect(parity.snapshotImports.last['dry_run'], 'true');
    });
  });

  group('invites', () {
    late AuthRepository auth;
    const link = InviteLink(
      baseUrl: 'https://tix.example',
      token: 'tix_inv_new',
    );
    setUp(() {
      auth = AuthRepository(server.factory);
      parity.invites['tix_inv_new'] = FakeInvite(email: 'lee@example.com');
    });

    test('preview needs no credential', () async {
      final p = await auth.previewInvite(link);
      expect(p.email, 'lee@example.com');
      expect(p.tenantName, 'Default');
      expect(last().headers['Authorization'], isNull);
      expect(last().uri.path, '/api/v1/auth/invites/tix_inv_new');
    });

    test('accept sends the password and name for the cli surface', () async {
      await expectLater(
        auth.acceptInvite(link, password: ''),
        kind(TixErrorKind.passwordRequired),
      );
      expect(server.requests, isEmpty);
      final result = await auth.acceptInvite(
        link,
        password: 'correct horse battery',
        displayName: ' Lee ',
      );
      expect(result.session?.token, isNotEmpty);
      expect(last().body, {
        'password': 'correct horse battery',
        'display_name': 'Lee',
        'surface': 'cli',
      });
    });

    test('a token is rotated by the id whoami names, with a grace', () async {
      parity.tokenIds['tok'] = 'tk0';
      final issued = await auth.rotateToken(
        'https://tix.example',
        const BearerCredential('tok'),
      );
      expect(issued.token, 'tok-rotated-1');
      expect(last().uri.path, '/api/v1/tokens/tk0/rotate');
      expect(last().body, {'grace': '1m'});
    });

    test('a credential that is not a token cannot be rotated', () async {
      await expectLater(
        auth.rotateToken('https://tix.example', const BearerCredential('tok')),
        kind(TixErrorKind.tokenRequired),
      );
      expect(parity.rotations, isEmpty);
    });

    test('a wrong password on an existing account says so', () async {
      parity.invites['tix_inv_new'] = FakeInvite(
        email: 'ana@example.com',
        existing: true,
      );
      await expectLater(
        auth.acceptInvite(link, password: 'nope'),
        kind(TixErrorKind.badCredentials),
      );
    });
  });
}
