// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/design.dart';

void main() {
  late BuildContext ctx;
  Future<void> pump(WidgetTester tester) => pumpComponent(
    tester,
    Builder(
      builder: (context) {
        ctx = context;
        return const SizedBox.expand();
      },
    ),
  );

  testWidgets('applied at once, kept when the server agrees, undone on Undo', (
    tester,
  ) async {
    await pump(tester);
    var done = false;
    var undone = 0;
    final ok = runOptimistic(
      ctx,
      apply: () => done = true,
      rollback: () => done = false,
      commit: () async {},
      describe: (_) => 'failed',
      success: 'Completed ops-7',
      undo: () async => undone++,
    );
    expect(done, isTrue);
    expect(await ok, isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Completed ops-7'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toast.action')));
    await tester.pumpAndSettle();
    expect((done, undone), (false, 1));
  });

  testWidgets('rolled back with an error toast when the server refuses', (
    tester,
  ) async {
    await pump(tester);
    var done = false;
    final ok = await runOptimistic(
      ctx,
      apply: () => done = true,
      rollback: () => done = false,
      commit: () async => throw StateError('no'),
      describe: (_) => 'Someone changed it first.',
    );
    await tester.pumpAndSettle();
    expect(ok, isFalse);
    expect(done, isFalse);
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.backgroundColor, TixTokens.light.dangerSoft);
    expect(find.text('Someone changed it first.'), findsOneWidget);
  });

  group('swiped away', () {
    Future<void> show(WidgetTester tester) async {
      await pump(tester);
      showTixToast(ctx, 'Completed ops-7');
      await tester.pumpAndSettle();
      expect(find.text('Completed ops-7'), findsOneWidget);
    }

    for (final (name, offset) in [
      ('to the left', const Offset(-300, 0)),
      ('to the right', const Offset(300, 0)),
      ('down', const Offset(0, 120)),
    ]) {
      testWidgets(name, (tester) async {
        await show(tester);
        await tester.fling(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Completed ops-7'),
          ),
          offset,
          1000,
        );
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
      });
    }

    testWidgets('sideways is the theme default for any snack bar', (
      tester,
    ) async {
      await pump(tester);
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text('Plain')));
      await tester.pumpAndSettle();
      await tester.fling(find.text('Plain'), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Plain'), findsNothing);
    });
  });
}
