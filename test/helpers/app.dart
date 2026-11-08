// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/api/providers.dart';

import 'fake_tix.dart';
import 'stores.dart';

const phone = Size(400, 800);
const desktop = Size(1280, 800);

/// Stores with one saved, active context for [FakeTix]'s default token.
({MemoryKeyValueStore settings, MemorySecretStore secrets}) signedInStores({
  String token = 'tok',
}) {
  final settings = MemoryKeyValueStore();
  final secrets = MemorySecretStore();
  settings.values['contexts'] = jsonEncode([
    {
      'id': 'c1',
      'name': 'Work',
      'base_url': 'https://tix.example',
      'handle': 'ana',
    },
  ]);
  settings.values['contexts.active'] = 'c1';
  secrets.values['token.c1'] = token;
  return (settings: settings, secrets: secrets);
}

/// Overrides that point the app at [server] with the given stores.
List<Override> fakeOverrides(
  FakeTix server, {
  MemoryKeyValueStore? settings,
  MemorySecretStore? secrets,
}) => [
  keyValueStoreProvider.overrideWithValue(settings ?? MemoryKeyValueStore()),
  secretStoreProvider.overrideWithValue(secrets ?? MemorySecretStore()),
  tixApiFactoryProvider.overrideWithValue(server.factory),
];

Future<void> setSize(WidgetTester tester, Size size) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Pumps [screen] at `/` under a router whose other routes draw their own
/// location, so a test can read where the screen navigated.
Future<ProviderContainer> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
  Size size = phone,
  Locale locale = const Locale('en'),
}) async {
  await setSize(tester, size);
  Widget stub(BuildContext _, GoRouterState s) =>
      Scaffold(body: Text('route:${s.uri}'));
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => screen),
      GoRoute(path: '/connect', builder: stub),
      GoRoute(path: '/settings', builder: stub),
      GoRoute(
        path: '/projects',
        builder: stub,
        routes: [
          GoRoute(
            path: ':key',
            builder: stub,
            routes: [GoRoute(path: 'tasks/:ref', builder: stub)],
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: overrides,
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byWidget(screen)));
}
