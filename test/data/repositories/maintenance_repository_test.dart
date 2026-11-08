// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/maintenance_repository.dart';

import '../../helpers/fake_integrations.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeIntegrations fake;
  late MaintenanceRepository repo;
  late ResponseCache cache;

  setUp(() {
    server = FakeTix();
    fake = FakeIntegrations(server);
    cache = ResponseCache(MemoryCacheStore(), const CacheScope('c1', ''));
    repo = MaintenanceRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      cache,
    );
  });

  test('retention reads, saves only what is given, and prunes', () async {
    expect((await repo.retention()).events, '720h0m0s');
    expect((await repo.cachedRetention())!.auditEntries, '8760h0m0s');
    final saved = await repo.saveRetention(events: '240h');
    expect(server.requests.last.body, {'events': '240h'});
    expect(saved.events, '240h0m0s');
    final preview = await repo.prune(dryRun: true);
    expect(preview.dryRun, isTrue);
    await repo.prune();
    expect(fake.prunes, [true, false]);
    expect(server.requests.last.body, <String, dynamic>{});
  });

  test('housekeeping reads, saves and runs', () async {
    final view = await repo.housekeeping();
    expect(view.pending!.done, 4);
    expect((await repo.cachedHousekeeping())!.paused, isFalse);
    final saved = await repo.saveHousekeeping(done: '30', trash: 'off');
    expect(server.requests.last.body, {'done': '30', 'trash': 'off'});
    expect(saved.tenant!.done, 30);
    final preview = await repo.runHousekeeping(dryRun: true);
    expect(preview.done, 4);
    await repo.runHousekeeping();
    expect(fake.housekeepingRuns, [true, false]);
  });

  test('the trash lists trashed tasks a page at a time and restores', () async {
    server
      ..pageSize = 1
      ..trash['infra-7'] = taskJson('infra-7', title: 'Old')
      ..trash['infra-8'] = taskJson('infra-8', title: 'Older');
    final first = await repo.trash();
    expect(server.requests.last.uri.queryParameters['trashed'], 'true');
    expect(first.items.single.ref, 'infra-7');
    expect((await repo.cachedTrash())!.items.single.ref, 'infra-7');
    final second = await repo.trash(cursor: first.nextCursor);
    expect(second.items.single.ref, 'infra-8');
    final restored = await repo.restore('infra-7');
    expect(restored.ref, 'infra-7');
    expect(server.trash.containsKey('infra-7'), isFalse);
  });
}
