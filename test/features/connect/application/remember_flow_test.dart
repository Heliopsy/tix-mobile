// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/auth.dart';
import 'package:tix_mobile/src/features/connect/application/connect_flow.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemorySecretStore secrets;

  setUp(() {
    server = FakeTix();
    secrets = MemorySecretStore();
  });

  void offer(String ttl, String rememberTtl) => server.publicRoutes.add(
    (o, path) => path == '/api/v1/auth/session-policy'
        ? FakeResponse(200, {'ttl': ttl, 'remember_ttl': rememberTtl})
        : null,
  );

  (ProviderContainer, ConnectFlow) open() {
    final c = makeContainer(fakeOverrides(server, secrets: secrets));
    final p = connectFlowProvider('remember');
    c.listen(p, (_, _) {});
    return (c, c.read(p.notifier));
  }

  List<Object?> remembers() => [
    for (final r in server.requestsTo('/api/v1/auth/login'))
      (r.data as Map<String, dynamic>)['remember'],
  ];

  Future<ProviderContainer> signIn({required bool remember}) async {
    final (c, flow) = open();
    await flow.signIn(
      url: 'tix.example',
      email: 'ana@example.com',
      password: 'pw',
      remember: remember,
    );
    return c;
  }

  test('rememberOffered wants a remembered lifetime longer than the '
      'ordinary one', () {
    expect(rememberOffered(null), isFalse);
    expect(
      rememberOffered(
        const SessionPolicy(ttl: '12h0m0s', rememberTtl: '720h0m0s'),
      ),
      isTrue,
    );
    expect(
      rememberOffered(const SessionPolicy(ttl: '12h0m0s', rememberTtl: '0s')),
      isFalse,
    );
    expect(
      rememberOffered(
        const SessionPolicy(ttl: '12h0m0s', rememberTtl: '12h0m0s'),
      ),
      isFalse,
    );
  });

  test('asked for and offered, the sign-in is remembered', () async {
    offer('12h0m0s', '720h0m0s');
    final c = await signIn(remember: true);
    expect(remembers(), [true]);
    expect(
      c.read(sessionControllerProvider).value?.connection.email,
      'ana@example.com',
    );
  });

  test('not asked for, nothing is sent though it is offered', () async {
    offer('12h0m0s', '720h0m0s');
    await signIn(remember: false);
    expect(remembers(), [null]);
  });

  test('a tenant that turned it off is not asked', () async {
    offer('12h0m0s', '0s');
    await signIn(remember: true);
    expect(remembers(), [null]);
  });

  test('a tix that predates it is not sent the field and still signs '
      'in', () async {
    final c = await signIn(remember: true);
    expect(server.requestsTo('/api/v1/auth/session-policy'), hasLength(1));
    expect(remembers(), [null]);
    expect(c.read(sessionControllerProvider).value?.connection, isNotNull);
  });

  test('a second factor step carries the choice', () async {
    offer('12h0m0s', '720h0m0s');
    server.requireCode = true;
    final (_, flow) = open();
    await flow.signIn(
      url: 'tix.example',
      email: 'ana@example.com',
      password: 'pw',
      remember: true,
    );
    await flow.code(FakeTix.goodCode);
    expect(remembers(), [true, true]);
  });
}
