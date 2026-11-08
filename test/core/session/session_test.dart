// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/session.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemoryKeyValueStore settings;
  late MemorySecretStore secrets;

  setUp(() {
    server = FakeTix();
    settings = MemoryKeyValueStore();
    secrets = MemorySecretStore();
  });

  Future<TixErrorKind> refusal(Future<void> call) async {
    try {
      await call;
    } on TixException catch (e) {
      return e.kind;
    }
    fail('expected a TixException');
  }

  test('no saved context means no session', () async {
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    expect(await c.read(sessionControllerProvider.future), isNull);
  });

  test('a saved context without its token means no session', () async {
    final stores = signedInStores();
    stores.secrets.values.clear();
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    expect(await c.read(sessionControllerProvider.future), isNull);
  });

  test('connect checks the server and the token, then saves both', () async {
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    await c.read(sessionControllerProvider.future);
    await c
        .read(sessionControllerProvider.notifier)
        .connect(url: 'tix.example/', token: ' tok ');
    final session = c.read(sessionControllerProvider).value!;
    expect(session.context.baseUrl, 'https://tix.example');
    expect(session.context.name, 'tix.example');
    expect(session.context.handle, 'ana');
    expect(session.token, 'tok');
    expect(secrets.values.values, ['tok']);
    expect(server.requests.map((r) => r.uri.path), [
      '/healthz',
      '/api/v1/whoami',
    ]);
    expect(c.read(savedContextsProvider), hasLength(1));
  });

  test('connecting again as the same person reuses the context', () async {
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    final notifier = c.read(sessionControllerProvider.notifier);
    await c.read(sessionControllerProvider.future);
    await notifier.connect(url: 'https://tix.example', token: 'tok');
    await notifier.connect(
      url: 'https://tix.example',
      token: 'tok',
      name: 'Work',
    );
    expect(c.read(savedContextsProvider).map((s) => s.name), ['Work']);
  });

  test(
    'connect refuses a bad address or an empty token before calling',
    () async {
      final c = makeContainer(fakeOverrides(server));
      final notifier = c.read(sessionControllerProvider.notifier);
      expect(
        await refusal(notifier.connect(url: 'ftp://x', token: 'tok')),
        TixErrorKind.badUrl,
      );
      expect(
        await refusal(notifier.connect(url: 'tix.example', token: '  ')),
        TixErrorKind.tokenRequired,
      );
      expect(server.requests, isEmpty);
    },
  );

  test('connect reports a refused token and saves nothing', () async {
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    await c.read(sessionControllerProvider.future);
    expect(
      await refusal(
        c
            .read(sessionControllerProvider.notifier)
            .connect(url: 'tix.example', token: 'wrong'),
      ),
      TixErrorKind.unauthenticated,
    );
    expect(secrets.values, isEmpty);
    expect(c.read(sessionControllerProvider).value, isNull);
  });

  test('a server without /healthz is not tix', () async {
    server.override = FakeResponse(404, envelope('not_found', 'nope'));
    final c = makeContainer(fakeOverrides(server));
    expect(
      await refusal(
        c
            .read(sessionControllerProvider.notifier)
            .connect(url: 'tix.example', token: 'tok'),
      ),
      TixErrorKind.notTix,
    );
  });

  test('switchTo and signOut move between saved contexts', () async {
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    final notifier = c.read(sessionControllerProvider.notifier);
    expect((await c.read(sessionControllerProvider.future))!.context.id, 'c1');
    await notifier.connect(url: 'https://other.example', token: 'tok');
    final second = c.read(sessionControllerProvider).value!.context.id;
    expect(second, isNot('c1'));
    await notifier.switchTo('c1');
    expect(c.read(sessionControllerProvider).value!.context.id, 'c1');
    await notifier.signOut();
    expect(c.read(sessionControllerProvider).value!.context.id, second);
    expect(stores.secrets.values.keys, ['token.$second']);
    await notifier.signOut();
    expect(c.read(sessionControllerProvider).value, isNull);
    await notifier.signOut();
  });

  test('sessionApi needs a session and talks to its server', () async {
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    expect(
      () => c.read(sessionApiProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isStateError,
        ),
      ),
    );
    await c.read(sessionControllerProvider.future);
    final page = await c.read(tasksRepositoryProvider).projects();
    expect(page.items, hasLength(2));
    expect(server.requests.single.uri.host, 'tix.example');
    expect(server.requests.single.headers['Authorization'], 'Bearer tok');
  });
}
