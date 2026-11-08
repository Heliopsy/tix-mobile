// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/inbox/application/channels.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('adds, turns off, tests, redelivers and deletes a channel', () async {
    final server = FakeTix();
    final c = await signedInContainer(server);
    final sub = c.listen(channelsProvider, (_, _) {});
    addTearDown(sub.close);
    expect(await c.read(channelsProvider.future), isEmpty);
    final channels = c.read(channelsProvider.notifier);
    final created = await channels.add(
      const InboxChannelInput(
        name: 'ntfy',
        url: 'https://ntfy.sh/me',
        format: 'ntfy',
      ),
    );
    expect(created.secret, 'whsec_test');
    expect(c.read(channelsProvider).value!.single.id, created.id);

    await channels.setActive(created.listed, active: false);
    expect(c.read(channelsProvider).value!.single.active, isFalse);
    expect(server.channels.single['active'], isFalse);

    final deliveries = c.listen(
      channelDeliveriesProvider(created.id),
      (_, _) {},
    );
    addTearDown(deliveries.close);
    await channels.test(created.id);
    final page = await c.read(channelDeliveriesProvider(created.id).future);
    expect(page.items.single.status, DeliveryStatus.delivered);
    await c
        .read(channelDeliveriesProvider(created.id).notifier)
        .redeliver(page.items.single);
    expect(
      c.read(channelDeliveriesProvider(created.id)).value!.items.single.status,
      DeliveryStatus.pending,
    );

    await channels.delete(created.id);
    expect(c.read(channelsProvider).value, isEmpty);
  });

  test('a refused switch puts the channel back', () async {
    final server = FakeTix();
    server.channels.add({
      'id': 'x',
      'name': 'Slack',
      'url': 'https://h',
      'active': true,
    });
    final c = await signedInContainer(server);
    final sub = c.listen(channelsProvider, (_, _) {});
    addTearDown(sub.close);
    final channel = (await c.read(channelsProvider.future)).single;
    server.failing['/api/v1/channels/x'] = FakeResponse(
      403,
      envelope('forbidden', 'no'),
    );
    await expectLater(
      c.read(channelsProvider.notifier).setActive(channel, active: false),
      throwsA(anything),
    );
    expect(c.read(channelsProvider).value!.single.active, isTrue);
  });
}
