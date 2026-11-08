// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/time/reader_time.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  setUp(() {
    server = FakeTix()..keepsTime = true;
    stores = signedInStores();
  });

  Future<ProviderContainer> settled() async {
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    await c.read(sessionControllerProvider.future);
    final sub = c.listen(readerTimeStyleProvider, (_, _) {});
    addTearDown(sub.close);
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return c;
  }

  test('follows the effective preference the server resolves', () async {
    server
      ..timeGlobal['time_format'] = 'iso'
      ..timeTenant['time_format'] = 'long'
      ..timeUser['time_format'] = 'dotted'
      ..timeTenant['timezone'] = 'Europe/Sofia';
    final c = await settled();
    final style = c.read(readerTimeStyleProvider);
    expect(style.format, 'dotted');
    expect(style.zone?.name, 'Europe/Sofia');
    expect(stores.settings.values['time.c1.'], contains('dotted'));
  });

  test('without a level set, or from an older server, the device', () async {
    expect((await settled()).read(readerTimeStyleProvider).named, isFalse);
    server.keepsTime = false;
    expect((await settled()).read(readerTimeStyleProvider).named, isFalse);
  });

  test('opens in what was remembered while the server is down', () async {
    server.timeUser['time_format'] = 'us';
    await settled();
    server.override = FakeResponse(500, envelope('internal', 'down'));
    final c = await settled();
    expect(c.read(readerTimeStyleProvider).format, 'us');
  });

  test('setting a preference sends it and applies at once', () async {
    final c = await settled();
    await c.read(readerTimeProvider.notifier).set(timezone: 'UTC');
    expect(server.requestsTo('/me/time').last.body, {'timezone': 'UTC'});
    expect(c.read(readerTimeStyleProvider).zone, isNotNull);
    await c.read(readerTimeProvider.notifier).set(format: 'relative');
    expect(c.read(readerTimeStyleProvider).relative, isTrue);
  });
}
