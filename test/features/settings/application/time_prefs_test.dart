// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/settings/application/time_prefs.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeParity parity;

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
  });

  test(
    'date settings load and keep the server answer after a change',
    () async {
      final c = await signedInContainer(server);
      c.listen(timePrefsStateProvider, (_, _) {});
      final first = await c.read(timePrefsStateProvider.future);
      expect(first.effective?.timeFormat, 'short');
      await c.read(timePrefsStateProvider.notifier).setFormat('long');
      expect(server.requests.last.body, {'time_format': 'long'});
      expect(c.read(timePrefsStateProvider).value?.formatSource, 'user');
      await c
          .read(timePrefsStateProvider.notifier)
          .setTimezone(' Europe/Sofia ');
      expect(server.requests.last.body, {'timezone': 'Europe/Sofia'});
      expect(
        c.read(timePrefsStateProvider).value?.effective?.timezone,
        'Europe/Sofia',
      );
      expect(parity.time['timezone_source'], 'user');
    },
  );
}
