// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/design.dart';

void main() {
  testWidgets('live is the dot alone; every other state says its word', (
    tester,
  ) async {
    await pumpComponent(tester, const LiveIndicator(state: LiveState.live));
    expect(find.text('Live'), findsNothing);
    for (final (state, word) in [
      (LiveState.connecting, 'Connecting'),
      (LiveState.polling, 'Polling'),
      (LiveState.refreshing, 'Refreshing'),
      (LiveState.offline, 'Offline'),
      (LiveState.unavailable, 'Not available'),
    ]) {
      await pumpComponent(tester, LiveIndicator(state: state));
      expect(
        find.descendant(
          of: find.byKey(const Key('live.indicator')),
          matching: find.text(word),
        ),
        findsOneWidget,
        reason: '$state',
      );
    }
  });

  testWidgets('a long press explains the state', (tester) async {
    await pumpComponent(
      tester,
      const Center(
        child: LiveIndicator(state: LiveState.refreshing, refreshSeconds: 30),
      ),
    );
    await tester.longPress(find.byKey(const Key('live.indicator')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('reloads every 30 seconds'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets('a screen reader hears the state and why', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpComponent(tester, const LiveIndicator(state: LiveState.polling));
    expect(
      find.bySemanticsLabel(RegExp(r'^Live updates: Polling\. .*plain HTTP')),
      findsOneWidget,
    );
    await pumpComponent(
      tester,
      const LiveIndicator(state: LiveState.offline, compact: true),
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Live updates: Offline\. ')),
      findsOneWidget,
    );
    expect(find.text('Offline'), findsNothing);
    semantics.dispose();
  });

  testWidgets(
    'the target is 48 dp and a degraded state is the warning colour',
    (tester) async {
      await pumpComponent(
        tester,
        const Center(child: LiveIndicator(state: LiveState.polling)),
      );
      final size = tester.getSize(find.byKey(const Key('live.indicator')));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
      final word = tester.widget<Text>(find.text('Polling'));
      expect(word.style!.color, TixTokens.light.warn);
    },
  );
}
