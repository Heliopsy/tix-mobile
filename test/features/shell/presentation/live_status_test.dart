// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/features/shell/presentation/context_switcher.dart';
import 'package:tix_mobile/src/features/shell/presentation/live_status.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  Finder inSwitcher(Finder f) =>
      find.descendant(of: find.byKey(const Key('switcher.open')), matching: f);

  Future<void> pump(
    WidgetTester tester, {
    EventSocketConnector events = refusingEventSocket,
    Widget button = const ContextSwitcherButton(),
    Size size = phone,
    Locale locale = const Locale('en'),
  }) async {
    final server = FakeTix();
    final stores = signedInStores();
    await pumpScreen(
      tester,
      Scaffold(body: const SizedBox.expand(), bottomNavigationBar: button),
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: events,
      ),
      size: size,
      locale: locale,
    );
  }

  testWidgets('the switcher says when live updates are refused', (
    tester,
  ) async {
    await pump(tester);
    expect(inSwitcher(find.text('Not available')), findsOneWidget);
  });

  testWidgets('connecting, then the dot alone once live', (tester) async {
    final sockets = FakeEventSockets();
    await pump(tester, events: sockets.connect);
    expect(inSwitcher(find.text('Connecting')), findsOneWidget);
    sockets.last.ack();
    await tester.pump();
    await tester.pump();
    expect(inSwitcher(find.text('Connecting')), findsNothing);
    final dot = tester.widget<LiveIndicator>(
      inSwitcher(find.byType(LiveIndicator)),
    );
    expect(dot.state, LiveState.live);
  });

  testWidgets('a narrow rail badges the avatar', (tester) async {
    await pump(
      tester,
      button: const ContextSwitcherButton(rail: true),
      size: desktop,
    );
    final badge = tester.widget<LiveIndicator>(
      inSwitcher(find.byType(LiveIndicator)),
    );
    expect(badge.compact, isTrue);
    expect(badge.state, LiveState.unavailable);
  });

  testWidgets('Bulgarian', (tester) async {
    await pump(tester, locale: const Locale('bg'));
    expect(inSwitcher(find.text('Недостъпно')), findsOneWidget);
  });

  test('every mode but closed has a state', () {
    for (final m in LiveMode.values) {
      expect(liveStateOf(m) == null, m == LiveMode.closed, reason: '$m');
    }
    expect(liveStateOf(null), isNull);
  });
}
