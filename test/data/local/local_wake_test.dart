// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/local/local_wake.dart';

import '../../helpers/fake_tix.dart';

void main() {
  test('each request wakes the engine and goes where it serves now', () async {
    final server = FakeTix();
    final api = server.factory(
      'http://127.0.0.1:1',
      const BearerCredential('tok'),
    );
    var wakes = 0;
    var touches = 0;
    api.transport.dio.interceptors.insert(
      0,
      LocalWakeInterceptor(
        wake: ({required background}) async {
          wakes++;
          return ('http://127.0.0.1:4242', true);
        },
        done: () => touches++,
      ),
    );
    await api.identity.whoami();
    expect(wakes, 1);
    expect(touches, 1);
    expect(server.requests.single.uri.authority, '127.0.0.1:4242');
    expect(server.requests.single.persistentConnection, isFalse);
    server.tokens.clear();
    await expectLater(api.identity.whoami(), throwsA(isA<TixException>()));
    expect(touches, 2);
  });

  test('an engine that will not wake fails with its own error', () async {
    final server = FakeTix();
    final api =
        server.factory('http://127.0.0.1:1', const BearerCredential('tok'))
          ..transport.dio.interceptors.insert(
            0,
            LocalWakeInterceptor(
              wake: ({required background}) async =>
                  throw const TixException(TixErrorKind.engineUnavailable),
              done: () {},
            ),
          );
    await expectLater(
      api.identity.whoami(),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.engineUnavailable,
        ),
      ),
    );
    expect(server.requests, isEmpty);
  });

  test('a poll is background work, and only a held wake is released', () async {
    final server = FakeTix();
    final api = server.factory(
      'http://127.0.0.1:1',
      const BearerCredential('tok'),
    );
    final asked = <bool>[];
    var released = 0;
    api.transport.dio.interceptors.insert(
      0,
      LocalWakeInterceptor(
        wake: ({required background}) async {
          asked.add(background);
          return ('http://127.0.0.1:4242', !background);
        },
        done: () => released++,
      ),
    );
    await api.event.poll();
    expect(asked, [true]);
    expect(released, 0);
    await api.identity.whoami();
    expect(asked, [true, false]);
    expect(released, 1);
  });

  test('requests a predicate picks are background work', () async {
    final server = FakeTix();
    final asked = <bool>[];
    final api =
        server.factory('http://127.0.0.1:1', const BearerCredential('tok'))
          ..transport.dio.interceptors.insert(
            0,
            LocalWakeInterceptor(
              wake: ({required background}) async {
                asked.add(background);
                return ('http://127.0.0.1:4242', false);
              },
              done: () {},
              background: (o) => o.path.endsWith('/whoami'),
            ),
          );
    await api.identity.whoami();
    expect(asked, [true]);
  });
}
