// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemorySecretStore secrets;

  setUp(() {
    server = FakeTix();
    secrets = MemorySecretStore();
  });

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
  }

  Future<void> fill(WidgetTester tester, String url, String token) async {
    await tester.enterText(find.byKey(const Key('connect.url')), url);
    await tester.enterText(find.byKey(const Key('connect.token')), token);
    await tap(tester, find.byKey(const Key('connect.submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('the tix mark heads the screen', (tester) async {
    await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server, secrets: secrets),
    );
    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(TixMark),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a good token signs in and lands in secure storage', (
    tester,
  ) async {
    final c = await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server, secrets: secrets),
    );
    await fill(tester, 'tix.example', 'tok');
    expect(find.byKey(const Key('connect.error')), findsNothing);
    expect(c.read(sessionControllerProvider).value?.connection.handle, 'ana');
    expect(secrets.values.values, ['tok']);
    expect(
      c.read(sessionControllerProvider).value?.connection.tenantKey,
      'default',
    );
  });

  testWidgets('a refused token is explained and nothing is saved', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server, secrets: secrets),
    );
    await fill(tester, 'tix.example', 'wrong');
    expect(
      tester.widget<Text>(find.byKey(const Key('connect.error'))).data,
      contains('did not accept this connection'),
    );
    expect(secrets.values, isEmpty);
  });

  testWidgets('a bad address is refused in Bulgarian too', (tester) async {
    await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server),
      locale: const Locale('bg'),
    );
    expect(find.text('Свързване с tix'), findsOneWidget);
    await fill(tester, 'ftp://nope', 'tok');
    expect(find.textContaining('Въведете адрес на сървър'), findsOneWidget);
    expect(server.requests, isEmpty);
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: busy while checking, fields locked', (tester) async {
      server.gate = Completer<void>();
      await pumpScreen(
        tester,
        const ConnectScreen(),
        size: size,
        overrides: fakeOverrides(server),
      );
      await tester.enterText(find.byKey(const Key('connect.url')), 'x.example');
      await tester.enterText(find.byKey(const Key('connect.token')), 'tok');
      await tap(tester, find.byKey(const Key('connect.submit')));
      await tester.pump();
      final button = tester.widget<FilledButton>(
        find.byKey(const Key('connect.submit')),
      );
      expect(button.onPressed, isNull);
      expect(
        find.descendant(
          of: find.byKey(const Key('connect.submit')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      final url = tester.widget<TextField>(
        find.byKey(const Key('connect.url')),
      );
      expect(url.enabled, isFalse);
      server.gate!.complete();
      await tester.pumpAndSettle();
    });
  }

  testWidgets('the token is hidden until asked for', (tester) async {
    await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server),
    );
    EditableText token() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('connect.token')),
        matching: find.byType(EditableText),
      ),
    );
    expect(token().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(token().obscureText, isFalse);
  });

  testWidgets('adding a server has a way back and goes to projects after', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ConnectScreen(adding: true),
      overrides: fakeOverrides(server),
    );
    expect(find.text('Add an instance'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('connect.name')), 'Home');
    await fill(tester, 'tix.example', 'tok');
    expect(find.text('route:/projects'), findsOneWidget);
  });

  testWidgets('the back button of add leads to settings', (tester) async {
    await pumpScreen(
      tester,
      const ConnectScreen(adding: true),
      overrides: fakeOverrides(server),
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings'), findsOneWidget);
  });

  Future<void> signIn(
    WidgetTester tester, {
    String url = 'tix.example',
    String email = 'ana@example.com',
    String password = 'pw',
  }) async {
    await tester.tap(find.text('Sign in').first);
    await tester.pump();
    if (find.byKey(const Key('connect.url')).evaluate().isNotEmpty) {
      await tester.enterText(find.byKey(const Key('connect.url')), url);
    }
    await tester.enterText(find.byKey(const Key('connect.email')), email);
    await tester.enterText(find.byKey(const Key('connect.password')), password);
    await tap(tester, find.byKey(const Key('connect.submit')));
    await tester.pumpAndSettle();
  }

  group('sign-in', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width: one tenant signs straight in, pinned', (
        tester,
      ) async {
        final c = await pumpScreen(
          tester,
          const ConnectScreen(adding: true),
          size: size,
          overrides: fakeOverrides(server, secrets: secrets),
        );
        await signIn(tester);
        expect(find.text('route:/projects'), findsOneWidget);
        final s = c.read(sessionControllerProvider).value!;
        expect(s.connection.kind, ConnectionKind.signIn);
        expect(s.connection.pinned, isTrue);
        expect(secrets.values.keys.single, startsWith('session.'));
        expect(server.requestsTo('/auth/login').single.body['password'], 'pw');
      });
    }

    testWidgets('a wrong password is explained', (tester) async {
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, secrets: secrets),
      );
      await signIn(tester, password: 'nope');
      expect(
        tester.widget<Text>(find.byKey(const Key('connect.error'))).data,
        'That email and password were not accepted.',
      );
      expect(secrets.values, isEmpty);
    });

    testWidgets('a second factor code is asked for, retried and sent', (
      tester,
    ) async {
      server.requireCode = true;
      final c = await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, secrets: secrets),
      );
      await signIn(tester);
      expect(find.byKey(const Key('connect.code')), findsOneWidget);
      expect(secrets.values, isEmpty);
      await tester.enterText(find.byKey(const Key('connect.code')), '000000');
      await tap(tester, find.byKey(const Key('connect.verify')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('connect.error')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('connect.code')),
        FakeTix.goodCode,
      );
      await tap(tester, find.byKey(const Key('connect.verify')));
      await tester.pumpAndSettle();
      expect(c.read(sessionControllerProvider).value, isNotNull);
      expect(secrets.values, hasLength(1));
    });

    testWidgets('back from the code returns to the form', (tester) async {
      server.requireCode = true;
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server),
      );
      await signIn(tester);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('connect.email')), findsOneWidget);
      expect(find.byKey(const Key('connect.code')), findsNothing);
    });

    testWidgets('enrolment is sent to the browser', (tester) async {
      server.challengeKind = 'enrol';
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, secrets: secrets),
      );
      await signIn(tester);
      expect(find.textContaining('set up a second factor'), findsOneWidget);
      expect(secrets.values, isEmpty);
    });

    testWidgets('several tenants: choose one and pin it', (tester) async {
      server
        ..tenants['acme'] = (name: 'Acme', host: '')
        ..tenants['own'] = (name: 'Own', host: 'own.example')
        ..accounts['ana@example.com'] = FakeAccount(
          password: 'pw',
          tenants: ['default', 'acme', 'own'],
        );
      final c = await pumpScreen(
        tester,
        const ConnectScreen(adding: true),
        overrides: fakeOverrides(server, secrets: secrets),
      );
      await signIn(tester);
      expect(find.byKey(const Key('connect.tenant.default')), findsOneWidget);
      expect(find.byKey(const Key('connect.tenant.own')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('connect.elsewhere.own')),
          matching: find.text('Served at own.example'),
        ),
        findsOneWidget,
      );
      await tap(tester, find.byKey(const Key('connect.tenant.acme')));
      await tap(tester, find.byKey(const Key('connect.pin')));
      await tester.pump();
      await tap(tester, find.byKey(const Key('connect.openTenant')));
      await tester.pumpAndSettle();
      final s = c.read(sessionControllerProvider).value!;
      expect(s.connection.tenantKey, 'acme');
      expect(s.connection.pinned, isTrue);
      expect(server.requestsTo('/auth/switch').single.body['tenant'], 'acme');
    });

    testWidgets('keeping the current tenant stays switchable', (tester) async {
      server
        ..tenants['acme'] = (name: 'Acme', host: '')
        ..accounts['ana@example.com'] = FakeAccount(
          password: 'pw',
          tenants: ['default', 'acme'],
        );
      final c = await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, secrets: secrets),
      );
      await signIn(tester);
      await tap(tester, find.byKey(const Key('connect.openTenant')));
      await tester.pumpAndSettle();
      final s = c.read(sessionControllerProvider).value!;
      expect(s.connection.tenantKey, 'default');
      expect(s.connection.switchable, isTrue);
      expect(server.requestsTo('/auth/switch'), isEmpty);
    });

    testWidgets('a switch that asks for a code asks for it', (tester) async {
      server
        ..tenants['acme'] = (name: 'Acme', host: '')
        ..switchNeedsCode.add('acme')
        ..accounts['ana@example.com'] = FakeAccount(
          password: 'pw',
          tenants: ['default', 'acme'],
        );
      final c = await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, secrets: secrets),
      );
      await signIn(tester);
      await tap(tester, find.byKey(const Key('connect.tenant.acme')));
      await tap(tester, find.byKey(const Key('connect.openTenant')));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('connect.verify')));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter the code from your authenticator app.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('connect.code')),
        FakeTix.goodCode,
      );
      await tap(tester, find.byKey(const Key('connect.verify')));
      await tester.pumpAndSettle();
      expect(
        c.read(sessionControllerProvider).value!.connection.tenantKey,
        'acme',
      );
    });

    testWidgets('a tenant at its own address opens add-instance there', (
      tester,
    ) async {
      server
        ..tenants['own'] = (name: 'Own', host: 'own.example')
        ..accounts['ana@example.com'] = FakeAccount(
          password: 'pw',
          tenants: ['default', 'own'],
        );
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server),
      );
      await signIn(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('connect.elsewhere.own')),
          matching: find.byType(TextButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'route:/connect?url=https%3A%2F%2Fown.example&email=ana%40example.com',
        ),
        findsOneWidget,
      );
    });

    testWidgets('an address and email from the switcher are filled in', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ConnectScreen(
          adding: true,
          url: 'https://own.example',
          email: 'ana@example.com',
        ),
        overrides: fakeOverrides(server),
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('connect.url')))
            .controller!
            .text,
        'https://own.example',
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('connect.email')))
            .controller!
            .text,
        'ana@example.com',
      );
    });

    testWidgets('signing in again keeps the connection', (tester) async {
      final stores = signInStores(server);
      server.sessions.clear();
      final c = await pumpScreen(
        tester,
        const ConnectScreen(adding: true, connectionId: 's1'),
        overrides: fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      expect(find.text('Work'), findsOneWidget);
      expect(find.byKey(const Key('connect.method')), findsNothing);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('connect.email')))
            .controller!
            .text,
        'ana@example.com',
      );
      await tester.enterText(find.byKey(const Key('connect.password')), 'pw');
      await tap(tester, find.byKey(const Key('connect.submit')));
      await tester.pumpAndSettle();
      expect(stores.secrets.values.keys, ['session.s1']);
      expect(server.sessions.keys, [stores.secrets.values['session.s1']]);
      expect(c.read(sessionControllerProvider).value!.connection.id, 's1');
    });

    testWidgets('a token added to a saved instance', (tester) async {
      final stores = signInStores(server);
      final c = await pumpScreen(
        tester,
        const ConnectScreen(adding: true, instanceId: 'i1'),
        overrides: fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      expect(find.byKey(const Key('connect.url')), findsNothing);
      expect(find.text('https://tix.example'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('connect.token')), 'tok');
      await tap(tester, find.byKey(const Key('connect.submit')));
      await tester.pumpAndSettle();
      final group = c.read(contextDirectoryProvider).groups.single;
      expect(group.connections, hasLength(2));
      await tester.pumpAndSettle();
    });

    testWidgets('back from a saved instance leads to instances', (
      tester,
    ) async {
      final stores = signInStores(server);
      await pumpScreen(
        tester,
        const ConnectScreen(adding: true, instanceId: 'i1'),
        overrides: fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('route:/settings/instances'), findsOneWidget);
    });
  });

  group('local', () {
    testWidgets('without the flag the choice is off and says why', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server),
      );
      expect(find.byKey(const Key('connect.localNote')), findsOneWidget);
      final segmented = tester.widget<SegmentedButton<InstanceKind>>(
        find.byKey(const Key('connect.kind')),
      );
      expect(
        segmented.segments
            .firstWhere((s) => s.value == InstanceKind.local)
            .enabled,
        isFalse,
      );
    });

    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width: open a file, create a tenant, land in it', (
        tester,
      ) async {
        final engine = InMemoryLocalTixEngine(existing: ['/data/team.db']);
        final files = FakeFilePicking(open: '/data/team.db');
        final c = await pumpScreen(
          tester,
          const ConnectScreen(adding: true),
          size: size,
          overrides: fakeOverrides(
            server,
            secrets: secrets,
            engine: engine,
            files: files,
            local: true,
          ),
        );
        expect(find.byKey(const Key('connect.localNote')), findsNothing);
        await tester.tap(find.text('This device'));
        await tester.pump();
        await tap(tester, find.byKey(const Key('connect.openDb')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('connect.localTenant.default')),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const Key('connect.tenantKey')),
          'home',
        );
        await tester.enterText(
          find.byKey(const Key('connect.tenantName')),
          'Home',
        );
        await tap(tester, find.byKey(const Key('connect.createTenant')));
        await tester.pumpAndSettle();
        expect(find.text('route:/projects'), findsOneWidget);
        final s = c.read(sessionControllerProvider).value!;
        expect(s.instance.kind, InstanceKind.local);
        expect(s.instance.dbPath, '/data/team.db');
        expect(s.connection.tenantKey, 'home');
        expect(secrets.values.values, ['local-home-1']);
        expect(engine.started, ['/data/team.db']);
      });
    }

    testWidgets('on a phone a new database goes to the documents folder', (
      tester,
    ) async {
      final engine = InMemoryLocalTixEngine();
      final files = FakeFilePicking(desktop: false);
      final c = await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(
          server,
          secrets: secrets,
          engine: engine,
          files: files,
          local: true,
        ),
      );
      await tester.tap(find.text('This device'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('connect.dbName')), 'notes');
      await tap(tester, find.byKey(const Key('connect.newDb')));
      await tester.pumpAndSettle();
      expect(engine.exists('/docs/notes.db'), isTrue);
      await tap(tester, find.byKey(const Key('connect.localTenant.default')));
      await tester.pumpAndSettle();
      expect(c.read(sessionControllerProvider).value!.instance.name, 'notes');
    });

    testWidgets('on a desktop a new database uses the save dialog', (
      tester,
    ) async {
      final engine = InMemoryLocalTixEngine();
      final files = FakeFilePicking(created: '/home/a/new.db');
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(
          server,
          engine: engine,
          files: files,
          local: true,
        ),
      );
      await tester.tap(find.text('This device'));
      await tester.pump();
      expect(find.byKey(const Key('connect.dbName')), findsNothing);
      await tap(tester, find.byKey(const Key('connect.newDb')));
      await tester.pumpAndSettle();
      expect(engine.exists('/home/a/new.db'), isTrue);
      expect(files.names, ['']);
    });

    testWidgets('a cancelled dialog does nothing', (tester) async {
      final engine = InMemoryLocalTixEngine();
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, engine: engine, local: true),
      );
      await tester.tap(find.text('This device'));
      await tester.pump();
      await tap(tester, find.byKey(const Key('connect.openDb')));
      await tap(tester, find.byKey(const Key('connect.newDb')));
      await tester.pumpAndSettle();
      expect(engine.started, isEmpty);
    });

    testWidgets('no engine in this build: says so and saves nothing', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(
          server,
          secrets: secrets,
          engine: const UnavailableLocalTixEngine(),
          files: FakeFilePicking(open: '/data/x.db'),
          local: true,
        ),
      );
      await tester.tap(find.text('This device'));
      await tester.pump();
      await tap(tester, find.byKey(const Key('connect.openDb')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('connect.error'))).data,
        'Databases on this device are not available in this build yet.',
      );
      expect(secrets.values, isEmpty);
    });

    testWidgets('an empty tenant key is refused; back stops the engine', (
      tester,
    ) async {
      final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(
          server,
          engine: engine,
          files: FakeFilePicking(open: '/a.db'),
          local: true,
        ),
      );
      await tester.tap(find.text('This device'));
      await tester.pump();
      await tap(tester, find.byKey(const Key('connect.openDb')));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('connect.createTenant')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a key for the tenant.'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(engine.running, isEmpty);
      expect(find.byKey(const Key('connect.openDb')), findsOneWidget);
    });

    testWidgets('a saved local instance opens another tenant', (tester) async {
      final engine = InMemoryLocalTixEngine(existing: ['/n.db']);
      final settings = MemoryKeyValueStore()
        ..values['storage.version'] = '2'
        ..values['instances'] =
            '[{"id":"l1","name":"Notes","kind":"local","db_path":"/n.db",'
            '"created_at":"2026-11-01T00:00:00.000Z"}]'
        ..values['connections'] =
            '[{"id":"k1","instance_id":"l1","kind":"token",'
            '"tenant_key":"default","created_at":"2026-11-01T00:00:00.000Z"}]';
      final c = await pumpScreen(
        tester,
        const ConnectScreen(adding: true, instanceId: 'l1'),
        overrides: fakeOverrides(
          server,
          settings: settings,
          secrets: secrets,
          engine: engine,
          local: true,
        ),
      );
      expect(find.byKey(const Key('connect.instancePath')), findsOneWidget);
      await tap(tester, find.byKey(const Key('connect.openSaved')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('connect.tenantKey')), 'b');
      await tap(tester, find.byKey(const Key('connect.createTenant')));
      await tester.pumpAndSettle();
      expect(
        c.read(contextDirectoryProvider).groups.single.connections,
        hasLength(2),
      );
      expect(engine.started, ['/n.db']);
    });
  });
}
