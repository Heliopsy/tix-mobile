// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/design.dart';

void main() {
  testWidgets('an empty state carries the create action', (tester) async {
    var created = 0;
    await pumpComponent(
      tester,
      EmptyState(
        title: 'No tasks',
        action: TixAction(
          key: const Key('add'),
          label: 'New task',
          icon: Icons.add,
          onPressed: () => created++,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('add')));
    expect(created, 1);
  });

  testWidgets('an error offers a retry and a way back', (tester) async {
    var retried = 0;
    var left = 0;
    await pumpComponent(
      tester,
      ErrorState(
        error: StateError('x'),
        onRetry: () => retried++,
        onBack: () => left++,
      ),
    );
    expect(find.text('Something went wrong.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('error.retry')));
    await tester.tap(find.byKey(const Key('error.back')));
    expect((retried, left), (1, 1));
  });

  testWidgets('a root screen error has no back button to nowhere', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      ErrorState(error: StateError('x'), onRetry: () {}),
    );
    expect(find.byKey(const Key('error.back')), findsNothing);
  });

  testWidgets('a loading list is a skeleton that says it is loading', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpComponent(tester, const SkeletonList(rows: 3));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    semantics.dispose();
  });

  testWidgets('a section is always drawn, never a fold', (tester) async {
    await pumpComponent(
      tester,
      const TixSection(
        title: 'Danger zone',
        info: 'Explained',
        children: [Text('Delete')],
      ),
    );
    expect(find.text('Delete'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
    expect(find.byType(InfoTip), findsOneWidget);
  });
}
