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
}
