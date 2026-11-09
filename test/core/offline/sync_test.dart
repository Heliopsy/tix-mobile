// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/offline/connectivity.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

class _Timers {
  final ticks = <void Function(Timer)>[];
  final periods = <Duration>[];

  Timer start(Duration period, void Function(Timer) tick) {
    periods.add(period);
    ticks.add(tick);
    return Timer(const Duration(days: 365), () {});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeTix server;
  late MemoryCacheStore cache;
  late _Timers timers;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  setUp(() {
    server = FakeTix(
      tasks: {
        'infra': [
          taskJson('infra-1', title: 'Fix login', assignee: 'me'),
          taskJson('infra-2', title: 'Rotate keys', starred: true),
          taskJson('infra-3', title: 'Patch'),
        ],
        'web': [taskJson('web-1', title: 'Logo')],
      },
    )..pageSize = 1;
    server.comments['infra-2'] = [
      {
        'id': 'c1',
        'task_id': 'id-infra-2',
        'author_actor_id': 'me',
        'body': 'Before Friday',
        'created_at': '2026-11-01T10:00:00Z',
        'updated_at': '2026-11-01T10:00:00Z',
      },
    ];
    cache = MemoryCacheStore();
    timers = _Timers();
    stores = signedInStores();
  });

  List<Override> overrides({
    NetworkState network = NetworkState.unmetered,
    DeviceConditions device = const DeviceConditions(),
    bool autoSync = false,
  }) => [
    ...fakeOverrides(
      server,
      settings: stores.settings,
      secrets: stores.secrets,
      cache: cache,
      network: network,
      autoSync: autoSync,
    ),
    deviceProbeProvider.overrideWithValue(() async => device),
    periodicTimerProvider.overrideWithValue(timers.start),
  ];

  Future<ProviderContainer> container({
    NetworkState network = NetworkState.unmetered,
    DeviceConditions device = const DeviceConditions(),
    bool autoSync = false,
  }) async {
    final c = makeContainer(
      overrides(network: network, device: device, autoSync: autoSync),
    );
    await c.read(sessionControllerProvider.future);
    return c;
  }

  const projectInfra = 'offline.c1..projects';

  int listings() => server.requestsTo('/api/v1/tasks').length;

  test('a sync fetches every page under the keys the screens read', () async {
    stores.settings.values[projectInfra] = jsonEncode(['infra']);
    final c = await container();
    await c.read(offlineSyncProvider.notifier).syncNow();
    final state = c.read(offlineSyncProvider);
    expect(state.error, isNull);
    expect(state.lastSyncedAt, fixedNow);
    expect(stores.settings.values['offline.c1..synced'], isNotNull);
    expect(server.requestsTo('/api/v1/tasks/infra-3/comments'), hasLength(1));

    server.offline = true;
    final offline = await container();
    Future<T> read<T>(ProviderListenable<Future<T>> p) =>
        offline.listen(p, (_, _) {}).read();
    final index = await read(taskContextProvider.future);
    expect(index.projects.map((p) => p.key), ['infra', 'web']);
    const screen = TaskScreenState();
    final project = await read(
      taskListingProvider(screen.query(const ProjectScope('infra'))).future,
    );
    expect(project.items.map((t) => t.ref), ['infra-1', 'infra-2', 'infra-3']);
    expect(project.cursor, isNull);
    final mine = await read(
      taskListingProvider(screen.query(const MineScope())).future,
    );
    expect(mine.items, isNotEmpty);
    final starred = await read(
      taskListingProvider(
        const TaskScreenState(expression: 'is:starred').query(const AllScope()),
      ).future,
    );
    expect(starred.items, isNotEmpty);
    expect(
      server
          .requestsTo('/api/v1/tasks')
          .where((r) => r.uri.queryParameters['starred'] == 'true'),
      isNotEmpty,
    );
    final task = await read(taskDetailProvider('infra-2').future);
    expect(task.title, 'Rotate keys');
    final comments = await read(taskCommentsProvider('infra-2').future);
    expect(comments.single.body, 'Before Friday');
    expect(await read(taskSubtasksProvider('infra-2').future), isEmpty);
    expect(await read(projectFieldsProvider('p1').future), isNotEmpty);
    expect((await read(projectWorkflowProvider('p1').future)).id, 'wf1');
    expect(await read(tagDirectoryProvider.future), isNotEmpty);
    expect(await read(actorDirectoryProvider.future), isNotEmpty);
    expect((await read(actorProvider('me').future)).id, 'me');
    expect(
      await read(savedCopySinceProvider.future),
      isNotNull,
      reason: 'the screens are told they draw a saved copy',
    );
  });

  test('a project not chosen is not fetched', () async {
    stores.settings.values['offline.c1..mywork'] = 'false';
    stores.settings.values['offline.c1..starred'] = 'false';
    final c = await container();
    await c.read(offlineSyncProvider.notifier).syncNow();
    expect(listings(), 0);
    expect(server.requestsTo('/api/v1/projects'), isNotEmpty);
  });

  test('steps run in order before the prefetch', () async {
    final c = await container();
    final order = <String>[];
    final steps = c.read(syncStepsProvider.notifier)
      ..add(() async => order.add('a ${listings()}'));
    final remove = steps.add(() async => order.add('b'));
    await c.read(offlineSyncProvider.notifier).syncNow();
    expect(order, ['a 0', 'b']);
    remove();
    order.clear();
    await c.read(offlineSyncProvider.notifier).syncNow();
    expect(order, hasLength(1));
    expect(order.single, startsWith('a '));
  });

  test('a failed sync keeps its error and the last good time', () async {
    final c = await container();
    await c.read(offlineSyncProvider.notifier).syncNow();
    server.offline = true;
    await c.read(offlineSyncProvider.notifier).syncNow();
    final state = c.read(offlineSyncProvider);
    expect(state.running, isFalse);
    expect(state.lastSyncedAt, fixedNow);
    expect(
      state.error,
      isA<TixException>().having((e) => e.kind, 'kind', TixErrorKind.network),
    );
  });

  group('automatic sync', () {
    test('runs on activation and on each tick on Wi-Fi', () async {
      final c = await container(autoSync: true);
      int projectReads() => server.requestsTo('/api/v1/projects').length;
      c.read(offlineSyncProvider);
      await pumpEventQueue();
      expect(projectReads(), greaterThan(0));
      await c.read(offlineSyncProvider.notifier).syncNow();
      expect(c.read(offlineSyncProvider).lastSyncedAt, fixedNow);
      expect(timers.periods, [syncEvery]);
      final before = projectReads();
      timers.ticks.single(Timer(Duration.zero, () {}));
      await pumpEventQueue();
      expect(projectReads(), greaterThan(before));
      await c.read(offlineSyncProvider.notifier).syncNow();
    });

    for (final (name, network, device) in [
      (
        'mobile data',
        NetworkState.metered,
        const DeviceConditions(phone: true),
      ),
      (
        'battery saver',
        NetworkState.unmetered,
        const DeviceConditions(phone: true, batterySaver: true),
      ),
      (
        'a low battery',
        NetworkState.unmetered,
        const DeviceConditions(phone: true, batteryLow: true),
      ),
      ('no network', NetworkState.offline, const DeviceConditions()),
    ]) {
      test('waits on $name, while Sync now runs', () async {
        final c = await container(
          autoSync: true,
          network: network,
          device: device,
        );
        final sync = c.read(offlineSyncProvider.notifier);
        await pumpEventQueue();
        expect(await sync.runAutomatic(), isFalse);
        expect(listings(), 0);
        expect(server.requestsTo('/api/v1/projects'), isEmpty);
        if (network != NetworkState.offline) {
          await sync.syncNow();
          expect(listings(), greaterThan(0));
          expect(c.read(offlineSyncProvider).lastSyncedAt, fixedNow);
        }
      });
    }

    test('a desktop on a metered network still runs', () async {
      final c = await container(network: NetworkState.metered);
      expect(await c.read(offlineSyncProvider.notifier).runAutomatic(), isTrue);
      expect(listings(), greaterThan(0));
    });
  });

  test('a local instance is never prefetched', () async {
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
    final c = makeContainer([
      ...overrides(autoSync: true, network: NetworkState.offline),
    ]);
    final session = await c.read(sessionControllerProvider.future);
    expect(session?.instance.name, 'Notes');
    expect(c.read(onlineProvider), isTrue);
    final sync = c.read(offlineSyncProvider.notifier);
    await pumpEventQueue();
    expect(timers.ticks, isEmpty);
    expect(await sync.runAutomatic(), isFalse);
    await sync.syncNow();
    expect(listings(), 0);
    expect(server.requestsTo('/api/v1/projects'), isEmpty);
    expect(c.read(offlineSyncProvider).lastSyncedAt, isNull);
  });

  test('clear forgets the copies and the last sync, keeping sync/', () async {
    final c = await container();
    await c.read(offlineSyncProvider.notifier).syncNow();
    const scope = CacheScope('c1', '');
    await cache.write(scope, 'sync/outbox/1', '{}');
    expect(await cache.sizeOf(scope), greaterThan(2));
    await c.read(offlineSyncProvider.notifier).clear();
    expect(c.read(offlineSyncProvider).lastSyncedAt, isNull);
    expect(stores.settings.values['offline.c1..synced'], isNull);
    expect(cache.entries['c1/']!.keys, ['sync/outbox/1']);
  });

  test('signing out mid-sync stops the prefetch and leaves no copy', () async {
    stores.settings.values[projectInfra] = jsonEncode(['infra']);
    final c = await container();
    final held = Completer<void>();
    final reached = Completer<void>();
    server.routes.add((o, path, caller) async {
      if (path == '/api/v1/tasks' && !held.isCompleted) {
        if (!reached.isCompleted) reached.complete();
        await held.future;
      }
      return null;
    });
    final sync = c.read(offlineSyncProvider.notifier).syncNow();
    await reached.future;
    final signOut = c.read(sessionControllerProvider.notifier).signOut();
    await pumpEventQueue();
    held.complete();
    await Future.wait([sync, signOut]);
    final listed = listings();
    await pumpEventQueue();
    expect(cache.entries.keys.where((k) => k.startsWith('c1/')), isEmpty);
    expect(listings(), listed);
    expect(
      server.requestsTo('/api/v1/tasks/infra-3/comments'),
      isEmpty,
      reason: 'the prefetch stopped before reading each task',
    );
    expect(c.read(offlineSyncProvider).error, isNull);
  });

  test('online follows the network for a remote instance', () async {
    final c = await container(network: NetworkState.offline);
    expect(c.read(onlineProvider), isFalse);
    final d = await container(network: NetworkState.metered);
    expect(d.read(onlineProvider), isTrue);
  });
}
