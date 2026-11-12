// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/design.dart';

void main() {
  testWidgets('the new rows pill counts them and is one 48dp button', (
    tester,
  ) async {
    var shown = 0;
    await pumpComponent(
      tester,
      Center(child: NewRowsPill(count: 3, onPressed: () => shown++)),
    );
    expect(find.text('3 new, show'), findsOneWidget);
    expect(tester.getSize(find.byType(NewRowsPill)).height, 48);
    await tester.tap(find.byType(NewRowsPill));
    expect(shown, 1);
  });

  testWidgets('the updated mark fades in and out without moving anything', (
    tester,
  ) async {
    await pumpComponent(tester, const UpdatedMark(visible: false));
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      0,
    );
    await pumpComponent(tester, const UpdatedMark(visible: true));
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );
    expect(find.text('Updated'), findsOneWidget);
  });

  testWidgets('changed elsewhere keeps the edit until Reload', (tester) async {
    var reloads = 0;
    var kept = 0;
    await pumpComponent(
      tester,
      ChangedElsewhereBanner(
        by: 'raj',
        onReload: () => reloads++,
        onDismiss: () => kept++,
      ),
    );
    expect(
      find.text('@raj changed this. Your edits are kept.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('live.keep')));
    expect((reloads, kept), (0, 1));
    await tester.tap(find.byKey(const Key('live.reload')));
    expect((reloads, kept), (1, 1));
  });

  testWidgets('without a name or a dismiss it says less and offers Reload', (
    tester,
  ) async {
    await pumpComponent(tester, ChangedElsewhereBanner(onReload: () {}));
    expect(
      find.text('This changed elsewhere. Your edits are kept.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('live.keep')), findsNothing);
  });

  testWidgets('a fresh row is washed in the accent, then fades', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      const FreshHighlight(fresh: true, child: Text('row')),
    );
    final box = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(box.duration, isNot(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.text('row'), findsOneWidget);
  });
}
