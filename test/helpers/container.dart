// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/session/session.dart';

import 'app.dart';
import 'fake_tix.dart';

ProviderContainer makeContainer(List<Override> overrides) {
  final container = ProviderContainer(overrides: overrides, retry: noRetry);
  addTearDown(container.dispose);
  return container;
}

/// A container signed in to [server] through saved stores, with the session
/// already loaded.
Future<ProviderContainer> signedInContainer(FakeTix server) async {
  final stores = signedInStores();
  final c = makeContainer(
    fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
  );
  await c.read(sessionControllerProvider.future);
  return c;
}
