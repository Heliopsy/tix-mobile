// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/design.dart';

void main() {
  testWidgets('a primary button runs its action', (tester) async {
    var pressed = 0;
    await pumpComponent(
      tester,
      TixButton.primary(label: 'New task', onPressed: () => pressed++),
    );
    await tester.tap(find.text('New task'));
    expect(pressed, 1);
  });

  testWidgets('a busy button shows a spinner and ignores presses', (
    tester,
  ) async {
    var pressed = 0;
    await pumpComponent(
      tester,
      TixButton.primary(label: 'Save', busy: true, onPressed: () => pressed++),
    );
    await tester.tap(find.text('Save'));
    expect(pressed, 0);
    expect(
      find.descendant(
        of: find.byType(TixButton),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
  });

  for (final size in TixButtonSize.values) {
    testWidgets('a ${size.name} button is at least 48 high to the finger', (
      tester,
    ) async {
      await pumpComponent(
        tester,
        Center(
          child: TixButton(label: 'Go', size: size, onPressed: () {}),
        ),
      );
      expect(
        tester.getSize(find.byType(TextButton)).height,
        greaterThanOrEqualTo(TixSize.target),
      );
    });
  }

  testWidgets('the danger intent is the danger colour, whatever the accent', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      TixButton.danger(label: 'Delete', onPressed: () {}),
      accent: TixAccent.resolve('ember'),
    );
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.style!.backgroundColor!.resolve({}), TixTokens.light.danger);
  });
}
