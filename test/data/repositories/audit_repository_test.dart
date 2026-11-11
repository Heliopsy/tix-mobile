// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/wire.dart';
import 'package:tix_mobile/src/data/repositories/audit_repository.dart';

import '../../helpers/fake_integrations.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeIntegrations fake;
  late AuditRepository repo;

  setUp(() {
    server = FakeTix();
    fake = FakeIntegrations(server);
    repo = AuditRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
    );
    fake.audit.addAll([
      auditJson(3, action: 'task.update', via: 'api', token: 'ci'),
      auditJson(2, via: 'ssh', source: 'tui'),
      auditJson(1, actor: 'a1'),
    ]);
  });

  test('an empty query asks for everything, newest first', () async {
    final page = await repo.list(const AuditQuery());
    expect(page.items.map((e) => e.seq), [3, 2, 1]);
    expect(server.requests.last.uri.queryParametersAll, {
      'limit': ['50'],
      'sort': ['seq'],
      'direction': ['desc'],
    });
  });

  test(
    'each entry keeps the object tix sent, nothing added or dropped',
    () async {
      fake.audit.insert(0, {...auditJson(4, via: 'ssh'), 'novel': true});
      final page = await repo.list(const AuditQuery());
      final first = page.items.first;
      expect(wireJson(first), {...auditJson(4, via: 'ssh'), 'novel': true});
      expect((wireJson(first)!['via']! as Map).keys, ['kind']);
      expect(wireJson(page.items.last), auditJson(1, actor: 'a1'));
    },
  );

  test('every filter reaches the server', () async {
    final since = DateTime.utc(2026, 10);
    final until = DateTime.utc(2026, 11);
    await repo.list(
      AuditQuery(
        text: ' login ',
        actorId: 'a1',
        action: 'task.update',
        token: 'ci',
        vias: const {'api', 'ssh'},
        sources: const {Source.cli},
        since: since,
        until: until,
      ),
    );
    final q = server.requests.last.uri.queryParametersAll;
    expect(q['text'], ['login']);
    expect(q['actor_id'], ['a1']);
    expect(q['action'], ['task.update']);
    expect(q['token'], ['ci']);
    expect(q['via'], unorderedEquals(['api', 'ssh']));
    expect(q['source'], ['cli']);
    expect(q['since'], [since.toIso8601String()]);
    expect(q['until'], [until.toIso8601String()]);
  });

  test('filters narrow and the cursor pages', () async {
    expect(
      (await repo.list(const AuditQuery(vias: {'ssh'}))).items.single.seq,
      2,
    );
    server.pageSize = 2;
    final first = await repo.list(const AuditQuery());
    final next = await repo.list(const AuditQuery(), cursor: first.nextCursor);
    expect(next.items.single.seq, 1);
  });

  test('queries compare by value', () {
    expect(
      const AuditQuery(vias: {'a', 'b'}),
      const AuditQuery(vias: {'b', 'a'}),
    );
    expect(const AuditQuery().isEmpty, isTrue);
    expect(const AuditQuery(token: 'x').isEmpty, isFalse);
    final q = const AuditQuery().copyWith(since: () => DateTime.utc(2026));
    expect(q.copyWith(since: () => null).since, isNull);
    expect(q.copyWith(text: 'x').since, DateTime.utc(2026));
  });
}
