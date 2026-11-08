// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/features/connect/application/connect_flow.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late FakeParity parity;
  late MemorySecretStore secrets;
  const link = 'https://tix.example/invite/tix_inv_abc';

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
    secrets = MemorySecretStore();
    parity.invites['tix_inv_abc'] = FakeInvite(
      email: 'lee@example.com',
      displayName: 'Lee',
    );
  });

  (ProviderContainer, ConnectFlow) open() {
    final c = makeContainer(fakeOverrides(server, secrets: secrets));
    final p = connectFlowProvider('invite');
    c.listen(p, (_, _) {});
    return (c, c.read(p.notifier));
  }

  test('a pasted link is previewed without signing in', () async {
    final (_, flow) = open();
    final found = await flow.previewInvite('Join: $link');
    expect(found.link.baseUrl, 'https://tix.example');
    expect(found.preview.email, 'lee@example.com');
    expect(server.requestsTo('/healthz'), hasLength(1));
  });

  test('text that is not a link is refused before anything is sent', () async {
    final (_, flow) = open();
    await expectLater(
      flow.previewInvite('see you tomorrow'),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.badInviteLink,
        ),
      ),
    );
    expect(server.requests, isEmpty);
  });

  test('accepting adds the server and the sign-in, and opens it', () async {
    final (c, flow) = open();
    final found = await flow.previewInvite(link);
    await flow.acceptInvite(
      found.link,
      email: found.preview.email,
      password: 'correct horse battery',
      displayName: 'Lee',
    );
    expect(c.read(connectFlowProvider('invite')), isA<ConnectDone>());
    final session = c.read(sessionControllerProvider).value!;
    expect(session.instance.baseUrl, 'https://tix.example');
    expect(session.connection.kind, ConnectionKind.signIn);
    expect(session.connection.email, 'lee@example.com');
    expect(secrets.values.keys.single, startsWith('session.'));
    expect(parity.invites['tix_inv_abc']!.used, isTrue);
  });

  test('an account in several tenants chooses which to open', () async {
    server.tenants['ops'] = (name: 'Ops', host: '');
    parity.invites['tix_inv_abc'] = FakeInvite(
      email: 'ana@example.com',
      tenant: 'ops',
      existing: true,
    );
    final (c, flow) = open();
    final found = await flow.previewInvite(link);
    expect(found.preview.existingAccount, isTrue);
    await flow.acceptInvite(
      found.link,
      email: found.preview.email,
      password: 'pw',
    );
    final step = c.read(connectFlowProvider('invite'));
    expect(step, isA<ConnectTenants>());
    expect(
      (step as ConnectTenants).memberships.map((m) => m.tenantKey),
      containsAll(['default', 'ops']),
    );
  });
}
