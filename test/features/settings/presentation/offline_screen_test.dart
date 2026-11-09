// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/features/settings/application/offline.dart';
import 'package:tix_mobile/src/features/settings/presentation/offline_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemoryCacheStore cache;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;
  const scope = CacheScope('c1', '');

  setUp(() {
    server = FakeTix();
    cache = MemoryCacheStore();
    stores = signedInStores();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Size size, {
    bool settle = true,
  }) => pumpScreen(
    tester,
    const OfflineScreen(),
    size: size,
    settle: settle,
    overrides: fakeOverrides(
      server,
      settings: stores.settings,
      secrets: stores.secrets,
      cache: cache,
    ),
  );

  Finder inSection(String key, Finder matching) => find.descendant(
    of: find.byKey(Key(key)),
    matching: matching,
    matchRoot: true,
  );

  bool switchOn(String key) =>
      (inSection(key, find.byType(Switch)).evaluate().single.widget as Switch)
          .value;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('lists the choice with My work and Starred on', (
        tester,
      ) async {
        await pump(tester, size);
        expect(switchOn('offline.mywork'), isTrue);
        expect(switchOn('offline.starred'), isTrue);
        expect(switchOn('offline.project.infra'), isFalse);
        expect(find.text('Infrastructure'), findsOneWidget);
        expect(find.text('Not synced yet'), findsOneWidget);
        expect(
          inSection('offline.size', find.textContaining(' B used')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('offline.project.infra')));
        await tester.tap(find.byKey(const Key('offline.starred')));
        await tester.pumpAndSettle();
        expect(switchOn('offline.project.infra'), isTrue);
        expect(switchOn('offline.starred'), isFalse);
        expect(stores.settings.values['offline.c1..projects'], '["infra"]');
        expect(stores.settings.values['offline.c1..starred'], 'false');
      });

      testWidgets('projects load with a skeleton', (tester) async {
        server.gate = Completer<void>();
        await pump(tester, size, settle: false);
        await tester.pump();
        expect(find.byType(SkeletonList), findsOneWidget);
        expect(find.byKey(const Key('offline.project.infra')), findsNothing);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(SkeletonList), findsNothing);
        expect(find.byKey(const Key('offline.project.infra')), findsOneWidget);
      });

      testWidgets('projects that fail to load can be retried', (tester) async {
        server.failing['/api/v1/projects'] = FakeResponse(
          403,
          envelope('forbidden', 'project:read'),
        );
        await pump(tester, size);
        expect(find.byType(ErrorState), findsOneWidget);
        expect(find.byKey(const Key('offline.project.infra')), findsNothing);
        server.failing.clear();
        await tester.tap(find.byKey(const Key('error.retry')));
        await tester.pumpAndSettle();
        expect(find.byType(ErrorState), findsNothing);
        expect(find.byKey(const Key('offline.project.infra')), findsOneWidget);
      });

      testWidgets('Sync now runs and says when', (tester) async {
        final c = await pump(tester, size);
        String sizeText() =>
            tester.widget<Text>(find.byKey(const Key('offline.size'))).data!;
        final before = sizeText();
        server.gate = Completer<void>();
        await tester.ensureVisible(find.byKey(const Key('offline.sync')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('offline.sync')));
        await tester.pump();
        final button = tester.widget<TixButton>(
          find.byKey(const Key('offline.sync')),
        );
        expect(button.busy, isTrue);
        expect(c.read(offlineSyncProvider).running, isTrue);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(c.read(offlineSyncProvider).lastSyncedAt, fixedNow);
        expect(find.textContaining('Last synced'), findsOneWidget);
        expect(sizeText(), isNot(before));
        expect(find.byKey(const Key('offline.error')), findsNothing);
      });

      testWidgets('a failed sync shows its error', (tester) async {
        await pump(tester, size);
        server.failing['/api/v1/workflows'] = FakeResponse(
          403,
          envelope('forbidden', 'workflow:read'),
        );
        await tester.ensureVisible(find.byKey(const Key('offline.sync')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('offline.sync')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('offline.error')));
        expect(find.byKey(const Key('offline.error')), findsOneWidget);
        expect(find.text('Not synced yet'), findsOneWidget);
      });

      testWidgets('clear asks first and keeps sync/', (tester) async {
        await cache.write(scope, 'tasks/infra', '{"at":"","data":null}');
        await cache.write(scope, 'sync/outbox/1', '{}');
        await pump(tester, size);
        final clear = find.byKey(const Key('offline.clear'));
        await tester.ensureVisible(clear);
        await tester.tap(clear);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(cache.entries['c1/']!.keys, contains('tasks/infra'));

        await tester.tap(clear);
        await tester.pumpAndSettle();
        expect(find.text('Clear saved copies?'), findsOneWidget);
        await tester.tap(find.byKey(const Key('confirm.ok')));
        await tester.pumpAndSettle();
        expect(cache.entries['c1/']!.keys, ['sync/outbox/1']);
        expect(find.text('2 B used'), findsOneWidget);
      });
    });
  }

  testWidgets('a local instance shows only the note', (tester) async {
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
    await pump(tester, phone);
    expect(find.byKey(const Key('offline.local')), findsOneWidget);
    expect(find.byKey(const Key('offline.sync')), findsNothing);
    expect(find.byKey(const Key('offline.mywork')), findsNothing);
  });

  test('sizes read as people write them', () {
    expect(formatBytes(512, 'en'), '512 B');
    expect(formatBytes(1536, 'en'), '1.5 KB');
    expect(formatBytes(5 * 1024 * 1024, 'de'), '5,0 MB');
  });

  testWidgets('the conflict policy is kept for the context', (tester) async {
    final c = await pump(tester, phone);
    await tester.dragUntilVisible(
      find.byKey(const Key('offline.policy')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('offline.policy')),
        matching: find.text('Keep theirs'),
      ),
    );
    await tester.pumpAndSettle();
    expect(c.read(conflictPolicySettingProvider), ConflictPolicy.keepTheirs);
    expect(stores.settings.values['sync.policy.c1.'], 'keepTheirs');
  });

  testWidgets('an unreadable outbox is set aside and said so', (tester) async {
    await cache.write(scope, SyncStore.key, '{"entries": [');
    final c = await pump(tester, phone);
    await tester.dragUntilVisible(
      find.byKey(const Key('offline.unreadable')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(
      inSection('offline.unreadable', find.textContaining('could not be read')),
      findsOneWidget,
    );
    final aside = c.read(syncStoreProvider).setAside!;
    expect(await cache.read(scope, aside), '{"entries": [');
  });

  testWidgets('discard all asks first, then empties the outbox', (
    tester,
  ) async {
    final snap = SyncSnapshot(
      entries: [
        OutboxEntry(
          id: 'e1',
          seq: 1,
          op: OutboxOp.comment,
          target: 'infra-1',
          idempotencyKey: 'k',
          createdAt: DateTime.utc(2026, 11),
          values: const {'body': 'hi'},
          state: OutboxState.failed,
        ),
      ],
    );
    await cache.write(scope, SyncStore.key, jsonEncode(snap.toJson()));
    final c = await pump(tester, phone);
    await tester.dragUntilVisible(
      find.byKey(const Key('offline.discardAll')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('offline.discardAll')));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 change made offline'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(c.read(syncStoreProvider).now.entries, hasLength(1));

    await tester.tap(find.byKey(const Key('offline.discardAll')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(c.read(syncStoreProvider).now.entries, isEmpty);
  });
}
