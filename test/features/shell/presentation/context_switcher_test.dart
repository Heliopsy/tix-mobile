// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/shell/presentation/context_switcher.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  setUp(() {
    server = FakeTix()
      ..tenants['acme'] = (name: 'Acme', host: '')
      ..tenants['own'] = (name: 'Own', host: 'own.example');
    stores = signInStores(server, tenants: ['default', 'acme', 'own']);
    final instances =
        jsonDecode(stores.settings.values['instances']!) as List<dynamic>;
    final connections =
        jsonDecode(stores.settings.values['connections']!) as List<dynamic>;
    instances.add({
      'id': 'i2',
      'name': 'Home',
      'kind': 'remote',
      'base_url': 'https://home.example',
      'created_at': '2026-11-01T00:00:00.000Z',
    });
    connections.add({
      'id': 't2',
      'instance_id': 'i2',
      'kind': 'token',
      'handle': 'ana',
      'tenant_key': 'default',
      'tenant_name': 'Default',
      'created_at': '2026-11-01T00:00:00.000Z',
    });
    stores.settings.values['instances'] = jsonEncode(instances);
    stores.settings.values['connections'] = jsonEncode(connections);
    stores.settings.values['context.recent'] = jsonEncode([
      {'connection_id': 's1', 'tenant_key': 'default'},
      {'connection_id': 't2', 'tenant_key': 'default'},
    ]);
    stores.secrets.values['token.t2'] = 'tok';
  });

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    Widget button = const ContextSwitcherButton(),
    Size size = phone,
  }) => pumpScreen(
    tester,
    Scaffold(body: const SizedBox.expand(), bottomNavigationBar: button),
    size: size,
    overrides: fakeOverrides(
      server,
      settings: stores.settings,
      secrets: stores.secrets,
    ),
  );

  Future<void> open(WidgetTester tester) async {
    final title = find.byKey(const Key('switcher.title'));
    await tester.tap(
      title.evaluate().isEmpty ? find.byKey(const Key('switcher.open')) : title,
    );
    await tester.pumpAndSettle();
  }

  Finder inSheet(Finder f) =>
      find.descendant(of: find.byKey(const Key('switcher.sheet')), matching: f);

  testWidgets('shows Instance › Tenant and the handle', (tester) async {
    await pump(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('switcher.title'))).data,
      'Work › Default',
    );
    expect(find.text('@ana'), findsOneWidget);
  });

  testWidgets('lists recent contexts first, then every instance', (
    tester,
  ) async {
    await pump(tester);
    await open(tester);
    expect(inSheet(find.text('Recent')), findsOneWidget);
    expect(find.byKey(const Key('switcher.recent.s1.default')), findsOneWidget);
    expect(find.byKey(const Key('switcher.recent.t2.default')), findsOneWidget);
    expect(find.byKey(const Key('switcher.entry.s1.acme')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('switcher.recent.s1.default')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('switcher.entry.s1.own')),
        matching: find.text('Served at own.example'),
      ),
      findsOneWidget,
    );
    final recentY = tester
        .getTopLeft(find.byKey(const Key('switcher.recent.t2.default')))
        .dy;
    final groupY = tester
        .getTopLeft(find.byKey(const Key('switcher.entry.s1.acme')))
        .dy;
    expect(recentY, lessThan(groupY));
  });

  testWidgets('picking a recent context switches to it', (tester) async {
    final c = await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('switcher.recent.t2.default')));
    await tester.pumpAndSettle();
    expect(c.read(sessionControllerProvider).value!.connection.id, 't2');
    expect(
      tester.widget<Text>(find.byKey(const Key('switcher.title'))).data,
      'Home › Default',
    );
  });

  testWidgets('picking another tenant switches the session', (tester) async {
    final c = await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('switcher.entry.s1.acme')));
    await tester.pumpAndSettle();
    expect(
      c.read(sessionControllerProvider).value!.connection.tenantKey,
      'acme',
    );
    expect(server.requestsTo('/auth/switch'), hasLength(1));
    expect(
      tester.widget<Text>(find.byKey(const Key('switcher.title'))).data,
      'Work › Acme',
    );
  });

  testWidgets('a switch that needs a code asks for one', (tester) async {
    server.switchNeedsCode.add('acme');
    final c = await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('switcher.entry.s1.acme')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('code.field')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('code.field')),
      FakeTix.goodCode,
    );
    await tester.tap(find.byKey(const Key('code.ok')));
    await tester.pumpAndSettle();
    expect(
      c.read(sessionControllerProvider).value!.connection.tenantKey,
      'acme',
    );
  });

  testWidgets('cancelling the code stays put', (tester) async {
    server.switchNeedsCode.add('acme');
    final c = await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('switcher.entry.s1.acme')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      c.read(sessionControllerProvider).value!.connection.tenantKey,
      'default',
    );
  });

  testWidgets('a failed switch is reported', (tester) async {
    await pump(tester);
    await open(tester);
    server.override = FakeResponse(403, envelope('forbidden', 'no'));
    await tester.tap(find.byKey(const Key('switcher.entry.s1.acme')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('This token is not allowed to do that.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a tenant at its own address opens add-instance', (tester) async {
    await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('switcher.entry.s1.own')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'route:/connect?url=https%3A%2F%2Fown.example&email=ana%40example.com',
      ),
      findsOneWidget,
    );
    expect(server.requestsTo('/auth/switch'), isEmpty);
  });

  testWidgets('manage and add lead to their screens', (tester) async {
    await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('switcher.manage')));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/instances'), findsOneWidget);
  });

  testWidgets('add leads to connect', (tester) async {
    await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('switcher.add')));
    await tester.pumpAndSettle();
    expect(find.text('route:/connect?add=1'), findsOneWidget);
  });

  testWidgets('a narrow rail shows the tenant under the icon', (tester) async {
    await pump(
      tester,
      size: const Size(700, 800),
      button: const ContextSwitcherButton(rail: true),
    );
    expect(find.byType(Tooltip), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    await open(tester);
    expect(find.byKey(const Key('switcher.sheet')), findsOneWidget);
  });

  testWidgets('a wide rail shows the full title', (tester) async {
    await pump(
      tester,
      size: desktop,
      button: const ContextSwitcherButton(rail: true, extended: true),
    );
    expect(find.byKey(const Key('switcher.title')), findsOneWidget);
  });

  testWidgets('signed out it draws nothing', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(bottomNavigationBar: ContextSwitcherButton()),
      overrides: fakeOverrides(server),
    );
    expect(find.byKey(const Key('switcher.open')), findsNothing);
  });
}
