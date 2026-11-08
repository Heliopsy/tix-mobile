// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/design/accent_provider.dart';
import 'package:tix_mobile/src/core/session/session.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  setUp(() {
    server = FakeTix();
    stores = signedInStores();
  });

  Future<TixAccent> settled() async {
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    await c.read(sessionControllerProvider.future);
    final sub = c.listen(tenantAccentProvider, (_, _) {});
    addTearDown(sub.close);
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    final accent = c.read(tenantAccentProvider);
    return accent;
  }

  bool fetchedTenant() => server.requests.any(
    (r) => r.method == 'GET' && r.uri.path == '/api/v1/tenants/default',
  );

  test('follows the theme the tenant names and remembers it', () async {
    server.tenantThemes['default'] = 'ember';
    expect((await settled()).name, 'ember');
    expect(fetchedTenant(), isTrue);
    expect(stores.settings.values['accent.c1.default'], 'ember');
  });

  test('a custom accent is derived', () async {
    server.tenantThemes['default'] = '#7a3ef0';
    expect((await settled()).accent, TixAccent.resolve('#7a3ef0').accent);
  });

  test('offline, it opens in the accent remembered for the context', () async {
    stores = signInStores(server);
    stores.settings.values['accent.s1.default'] = 'plum';
    server.override = FakeResponse(500, envelope('internal', 'down'));
    expect((await settled()).name, 'plum');
    expect(stores.settings.values['accent.s1.default'], 'plum');
  });

  test(
    'a tenant that names nothing is tix teal and forgets the old one',
    () async {
      stores.settings.values['accent.c1.default'] = 'plum';
      expect(await settled(), TixAccent.standard);
      expect(stores.settings.values.containsKey('accent.c1.default'), isFalse);
    },
  );

  test('without a context the accent is the default', () async {
    final c = makeContainer(fakeOverrides(server));
    await c.read(sessionControllerProvider.future);
    expect(c.read(tenantAccentProvider), TixAccent.standard);
    expect(fetchedTenant(), isFalse);
  });
}
