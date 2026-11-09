// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/integrations_repository.dart';

import '../../helpers/fake_integrations.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeIntegrations fake;
  late MemoryCacheStore store;
  late IntegrationsRepository repo;
  late List<String> logged;

  setUp(() {
    server = FakeTix();
    fake = FakeIntegrations(server);
    store = MemoryCacheStore();
    repo = IntegrationsRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(store, const CacheScope('c1', '')),
    );
    logged = [];
    final sink = logSink;
    logSink = (m, e, _) => logged.add('$m $e');
    addTearDown(() => logSink = sink);
  });

  String cached() => store.entries.values.expand((m) => m.values).join('\n');

  test(
    'a new endpoint with no secret hands back the one tix generated',
    () async {
      final saved = await repo.saveWebhook(
        url: 'https://hooks.example/tix',
        eventTypes: const ['task.*'],
        active: true,
      );
      expect(server.requests.last.body, {
        'url': 'https://hooks.example/tix',
        'event_types': ['task.*'],
        'active': true,
      });
      final secret = saved.generatedSecret!;
      expect(secret, startsWith('whsec-generated-'));
      expect(fake.secrets[saved.endpoint.id], secret);
      expect(saved.endpoint.toString(), isNot(contains(secret)));
    },
  );

  test('a secret of your own is sent and not handed back', () async {
    final saved = await repo.saveWebhook(
      url: 'https://hooks.example/tix',
      eventTypes: const [],
      active: false,
      secret: 'mine',
    );
    expect(saved.generatedSecret, isNull);
    expect(fake.secrets[saved.endpoint.id], 'mine');
  });

  test('an update with no secret keeps the stored one', () async {
    final first = await repo.saveWebhook(
      url: 'https://a.example',
      eventTypes: const [],
      active: true,
      secret: 'kept',
    );
    final again = await repo.saveWebhook(
      id: first.endpoint.id,
      url: 'https://b.example',
      eventTypes: const [],
      active: true,
    );
    expect(again.generatedSecret, isNull);
    expect(server.requests.last.body.containsKey('secret'), isFalse);
    expect(server.requests.last.body['id'], first.endpoint.id);
    expect(fake.secrets[first.endpoint.id], 'kept');
  });

  test('secrets never reach the cache or the log', () async {
    final saved = await repo.saveWebhook(
      url: 'https://hooks.example/tix',
      eventTypes: const [],
      active: true,
    );
    await repo.webhooks();
    await repo.saveSyncSource(
      const SyncSourceInput(
        name: 'jira-main',
        system: 'jira',
        token: 'sync-token-abcd1234',
        password: 'hunter22-password',
      ),
    );
    await repo.syncSources();
    expect(cached(), contains('hooks.example'));
    expect(logged, isNotEmpty);
    for (final secret in [
      saved.generatedSecret!,
      'sync-token-abcd1234',
      'hunter22-password',
    ]) {
      expect(cached(), isNot(contains(secret)));
      expect(logged.join('\n'), isNot(contains(secret)));
    }
  });

  test('sync sources are not cached at all', () async {
    await repo.saveSyncSource(
      const SyncSourceInput(name: 'jira-main', system: 'jira'),
    );
    await repo.syncSources();
    expect(cached(), isEmpty);
  });

  test('a refused endpoint keeps the server message', () async {
    await expectLater(
      repo.saveWebhook(url: 'http://x', eventTypes: const [], active: true),
      throwsA(
        isA<TixException>()
            .having((e) => e.kind, 'kind', TixErrorKind.invalid)
            .having((e) => e.message, 'message', contains('https')),
      ),
    );
  });

  test('deliveries filter by endpoint and status, newest first', () async {
    fake.deliveries.addAll([
      deliveryJson('d1'),
      deliveryJson('d2', status: 'failed', endpoint: 'wh2'),
    ]);
    final page = await repo.deliveries(
      endpointId: 'wh2',
      statuses: {DeliveryStatus.failed},
    );
    expect(page.items.map((d) => d.id), ['d2']);
    final q = server.requests.last.uri.queryParametersAll;
    expect(q['endpoint_id'], ['wh2']);
    expect(q['status'], ['failed']);
    expect(q['direction'], ['desc']);
    await repo.redeliver('d2');
    expect(fake.redelivered, ['d2']);
  });

  test('a test event answers the delivery tix queued', () async {
    final saved = await repo.saveWebhook(
      url: 'https://a.example',
      eventTypes: const [],
      active: true,
    );
    final delivery = await repo.ping(saved.endpoint.id);
    expect(server.requests.last.method, 'POST');
    expect(
      server.requests.last.uri.path,
      endsWith('/webhooks/${saved.endpoint.id}/ping'),
    );
    expect(delivery.status, DeliveryStatus.delivered);
    expect(delivery.lastStatusCode, 200);
    expect(fake.pinged, [saved.endpoint.id]);
  });

  test('delete removes an endpoint', () async {
    final saved = await repo.saveWebhook(
      url: 'https://a.example',
      eventTypes: const [],
      active: true,
    );
    await repo.deleteWebhook(saved.endpoint.id);
    expect(fake.webhooks, isEmpty);
  });

  test('sync: save, check, run and the run history', () async {
    final checked = await repo.saveSyncSource(
      const SyncSourceInput(name: 'jira-main', system: 'jira', check: true),
    );
    expect(checked.resolved!.missing, isNotEmpty);
    expect(fake.sources, isEmpty);
    final saved = await repo.saveSyncSource(
      const SyncSourceInput(name: 'jira-main', system: 'jira'),
    );
    final result = await repo.runSync(saved.id, dryRun: true, full: true);
    expect(fake.runs.single, {
      'source_id': saved.id,
      'dry_run': true,
      'full': true,
    });
    expect(result.dryRun, isTrue);
    expect(result.created['task'], 3);
    await repo.deleteSyncSource(saved.id);
    expect(fake.sources, isEmpty);
    fake.audit.addAll([
      auditJson(2, action: 'sync.run', subjectType: 'sync_source'),
      auditJson(1),
    ]);
    final runs = await repo.syncRuns();
    expect(runs.items.map((e) => e.seq), [2]);
    final q = server.requests.last.uri.queryParametersAll;
    expect(q['subject_type'], ['sync_source']);
    expect(q['action'], ['sync.run']);
    expect(q['sort'], ['seq']);
    expect(q['direction'], ['desc']);
  });
}
