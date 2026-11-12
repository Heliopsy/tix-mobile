// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/api/credential.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

import '../../helpers/container.dart';
import '../../helpers/fake_tix.dart';

void main() {
  final session = Session(
    instance: Instance(
      id: 'i',
      name: 'n',
      kind: InstanceKind.remote,
      baseUrl: 'https://x',
      createdAt: DateTime(2026),
    ),
    connection: Connection(
      id: 'c',
      instanceId: 'i',
      kind: ConnectionKind.token,
      createdAt: DateTime(2026),
    ),
    baseUrl: 'https://x',
    credential: const BearerCredential('t'),
  );
  const loading = AsyncLoading<Session?>();
  const out = AsyncData<Session?>(null);
  final signedIn = AsyncData<Session?>(session);

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
    expect(go(signedIn, '/connect?instance=i1'), isNull);
    expect(go(signedIn, '/connect?connection=s1'), isNull);
    expect(go(signedIn, '/connect?url=https%3A%2F%2Fa&email=x'), isNull);
    expect(go(signedIn, '/projects/infra/tasks/infra-1'), isNull);
  });

  test('a session reloading keeps the screen it is on', () async {
    final c = await signedInContainer(FakeTix());
    c.invalidate(sessionControllerProvider);
    final reloading = c.read(sessionControllerProvider);
    expect(reloading.isLoading, isTrue);
    expect(go(reloading, '/settings'), isNull);
  });

  test('moving to another context waits on the switching screen', () {
    String? moving(String location) =>
        redirectFor(signedIn, Uri.parse(location), moving: true);
    expect(moving('/projects/infra/tasks/infra-1'), '/switching');
    expect(moving('/settings'), '/switching');
    expect(moving('/switching'), isNull);
    expect(go(signedIn, '/switching'), '/projects');
    expect(go(out, '/switching'), '/connect');
  });

  test('a move without a target lands on the root of its tab', () {
    String? from(String location) => landingFrom(Uri.parse(location));
    expect(from('/projects/infra/tasks/infra-1'), '/projects');
    expect(from('/projects/infra/settings'), '/projects');
    expect(from('/tasks?filter=f1'), '/tasks');
    expect(from('/activity'), '/activity');
    expect(from('/events'), '/events');
    expect(from('/inbox'), '/inbox');
    expect(from('/mine'), '/mine');
    expect(from('/templates'), '/templates');
    expect(from('/manage/workflows/default'), '/manage');
    expect(from('/manage/users/u1'), '/manage');
    expect(from('/manage/fields/infra'), '/manage');
    expect(from('/settings/notifications/channels/ch1'), '/settings');
    expect(from('/settings/instances'), '/settings/instances');
    expect(from('/settings/about'), '/settings/about');
    expect(from('/switching'), isNull);
    expect(from('/'), isNull);
  });

  test('routes escape keys and refs', () {
    expect(Routes.project('a b'), '/projects/a%20b');
    expect(Routes.task('infra', 'infra-1'), '/projects/infra/tasks/infra-1');
    expect(Routes.addConnection('i 1'), '/connect?instance=i+1');
    expect(Routes.reconnect('s1'), '/connect?connection=s1');
    expect(
      Routes.addInstanceAt('https://own.example', email: 'a@b'),
      '/connect?url=https%3A%2F%2Fown.example&email=a%40b',
    );
    expect(Routes.addInstanceAt('https://x'), '/connect?url=https%3A%2F%2Fx');
  });
}
