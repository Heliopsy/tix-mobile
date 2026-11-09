// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/platform/local_access.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/api/credential.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/eventually.dart';
import '../../helpers/fake_events.dart';
import '../../helpers/fake_local_access.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemoryKeyValueStore settings;
  late MemorySecretStore secrets;

  setUp(() {
    server = FakeTix();
    settings = MemoryKeyValueStore();
    secrets = MemorySecretStore();
  });

  Future<TixErrorKind> refusal(Future<void> call) async {
    try {
      await call;
    } on TixException catch (e) {
      return e.kind;
    }
    fail('expected a TixException');
  }

  test('no saved context means no session', () async {
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    expect(await c.read(sessionControllerProvider.future), isNull);
  });

  test('a saved context without its token means no session', () async {
    final stores = signedInStores();
    stores.secrets.values.clear();
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    expect(await c.read(sessionControllerProvider.future), isNull);
  });

  test('connect checks the server and the token, then saves both', () async {
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    await c.read(sessionControllerProvider.future);
    await c
        .read(sessionControllerProvider.notifier)
        .connect(url: 'tix.example/', token: ' tok ');
    final session = c.read(sessionControllerProvider).value!;
    expect(session.instance.baseUrl, 'https://tix.example');
    expect(session.instance.name, 'tix.example');
    expect(session.instance.kind, InstanceKind.remote);
    expect(session.connection.kind, ConnectionKind.token);
    expect(session.connection.handle, 'ana');
    expect(session.connection.tenantKey, 'default');
    expect(session.connection.pinned, isTrue);
    expect(session.credential, const BearerCredential('tok'));
    expect(secrets.values, {'token.${session.connection.id}': 'tok'});
    expect(settings.values.values.any((v) => v.contains('tok"')), isFalse);
    expect(server.requests.map((r) => r.uri.path), [
      '/healthz',
      '/api/v1/whoami',
      '/api/v1/tenants/id-default',
    ]);
    expect(c.read(contextDirectoryProvider).groups, hasLength(1));
  });

  test('connecting again as the same person reuses the connection', () async {
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    final notifier = c.read(sessionControllerProvider.notifier);
    await c.read(sessionControllerProvider.future);
    await notifier.connect(url: 'https://tix.example', token: 'tok');
    await notifier.connect(
      url: 'https://tix.example',
      token: 'tok',
      name: 'Work',
    );
    final groups = c.read(contextDirectoryProvider).groups;
    expect(groups, hasLength(1));
    expect(groups.single.connections.map((s) => s.label), ['Work']);
  });

  test('a token of another tenant is a second connection', () async {
    server
      ..tenants['acme'] = (name: 'Acme', host: '')
      ..tokens['tok2'] = 'acme';
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    final notifier = c.read(sessionControllerProvider.notifier);
    await c.read(sessionControllerProvider.future);
    await notifier.connect(url: 'https://tix.example', token: 'tok');
    final first = c.read(sessionControllerProvider).value!.instance.id;
    await notifier.connect(url: '', token: 'tok2', instanceId: first);
    final group = c.read(contextDirectoryProvider).groups.single;
    expect(group.connections.map((x) => x.tenantKey), ['default', 'acme']);
    expect(
      c.read(sessionControllerProvider).value!.connection.tenantName,
      'Acme',
    );
  });

  test(
    'connect refuses a bad address or an empty token before calling',
    () async {
      final c = makeContainer(fakeOverrides(server));
      final notifier = c.read(sessionControllerProvider.notifier);
      expect(
        await refusal(notifier.connect(url: 'ftp://x', token: 'tok')),
        TixErrorKind.badUrl,
      );
      expect(
        await refusal(notifier.connect(url: 'tix.example', token: '  ')),
        TixErrorKind.tokenRequired,
      );
      expect(server.requests, isEmpty);
    },
  );

  test('connect reports a refused token and saves nothing', () async {
    final c = makeContainer(
      fakeOverrides(server, settings: settings, secrets: secrets),
    );
    await c.read(sessionControllerProvider.future);
    expect(
      await refusal(
        c
            .read(sessionControllerProvider.notifier)
            .connect(url: 'tix.example', token: 'wrong'),
      ),
      TixErrorKind.unauthenticated,
    );
    expect(secrets.values, isEmpty);
    expect(c.read(sessionControllerProvider).value, isNull);
  });

  test('a server without /healthz is not tix', () async {
    server.override = FakeResponse(404, envelope('not_found', 'nope'));
    final c = makeContainer(fakeOverrides(server));
    expect(
      await refusal(
        c
            .read(sessionControllerProvider.notifier)
            .connect(url: 'tix.example', token: 'tok'),
      ),
      TixErrorKind.notTix,
    );
  });

  test('a migrated connection learns its tenant from whoami', () async {
    final c = await signedInContainer(server);
    await pumpEventQueue();
    final session = c.read(sessionControllerProvider).value!;
    expect(session.connection.id, 'c1');
    expect(session.connection.tenantKey, 'default');
    expect(session.connection.tenantName, 'Default');
    expect(
      c.read(instancesRepositoryProvider).connection('c1')!.tenantKey,
      'default',
    );
  });

  test('offline, the backfill leaves the connection as it was', () async {
    server.override = FakeResponse(503, envelope('upstream', 'down'));
    final c = await signedInContainer(server);
    await pumpEventQueue();
    expect(c.read(sessionControllerProvider).value!.connection.tenantKey, '');
  });

  test('activate and signOut move between saved contexts', () async {
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    final notifier = c.read(sessionControllerProvider.notifier);
    expect(
      (await c.read(sessionControllerProvider.future))!.connection.id,
      'c1',
    );
    await notifier.connect(url: 'https://other.example', token: 'tok');
    final second = c.read(sessionControllerProvider).value!.connection.id;
    expect(second, isNot('c1'));
    await notifier.activate(const ContextRef(connectionId: 'c1'));
    expect(c.read(sessionControllerProvider).value!.connection.id, 'c1');
    expect(
      c.read(contextDirectoryProvider).recent.map((e) => e.connection.id),
      ['c1', second],
    );
    await notifier.signOut();
    expect(c.read(sessionControllerProvider).value!.connection.id, second);
    expect(stores.secrets.values.keys, ['token.$second']);
    await notifier.signOut();
    expect(c.read(sessionControllerProvider).value, isNull);
    expect(c.read(contextDirectoryProvider).groups, isEmpty);
    await notifier.signOut();
    await notifier.activate(const ContextRef(connectionId: 'gone'));
  });

  test('sessionApi needs a session and talks to its server', () async {
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    expect(
      () => c.read(sessionApiProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isStateError,
        ),
      ),
    );
    await c.read(sessionControllerProvider.future);
    final page = await c.read(tasksRepositoryProvider).projects();
    expect(page.items, hasLength(2));
    final sent = server.requestsTo('/api/v1/projects').single;
    expect(sent.uri.host, 'tix.example');
    expect(sent.headers['Authorization'], 'Bearer tok');
  });

  group('sign-in', () {
    Actor me(String tenant, List<String> tenants) => Actor(
      id: 'me',
      handle: 'ana',
      tenantKey: tenant,
      tenantName: tenant,
      memberships: [for (final t in tenants) AccountMembership(tenantKey: t)],
    );

    test('saveSignIn keeps the session in secure storage only', () async {
      final c = makeContainer(
        fakeOverrides(server, settings: settings, secrets: secrets),
      );
      await c.read(sessionControllerProvider.future);
      final token = server.startSession('ana@example.com', 'default');
      await c
          .read(sessionControllerProvider.notifier)
          .saveSignIn(
            baseUrl: 'https://tix.example',
            email: ' ana@example.com ',
            session: token,
            me: me('default', ['default']),
            pinned: false,
          );
      final s = c.read(sessionControllerProvider).value!;
      expect(s.connection.kind, ConnectionKind.signIn);
      expect(s.connection.email, 'ana@example.com');
      expect(s.connection.switchable, isTrue);
      expect(s.credential, SessionCredential(token));
      expect(secrets.values, {'session.${s.connection.id}': token});
      expect(settings.values.values.any((v) => v.contains(token)), isFalse);
      final page = await c.read(tasksRepositoryProvider).projects();
      expect(page.items, isNotEmpty);
      final sent = server.requestsTo('/api/v1/projects').single;
      expect(sent.headers['Cookie'], 'tix_session=$token');
      expect(sent.headers.containsKey('Authorization'), isFalse);
    });

    test('a switchable connection switches tenant on the server', () async {
      server
        ..tenants['acme'] = (name: 'Acme', host: '')
        ..tenantProjects['acme'] = [
          {'id': 'p9', 'key': 'ops', 'name': 'Operations'},
        ];
      final stores = signInStores(server, tenants: ['default', 'acme']);
      final old = stores.secrets.values['session.s1']!;
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      final entries = c.read(contextDirectoryProvider).groups.single.entries;
      expect(entries.map((e) => e.tenantKey), ['default', 'acme']);
      await c
          .read(sessionControllerProvider.notifier)
          .activate(const ContextRef(connectionId: 's1', tenantKey: 'acme'));
      final s = c.read(sessionControllerProvider).value!;
      expect(s.connection.tenantKey, 'acme');
      expect(s.connection.tenantName, 'Acme');
      expect(server.requestsTo('/auth/switch').single.data, {
        'tenant': 'acme',
        'surface': 'cli',
      });
      final fresh = stores.secrets.values['session.s1']!;
      expect(fresh, isNot(old));
      expect(server.sessions.containsKey(old), isFalse);
      final page = await c.read(tasksRepositoryProvider).projects();
      expect(page.items.single.key, 'ops');
    });

    test('a switch asking for a code throws until one is sent', () async {
      server
        ..tenants['acme'] = (name: 'Acme', host: '')
        ..switchNeedsCode.add('acme');
      final stores = signInStores(server, tenants: ['default', 'acme']);
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      final notifier = c.read(sessionControllerProvider.notifier);
      const target = ContextRef(connectionId: 's1', tenantKey: 'acme');
      expect(
        await refusal(notifier.activate(target)),
        TixErrorKind.codeRequired,
      );
      expect(
        c.read(sessionControllerProvider).value!.connection.tenantKey,
        'default',
      );
      await notifier.activate(target, code: FakeTix.goodCode);
      expect(
        c.read(sessionControllerProvider).value!.connection.tenantKey,
        'acme',
      );
    });

    test('a pinned connection never switches', () async {
      server.tenants['acme'] = (name: 'Acme', host: '');
      final stores = signInStores(
        server,
        tenants: ['default', 'acme'],
        pinned: true,
      );
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      final entries = c.read(contextDirectoryProvider).groups.single.entries;
      expect(entries.map((e) => e.tenantKey), ['default']);
      await c
          .read(sessionControllerProvider.notifier)
          .activate(const ContextRef(connectionId: 's1', tenantKey: 'acme'));
      expect(server.requestsTo('/auth/switch'), isEmpty);
      expect(
        c.read(sessionControllerProvider).value!.connection.tenantKey,
        'default',
      );
    });

    test('setPinned flips a sign-in and leaves a token alone', () async {
      server.tenants['acme'] = (name: 'Acme', host: '');
      final stores = signInStores(server, tenants: ['default', 'acme']);
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      final notifier = c.read(sessionControllerProvider.notifier);
      await notifier.setPinned('s1', pinned: true);
      expect(
        c.read(sessionControllerProvider).value!.connection.pinned,
        isTrue,
      );
      expect(
        c.read(contextDirectoryProvider).groups.single.entries,
        hasLength(1),
      );
      await notifier.setPinned('s1', pinned: false);
      expect(
        c.read(contextDirectoryProvider).groups.single.entries,
        hasLength(2),
      );
      await notifier.setPinned('nope', pinned: true);
    });

    test('a tenant at its own address is listed but not recent', () async {
      server.tenants['own'] = (name: 'Own', host: 'own.example');
      final stores = signInStores(server, tenants: ['default', 'own']);
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      final entries = c.read(contextDirectoryProvider).groups.single.entries;
      expect(entries.last.elsewhere, 'own.example');
      expect(entries.first.elsewhere, '');
    });

    test('removing a sign-in ends its session on the server', () async {
      final stores = signInStores(server);
      final token = stores.secrets.values['session.s1']!;
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      await c.read(sessionControllerProvider.notifier).removeConnection('s1');
      expect(server.sessions.containsKey(token), isFalse);
      expect(stores.secrets.values, isEmpty);
      expect(c.read(sessionControllerProvider).value, isNull);
    });

    test('an expired session is still removed', () async {
      final stores = signInStores(server);
      server.sessions.clear();
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      await c.read(sessionControllerProvider.notifier).removeInstance('i1');
      expect(stores.secrets.values, isEmpty);
      expect(c.read(contextDirectoryProvider).groups, isEmpty);
    });

    test('signing in again keeps the connection', () async {
      final stores = signInStores(server);
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      final token = server.startSession('ana@example.com', 'default');
      await c
          .read(sessionControllerProvider.notifier)
          .saveSignIn(
            baseUrl: 'https://tix.example',
            email: 'ana@example.com',
            session: token,
            me: me('default', ['default']),
            pinned: false,
            replacing: 's1',
          );
      expect(stores.secrets.values, {'session.s1': token});
      expect(
        c.read(contextDirectoryProvider).groups.single.connections,
        hasLength(1),
      );
    });
  });

  group('local', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    Future<void> addLocal(
      ProviderContainer c,
      InMemoryLocalTixEngine engine,
      String dbPath, {
      bool inPlace = false,
      String bookmark = '',
    }) async {
      final handle = await engine.start(dbPath: dbPath);
      final token = await engine.token(
        handle,
        tenant: 'default',
        name: 'tix-mobile',
      );
      server.tokens[token] = 'default';
      await c
          .read(sessionControllerProvider.notifier)
          .saveLocal(
            dbPath: dbPath,
            handle: handle,
            tenant: const TenantRef(key: 'default', name: 'Default'),
            token: token,
            inPlace: inPlace,
            bookmark: bookmark,
          );
    }

    Future<({ProviderContainer c, InMemoryLocalTixEngine engine})>
    localContainer({
      FakeFilePicking? files,
      FakeLocalFileAccess? access,
      bool inPlace = false,
      FakeEventSockets? sockets,
    }) async {
      final engine = InMemoryLocalTixEngine();
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: settings,
          secrets: secrets,
          engine: engine,
          files: files,
          access: access,
          events: sockets?.connect ?? refusingEventSocket,
        ),
      );
      await c.read(sessionControllerProvider.future);
      await addLocal(
        c,
        engine,
        '/data/notes.db',
        inPlace: inPlace,
        bookmark: inPlace ? 'bm1' : '',
      );
      return (c: c, engine: engine);
    }

    ProviderContainer relaunch(InMemoryLocalTixEngine engine) => makeContainer(
      fakeOverrides(
        server,
        settings: settings,
        secrets: secrets,
        engine: engine,
      ),
    );

    test('switching between local instances stops the first', () async {
      final (:c, :engine) = await localContainer();
      final a = engine.running.single;
      await addLocal(c, engine, '/data/b.db');
      expect(engine.running, hasLength(1));
      expect(engine.stopped.first.id, a);
      final b = engine.running.single;
      final first = c
          .read(contextDirectoryProvider)
          .groups
          .first
          .connections
          .single;
      await c.read(sessionControllerProvider.notifier).activate(first.ref);
      expect(engine.stopped.map((h) => h.id), [a, b]);
      expect(engine.running, hasLength(1));
      expect(c.read(localEnginesProvider).running, [first.instanceId]);
    });

    test('launching with a remote context starts no engine', () async {
      final (:c, engine: _) = await localContainer();
      await c
          .read(sessionControllerProvider.notifier)
          .connect(url: 'tix.example', token: 'tok');
      final fresh = InMemoryLocalTixEngine(existing: ['/data/notes.db']);
      final again = relaunch(fresh);
      final s = await again.read(sessionControllerProvider.future);
      expect(s!.instance.kind, InstanceKind.remote);
      expect(again.read(contextDirectoryProvider).groups, hasLength(2));
      expect(fresh.started, isEmpty);
    });

    test('launching with a local context starts its engine', () async {
      await localContainer();
      final fresh = InMemoryLocalTixEngine(existing: ['/data/notes.db']);
      final again = relaunch(fresh);
      final s = await again.read(sessionControllerProvider.future);
      expect(s!.instance.kind, InstanceKind.local);
      expect(fresh.started, ['/data/notes.db']);
    });

    test('a resting engine starts again for the next request', () async {
      final (:c, :engine) = await localContainer();
      final s = c.read(sessionControllerProvider).value!;
      final engines = c.read(localEnginesProvider);
      await engines.rest(s.instance.id);
      expect(engine.running, isEmpty);
      final page = await c.read(tasksRepositoryProvider).projects();
      expect(page.items, isNotEmpty);
      expect(engine.running, hasLength(1));
      expect(engine.started, ['/data/notes.db', '/data/notes.db']);
      expect(
        server.requestsTo('/api/v1/projects').single.uri.authority,
        Uri.parse(s.baseUrl).authority,
      );
    });

    test('a poll neither wakes a resting engine nor holds it', () async {
      final (:c, :engine) = await localContainer();
      final s = c.read(sessionControllerProvider).value!;
      final engines = c.read(localEnginesProvider);
      final poller = TixEventPoller(c.read(sessionApiProvider));
      await poller.poll(sinceSeq: 0);
      expect(server.polls, hasLength(1));
      await engines.rest(s.instance.id);
      await expectLater(
        poller.poll(sinceSeq: 0),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.engineUnavailable,
          ),
        ),
      );
      expect(engine.running, isEmpty);
      expect(server.polls, hasLength(1));
    });

    test('coming back starts a resting engine', () async {
      final (:c, :engine) = await localContainer();
      final s = c.read(sessionControllerProvider).value!;
      await c.read(localEnginesProvider).rest(s.instance.id);
      expect(engine.running, isEmpty);
      await c.read(sessionControllerProvider.notifier).wakeLocal();
      expect(engine.running, hasLength(1));
      expect(
        c.read(localEnginesProvider).statuses[s.instance.id]?.state,
        LocalEngineState.running,
      );
    });

    test('live updates sleep with the engine and wake with it', () async {
      final sockets = FakeEventSockets();
      final (:c, engine: _) = await localContainer(sockets: sockets);
      final s = c.read(sessionControllerProvider).value!;
      final live = c.read(tixEventStreamProvider)!;
      final sub = live.updates.listen((_) {});
      addTearDown(sub.cancel);
      await eventually(
        () => sockets.sockets.isNotEmpty && sockets.last.sent.isNotEmpty,
      );
      final first = sockets.last..ack();
      await eventually(() => live.status.mode == LiveMode.websocket);
      await c.read(localEnginesProvider).rest(s.instance.id);
      expect(live.status.mode, LiveMode.paused);
      await eventually(() => first.closed);
      expect(sockets.sockets, hasLength(1));
      await c.read(sessionControllerProvider.notifier).wakeLocal();
      expect(c.read(tixEventStreamProvider), same(live));
      await eventually(() => sockets.sockets.length == 2);
      expect(live.status.mode, LiveMode.connecting);
      expect(server.polls, isEmpty);
    });

    test('an engine that will not wake fails the request', () async {
      final access = FakeLocalFileAccess();
      final (:c, :engine) = await localContainer(access: access, inPlace: true);
      final s = c.read(sessionControllerProvider).value!;
      await c.read(localEnginesProvider).rest(s.instance.id);
      access.denied = const TixException(TixErrorKind.localAccessDenied);
      await expectLater(
        c.read(tasksRepositoryProvider).projects(),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.localAccessDenied,
          ),
        ),
      );
      expect(engine.running, isEmpty);
    });

    test('a renewed bookmark is saved on the instance', () async {
      final access = FakeLocalFileAccess();
      final (:c, engine: _) = await localContainer(
        access: access,
        inPlace: true,
      );
      final s = c.read(sessionControllerProvider).value!;
      expect(s.instance.inPlace, isTrue);
      expect(s.instance.bookmark, 'bm1');
      await c.read(localEnginesProvider).rest(s.instance.id);
      access.grant = const AccessGrant(
        dbPath: '/data/notes.db',
        bookmark: 'bm2',
      );
      await c.read(tasksRepositoryProvider).projects();
      await pumpEventQueue();
      expect(
        c.read(instancesRepositoryProvider).instance(s.instance.id)!.bookmark,
        'bm2',
      );
    });

    test('a local instance is served by its engine', () async {
      final (:c, :engine) = await localContainer();
      final s = c.read(sessionControllerProvider).value!;
      expect(s.instance.kind, InstanceKind.local);
      expect(s.instance.name, 'notes');
      expect(s.baseUrl, startsWith('http://127.0.0.1:'));
      expect(s.connection.tenantKey, 'default');
      expect(engine.started, ['/data/notes.db']);
      expect(secrets.values.values.single, 'local-default-1');
      final page = await c.read(tasksRepositoryProvider).projects();
      expect(page.items, isNotEmpty);
      expect(
        server.requestsTo('/api/v1/projects').single.uri.host,
        '127.0.0.1',
      );
    });

    test(
      'export stops the engine for a whole file, then restarts it',
      () async {
        final files = FakeFilePicking(desktop: false);
        final (:c, :engine) = await localContainer(files: files);
        final s = c.read(sessionControllerProvider).value!;
        final first = engine.running.single;
        final done = await c
            .read(sessionControllerProvider.notifier)
            .exportLocal(s.instance.id);
        expect(done, isTrue);
        expect(files.exports, ['/data/notes.db']);
        expect(engine.running, isNot(contains(first)));
        expect(engine.running, hasLength(1));
        expect(c.read(sessionControllerProvider).value!.problem, isNull);
        expect(
          await c.read(sessionControllerProvider.notifier).exportLocal('nope'),
          isFalse,
        );
      },
    );

    test('an engine back on another port rebuilds the session', () async {
      final (:c, :engine) = await localContainer();
      final before = c.read(sessionControllerProvider).value!.baseUrl;
      final engines = c.read(localEnginesProvider);
      await engines.suspend();
      engine.taken.add(Uri.parse(before).authority);
      await engines.resume();
      await pumpEventQueue();
      final after = await c.read(sessionControllerProvider.future);
      expect(after!.baseUrl, isNot(before));
      expect(after.baseUrl, startsWith('http://127.0.0.1:'));
    });

    test('switching to a remote context stops the engine', () async {
      final (:c, :engine) = await localContainer();
      await c
          .read(sessionControllerProvider.notifier)
          .connect(url: 'tix.example', token: 'tok');
      expect(engine.running, isEmpty);
      expect(engine.stopped, hasLength(1));
      final local = c
          .read(contextDirectoryProvider)
          .groups
          .first
          .connections
          .single;
      await c.read(sessionControllerProvider.notifier).activate(local.ref);
      expect(engine.started, ['/data/notes.db', '/data/notes.db']);
      expect(engine.running, hasLength(1));
      await c
          .read(sessionControllerProvider.notifier)
          .removeInstance(local.instanceId);
      expect(engine.running, isEmpty);
    });

    test('an engine that will not start is the session problem', () async {
      settings.values['storage.version'] = '2';
      settings.values['instances'] = jsonEncode([
        {
          'id': 'l1',
          'name': 'Notes',
          'kind': 'local',
          'db_path': '/gone.db',
          'created_at': '2026-11-01T00:00:00.000Z',
        },
      ]);
      settings.values['connections'] = jsonEncode([
        {
          'id': 'k1',
          'instance_id': 'l1',
          'kind': 'token',
          'tenant_key': 'default',
          'created_at': '2026-11-01T00:00:00.000Z',
        },
      ]);
      settings.values['context.active'] = jsonEncode({'connection_id': 'k1'});
      secrets.values['token.k1'] = 'x';
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: settings,
          secrets: secrets,
          engine: const UnavailableLocalTixEngine(),
        ),
      );
      final s = (await c.read(sessionControllerProvider.future))!;
      expect(s.problem?.kind, TixErrorKind.engineUnavailable);
      expect(
        () => c.read(sessionApiProvider),
        throwsA(
          isA<ProviderException>().having(
            (e) => (e.exception as TixException).kind,
            'kind',
            TixErrorKind.engineUnavailable,
          ),
        ),
      );
      expect(c.read(localEnginesProvider).running, isEmpty);
    });
  });
}
