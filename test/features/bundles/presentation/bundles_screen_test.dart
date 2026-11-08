// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/features/bundles/presentation/bundles_screen.dart';
import 'package:tix_mobile/src/features/bundles/presentation/snapshot_import_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/attachments.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeParity parity;
  late FakeAttachments files;

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
    files = FakeAttachments();
  });

  PickedFile file(String name, String content) => PickedFile(
    name: name,
    bytes: Uint8List.fromList(utf8.encode(content)),
    mimeType: 'application/json',
  );

  Future<void> pump(WidgetTester tester, Widget screen, {Size size = phone}) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      screen,
      size: size,
      overrides: [
        ...fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        files.asOverride,
      ],
    );
  }

  Future<void> press(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  group('bundles', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width: exports the picked kinds as a file', (tester) async {
        await pump(tester, const BundlesScreen(), size: size);
        expect(find.textContaining('every kind'), findsOneWidget);
        await press(tester, 'bundle.kind.workflow');
        await tester.enterText(find.byKey(const Key('bundle.name')), 'Ops');
        await press(tester, 'bundle.export');
        expect(server.requests.last.body, {
          'kinds': ['workflow'],
          'name': 'Ops',
        });
        final saved = files.saved.single;
        expect(saved.name, 'tix-bundle-ops.json');
        expect(saved.mimeType, 'application/vnd.tix.bundle+json');
        expect(find.text('Exported tix-bundle-ops.json'), findsOneWidget);
      });
    }

    testWidgets('a picked file is previewed, then imported', (tester) async {
      files.picked = file('setup.json', '{"bundle_version":1}');
      await pump(tester, const BundlesScreen());
      Finder importButton() => find.byKey(const Key('bundle.import'));
      expect(tester.widget<TixButton>(importButton()).onPressed, isNull);
      await press(tester, 'bundle.pick');
      expect(parity.bundleImports.single['preview'], 'true');
      expect(find.byKey(const Key('bundle.plan')), findsOneWidget);
      expect(find.textContaining('urgent → urgent-2'), findsOneWidget);
      await press(tester, 'bundle.import');
      expect(parity.bundleImports.last['preview'], 'false');
      expect(parity.bundleImports.last['body'], '{"bundle_version":1}');
      expect(find.text('Bundle imported.'), findsOneWidget);
      expect(find.byKey(const Key('bundle.done')), findsOneWidget);
    });

    testWidgets('replacing asks first, and a refusal is shown', (tester) async {
      files.picked = file('setup.json', '{}');
      await pump(tester, const BundlesScreen());
      await press(tester, 'bundle.pick');
      await tester.ensureVisible(find.text('Replace mine'));
      await tester.tap(find.text('Replace mine'));
      await tester.pumpAndSettle();
      await press(tester, 'bundle.preview');
      await press(tester, 'bundle.import');
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        parity.bundleImports.where((q) => q['preview'] == 'false'),
        isEmpty,
      );
      server.failures['POST /api/v1/bundles/import'] = FakeResponse(
        409,
        envelope('conflict', 'workflow "kanban" exists'),
      );
      await press(tester, 'bundle.preview');
      expect(find.byKey(const Key('bundle.error')), findsOneWidget);
    });
  });

  group('snapshot import', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width: a dry run counts, then the import asks first', (
        tester,
      ) async {
        files.picked = file('tix.ndjson', '{"kind":"task"}\n');
        await pump(tester, const SnapshotImportScreen(), size: size);
        await press(tester, 'snapshot.pick');
        expect(parity.snapshotImports.single['dry_run'], 'true');
        expect(parity.snapshotImports.single['mode'], 'merge');
        expect(find.text('Created: task 4, project 1'), findsOneWidget);
        await press(tester, 'snapshot.import');
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(
          find
              .descendant(
                of: find.byType(AlertDialog),
                matching: find.text('Import snapshot'),
              )
              .last,
        );
        await tester.pumpAndSettle();
        expect(parity.snapshotImports.last['dry_run'], 'false');
        expect(find.text('Snapshot imported.'), findsOneWidget);
      });
    }

    testWidgets('replace needs a fresh dry run and warns', (tester) async {
      files.picked = file('tix.ndjson', '{}\n');
      await pump(tester, const SnapshotImportScreen());
      await press(tester, 'snapshot.pick');
      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TixButton>(find.byKey(const Key('snapshot.import')))
            .onPressed,
        isNull,
      );
      await press(tester, 'snapshot.dryRun');
      expect(parity.snapshotImports.last['mode'], 'replace');
      expect(find.text('Deleted: task 1'), findsOneWidget);
      await press(tester, 'snapshot.import');
      expect(find.textContaining('cannot be undone'), findsOneWidget);
    });
  });
}
