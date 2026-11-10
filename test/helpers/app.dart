// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/offline/connectivity.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/platform/local_access.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';

import 'fake_events.dart';
import 'fake_local_access.dart';
import 'fake_notes.dart';
import 'fake_tix.dart';
import 'fake_widgets.dart';
import 'stores.dart';

const phone = Size(400, 800);
const desktop = Size(1280, 800);

/// The compact and expanded widths every screen is tested at.
const Map<String, Size> widths = {'compact': phone, 'expanded': desktop};

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

/// Stores holding a v2 sign-in to `https://tix.example` for
/// `ana@example.com`, with a live session on [server] in [tenant]. The
/// connection is switchable unless [pinned].
({MemoryKeyValueStore settings, MemorySecretStore secrets}) signInStores(
  FakeTix server, {
  String tenant = 'default',
  bool pinned = false,
  List<String> tenants = const ['default'],
}) {
  final settings = MemoryKeyValueStore();
  final secrets = MemorySecretStore();
  server.accounts['ana@example.com'] = FakeAccount(
    password: 'pw',
    tenants: tenants,
  );
  settings.values['storage.version'] = '2';
  settings.values['instances'] = jsonEncode([
    {
      'id': 'i1',
      'name': 'Work',
      'kind': 'remote',
      'base_url': 'https://tix.example',
      'created_at': '2026-11-01T00:00:00.000Z',
    },
  ]);
  settings.values['connections'] = jsonEncode([
    {
      'id': 's1',
      'instance_id': 'i1',
      'kind': 'sign_in',
      'email': 'ana@example.com',
      'handle': 'ana',
      'tenant_key': tenant,
      'tenant_name': server.tenants[tenant]?.name ?? tenant,
      'pinned': pinned,
      'memberships': [
        for (final t in tenants)
          {
            'tenant_key': t,
            'tenant_name': server.tenants[t]?.name ?? t,
            'handle': 'ana',
            'role': 'admin',
            'host': server.tenants[t]?.host ?? '',
          },
      ],
      'created_at': '2026-11-01T00:00:00.000Z',
    },
  ]);
  settings.values['context.active'] = jsonEncode({
    'connection_id': 's1',
    'tenant_key': tenant,
  });
  secrets.values['session.s1'] = server.startSession('ana@example.com', tenant);
  return (settings: settings, secrets: secrets);
}

/// Overrides that point the app at [server] with the given stores.
List<Override> fakeOverrides(
  FakeTix server, {
  MemoryKeyValueStore? settings,
  MemorySecretStore? secrets,
  LocalTixEngine? engine,
  FilePicking? files,
  LocalFileAccess? access,
  bool local = false,
  CacheStore? cache,
  EventSocketConnector events = refusingEventSocket,
  FakeNotes? notes,
  FakeWidgetBridge? widgets,
  NetworkState network = NetworkState.unmetered,
  Stream<NetworkState>? networks,
  bool autoSync = false,
  UpdateMode updates = UpdateMode.off,
  DateTime Function()? clock,
}) => [
  keyValueStoreProvider.overrideWithValue(settings ?? MemoryKeyValueStore()),
  secretStoreProvider.overrideWithValue(secrets ?? MemorySecretStore()),
  tixApiFactoryProvider.overrideWithValue(server.factory),
  localTixEngineProvider.overrideWithValue(engine ?? InMemoryLocalTixEngine()),
  localInstancesEnabledProvider.overrideWithValue(local),
  filePickingProvider.overrideWithValue(files ?? FakeFilePicking()),
  localFileAccessProvider.overrideWithValue(
    access ??
        FakeLocalFileAccess(
          inPlace: (files?.opensInPlace ?? true)
              ? InPlaceKind.dialogs
              : InPlaceKind.none,
        ),
  ),
  clockProvider.overrideWithValue(clock ?? () => fixedNow),
  cacheStoreProvider.overrideWithValue(cache ?? MemoryCacheStore()),
  eventSocketConnectorProvider.overrideWithValue(events),
  appResumedProvider.overrideWithValue(const AsyncData(null)),
  appHiddenProvider.overrideWithValue(const AsyncData(null)),
  localNotesProvider.overrideWithValue(notes ?? FakeNotes()),
  widgetBridgeProvider.overrideWithValue(
    widgets ?? FakeWidgetBridge(supported: false),
  ),
  if (networks == null)
    networkStateProvider.overrideWithValue(AsyncData(network))
  else
    networkStateProvider.overrideWith((ref) => networks),
  autoSyncProvider.overrideWithValue(autoSync),
  updateModeProvider.overrideWithValue(AsyncData(updates)),
];

/// The time every test runs at.
final fixedNow = DateTime.utc(2026, 11, 1, 12);

/// File dialogs that answer from fields.
class FakeFilePicking implements FilePicking {
  FakeFilePicking({
    this.desktop = true,
    this.open,
    this.created,
    this.exported = true,
  });

  final bool desktop;
  String? open;
  String? created;
  bool exported;
  final names = <String>[];
  final imports = <String>[];
  final exports = <String>[];

  @override
  bool get opensInPlace => desktop;

  @override
  Future<String?> openDatabase() async => open;

  @override
  Future<String?> importDatabase() async {
    final picked = open;
    if (picked == null) return null;
    imports.add(picked);
    return '/docs/${picked.split('/').last}';
  }

  @override
  Future<bool> exportDatabase(String path, {Rect? origin}) async {
    exports.add(path);
    return exported;
  }

  @override
  Future<String?> newDatabase(String name) async {
    names.add(name);
    return created;
  }

  @override
  Future<String> documentsDatabase(String name) async {
    names.add(name);
    return '/docs/${withDbExtension(name)}';
  }
}

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
  bool settle = true,
}) async {
  await setSize(tester, size);
  Widget stub(BuildContext _, GoRouterState s) =>
      Scaffold(body: Text('route:${s.uri}'));
  final router = GoRouter(
    errorBuilder: stub,
    routes: [
      GoRoute(path: '/', builder: (_, _) => screen),
      GoRoute(path: '/connect', builder: stub),
      GoRoute(path: '/inbox', builder: stub),
      GoRoute(path: '/tasks', builder: stub),
      GoRoute(
        path: '/settings',
        builder: stub,
        routes: [
          GoRoute(path: 'instances', builder: stub),
          GoRoute(path: 'filters', builder: stub),
          GoRoute(
            path: 'notifications',
            builder: stub,
            routes: [GoRoute(path: 'channels/:id', builder: stub)],
          ),
          GoRoute(path: 'about', builder: stub),
          GoRoute(path: 'account', builder: stub),
          GoRoute(path: 'calendar', builder: stub),
          GoRoute(path: 'tokens', builder: stub),
          GoRoute(path: 'offline', builder: stub),
          GoRoute(path: 'conflicts', builder: stub),
        ],
      ),
      GoRoute(
        path: '/projects',
        builder: stub,
        routes: [
          GoRoute(
            path: ':key',
            builder: stub,
            routes: [
              GoRoute(path: 'tasks/:ref', builder: stub),
              GoRoute(path: 'settings', builder: stub),
              GoRoute(path: 'fields', builder: stub),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/manage',
        builder: stub,
        routes: [
          GoRoute(
            path: 'workflows',
            builder: stub,
            routes: [GoRoute(path: ':key', builder: stub)],
          ),
          GoRoute(
            path: 'fields',
            builder: stub,
            routes: [GoRoute(path: ':key', builder: stub)],
          ),
          GoRoute(
            path: 'users',
            builder: stub,
            routes: [GoRoute(path: ':id', builder: stub)],
          ),
          GoRoute(path: 'tokens', builder: stub),
          GoRoute(path: 'transfer', builder: stub),
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
        theme: buildTixTheme(Brightness.light),
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
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return ProviderScope.containerOf(tester.element(find.byWidget(screen)));
}
