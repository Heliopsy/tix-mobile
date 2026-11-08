// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/widget_snapshot.dart';
import 'package:tix_mobile/src/features/widgets/application/headless.dart';
import 'package:tix_mobile/src/features/widgets/application/widget_sync.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/fake_widgets.dart';
import '../../../helpers/stores.dart';

const _token = 'widget-test-token';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeTix server;
  late FakeWidgetBridge widgets;
  late MemoryKeyValueStore settings;
  late MemorySecretStore secrets;
  late InMemoryLocalTixEngine engine;

  Map<String, Object?> mine(
    String ref, {
    String? due,
    String status = 'todo',
  }) =>
      taskJson(ref, due: due, status: status, assignee: 'me')
        ..['project_id'] = 'p1';

  setUp(() {
    server = FakeTix(
      token: _token,
      projects: [
        {
          'id': 'p1',
          'key': 'ops',
          'name': 'Operations',
          'color': 'blue',
          'workflow_id': 'wf1',
        },
      ],
      tasks: {
        'ops': [
          mine('ops-1', due: '2026-10-30T00:00:00Z'),
          mine('ops-2'),
          mine('ops-3', status: 'doing'),
        ],
      },
    );
    widgets = FakeWidgetBridge();
    engine = InMemoryLocalTixEngine();
    settings = MemoryKeyValueStore()
      ..values['storage.version'] = '2'
      ..values['instances'] = jsonEncode([
        {
          'id': 'i1',
          'name': 'Work',
          'kind': 'remote',
          'base_url': 'https://tix.example',
          'created_at': '2026-11-01T00:00:00.000Z',
        },
        {
          'id': 'i2',
          'name': 'Laptop',
          'kind': 'local',
          'db_path': '/home/ana/tix.db',
          'created_at': '2026-11-01T00:00:00.000Z',
        },
      ])
      ..values['connections'] = jsonEncode([
        {
          'id': 'c1',
          'instance_id': 'i1',
          'kind': 'token',
          'handle': 'ana',
          'tenant_key': 'default',
          'tenant_name': 'Default',
          'created_at': '2026-11-01T00:00:00.000Z',
        },
        {
          'id': 'l1',
          'instance_id': 'i2',
          'kind': 'token',
          'handle': 'ana',
          'tenant_key': 'default',
          'tenant_name': 'Default',
          'created_at': '2026-11-01T00:00:00.000Z',
        },
      ])
      ..values['context.active'] = jsonEncode({
        'connection_id': 'c1',
        'tenant_key': 'default',
      });
    secrets = MemorySecretStore()
      ..values['token.c1'] = _token
      ..values['token.l1'] = 'local-token';
  });

  ProviderContainer container() => makeContainer(
    fakeOverrides(
      server,
      settings: settings,
      secrets: secrets,
      engine: engine,
      local: true,
      widgets: widgets,
    ),
  );

  Future<ProviderContainer> synced() async {
    final c = container();
    await c.read(sessionControllerProvider.future);
    final sub = c.listen(widgetSyncProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(widgetSyncProvider.future);
    return c;
  }

  void queue(List<WidgetAction> actions) => widgets.values[WidgetKeys.queue] =
      jsonEncode([for (final a in actions) a.toJson()]);

  Map<String, dynamic> task(String ref) =>
      server.tasks['ops']!.firstWhere((t) => t['ref'] == ref)
          as Map<String, dynamic>;

  test(
    'writes the index, my work and the inbox of the active context',
    () async {
      await synced();
      final index = WidgetIndex.fromJson(
        widgets.json(WidgetKeys.index)! as Map<String, dynamic>,
      );
      expect(index.active, 'c1.default');
      expect(index.contexts.map((c) => c.id), ['c1.default', 'l1.default']);
      expect(index.contexts.last.local, isTrue);
      expect(index.projects['c1.default']!.single.key, 'ops');
      expect(index.lockCounts, isTrue);
      expect(index.strings['myWork'], 'My work');
      final work = MyWorkSnapshot.fromJson(
        widgets.json(WidgetKeys.myWork('c1.default'))! as Map<String, dynamic>,
      );
      expect(work.tasks.first.ref, 'ops-1');
      expect(work.total, 3);
      expect(work.ctx.instance, 'Work');
      final inbox = InboxSnapshot.fromJson(
        widgets.json(WidgetKeys.inbox('c1.default'))! as Map<String, dynamic>,
      );
      expect(
        inbox.unread,
        server.inbox.where((i) => i['read_at'] == null).length,
      );
      expect(widgets.redraws, greaterThan(0));
    },
  );

  test(
    'no value written for a widget holds the token or the address',
    () async {
      widgets.values[WidgetKeys.wanted] = jsonEncode({
        'android:1': {'ctx': 'active', 'project': 'ops', 'at': 0},
      });
      await synced();
      expect(widgets.written, isNotEmpty);
      expect(
        widgets.values.keys,
        contains(WidgetKeys.project('c1.default', 'ops')),
      );
      for (final value in widgets.written) {
        expect(value, isNot(contains(_token)));
        expect(value, isNot(contains('tix.example')));
        expect(value, isNot(contains('local-token')));
      }
    },
  );

  test('the privacy setting reaches the index', () async {
    settings.values['settings.widgetLockCounts'] = 'false';
    await synced();
    final index = widgets.json(WidgetKeys.index)! as Map<String, dynamic>;
    expect(index['lockCounts'], isFalse);
  });

  test('a queued tick completes the task and leaves the queue', () async {
    queue([
      const WidgetAction(
        id: 'w1',
        op: 'complete',
        ctx: 'c1.default',
        ref: 'ops-2',
      ),
    ]);
    await synced();
    expect(task('ops-2')['status'], 'done');
    expect(widgets.values.containsKey(WidgetKeys.queue), isFalse);
    final work =
        widgets.json(WidgetKeys.myWork('c1.default'))! as Map<String, dynamic>;
    expect(
      (work['tasks']! as List).map((t) => (t as Map)['ref']),
      isNot(contains('ops-2')),
    );
  });

  test('a tick the server refuses for good is dropped', () async {
    queue([
      const WidgetAction(
        id: 'w1',
        op: 'complete',
        ctx: 'c1.default',
        ref: 'ops-404',
      ),
    ]);
    await synced();
    expect(widgets.values.containsKey(WidgetKeys.queue), isFalse);
  });

  test('a tick offline waits in the queue', () async {
    queue([
      const WidgetAction(
        id: 'w1',
        op: 'complete',
        ctx: 'c1.default',
        ref: 'ops-2',
      ),
    ]);
    final c = container();
    await c.read(sessionControllerProvider.future);
    server.offline = true;
    final sub = c.listen(widgetSyncProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(widgetSyncProvider.future);
    expect(widgets.values[WidgetKeys.queue], contains('w1'));
  });

  group('in the background', () {
    Future<void> run(String host) async {
      final c = container();
      await c.read(sessionControllerProvider.future);
      engine.started.clear();
      await runWidgetBackground(Uri.parse('tixwidget://$host'), c);
    }

    test('drains remote ticks and rewrites remote snapshots', () async {
      queue([
        const WidgetAction(
          id: 'w1',
          op: 'complete',
          ctx: 'c1.default',
          ref: 'ops-2',
        ),
      ]);
      await run('drain');
      expect(task('ops-2')['status'], 'done');
      expect(widgets.values, contains(WidgetKeys.myWork('c1.default')));
    });

    test('never starts a local engine; local ticks wait', () async {
      settings.values['context.active'] = jsonEncode({
        'connection_id': 'l1',
        'tenant_key': 'default',
      });
      queue([
        const WidgetAction(
          id: 'w1',
          op: 'complete',
          ctx: 'l1.default',
          ref: 'ops-2',
        ),
      ]);
      await run('refresh');
      expect(engine.started, isEmpty);
      expect(widgets.values[WidgetKeys.queue], contains('w1'));
      expect(
        widgets.values.containsKey(WidgetKeys.myWork('l1.default')),
        isFalse,
      );
      final index = widgets.json(WidgetKeys.index)! as Map<String, dynamic>;
      expect(index['active'], 'l1.default');
    });

    test('ignores links it does not know', () async {
      await run('nothing');
      expect(widgets.values, isEmpty);
    });
  });

  test('a removed context leaves no snapshot behind', () async {
    final c = await synced();
    expect(widgets.values, contains(WidgetKeys.myWork('c1.default')));
    widgets.values[WidgetKeys.inbox('l1.default')] = '{}';
    await c.read(sessionControllerProvider.notifier).removeInstance('i2');
    await c.read(widgetSyncProvider.notifier).sync();
    expect(widgets.values.containsKey(WidgetKeys.inbox('l1.default')), isFalse);
  });

  group('taps', () {
    test('open marks the inbox item read and answers the route', () async {
      final c = await synced();
      final route = await c
          .read(widgetSyncProvider.notifier)
          .open(
            Uri.parse(
              'tixwidget://open?ctx=c1.default&route=/projects/ops/tasks/ops-1&item=i1',
            ),
          );
      expect(route, '/projects/ops/tasks/ops-1');
      expect(server.requestsTo('/api/v1/inbox/i1/read'), isNotEmpty);
    });

    test('quick add opens a draft in the widget\'s project', () async {
      final c = await synced();
      final route = await c
          .read(widgetSyncProvider.notifier)
          .open(Uri.parse('tixwidget://quickadd?ctx=active&project=ops'));
      expect(route, isNull);
      expect(c.read(quickAddDraftsProvider)?.project, 'ops');
    });

    test('a pinned widget switches to its context first', () async {
      final c = await synced();
      await c
          .read(widgetSyncProvider.notifier)
          .open(Uri.parse('tixwidget://app?ctx=l1.default'));
      expect(c.read(sessionControllerProvider).value?.connection.id, 'l1');
    });

    test('links from elsewhere are ignored', () async {
      final c = await synced();
      final route = await c
          .read(widgetSyncProvider.notifier)
          .open(Uri.parse('https://example.com/?route=/inbox'));
      expect(route, isNull);
    });
  });
}
