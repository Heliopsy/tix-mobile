// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/offline/sync_store.dart';
import 'package:tix_mobile/src/features/sync/presentation/conflicts_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late MemoryCacheStore cache;
  const scope = CacheScope('c1', '');
  final at = DateTime.utc(2026, 11, 1, 10);

  OutboxEntry entry(
    String id,
    OutboxState state, {
    OutboxOp op = OutboxOp.update,
    Map<String, Object?> values = const {'title': 'My title'},
    String error = '',
  }) => OutboxEntry(
    id: id,
    seq: id.hashCode & 0xff,
    op: op,
    target: 'infra-1',
    idempotencyKey: 'k-$id',
    createdAt: at,
    values: values,
    state: state,
    errorMessage: error,
  );

  ConflictRecord record(
    String id, {
    String entryId = 'e1',
    ConflictKind kind = ConflictKind.fields,
    Resolution? resolution,
    bool auto = false,
  }) => ConflictRecord(
    id: id,
    entryId: entryId,
    taskRef: 'infra-1',
    taskTitle: 'Fix login',
    kind: kind,
    createdAt: at,
    reason: 'no route from todo to done',
    wanted: 'done',
    resolution: resolution,
    auto: auto,
    fields: const [
      FieldConflict(
        field: 'title',
        base: 'Fix',
        mine: 'My title',
        theirs: 'Their title',
      ),
    ],
  );

  setUp(() {
    server = FakeTix();
    cache = MemoryCacheStore();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Size size,
    SyncSnapshot snap,
  ) async {
    await cache.write(scope, SyncStore.key, jsonEncode(snap.toJson()));
    final stores = signedInStores();
    return await pumpScreen(
      tester,
      const ConflictsScreen(),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        cache: cache,
      ),
    );
  }

  SyncSnapshot kept(ProviderContainer c) => c.read(syncStoreProvider).now;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('says when everything is synced', (tester) async {
        await pump(tester, size, const SyncSnapshot());
        expect(find.text('Everything is synced'), findsOneWidget);
      });

      testWidgets('shows both sides of a conflict and keeps mine', (
        tester,
      ) async {
        final c = await pump(
          tester,
          size,
          SyncSnapshot(
            entries: [entry('e1', OutboxState.conflict)],
            conflicts: [record('r1')],
          ),
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('sync.side.mine.title')),
            matching: find.text('My title'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('sync.side.theirs.title')),
            matching: find.text('Their title'),
          ),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('sync.mine.r1')));
        await tester.pumpAndSettle();

        expect(kept(c).conflicts.single.resolution, Resolution.mine);
        expect(kept(c).entries, isEmpty);
        expect(server.task('infra-1')!['title'], 'My title');
      });

      testWidgets('an edit sends what the person typed', (tester) async {
        final c = await pump(
          tester,
          size,
          SyncSnapshot(
            entries: [entry('e1', OutboxState.conflict)],
            conflicts: [record('r1')],
          ),
        );
        await tester.tap(find.byKey(const Key('sync.edit.r1')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byKey(const Key('sync.edit.title')),
            matching: find.byType(EditableText),
          ),
          'Both',
        );
        await tester.tap(find.byKey(const Key('sync.edit.save')));
        await tester.pumpAndSettle();

        expect(kept(c).conflicts.single.resolution, Resolution.edited);
        expect(server.task('infra-1')!['title'], 'Both');
      });

      testWidgets('keep all theirs settles every open conflict', (
        tester,
      ) async {
        final c = await pump(
          tester,
          size,
          SyncSnapshot(
            entries: [
              entry('e1', OutboxState.conflict),
              entry('e2', OutboxState.conflict),
            ],
            conflicts: [
              record('r1'),
              record('r2', entryId: 'e2'),
            ],
          ),
        );
        await tester.tap(find.byKey(const Key('sync.keepAllTheirs')));
        await tester.pumpAndSettle();

        expect(
          kept(c).conflicts.map((r) => r.resolution),
          everyElement(Resolution.theirs),
        );
        expect(kept(c).entries, isEmpty);
      });

      testWidgets('a deleted task is discarded only after confirming', (
        tester,
      ) async {
        final c = await pump(
          tester,
          size,
          SyncSnapshot(
            entries: [entry('e1', OutboxState.conflict)],
            conflicts: [record('r1', kind: ConflictKind.deleted)],
          ),
        );
        await tester.tap(find.byKey(const Key('sync.discard.r1')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(kept(c).entries, hasLength(1));

        await tester.tap(find.byKey(const Key('sync.discard.r1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm.ok')));
        await tester.pumpAndSettle();
        expect(kept(c).entries, isEmpty);
        expect(kept(c).conflicts.single.resolution, Resolution.discarded);
      });

      testWidgets('a refused change shows the reason and can be dropped', (
        tester,
      ) async {
        final c = await pump(
          tester,
          size,
          SyncSnapshot(
            entries: [
              entry('e1', OutboxState.failed, error: 'priority must be 1 to 5'),
            ],
          ),
        );
        expect(
          find.text('The server refused it: priority must be 1 to 5'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('sync.discardEntry.e1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm.ok')));
        await tester.pumpAndSettle();
        expect(kept(c).entries, isEmpty);
      });

      testWidgets('the history says what the setting decided and reverses '
          'it', (tester) async {
        final c = await pump(
          tester,
          size,
          SyncSnapshot(
            conflicts: [record('r1', resolution: Resolution.mine, auto: true)],
          ),
        );
        expect(find.text('Kept mine, by your setting'), findsOneWidget);

        await tester.tap(find.byKey(const Key('sync.reverse.r1')));
        await tester.pumpAndSettle();

        expect(kept(c).conflicts.single.resolution, Resolution.theirs);
        expect(server.task('infra-1')!['title'], 'Their title');
      });
    });
  }
}
