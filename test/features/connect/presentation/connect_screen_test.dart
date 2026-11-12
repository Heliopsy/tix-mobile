// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/local_access.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_local_access.dart';
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
    await tester.pumpAndSettle();
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

    group('stay signed in', () {
      setUp(
        () => server.publicRoutes.add(
          (o, path) => path == '/api/v1/auth/session-policy'
              ? const FakeResponse(200, {
                  'ttl': '12h0m0s',
                  'remember_ttl': '720h0m0s',
                })
              : null,
        ),
      );

      SwitchListTile stay(WidgetTester tester) => tester.widget<SwitchListTile>(
        find.byKey(const Key('connect.remember')),
      );

      testWidgets('is on by default and asks to be remembered', (tester) async {
        await pumpScreen(
          tester,
          const ConnectScreen(adding: true),
          overrides: fakeOverrides(server, secrets: secrets),
        );
        await tester.tap(find.text('Sign in').first);
        await tester.pump();
        expect(stay(tester).value, isTrue);
        expect(
          find.descendant(
            of: find.byKey(const Key('connect.remember')),
            matching: find.text('Stay signed in'),
          ),
          findsOneWidget,
        );
        await signIn(tester);
        expect(server.requestsTo('/auth/login').single.body['remember'], true);
      });

      testWidgets('switched off, the sign-in is not remembered', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          const ConnectScreen(adding: true),
          overrides: fakeOverrides(server, secrets: secrets),
        );
        await tester.tap(find.text('Sign in').first);
        await tester.pump();
        await tap(tester, find.byKey(const Key('connect.remember')));
        await tester.pump();
        expect(stay(tester).value, isFalse);
        await signIn(tester);
        expect(
          server.requestsTo('/auth/login').single.body,
          isNot(contains('remember')),
        );
      });

      testWidgets('signing in again offers it too', (tester) async {
        final stores = signInStores(server);
        server.sessions.clear();
        await pumpScreen(
          tester,
          const ConnectScreen(adding: true, connectionId: 's1'),
          overrides: fakeOverrides(
            server,
            settings: stores.settings,
            secrets: stores.secrets,
          ),
        );
        expect(stay(tester).value, isTrue);
      });
    });

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
        await tester.pumpAndSettle();
        await tap(tester, find.byKey(const Key('connect.inPlace')));
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
        expect(s.instance.inPlace, isTrue);
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
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('connect.dbName')), 'notes');
      await tap(tester, find.byKey(const Key('connect.newDb')));
      await tester.pumpAndSettle();
      expect(engine.exists('/docs/notes.db'), isTrue);
      await tap(tester, find.byKey(const Key('connect.localTenant.default')));
      await tester.pumpAndSettle();
      expect(c.read(sessionControllerProvider).value!.instance.name, 'notes');
    });

    testWidgets('on a phone an existing database is imported as a copy', (
      tester,
    ) async {
      final engine = InMemoryLocalTixEngine(existing: ['/docs/team.db']);
      final files = FakeFilePicking(desktop: false, open: '/cache/team.db');
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
      await tester.pumpAndSettle();
      expect(find.textContaining('own copy'), findsOneWidget);
      expect(find.byKey(const Key('connect.inPlaceNote')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('connect.openDb')),
          matching: find.text('Import a database file…'),
        ),
        findsOneWidget,
      );
      await tap(tester, find.byKey(const Key('connect.openDb')));
      await tester.pumpAndSettle();
      expect(files.imports, ['/cache/team.db']);
      expect(engine.started, ['/docs/team.db']);
      await tap(tester, find.byKey(const Key('connect.localTenant.default')));
      await tester.pumpAndSettle();
      expect(
        c.read(sessionControllerProvider).value!.instance.dbPath,
        '/docs/team.db',
      );
    });

    testWidgets('on a desktop the file is opened in place and says so', (
      tester,
    ) async {
      final engine = InMemoryLocalTixEngine(existing: ['/data/team.db']);
      final files = FakeFilePicking(open: '/data/team.db');
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
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('connect.inPlaceNote')), findsOneWidget);
      expect(find.byKey(const Key('connect.syncWarning')), findsOneWidget);
      expect(find.byKey(const Key('connect.openDb')), findsNothing);
      await tap(tester, find.byKey(const Key('connect.inPlace')));
      await tester.pumpAndSettle();
      expect(files.imports, isEmpty);
      expect(engine.started, ['/data/team.db']);
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
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('connect.inPlace')));
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
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('connect.inPlace')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('connect.error'))).data,
        'Databases on this device are not available: '
        'this build was made without the tix engine.',
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
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('connect.inPlace')));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('connect.createTenant')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a key for the tenant.'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(engine.running, isEmpty);
      expect(find.byKey(const Key('connect.inPlace')), findsOneWidget);
    });

    group('open in place', () {
      Future<ProviderContainer> pumpLocal(
        WidgetTester tester, {
        required InMemoryLocalTixEngine engine,
        required FakeLocalFileAccess access,
        FakeFilePicking? files,
      }) async {
        final c = await pumpScreen(
          tester,
          const ConnectScreen(),
          overrides: fakeOverrides(
            server,
            secrets: secrets,
            engine: engine,
            files: files ?? FakeFilePicking(desktop: false),
            access: access,
            local: true,
          ),
        );
        await tester.tap(find.text('This device'));
        await tester.pumpAndSettle();
        return c;
      }

      testWidgets('Android asks for access, then browses shared storage', (
        tester,
      ) async {
        const root = '/storage/emulated/0';
        final engine = InMemoryLocalTixEngine(
          existing: ['$root/Nextcloud/team.db'],
        );
        final access = FakeLocalFileAccess(
          inPlace: InPlaceKind.sharedStorage,
          granted: false,
          folders: {
            root: const [
              FolderEntry(
                name: 'Nextcloud',
                path: '$root/Nextcloud',
                dir: true,
              ),
            ],
            '$root/Nextcloud': const [
              FolderEntry(name: 'team.db', path: '$root/Nextcloud/team.db'),
            ],
          },
        );
        final c = await pumpLocal(tester, engine: engine, access: access);
        expect(find.byKey(const Key('connect.syncWarning')), findsOneWidget);
        await tap(tester, find.byKey(const Key('connect.inPlace')));
        await tester.pumpAndSettle();
        expect(find.text('Allow access to your files'), findsOneWidget);
        await tap(tester, find.byKey(const Key('connect.permissionContinue')));
        await tester.pumpAndSettle();
        expect(access.requests, 1);
        await tap(tester, find.byKey(const Key('browser.entry.Nextcloud')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('browser.up')), findsOneWidget);
        await tap(tester, find.byKey(const Key('browser.entry.team.db')));
        await tester.pumpAndSettle();
        expect(access.checked, ['$root/Nextcloud/team.db']);
        await tap(tester, find.byKey(const Key('connect.localTenant.default')));
        await tester.pumpAndSettle();
        final s = c.read(sessionControllerProvider).value!;
        expect(s.instance.dbPath, '$root/Nextcloud/team.db');
        expect(s.instance.inPlace, isTrue);
      });

      testWidgets('Android refused: says so and offers to import a copy', (
        tester,
      ) async {
        final engine = InMemoryLocalTixEngine(existing: ['/docs/team.db']);
        final files = FakeFilePicking(desktop: false, open: '/cache/team.db');
        final access = FakeLocalFileAccess(
          inPlace: InPlaceKind.sharedStorage,
          granted: false,
          grants: false,
        );
        await pumpLocal(tester, engine: engine, access: access, files: files);
        await tap(tester, find.byKey(const Key('connect.inPlace')));
        await tester.pumpAndSettle();
        await tap(tester, find.byKey(const Key('connect.permissionContinue')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('connect.accessRefused')), findsOneWidget);
        expect(engine.started, isEmpty);
        await tap(tester, find.byKey(const Key('connect.importInstead')));
        await tester.pumpAndSettle();
        expect(files.imports, ['/cache/team.db']);
        expect(engine.started, ['/docs/team.db']);
      });

      testWidgets('Android: cancelling the explanation asks for nothing', (
        tester,
      ) async {
        final engine = InMemoryLocalTixEngine();
        final access = FakeLocalFileAccess(
          inPlace: InPlaceKind.sharedStorage,
          granted: false,
        );
        await pumpLocal(tester, engine: engine, access: access);
        await tap(tester, find.byKey(const Key('connect.inPlace')));
        await tester.pumpAndSettle();
        await tap(tester, find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(access.requests, 0);
        expect(engine.started, isEmpty);
      });

      testWidgets('Apple: a picked folder is bookmarked and a file created', (
        tester,
      ) async {
        final engine = InMemoryLocalTixEngine();
        const folder = PickedFolder(path: '/icloud/tix', bookmark: 'bm1');
        final access = FakeLocalFileAccess(
          inPlace: InPlaceKind.bookmark,
          folder: folder,
        );
        final c = await pumpLocal(tester, engine: engine, access: access);
        await tap(tester, find.byKey(const Key('connect.inPlace')));
        await tester.pumpAndSettle();
        expect(find.text('No folders or databases here.'), findsOneWidget);
        await tester.enterText(find.byKey(const Key('browser.name')), 'team');
        await tap(tester, find.byKey(const Key('browser.create')));
        await tester.pumpAndSettle();
        expect(access.released, [folder]);
        expect(access.opened.single.bookmark, 'bm1');
        expect(engine.exists('/icloud/tix/team.db'), isTrue);
        await tap(tester, find.byKey(const Key('connect.localTenant.default')));
        await tester.pumpAndSettle();
        final s = c.read(sessionControllerProvider).value!;
        expect(s.instance.bookmark, 'bm1');
        expect(s.instance.inPlace, isTrue);
        expect(access.closed, isEmpty);
      });

      testWidgets('a file SQLite cannot use is refused and nothing saved', (
        tester,
      ) async {
        final engine = InMemoryLocalTixEngine(existing: ['/data/team.db']);
        final access = FakeLocalFileAccess()
          ..unusable = const TixException(
            TixErrorKind.localNotUsable,
            details: {'reason': 'notDatabase'},
          );
        await pumpLocal(
          tester,
          engine: engine,
          access: access,
          files: FakeFilePicking(open: '/data/team.db'),
        );
        await tap(tester, find.byKey(const Key('connect.inPlace')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const Key('connect.error'))).data,
          contains('not a tix database on this device'),
        );
        expect(engine.started, isEmpty);
        expect(secrets.values, isEmpty);
      });

      testWidgets('conflict copies are named before a tenant is opened', (
        tester,
      ) async {
        final engine = InMemoryLocalTixEngine(existing: ['/data/team.db']);
        final access = FakeLocalFileAccess()
          ..found = const SyncFindings(
            conflicts: ['team (conflicted copy 2026-11-08).db'],
            walLeftOver: true,
          );
        await pumpLocal(
          tester,
          engine: engine,
          access: access,
          files: FakeFilePicking(open: '/data/team.db'),
        );
        await tap(tester, find.byKey(const Key('connect.inPlace')));
        await tester.pumpAndSettle();
        final note = find.byKey(const Key('connect.findings'));
        expect(
          find.descendant(
            of: note,
            matching: find.textContaining('conflicted copy 2026-11-08'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: note,
            matching: find.textContaining('write-ahead log'),
          ),
          findsOneWidget,
        );
      });
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

  group('help', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width: the (i) beside the address says where it comes '
          'from', (tester) async {
        await pumpScreen(
          tester,
          const ConnectScreen(),
          size: size,
          overrides: fakeOverrides(server),
        );
        await tap(tester, find.byKey(const Key('connect.help.server')));
        await tester.pumpAndSettle();
        final shown = find.byType(width == 'compact' ? BottomSheet : Dialog);
        expect(shown, findsOneWidget);
        expect(
          find.descendant(
            of: shown,
            matching: find.textContaining('https://tix.example.com'),
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('help.close')));
        await tester.pumpAndSettle();
        expect(shown, findsNothing);
      });
    }

    testWidgets('every field and choice has its own (i)', (tester) async {
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server),
      );
      Finder help(String name) => find.byKey(Key('connect.help.$name'));
      for (final name in ['kind', 'server', 'method', 'token', 'name']) {
        expect(help(name), findsOneWidget, reason: name);
      }
      expect(find.byTooltip('Help: API token'), findsOneWidget);
      await tester.tap(find.text('Sign in').first);
      await tester.pumpAndSettle();
      for (final name in ['email', 'password', 'remember']) {
        expect(help(name), findsOneWidget, reason: name);
      }
      await tester.tap(find.text('Invite').first);
      await tester.pumpAndSettle();
      expect(help('invite'), findsOneWidget);
      expect(help('server'), findsNothing);
    });

    testWidgets('the token help names both places a token comes from', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server),
      );
      await tap(tester, find.byKey(const Key('connect.help.token')));
      await tester.pumpAndSettle();
      final body = find.byKey(const Key('help.body'));
      expect(
        find.descendant(of: body, matching: find.textContaining('API tokens')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: body,
          matching: find.textContaining('tix token create'),
        ),
        findsOneWidget,
      );
    });
  });

  group('address', () {
    testWidgets('trailing slashes are dropped before connecting', (
      tester,
    ) async {
      final c = await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, secrets: secrets),
      );
      await fill(tester, ' https://tix.example/// ', 'tok');
      expect(find.byKey(const Key('connect.error')), findsNothing);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('connect.url')))
            .controller!
            .text,
        'https://tix.example',
      );
      expect(
        c.read(instancesRepositoryProvider).instances().single.baseUrl,
        'https://tix.example',
      );
    });

    testWidgets('a second spelling of a saved address adds no instance', (
      tester,
    ) async {
      final c = await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, secrets: secrets),
      );
      final repo = c.read(instancesRepositoryProvider);
      await repo.save(
        instance: Instance(
          id: 'old',
          name: 'Old',
          kind: InstanceKind.remote,
          baseUrl: 'https://tix.example',
          createdAt: DateTime.utc(2026),
        ),
        connection: Connection(
          id: 'k',
          instanceId: 'old',
          kind: ConnectionKind.token,
          handle: 'bot',
          createdAt: DateTime.utc(2026),
        ),
        secret: 'old',
      );
      await fill(tester, 'tix.example/', 'tok');
      expect(find.byKey(const Key('connect.error')), findsNothing);
      expect(repo.instances().map((i) => i.id), ['old']);
      expect(repo.connections(), hasLength(2));
    });

    testWidgets('an address handed to the screen is shown tidied', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ConnectScreen(adding: true, url: 'https://tix.example/'),
        overrides: fakeOverrides(server),
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('connect.url')))
            .controller!
            .text,
        'https://tix.example',
      );
    });
  });
}
