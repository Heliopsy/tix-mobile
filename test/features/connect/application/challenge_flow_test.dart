// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/connect/application/connect_flow.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemorySecretStore secrets;
  const email = 'ana@example.com';
  const replacement = 'a much longer one';

  setUp(() {
    server = FakeTix();
    secrets = MemorySecretStore();
  });

  (ProviderContainer, ConnectFlow) open() {
    final c = makeContainer(fakeOverrides(server, secrets: secrets));
    final p = connectFlowProvider('challenges');
    c.listen(p, (_, _) {});
    return (c, c.read(p.notifier));
  }

  Future<(ProviderContainer, ConnectFlow)> signIn({
    bool remember = false,
  }) async {
    final (c, flow) = open();
    await flow.signIn(
      url: 'tix.example',
      email: email,
      password: 'pw',
      remember: remember,
    );
    return (c, flow);
  }

  List<Map<String, dynamic>> logins() => [
    for (final r in server.requestsTo('/api/v1/auth/login'))
      r.data as Map<String, dynamic>,
  ];

  Matcher kind(TixErrorKind k) =>
      throwsA(isA<TixException>().having((e) => e.kind, 'kind', k));

  void offerRemember() => server.publicRoutes.add(
    (o, path) => path == '/api/v1/auth/session-policy'
        ? const FakeResponse(200, {
            'ttl': '12h0m0s',
            'remember_ttl': '720h0m0s',
          })
        : null,
  );

  group('password change', () {
    setUp(() => server.mustChangePassword.add(email));

    test('asks for a new password and stores nothing yet', () async {
      final (c, _) = await signIn();
      expect(
        c.read(connectFlowProvider('challenges')),
        isA<ConnectPasswordChange>(),
      );
      expect(c.read(sessionControllerProvider).value, isNull);
      expect(secrets.values, isEmpty);
    });

    test('sends the email, the password and the new one, then signs '
        'in', () async {
      offerRemember();
      final (c, flow) = await signIn(remember: true);
      await flow.changePassword(
        password: 'pw',
        newPassword: replacement,
        confirm: replacement,
      );
      expect(logins().last, {
        'email': email,
        'password': 'pw',
        'new_password': replacement,
        'surface': 'cli',
        'remember': true,
      });
      expect(c.read(connectFlowProvider('challenges')), isA<ConnectDone>());
      expect(c.read(sessionControllerProvider).value?.connection.email, email);
      expect(server.changedPasswords[email], replacement);
    });

    test('two different passwords are refused before anything is '
        'sent', () async {
      final (c, flow) = await signIn();
      await expectLater(
        flow.changePassword(
          password: 'pw',
          newPassword: replacement,
          confirm: '$replacement!',
        ),
        kind(TixErrorKind.passwordMismatch),
      );
      expect(logins(), hasLength(1));
      expect(
        c.read(connectFlowProvider('challenges')),
        isA<ConnectPasswordChange>(),
      );
    });

    test('an empty new password is refused before anything is sent', () async {
      final (_, flow) = await signIn();
      await expectLater(
        flow.changePassword(password: 'pw', newPassword: '', confirm: ''),
        kind(TixErrorKind.newPasswordRequired),
      );
      expect(logins(), hasLength(1));
    });

    test('the server judges the new password, and the step stays '
        'open', () async {
      final (c, flow) = await signIn();
      await expectLater(
        flow.changePassword(
          password: 'pw',
          newPassword: 'short',
          confirm: 'short',
        ),
        kind(TixErrorKind.invalid),
      );
      expect(logins().last['new_password'], 'short');
      expect(
        c.read(connectFlowProvider('challenges')),
        isA<ConnectPasswordChange>(),
      );
    });
  });

  group('enrolment', () {
    setUp(() => server.mustEnrol.add(email));

    test('shows the secret, and the code shows the recovery codes before '
        'anything is saved', () async {
      final (c, flow) = await signIn();
      final step = c.read(connectFlowProvider('challenges'));
      expect(step, isA<ConnectEnrol>());
      expect((step as ConnectEnrol).enrolment.secret, FakeTix.enrolSecret);

      await flow.code(FakeTix.goodCode);
      final codes = c.read(connectFlowProvider('challenges'));
      expect(codes, isA<ConnectRecoveryCodes>());
      expect((codes as ConnectRecoveryCodes).codes, FakeTix.recoveryCodes);
      expect(logins().last['ticket'], step.ticket);
      expect(c.read(sessionControllerProvider).value, isNull);
      expect(secrets.values, isEmpty);

      await flow.codesSaved();
      expect(c.read(connectFlowProvider('challenges')), isA<ConnectDone>());
      expect(c.read(sessionControllerProvider).value?.connection.email, email);
      expect(
        secrets.values.values.where(FakeTix.recoveryCodes.contains),
        isEmpty,
      );
    });

    test('a wrong code keeps the step for another try', () async {
      final (c, flow) = await signIn();
      await expectLater(flow.code('000000'), kind(TixErrorKind.badCredentials));
      expect(c.read(connectFlowProvider('challenges')), isA<ConnectEnrol>());
    });

    test('the code step carries the remember choice', () async {
      offerRemember();
      final (_, flow) = await signIn(remember: true);
      await flow.code(FakeTix.goodCode);
      expect(logins().last['remember'], isTrue);
    });
  });

  test('a password change followed by enrolment goes through both', () async {
    server
      ..mustChangePassword.add(email)
      ..mustEnrol.add(email);
    final (c, flow) = await signIn();
    expect(
      c.read(connectFlowProvider('challenges')),
      isA<ConnectPasswordChange>(),
    );
    await flow.changePassword(
      password: 'pw',
      newPassword: replacement,
      confirm: replacement,
    );
    expect(c.read(connectFlowProvider('challenges')), isA<ConnectEnrol>());
    await flow.code(FakeTix.goodCode);
    expect(
      c.read(connectFlowProvider('challenges')),
      isA<ConnectRecoveryCodes>(),
    );
    await flow.codesSaved();
    expect(c.read(connectFlowProvider('challenges')), isA<ConnectDone>());
    expect(c.read(sessionControllerProvider).value?.connection.email, email);
  });
}
