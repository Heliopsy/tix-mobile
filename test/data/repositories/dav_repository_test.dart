// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/data/repositories/dav_repository.dart';

import '../../helpers/container.dart';
import '../../helpers/fake_dav.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeDav dav;
  late DavRepository repo;

  setUp(() async {
    server = FakeTix();
    dav = FakeDav.on(server);
    repo = (await signedInContainer(server)).read(davRepositoryProvider);
  });

  group('info', () {
    test('reads what tix answers', () async {
      final info = (await repo.info())!;
      expect(info.enabled, isTrue);
      expect(info.username, 'ana@example.com');
      expect(info.write, isFalse);
      expect(info.collections, ['assigned', 'projects', 'all']);
      expect(info.addressOn('https://other'), 'https://tix.example/dav/');
    });

    test('an empty url falls back to the path on the connection', () async {
      dav.info = {'enabled': true, 'path': '/dav/', 'url': ''};
      final info = (await repo.info())!;
      expect(
        info.addressOn('https://tix.example/'),
        'https://tix.example/dav/',
      );
      expect(info.addressOn('https://tix.example'), 'https://tix.example/dav/');
      expect(info.collections, isEmpty);
    });

    test('off says why', () async {
      dav.info = {'enabled': false, 'reason': 'caldav.enabled is false'};
      final info = (await repo.info())!;
      expect(info.enabled, isFalse);
      expect(info.reason, 'caldav.enabled is false');
    });

    test('a tix without the route answers null, 404 or 405', () async {
      for (final status in [404, 405]) {
        server.failing['/api/v1/dav'] = FakeResponse(
          status,
          envelope('not_found', 'no such route'),
        );
        expect(await repo.info(), isNull, reason: '$status');
      }
      server.failing.remove('/api/v1/dav');
      final bare = FakeTix();
      final plain = (await signedInContainer(bare)).read(davRepositoryProvider);
      expect(await plain.info(), isNull);
    });

    test("a refusal is the caller's", () async {
      server.failing['/api/v1/dav'] = FakeResponse(
        403,
        envelope('forbidden', 'an agent cannot have an app password'),
      );
      await expectLater(
        repo.info(),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.forbidden,
          ),
        ),
      );
    });
  });

  test('lists passwords, revoked ones included', () async {
    dav.passwords.add({
      'id': 'p2',
      'name': 'old',
      'collections': 'projects',
      'read_only': true,
      'created_at': '2026-09-01T00:00:00Z',
      'revoked_at': '2026-10-01T00:00:00Z',
      'scopes': null,
    });
    final list = await repo.passwords();
    expect(list.map((p) => p.id), ['p1', 'p2']);
    expect(list.last.revokedAt, DateTime.utc(2026, 10));
    expect(list.last.readOnly, isTrue);
    expect(list.last.collections, 'projects');
    expect(list.last.scopes, isEmpty);
    expect(list.first.lastUsedAt, DateTime.utc(2026, 10, 31, 8));
  });

  group('create', () {
    test('sends only the name when nothing else is chosen', () async {
      final issued = await repo.create(name: '  iPhone 2  ');
      expect(dav.created.single, {'name': 'iPhone 2'});
      expect(issued.password, dav.issued.single);
      expect(issued.username, 'ana@example.com');
      expect(issued.url, 'https://tix.example/dav/');
      expect('$issued', isNot(contains(dav.issued.single)));
    });

    test('sends the lists, read only and expiry in UTC', () async {
      await repo.create(
        name: 'desk',
        collections: DavCollections.projects,
        readOnly: true,
        expiresAt: DateTime.utc(2027, 1, 30),
      );
      expect(dav.created.single, {
        'name': 'desk',
        'collections': 'projects',
        'read_only': true,
        'expires_at': '2027-01-30T00:00:00.000Z',
      });
    });

    test("a name in use is tix's 409", () async {
      await expectLater(
        repo.create(name: 'iPhone'),
        throwsA(
          isA<TixException>()
              .having((e) => e.kind, 'kind', TixErrorKind.conflict)
              .having((e) => e.message, 'message', contains('iPhone')),
        ),
      );
    });
  });

  test('revokes by id', () async {
    await repo.revoke('p1');
    expect(dav.revoked, ['p1']);
    expect(
      server.requestsTo('/api/v1/dav/passwords/p1').single.method,
      'DELETE',
    );
  });
}
