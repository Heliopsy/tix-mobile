// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

/// An iPhone 15 in points, with its notch and home indicator insets.
const iphone = Size(393, 852);
const notch = 59.0;
const homeIndicator = 34.0;

/// Runs a test with the platform set to iOS.
final ios = TargetPlatformVariant.only(TargetPlatform.iOS);

void main() {
  Future<ProviderContainer> pumpIphone(WidgetTester tester) async {
    await setSize(tester, iphone);
    tester.view
      ..padding = const FakeViewPadding(top: notch, bottom: homeIndicator)
      ..viewPadding = const FakeViewPadding(top: notch, bottom: homeIndicator);
    final stores = signedInStores();
    final scope = ProviderScope(
      retry: noRetry,
      overrides: fakeOverrides(
        FakeTix(),
        settings: stores.settings,
        secrets: stores.secrets,
      ),
      child: const App(),
    );
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(App)));
  }

  /// Whether [finder]'s whole box sits between the notch and the home
  /// indicator, where a thumb can reach it.
  void expectInReach(WidgetTester tester, Finder finder) {
    final box = tester.getRect(finder);
    expect(box.top, greaterThanOrEqualTo(notch));
    expect(box.bottom, lessThanOrEqualTo(iphone.height - homeIndicator));
  }

  testWidgets('on an iPhone the shell offers quick add above the bar', (
    tester,
  ) async {
    final c = await pumpIphone(tester);
    final button = find.byKey(const Key('shell.quickAdd'));
    expect(button, findsOneWidget);
    expect(button.hitTestable(), findsOneWidget);
    expectInReach(tester, button);
    expect(
      tester.getBottomLeft(button).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy),
    );
    expect(c.read(quickAddDraftsProvider), isNull);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quickAdd.line')), findsOneWidget);
  }, variant: ios);

  testWidgets("on an iPhone a project's New task button clears the bar", (
    tester,
  ) async {
    await pumpIphone(tester);
    await tester.tap(find.text('Infrastructure'));
    await tester.pumpAndSettle();
    final fab = find.byKey(const Key('tasks.quickAdd'));
    expect(fab.hitTestable(), findsOneWidget);
    expectInReach(tester, fab);
    expect(
      tester.getBottomLeft(fab).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy),
    );
  }, variant: ios);
}
