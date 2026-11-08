// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  Future<Future<T?> Function()> open<T>(
    WidgetTester tester,
    Future<T?> Function(BuildContext) show, {
    Size size = phone,
  }) async {
    late Future<T?> result;
    await pumpComponent(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => result = show(context),
          child: const Text('open'),
        ),
      ),
      size: size,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => result;
  }

  testWidgets('a destructive action asks, and answers true only on the red '
      'button', (tester) async {
    late Future<bool> answer;
    await pumpComponent(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => answer = confirmDestructive(
            context,
            title: 'Delete?',
            body: 'Gone.',
            action: 'Delete',
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final ok = tester.widget<TixButton>(
      find.ancestor(of: find.text('Delete'), matching: find.byType(TixButton)),
    );
    expect(ok.intent, TixButtonIntent.danger);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await answer, isFalse);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(await answer, isTrue);
  });

  Widget sheet(BuildContext context) =>
      const TixSheetBody(title: 'New project', child: Text('form'));

  testWidgets('a form opens as a sheet on a phone', (tester) async {
    await open<void>(
      tester,
      (context) => showTixSheet<void>(context, builder: sheet),
    );
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('a form opens as a dialog on a desktop', (tester) async {
    await open<void>(
      tester,
      (context) => showTixSheet<void>(context, builder: sheet),
      size: desktop,
    );
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('an action sheet answers with the chosen value', (tester) async {
    final result = await open<int>(
      tester,
      (context) => showActionSheet<int>(
        context,
        title: 'infra-11',
        actions: const [
          TixSheetAction(value: 1, label: 'Complete'),
          TixSheetAction(value: 2, label: 'Delete', destructive: true),
        ],
      ),
    );
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await result(), 2);
  });
}
