// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/maintenance/application/maintenance.dart';

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

  test('retention saves and prunes', () async {
    final c = await signedInContainer(server);
    final sub = c.listen(retentionProvider, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(retentionProvider.future)).events, '720h0m0s');
    await c.read(retentionProvider.notifier).save(events: '48h');
    expect(c.read(retentionProvider).value!.events, '48h0m0s');
    final r = await c.read(retentionProvider.notifier).prune(dryRun: true);
    expect(r.events, 172);
    expect(fake.prunes, [true]);
  });

  test('housekeeping saves, previews and runs', () async {
    final c = await signedInContainer(server);
    final sub = c.listen(housekeepingProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(housekeepingProvider.future);
    await c.read(housekeepingProvider.notifier).save(done: '14');
    expect(c.read(housekeepingProvider).value!.tenant!.done, 14);
    await c.read(housekeepingProvider.notifier).run(dryRun: true);
    await c.read(housekeepingProvider.notifier).run();
    expect(fake.housekeepingRuns, [true, false]);
  });

  test('restoring takes a task out of the trash list', () async {
    server.trash['infra-9'] = taskJson('infra-9', title: 'Gone');
    final c = await signedInContainer(server);
    final sub = c.listen(trashProvider, (_, _) {});
    addTearDown(sub.close);
    final paged = await c.read(trashProvider.future);
    final t = paged.items.single;
    await c.read(trashProvider.notifier).restore(t);
    expect(c.read(trashProvider).value!.items, isEmpty);
    expect(server.task('infra-9'), isNotNull);
  });

  test('purging deletes for good and reads the trash again', () async {
    server
      ..trash['infra-9'] = taskJson('infra-9', title: 'Gone')
      ..trash['infra-10'] = taskJson('infra-10', title: 'Also gone');
    final c = await signedInContainer(server);
    final sub = c.listen(trashProvider, (_, _) {});
    addTearDown(sub.close);
    final paged = await c.read(trashProvider.future);
    final listed = server.requests.where(
      (r) => r.uri.queryParameters['trashed'] == 'true',
    );
    expect(listed, hasLength(1));
    await c.read(trashProvider.notifier).purge(paged.items.first);
    final after = await c.read(trashProvider.future);
    expect(fake.purged, ['infra-9']);
    expect(after.items.map((t) => t.ref), ['infra-10']);
    await pumpEventQueue();
    expect(listed, hasLength(2));
    expect(server.task('infra-9'), isNull);
  });
}
