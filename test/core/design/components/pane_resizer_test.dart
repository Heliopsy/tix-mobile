// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/gestures.dart'
    show kDoubleTapMinTime, kDoubleTapTimeout;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  late List<String> calls;

  setUp(() => calls = []);

  Widget handle({
    double width = 200,
    bool growsLeft = false,
    bool collapsed = false,
    bool collapsible = true,
  }) => Row(
    children: [
      SizedBox(width: width),
      TixPaneResizer(
        key: const Key('handle'),
        label: 'Resize pane',
        width: width,
        min: 180,
        max: 480,
        growsLeft: growsLeft,
        collapsed: collapsed,
        collapseAt: 120,
        onResize: (w, {required done}) =>
            calls.add('${done ? 'set' : 'drag'} ${w.round()}'),
        onReset: () => calls.add('reset'),
        onCollapse: collapsible ? () => calls.add('collapse') : null,
        onExpand: () => calls.add('expand'),
      ),
      const Expanded(child: SizedBox.expand()),
    ],
  );

  final finder = find.byKey(const Key('handle'));

  Future<void> focus(WidgetTester tester) async {
    Focus.of(
      tester.element(
        find.descendant(of: finder, matching: find.byType(MouseRegion)),
      ),
    ).requestFocus();
    await tester.pump();
  }

  Future<void> press(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    bool shift = false,
  }) async {
    if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(key);
    if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
  }

  testWidgets('a drag reports widths as it goes and keeps the last', (
    tester,
  ) async {
    await pumpComponent(tester, handle(), size: desktop);
    final gesture = await tester.startGesture(tester.getCenter(finder));
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(60, 0));
    await gesture.up();
    await tester.pump(kDoubleTapTimeout);
    await tester.pump();
    expect(calls.where((c) => c.startsWith('drag')), isNotEmpty);
    expect(calls.last, 'set 300');
    expect(calls, isNot(contains('collapse')));
  });

  testWidgets('a drag stops at the maximum', (tester) async {
    await pumpComponent(tester, handle(), size: desktop);
    await tester.drag(finder, const Offset(600, 0));
    await tester.pump(kDoubleTapTimeout);
    await tester.pump();
    expect(calls.last, 'set 480');
  });

  testWidgets('a drag under the collapse width collapses, once', (
    tester,
  ) async {
    await pumpComponent(tester, handle(), size: desktop);
    final gesture = await tester.startGesture(tester.getCenter(finder));
    await gesture.moveBy(const Offset(-50, 0));
    await gesture.moveBy(const Offset(-50, 0));
    await gesture.moveBy(const Offset(-10, 0));
    await gesture.up();
    await tester.pump(kDoubleTapTimeout);
    await tester.pump();
    expect(calls.where((c) => c == 'collapse'), hasLength(1));
    expect(calls.last, 'collapse');
  });

  testWidgets('without a collapse, a drag stops at the minimum', (
    tester,
  ) async {
    await pumpComponent(tester, handle(collapsible: false), size: desktop);
    await tester.drag(finder, const Offset(-150, 0));
    await tester.pump(kDoubleTapTimeout);
    await tester.pump();
    expect(calls.last, 'set 180');
  });

  testWidgets('a pane on the right widens when dragged left', (tester) async {
    await pumpComponent(tester, handle(growsLeft: true), size: desktop);
    await tester.drag(finder, const Offset(-100, 0));
    await tester.pump(kDoubleTapTimeout);
    await tester.pump();
    expect(calls.last, 'set 300');
  });

  testWidgets('a double click resets', (tester) async {
    await pumpComponent(tester, handle(), size: desktop);
    await tester.tap(finder);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(calls, ['reset']);
  });

  testWidgets('the keys move it as tix web does', (tester) async {
    await pumpComponent(tester, handle(), size: desktop);
    await focus(tester);
    await press(tester, LogicalKeyboardKey.arrowRight);
    await press(tester, LogicalKeyboardKey.arrowRight, shift: true);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    await press(tester, LogicalKeyboardKey.home);
    await press(tester, LogicalKeyboardKey.end);
    await press(tester, LogicalKeyboardKey.enter);
    expect(calls, [
      'set 216',
      'set 264',
      'set 184',
      'set 180',
      'set 480',
      'reset',
    ]);
  });

  testWidgets('Left at the minimum collapses and Right expands', (
    tester,
  ) async {
    await pumpComponent(tester, handle(width: 180), size: desktop);
    await focus(tester);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(calls, ['collapse']);
    calls.clear();
    await pumpComponent(
      tester,
      handle(width: 80, collapsed: true),
      size: desktop,
    );
    await focus(tester);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(calls, ['expand']);
  });

  testWidgets('a pane on the right takes the arrows the other way', (
    tester,
  ) async {
    await pumpComponent(tester, handle(growsLeft: true), size: desktop);
    await focus(tester);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(calls, ['set 216']);
  });

  testWidgets('is announced with its width and can be stepped', (tester) async {
    final semantics = tester.ensureSemantics();
    SemanticsNode node() => tester.getSemantics(
      find.descendant(of: finder, matching: find.byType(Semantics)).first,
    );
    await pumpComponent(tester, handle(), size: desktop);
    final data = node().getSemanticsData();
    expect(data.label, 'Resize pane');
    expect(data.value, '200');
    expect(data.increasedValue, '216');
    expect(data.decreasedValue, '184');
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);
    node().owner!.performAction(node().id, SemanticsAction.increase);
    await tester.pump();
    expect(calls, ['set 216']);
    await pumpComponent(
      tester,
      handle(width: 80, collapsed: true),
      size: desktop,
    );
    expect(node().getSemanticsData().value, 'Collapsed');
    semantics.dispose();
  });
}
