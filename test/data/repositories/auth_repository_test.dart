// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/auth.dart';
import 'package:tix_mobile/src/data/repositories/auth_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late AuthRepository auth;
  const base = 'https://tix.example';

  setUp(() {
    server = FakeTix();
    auth = AuthRepository(server.factory);
  });

  Matcher kind(TixErrorKind k) =>
      throwsA(isA<TixException>().having((e) => e.kind, 'kind', k));

  test('checkServer normalises and asks /healthz', () async {
    expect(await auth.checkServer('tix.example/api/v1'), base);
    expect(server.requests.single.uri.path, '/healthz');
    await expectLater(auth.checkServer('ftp://x'), kind(TixErrorKind.badUrl));
    server.override = FakeResponse(404, envelope('not_found', 'x'));
    await expectLater(auth.checkServer(base), kind(TixErrorKind.notTix));
    server.override = FakeResponse(503, envelope('upstream', 'x'));
    await expectLater(auth.checkServer(base), kind(TixErrorKind.upstream));
  });

  test('login refuses empty fields before calling', () async {
    await expectLater(
      auth.login(base, email: ' ', password: 'pw'),
      kind(TixErrorKind.emailRequired),
    );
    await expectLater(
      auth.login(base, email: 'a@b', password: ''),
      kind(TixErrorKind.passwordRequired),
    );
    await expectLater(
      auth.loginCode(base, ticket: 't', code: ' '),
      kind(TixErrorKind.codeRequired),
    );
    expect(server.requests, isEmpty);
  });

  test('a wrong password is bad credentials', () async {
    await expectLater(
      auth.login(base, email: 'ana@example.com', password: 'nope'),
      kind(TixErrorKind.badCredentials),
    );
  });

  test('a password and a code sign in', () async {
    server.requireCode = true;
    final first = await auth.login(
      base,
      email: ' ana@example.com ',
      password: 'pw',
    );
    expect(server.requests.single.body['email'], 'ana@example.com');
    expect(first.session, isNull);
    await expectLater(
      auth.loginCode(base, ticket: first.challenge!.ticket, code: '000000'),
      kind(TixErrorKind.badCredentials),
    );
    final done = await auth.loginCode(
      base,
      ticket: first.challenge!.ticket,
      code: ' ${FakeTix.goodCode} ',
    );
    expect(server.sessions.containsKey(done.session!.token), isTrue);
    expect(server.requests.last.data, {
      'ticket': first.challenge!.ticket,
      'code': FakeTix.goodCode,
      'surface': 'cli',
    });
  });

  test('an enrol challenge without its secret goes to the browser', () async {
    server.challengeKind = 'enrol';
    await expectLater(
      auth.login(base, email: 'ana@example.com', password: 'pw'),
      kind(TixErrorKind.secondFactorSetup),
    );
  });

  test('a password change comes back as a challenge, and the new password '
      'goes with the same email and password', () async {
    server.mustChangePassword.add('ana@example.com');
    final first = await auth.login(
      base,
      email: 'ana@example.com',
      password: 'pw',
    );
    expect(first.challenge?.kind, TOTPChallengeKind.passwordChange);
    final done = await auth.login(
      base,
      email: 'ana@example.com',
      password: 'pw',
      newPassword: 'a much longer one',
      remember: true,
    );
    expect(done.session, isNotNull);
    expect(server.requests.last.data, {
      'email': 'ana@example.com',
      'password': 'pw',
      'new_password': 'a much longer one',
      'surface': 'cli',
      'remember': true,
    });
  });

  test('an empty new password is not sent', () async {
    await expectLater(
      auth.login(
        base,
        email: 'ana@example.com',
        password: 'pw',
        newPassword: '',
      ),
      kind(TixErrorKind.newPasswordRequired),
    );
    expect(server.requests, isEmpty);
  });

  test('an enrol challenge carries its secret, and its code returns the '
      'recovery codes', () async {
    server.mustEnrol.add('ana@example.com');
    final first = await auth.login(
      base,
      email: 'ana@example.com',
      password: 'pw',
    );
    final challenge = first.challenge!;
    expect(challenge.kind, TOTPChallengeKind.enrol);
    expect(challenge.enrolment?.secret, FakeTix.enrolSecret);
    final done = await auth.loginCode(
      base,
      ticket: challenge.ticket,
      code: FakeTix.goodCode,
    );
    expect(done.session, isNotNull);
    expect(done.recoveryCodes, FakeTix.recoveryCodes);
  });

  test('switch and logout present the session cookie', () async {
    server
      ..tenants['acme'] = (name: 'Acme', host: '')
      ..accounts['ana@example.com'] = FakeAccount(
        password: 'pw',
        tenants: ['default', 'acme'],
      );
    final s = server.startSession('ana@example.com', 'default');
    final result = await auth.switchTenant(base, session: s, tenant: 'acme');
    expect(server.requests.single.headers['Cookie'], 'tix_session=$s');
    final me = await auth.whoami(
      base,
      SessionCredential(result.session!.token),
    );
    expect(me.tenantKey, 'acme');
    await auth.logout(base, result.session!.token);
    expect(server.sessions, isEmpty);
  });

  test('a switch to a tenant at its own address is refused', () async {
    server
      ..tenants['own'] = (name: 'Own', host: 'own.example')
      ..accounts['ana@example.com'] = FakeAccount(
        password: 'pw',
        tenants: ['default', 'own'],
      );
    final s = server.startSession('ana@example.com', 'default');
    await expectLater(
      auth.switchTenant(base, session: s, tenant: 'own'),
      kind(TixErrorKind.invalid),
    );
  });

  test('a token learns its tenant from GET /tenants/{id}', () async {
    final me = await auth.whoami(base, const BearerCredential('tok'));
    expect(me.tenantKey, 'default');
    expect(me.tenantName, 'Default');
    expect(server.requests.last.uri.path, '/api/v1/tenants/id-default');
  });

  test('a token that may not read its tenant stays unnamed', () async {
    server.narrowTokens.add('tok');
    final me = await auth.whoami(base, const BearerCredential('tok'));
    expect(me.tenantKey, '');
    expect(me.tenantId, 'id-default');
  });

  test('a failing tenant lookup is not hidden', () async {
    final failing = AuthRepository(
      (b, c, {tenant}) => TixApi(
        baseUrl: b,
        credential: c,
        adapter: FakeAdapter(
          (o) => o.uri.path.endsWith('/whoami')
              ? const FakeResponse(200, {'id': 'x', 'tenant_id': 't'})
              : FakeResponse(500, envelope('internal', 'boom')),
        ),
      ),
    );
    await expectLater(
      failing.whoami(base, const BearerCredential('tok')),
      kind(TixErrorKind.internal),
    );
  });

  test('a switch needing a second factor goes to the browser', () async {
    server
      ..tenants['acme'] = (name: 'Acme', host: '')
      ..switchNeedsSetup.add('acme')
      ..accounts['ana@example.com'] = FakeAccount(
        password: 'pw',
        tenants: ['default', 'acme'],
      );
    final s = server.startSession('ana@example.com', 'default');
    await expectLater(
      auth.switchTenant(base, session: s, tenant: 'acme'),
      kind(TixErrorKind.secondFactorSetup),
    );
  });

  test('an expired session switching is unauthenticated', () async {
    await expectLater(
      auth.switchTenant(base, session: 'gone', tenant: 'acme'),
      kind(TixErrorKind.unauthenticated),
    );
  });

  group('remember', () {
    Map<String, dynamic> loginBody(int i) =>
        server.requestsTo('/api/v1/auth/login')[i].data as Map<String, dynamic>;

    test('is sent with the step that completes the sign-in', () async {
      server.requireCode = true;
      final first = await auth.login(
        base,
        email: 'ana@example.com',
        password: 'pw',
        remember: true,
      );
      await auth.loginCode(
        base,
        ticket: first.challenge!.ticket,
        code: FakeTix.goodCode,
        remember: true,
      );
      expect(loginBody(0)['remember'], isTrue);
      expect(loginBody(1)['remember'], isTrue);
    });

    test('is left out when not asked for', () async {
      await auth.login(base, email: 'ana@example.com', password: 'pw');
      expect(loginBody(0).containsKey('remember'), isFalse);
    });

    test('the policy is read without a credential', () async {
      server.publicRoutes.add(
        (o, path) => path == '/api/v1/auth/session-policy'
            ? const FakeResponse(200, {
                'ttl': '12h0m0s',
                'remember_ttl': '720h0m0s',
              })
            : null,
      );
      final policy = await auth.sessionPolicy(base);
      expect(policy?.rememberTtl, '720h0m0s');
      expect(
        server.requestsTo('/api/v1/auth/session-policy').single.headers,
        isNot(contains('Authorization')),
      );
    });

    for (final (status, code) in [
      (404, 'not_found'),
      (401, 'unauthenticated'),
    ]) {
      test('a tix without the policy answering $status has none', () async {
        server.override = FakeResponse(status, envelope(code, 'x'));
        expect(await auth.sessionPolicy(base), isNull);
      });
    }

    test('any other failure reading the policy is not hidden', () async {
      server.override = FakeResponse(503, envelope('upstream', 'x'));
      await expectLater(auth.sessionPolicy(base), kind(TixErrorKind.upstream));
    });
  });
}
