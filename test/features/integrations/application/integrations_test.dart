// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/features/integrations/application/sync.dart';
import 'package:tix_mobile/src/features/integrations/application/webhooks.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_integrations.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeIntegrations fake;

  setUp(() {
    server = FakeTix();
    fake = FakeIntegrations(server);
  });

  test('endpoints load, save with a generated secret, and delete', () async {
    final c = await signedInContainer(server);
    final sub = c.listen(webhookEndpointsProvider, (_, _) {});
    addTearDown(sub.close);
    expect(await c.read(webhookEndpointsProvider.future), isEmpty);
    final notifier = c.read(webhookEndpointsProvider.notifier);
    final saved = await notifier.save(
      url: 'https://a.example',
      eventTypes: const [],
      active: true,
    );
    expect(saved.generatedSecret, isNotNull);
    expect(
      (await c.read(webhookEndpointsProvider.future)).single.url,
      'https://a.example',
    );
    await notifier.delete(saved.endpoint.id);
    expect(c.read(webhookEndpointsProvider).value, isEmpty);
    expect(fake.webhooks, isEmpty);
  });

  test('deliveries page, filter and redeliver', () async {
    server.pageSize = 2;
    fake.deliveries.addAll([
      for (var i = 0; i < 3; i++) deliveryJson('d$i'),
      deliveryJson('f1', status: 'failed'),
    ]);
    final c = await signedInContainer(server);
    final all = webhookDeliveriesProvider();
    final sub = c.listen(all, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(all.future)).items.length, 2);
    await c.read(all.notifier).loadMore();
    await c.read(all.notifier).loadMore();
    expect(c.read(all).value!.items.length, 4);
    final failed = webhookDeliveriesProvider(status: 'failed');
    final sub2 = c.listen(failed, (_, _) {});
    addTearDown(sub2.close);
    expect((await c.read(failed.future)).items.map((d) => d.status), [
      DeliveryStatus.failed,
    ]);
    await c.read(failed.notifier).redeliver('f1');
    expect(fake.redelivered, ['f1']);
  });

  test('sources check without saving, save, run and delete', () async {
    final c = await signedInContainer(server);
    final sub = c.listen(syncSourcesProvider, (_, _) {});
    addTearDown(sub.close);
    expect(await c.read(syncSourcesProvider.future), isEmpty);
    final n = c.read(syncSourcesProvider.notifier);
    const input = SyncSourceInput(name: 'jira-main', system: 'jira');
    final checked = await n.check(input);
    expect(server.requests.last.body['check'], isTrue);
    expect(checked.resolved!.missing, isNotEmpty);
    expect(fake.sources, isEmpty);
    final saved = await n.save(input);
    expect(server.requests.last.body.containsKey('check'), isFalse);
    expect((await c.read(syncSourcesProvider.future)).single.id, saved.id);
    final preview = await n.run(saved.id, dryRun: true);
    expect(preview.counts(), (created: 3, updated: 1, skipped: 7, deleted: 0));
    await n.run(saved.id);
    expect(fake.runs.last, {'source_id': saved.id});
    await n.delete(saved.id);
    expect(c.read(syncSourcesProvider).value, isEmpty);
  });

  test('run history reads each run from its audit entry', () async {
    server.pageSize = 1;
    fake.audit.addAll([
      auditJson(
        5,
        action: 'sync.run',
        subjectType: 'sync_source',
        after: {
          'source': 'jira-main',
          'system': 'jira',
          'created': {'task': 2},
        },
      ),
      auditJson(4, action: 'sync.run', subjectType: 'sync_source'),
    ]);
    final c = await signedInContainer(server);
    final sub = c.listen(syncRunsProvider, (_, _) {});
    addTearDown(sub.close);
    final first = await c.read(syncRunsProvider.future);
    expect(syncRunOf(first.items.single)!.counts().created, 2);
    await c.read(syncRunsProvider.notifier).loadMore();
    final second = c.read(syncRunsProvider).value!.items.last;
    expect(syncRunOf(second), isNull);
  });
}
