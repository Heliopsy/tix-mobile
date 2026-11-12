// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  const help = HelpButton(
    key: Key('help'),
    title: 'Server address',
    body: 'First part.\n\nSecond part.',
  );

  testWidgets('a labelled 48 dp button', (tester) async {
    await pumpComponent(tester, const Center(child: help));
    expect(find.byTooltip('Help: Server address'), findsOneWidget);
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(TixSize.target));
    expect(size.height, greaterThanOrEqualTo(TixSize.target));
  });

  testWidgets('on a phone it opens a sheet, a paragraph per blank line', (
    tester,
  ) async {
    await pumpComponent(tester, const Center(child: help));
    await tester.tap(find.byKey(const Key('help')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    final body = find.byKey(const Key('help.body'));
    expect(
      find.descendant(of: body, matching: find.text('First part.')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: body, matching: find.text('Second part.')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('help.close')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('wider, the keyboard opens it as a dialog', (tester) async {
    await pumpComponent(tester, const Center(child: help), size: desktop);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Server address'),
      ),
      findsOneWidget,
    );
    expect(find.byType(BottomSheet), findsNothing);
  });
}
