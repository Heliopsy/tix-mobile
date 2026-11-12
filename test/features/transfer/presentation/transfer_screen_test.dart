// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/transfer/presentation/transfer_screen.dart';

import '../../../helpers/fake_tix.dart';
import '../../../helpers/people_app.dart';

void main() {
  const tallPhone = Size(400, 3000);
  const tallDesktop = Size(1280, 3000);

  for (final MapEntry(key: width, value: size) in {
    'compact': tallPhone,
    'expanded': tallDesktop,
  }.entries) {
    group(width, () {
      testWidgets('loading, then every section', (tester) async {
        final rig = PeopleRig();
        rig.server.gate = Completer<void>();
        await rig.pump(
          tester,
          const TransferScreen(),
          size: size,
          settle: false,
        );
        expect(find.byType(SkeletonList), findsOneWidget);
        rig.server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('transfer.export')), findsOneWidget);
        expect(find.byKey(const Key('transfer.import')), findsOneWidget);
        expect(find.byKey(const Key('transfer.snapshot')), findsOneWidget);
        expect(
          find.byKey(const Key('transfer.column.custom:env')),
          findsOneWidget,
        );
      });

      testWidgets('no projects', (tester) async {
        final rig = PeopleRig();
        rig.server.projects.clear();
        await rig.pump(tester, const TransferScreen(), size: size);
        expect(find.byKey(const Key('transfer.export')), findsNothing);
        expect(find.byType(EmptyState), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final rig = PeopleRig();
        rig.server.override = FakeResponse(500, envelope('internal', 'x'));
        await rig.pump(tester, const TransferScreen(), size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });
    });
  }

  testWidgets('exports a filtered CSV with chosen columns', (tester) async {
    final rig = PeopleRig();
    await rig.pump(
      tester,
      const TransferScreen(project: 'infra', query: 'tag:auth'),
      size: tallDesktop,
    );
    for (final c in ['body', 'created_at', 'updated_at', 'completed_at']) {
      await tapIn(tester, find.byKey(Key('transfer.column.$c')));
    }
    await tapIn(tester, find.byKey(const Key('transfer.column.custom:paged')));
    await tapIn(tester, find.byKey(const Key('transfer.delimiter.;')));
    await tapIn(tester, find.byKey(const Key('transfer.exportButton')));
    expect(rig.people.lastExport, {
      'format': 'csv',
      'columns': [
        'ref',
        'title',
        'status',
        'priority',
        'assignee',
        'tags',
        'due',
        'parent',
        'depends_on',
        'recurrence',
        'custom:env',
        'custom:window',
      ],
      'query': 'tag:auth',
      'exclude_finished': false,
      'exclude_subtasks': false,
      'include_trashed': false,
      'dates': 'iso',
      'delimiter': ';',
    });
    final saved = rig.files.saved.single;
    expect(saved.name, 'infra-tasks.csv');
    expect(saved.mimeType, 'text/csv');
    expect(utf8.decode(saved.bytes), 'ref,title\ninfra-1,Fix login\n');
    expect(find.text('Saved infra-tasks.csv'), findsOneWidget);
  });

  testWidgets('Markdown sends no delimiter', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const TransferScreen(), size: tallDesktop);
    await tapIn(tester, find.byKey(const Key('transfer.format.markdown')));
    expect(find.byKey(const Key('transfer.delimiter.;')), findsNothing);
    await tapIn(tester, find.byKey(const Key('transfer.exportButton')));
    expect(rig.people.lastExport!['format'], 'markdown');
    expect(rig.people.lastExport!.containsKey('delimiter'), isFalse);
    expect(rig.files.saved.single.name, 'infra-tasks.md');
  });

  testWidgets('a snapshot is saved as NDJSON', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const TransferScreen(), size: tallDesktop);
    await tapIn(tester, find.byKey(const Key('transfer.snapshotButton')));
    expect(rig.files.saved.single.name, 'tix-snapshot.ndjson');
  });

  testWidgets('the import opens on the chosen project', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const TransferScreen(), size: tallDesktop);
    await tapIn(tester, find.byKey(const Key('transfer.importProject')));
    await tapIn(tester, find.text('Web').last);
    await tapIn(tester, find.byKey(const Key('transfer.openImport')));
    expect(
      find.text('route:/manage/transfer/import?project=web'),
      findsOneWidget,
    );
    expect(rig.people.imports, isEmpty);
  });

  testWidgets('a viewer sees no import and no snapshot', (tester) async {
    final rig = PeopleRig();
    rig.people.me = {...rig.people.me, 'role': 'viewer'};
    await rig.pump(tester, const TransferScreen(), size: tallDesktop);
    expect(find.byKey(const Key('transfer.import')), findsNothing);
    expect(find.byKey(const Key('transfer.snapshot')), findsNothing);
  });
}
