// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
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

  test('enrolment and a password change go to the browser', () async {
    server.challengeKind = 'enrol';
    await expectLater(
      auth.login(base, email: 'ana@example.com', password: 'pw'),
      kind(TixErrorKind.secondFactorSetup),
    );
    server.challengeKind = 'password_change';
    await expectLater(
      auth.login(base, email: 'ana@example.com', password: 'pw'),
      kind(TixErrorKind.passwordChange),
    );
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
      (b, c) => TixApi(
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
}
