// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/instances/presentation/instances_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  setUp(() {
    server = FakeTix()..tenants['acme'] = (name: 'Acme', host: '');
    stores = signInStores(server, tenants: ['default', 'acme']);
    final connections =
        jsonDecode(stores.settings.values['connections']!) as List<dynamic>;
    final instances =
        jsonDecode(stores.settings.values['instances']!) as List<dynamic>..add({
          'id': 'i2',
          'name': 'Laptop',
          'kind': 'local',
          'db_path': '/home/ana/tix.db',
          'created_at': '2026-11-01T00:00:00.000Z',
        });
    connections
      ..add({
        'id': 't1',
        'instance_id': 'i1',
        'kind': 'token',
        'label': 'CI bot',
        'handle': 'ci',
        'tenant_key': 'acme',
        'tenant_name': 'Acme',
        'created_at': '2026-11-01T00:00:00.000Z',
      })
      ..add({
        'id': 'l1',
        'instance_id': 'i2',
        'kind': 'token',
        'tenant_key': 'default',
        'created_at': '2026-11-01T00:00:00.000Z',
      });
    stores.settings.values['instances'] = jsonEncode(instances);
    stores.settings.values['connections'] = jsonEncode(connections);
    stores.secrets.values['token.t1'] = 'tok-acme';
    stores.secrets.values['token.l1'] = 'local';
    server.tokens['tok-acme'] = 'acme';
  });

  Future<ProviderContainer> pump(WidgetTester tester, {Size size = phone}) =>
      pumpScreen(
        tester,
        const InstancesScreen(),
        size: size,
        overrides: fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );

  Finder inConnection(String id, Finder f) => find.descendant(
    of: find.byKey(Key('instances.connection.$id')),
    matching: f,
  );

  Future<void> menu(WidgetTester tester, String key, String item) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: every instance with its connections', (tester) async {
      await pump(tester, size: size);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('https://tix.example'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('/home/ana/tix.db'), findsOneWidget);
      expect(
        inConnection('s1', find.text('Default · ana@example.com · Switchable')),
        findsOneWidget,
      );
      expect(
        inConnection('s1', find.byIcon(Icons.check_circle)),
        findsOneWidget,
      );
      expect(
        inConnection('t1', find.text('Acme · @ci · Token · Pinned')),
        findsOneWidget,
      );
      expect(inConnection('t1', find.text('CI bot')), findsOneWidget);
      expect(inConnection('t1', find.byIcon(Icons.key)), findsOneWidget);
    });
  }

  testWidgets('no instances says so', (tester) async {
    await pumpScreen(
      tester,
      const InstancesScreen(),
      overrides: fakeOverrides(server),
    );
    expect(find.text('No instances yet.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('instances.add')));
    await tester.pumpAndSettle();
    expect(find.text('route:/connect?add=1'), findsOneWidget);
  });

  testWidgets('tapping a connection makes it active', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.byKey(const Key('instances.connection.t1')));
    await tester.pumpAndSettle();
    expect(c.read(sessionControllerProvider).value!.connection.id, 't1');
    expect(inConnection('t1', find.byIcon(Icons.check_circle)), findsOneWidget);
    await menu(tester, 'instances.connection.s1.menu', 'Use');
    expect(c.read(sessionControllerProvider).value!.connection.id, 's1');
  });

  testWidgets('a sign-in can be pinned and made switchable again', (
    tester,
  ) async {
    final c = await pump(tester);
    await menu(tester, 'instances.connection.s1.menu', 'Pin to current tenant');
    expect(c.read(sessionControllerProvider).value!.connection.pinned, isTrue);
    expect(inConnection('s1', find.textContaining('Pinned')), findsOneWidget);
    await menu(tester, 'instances.connection.s1.menu', 'Make switchable');
    expect(c.read(sessionControllerProvider).value!.connection.pinned, isFalse);
  });

  testWidgets('a token offers no pin and no sign-in', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('instances.connection.t1.menu')));
    await tester.pumpAndSettle();
    expect(find.text('Sign in again'), findsNothing);
    expect(find.text('Pin to current tenant'), findsNothing);
    expect(find.text('Remove connection'), findsOneWidget);
  });

  testWidgets('sign in again and add a connection lead to connect', (
    tester,
  ) async {
    await pump(tester);
    await menu(tester, 'instances.connection.s1.menu', 'Sign in again');
    expect(find.text('route:/connect?connection=s1'), findsOneWidget);
  });

  testWidgets('add a connection, or a tenant for a local one', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('instances.instance.i2.menu')));
    await tester.pumpAndSettle();
    expect(find.text('Open a tenant'), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await menu(tester, 'instances.instance.i1.menu', 'Add a connection');
    expect(find.text('route:/connect?instance=i1'), findsOneWidget);
  });

  testWidgets('removing a connection asks first', (tester) async {
    await pump(tester);
    await menu(tester, 'instances.connection.t1.menu', 'Remove connection');
    expect(find.textContaining('This forgets CI bot'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(stores.secrets.values.containsKey('token.t1'), isTrue);
    await menu(tester, 'instances.connection.t1.menu', 'Remove connection');
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(stores.secrets.values.containsKey('token.t1'), isFalse);
    expect(find.byKey(const Key('instances.connection.t1')), findsNothing);
  });

  testWidgets('removing an instance forgets all its connections', (
    tester,
  ) async {
    final c = await pump(tester);
    final session = stores.secrets.values['session.s1']!;
    await menu(tester, 'instances.instance.i1.menu', 'Remove instance');
    expect(find.textContaining('This forgets Work'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsNothing);
    expect(stores.secrets.values.keys, ['token.l1']);
    expect(server.sessions.containsKey(session), isFalse);
    expect(c.read(sessionControllerProvider).value!.instance.id, 'i2');
  });
}
