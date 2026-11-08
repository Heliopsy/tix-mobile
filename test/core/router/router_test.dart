// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/server_context.dart';

import '../../helpers/container.dart';
import '../../helpers/fake_tix.dart';

void main() {
  const session = Session(
    context: ServerContext(id: 'c', name: 'n', baseUrl: 'https://x'),
    token: 't',
  );
  const loading = AsyncLoading<Session?>();
  const out = AsyncData<Session?>(null);
  const signedIn = AsyncData<Session?>(session);

  String? go(AsyncValue<Session?> s, String location) =>
      redirectFor(s, Uri.parse(location));

  test('while the session loads everything waits on the splash', () {
    expect(go(loading, '/'), isNull);
    expect(go(loading, '/projects'), '/');
  });

  test('signed out, everything leads to connect', () {
    expect(go(out, '/'), '/connect');
    expect(go(out, '/projects/infra'), '/connect');
    expect(go(out, '/connect'), isNull);
    expect(
      go(AsyncError<Session?>(Exception(), StackTrace.empty), '/settings'),
      '/connect',
    );
  });

  test('signed in, the splash and connect lead to projects', () {
    expect(go(signedIn, '/'), '/projects');
    expect(go(signedIn, '/connect'), '/projects');
    expect(go(signedIn, '/connect?add=1'), isNull);
    expect(go(signedIn, '/projects/infra/tasks/infra-1'), isNull);
  });

  test('a session reloading keeps the screen it is on', () async {
    final c = await signedInContainer(FakeTix());
    c.invalidate(sessionControllerProvider);
    final reloading = c.read(sessionControllerProvider);
    expect(reloading.isLoading, isTrue);
    expect(go(reloading, '/settings'), isNull);
  });

  test('routes escape keys and refs', () {
    expect(Routes.project('a b'), '/projects/a%20b');
    expect(Routes.task('infra', 'infra-1'), '/projects/infra/tasks/infra-1');
  });
}
