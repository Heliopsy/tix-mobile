// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/data/models/task.dart';

import '../../../helpers/design.dart';

void main() {
  testWidgets('each mark reads as its word', (tester) async {
    const words = {
      SyncMarkKind.unsynced: 'Unsynced',
      SyncMarkKind.draft: 'Draft',
      SyncMarkKind.conflict: 'Conflict',
      SyncMarkKind.failed: 'Refused',
      SyncMarkKind.check: 'Check',
    };
    for (final MapEntry(key: kind, value: word) in words.entries) {
      await pumpComponent(tester, SyncMark(kind));
      expect(find.bySemanticsLabel(word), findsOneWidget, reason: kind.name);
    }
  });

  testWidgets('a banner offers its action only when the person has to act', (
    tester,
  ) async {
    var pressed = 0;
    await pumpComponent(
      tester,
      SyncBanner(message: 'waits', actionLabel: 'Resolve', onAction: () {}),
    );
    expect(find.byKey(const Key('sync.banner.action')), findsOneWidget);
    await pumpComponent(
      tester,
      SyncBanner(
        message: 'decide',
        attention: true,
        actionLabel: 'Resolve',
        onAction: () => pressed++,
      ),
    );
    await tester.tap(find.byKey(const Key('sync.banner.action')));
    expect(pressed, 1);
    await pumpComponent(tester, const SyncBanner(message: 'only waits'));
    expect(find.byKey(const Key('sync.banner.action')), findsNothing);
  });

  testWidgets('a row shows its mark beside the title', (tester) async {
    await pumpComponent(
      tester,
      TaskRow(
        task: const Task(id: 'x', ref: 'ops-draft1', title: 'Spike'),
        facts: const TaskFacts(sync: SyncMarkKind.draft),
        onTap: () {},
      ),
    );
    expect(
      find.descendant(
        of: find.byType(TaskRow),
        matching: find.byType(SyncMark),
      ),
      findsOneWidget,
    );
  });
}
