// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/dav/application/dav.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_dav.dart';
import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeTix server;
  late FakeDav dav;
  late FakeNotes notes;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  setUp(() {
    server = FakeTix();
    dav = FakeDav.on(server);
    notes = FakeNotes();
    stores = signedInStores();
  });

  Future<ProviderContainer> container() async {
    final c = makeContainer(
      fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        notes: notes,
      ),
    );
    await c.read(sessionControllerProvider.future);
    return c;
  }

  Future<DavStatus> status() async {
    final c = await container();
    c.listen(davStatusProvider, (_, _) {});
    return await c.read(davStatusProvider.future);
  }

  group('the status', () {
    test('ready, with the address and user name tix gave', () async {
      final s = await status() as DavReady;
      expect(s.address, 'https://tix.example/dav/');
      expect(s.info.username, 'ana@example.com');
      expect(s.write, isFalse);
    });

    test('ready on a server that does not know its own address', () async {
      dav.info = {...dav.info, 'url': ''};
      final s = await status() as DavReady;
      expect(s.address, 'https://tix.example/dav/');
    });

    test('write comes from the server, for phase 2', () async {
      dav.info = {...dav.info, 'write': true};
      expect((await status() as DavReady).write, isTrue);
    });

    test('turned off, with the reason', () async {
      dav.info = {'enabled': false, 'reason': 'turned off here'};
      final s = await status() as DavOff;
      expect(s.reason, 'turned off here');
    });

    test('a server without the route has not got it yet', () async {
      server = FakeTix();
      expect(await status(), isA<DavNotOffered>());
    });

    test('405 reads the same', () async {
      server.failing['/api/v1/dav'] = const FakeResponse(405);
      expect(await status(), isA<DavNotOffered>());
    });

    test(
      'a token tix refuses is not allowed, with a hint to sign in',
      () async {
        server.failing['/api/v1/dav'] = FakeResponse(
          403,
          envelope('forbidden', 'an agent cannot have an app password'),
        );
        final s = await status() as DavNotAllowed;
        expect(s.message, 'an agent cannot have an app password');
        expect(s.token, isTrue);
      },
    );

    test('a sign-in tix refuses gets no token hint', () async {
      stores = signInStores(server);
      server.failing['/api/v1/dav'] = FakeResponse(
        403,
        envelope('forbidden', 'needs task:read'),
      );
      expect((await status() as DavNotAllowed).token, isFalse);
    });

    test('a local instance asks nothing', () async {
      stores.settings.values
        ..clear()
        ..['storage.version'] = '2'
        ..['instances'] = jsonEncode([
          {
            'id': 'l1',
            'name': 'Notes',
            'kind': 'local',
            'db_path': '/data/notes.db',
            'created_at': '2026-11-01T00:00:00.000Z',
          },
        ])
        ..['connections'] = jsonEncode([
          {
            'id': 'k1',
            'instance_id': 'l1',
            'kind': 'token',
            'tenant_key': 'default',
            'created_at': '2026-11-01T00:00:00.000Z',
          },
        ])
        ..['context.active'] = jsonEncode({'connection_id': 'k1'});
      stores.secrets.values['token.k1'] = 'tok';
      expect(await status(), isA<DavLocal>());
      expect(server.requestsTo('/api/v1/dav'), isEmpty);
    });

    test('a server error is an error, for Retry', () async {
      server.failing['/api/v1/dav'] = FakeResponse(
        500,
        envelope('internal', 'x'),
      );
      final c = await container();
      c.listen(davStatusProvider, (_, _) {});
      await expectLater(c.read(davStatusProvider.future), throwsA(anything));
    });
  });

  group('app passwords', () {
    test('live first, newest first', () async {
      dav.passwords.addAll([
        {
          'id': 'p2',
          'name': 'gone',
          'created_at': '2026-10-25T00:00:00Z',
          'revoked_at': '2026-10-26T00:00:00Z',
        },
        {'id': 'p3', 'name': 'newer', 'created_at': '2026-10-28T00:00:00Z'},
        {
          'id': 'p4',
          'name': 'lapsed',
          'created_at': '2026-10-29T00:00:00Z',
          'expires_at': '2026-10-30T00:00:00Z',
        },
      ]);
      final c = await container();
      final list = await c.read(appPasswordsProvider.future);
      expect(list.map((p) => p.id), ['p3', 'p1', 'p4', 'p2']);
      expect(list.map((p) => davPasswordState(p, fixedNow)), [
        DavPasswordState.live,
        DavPasswordState.live,
        DavPasswordState.expired,
        DavPasswordState.revoked,
      ]);
    });

    test('create hands the value back and keeps it out of state', () async {
      final c = await container();
      c.listen(appPasswordsProvider, (_, _) {});
      await c.read(appPasswordsProvider.future);
      final issued = await c
          .read(appPasswordsProvider.notifier)
          .create(name: 'Mac', collections: 'all');
      expect(issued.password, dav.issued.single);
      final list = await c.read(appPasswordsProvider.future);
      expect(list.map((p) => p.name), contains('Mac'));
      expect(
        c.read(appPasswordsProvider).toString(),
        isNot(contains(dav.issued.single)),
      );
    });

    test('revoke reloads the row as revoked', () async {
      final c = await container();
      c.listen(appPasswordsProvider, (_, _) {});
      final p1 = (await c.read(appPasswordsProvider.future)).single;
      await c.read(appPasswordsProvider.notifier).revoke(p1);
      expect(dav.revoked, ['p1']);
      final after = (await c.read(appPasswordsProvider.future)).single;
      expect(davPasswordState(after, fixedNow), DavPasswordState.revoked);
    });

    test('a revoked or expired app password never marks the connection '
        'refused', () async {
      dav.passwords
        ..first['revoked_at'] = '2026-10-31T00:00:00Z'
        ..add({
          'id': 'p2',
          'name': 'lapsed',
          'expires_at': '2026-10-30T00:00:00Z',
        });
      final c = await container();
      c.listen(appPasswordsProvider, (_, _) {});
      await c.read(appPasswordsProvider.future);
      await c.read(appPasswordsProvider.notifier).create(name: 'new');
      await c.read(appPasswordsProvider.future);
      await pumpEventQueue();
      expect(
        c.read(instancesRepositoryProvider).connection('c1')?.refused,
        isFalse,
      );
      expect(c.read(sessionControllerProvider).value, isNotNull);
      expect(notes.shown, isEmpty);
    });

    test("a 401 on the list is the connection's own credential", () async {
      final c = await container();
      server.tokens.remove('tok');
      c.listen(appPasswordsProvider, (_, _) {});
      await expectLater(c.read(appPasswordsProvider.future), throwsA(anything));
      await pumpEventQueue();
      expect(
        c.read(instancesRepositoryProvider).connection('c1')?.refused,
        isTrue,
      );
      expect(c.read(sessionControllerProvider).value, isNull);
    });

    test('no request ever carries an app password', () async {
      final c = await container();
      c.listen(appPasswordsProvider, (_, _) {});
      await c.read(appPasswordsProvider.future);
      final issued = await c
          .read(appPasswordsProvider.notifier)
          .create(name: 'phone');
      await c.read(appPasswordsProvider.future);
      final p = (await c.read(appPasswordsProvider.future))
          .firstWhere((p) => p.id == issued.id);
      await c.read(appPasswordsProvider.notifier).revoke(p);
      await c.read(appPasswordsProvider.future);
      expect(server.requests, isNotEmpty);
      for (final r in server.requests) {
        final seen = '${r.uri} ${r.headers} ${jsonEncode(r.data)}';
        expect(seen, isNot(contains(issued.password)), reason: '${r.uri}');
        expect(r.uri.path, isNot(startsWith('/dav')));
      }
    });
  });
}
