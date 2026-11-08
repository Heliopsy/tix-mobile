// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_events.dart';
import '../../helpers/fake_tix.dart';

const config = LiveConfig(
  socketBackoff: Backoff(max: Duration(seconds: 1), jitter: 0),
  probeJitter: 0,
);

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;

  ProviderContainer signedIn(FakeAsync async) {
    final stores = signedInStores();
    final c = makeContainer([
      ...fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: sockets.connect,
      ),
      liveConfigProvider.overrideWithValue(config),
    ]);
    unawaited(c.read(sessionControllerProvider.future));
    async.elapse(Duration.zero);
    return c;
  }

  LiveMode? mode(ProviderContainer c) => c.read(liveStatusProvider).value?.mode;

  void breakSocket(FakeAsync async) {
    sockets.refuse = 502;
    unawaited(sockets.last.drop());
    async.elapse(const Duration(seconds: 3));
  }

  setUp(() {
    server = FakeTix();
    sockets = FakeEventSockets();
  });

  test('the status follows the transport', () {
    fakeAsync((async) {
      final c = signedIn(async);
      final sub = c.listen(liveStatusProvider, (_, _) {});
      addTearDown(sub.close);
      async.elapse(Duration.zero);
      expect(mode(c), LiveMode.connecting);
      sockets.last.ack();
      async.elapse(Duration.zero);
      expect(mode(c), LiveMode.websocket);
      breakSocket(async);
      expect(mode(c), LiveMode.polling);
      expect(c.read(liveStatusProvider).value?.lastError, isNotNull);
    });
  });

  test('without a poll endpoint the open list is read every 45 s', () {
    fakeAsync((async) {
      server.pollSupported = false;
      final c = signedIn(async);
      final status = c.listen(liveStatusProvider, (_, _) {});
      final list = c.listen(projectsProvider, (_, _) {});
      addTearDown(() {
        status.close();
        list.close();
      });
      async.elapse(Duration.zero);
      sockets.last.ack();
      async.elapse(Duration.zero);
      breakSocket(async);
      expect(mode(c), LiveMode.refreshing);
      final reads = server.requestsTo('/api/v1/projects').length;
      async.elapse(const Duration(seconds: 46));
      expect(server.requestsTo('/api/v1/projects'), hasLength(reads + 1));
      async.elapse(const Duration(seconds: 45));
      expect(server.requestsTo('/api/v1/projects'), hasLength(reads + 2));
    });
  });

  test('no context, no status', () {
    fakeAsync((async) {
      final c = makeContainer(fakeOverrides(server));
      unawaited(c.read(sessionControllerProvider.future));
      final sub = c.listen(liveStatusProvider, (_, _) {});
      addTearDown(sub.close);
      async.elapse(Duration.zero);
      expect(c.read(liveStatusProvider).value, isNull);
      expect(c.read(liveStatusProvider).hasValue, isTrue);
    });
  });
}
