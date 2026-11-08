// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

/// Pumps [screen] signed in to [server] with a token, or with a
/// switchable sign-in to [tenants] when [signIn].
Future<ProviderContainer> pumpAdmin(
  WidgetTester tester,
  FakeTix server,
  Widget screen, {
  Size size = phone,
  bool settle = true,
  bool signIn = false,
  List<String> tenants = const ['default'],
}) {
  final stores = signIn
      ? signInStores(server, tenants: tenants)
      : signedInStores();
  return pumpScreen(
    tester,
    screen,
    size: size,
    settle: settle,
    overrides: fakeOverrides(
      server,
      settings: stores.settings,
      secrets: stores.secrets,
    ),
  );
}

/// Scrolls the screen's list until [finder] is built and visible.
Future<void> reveal(WidgetTester tester, Finder finder) => tester
    .scrollUntilVisible(finder, 300, scrollable: find.byType(Scrollable).first);

/// Brings [finder] into view and taps it.
Future<void> tapShown(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
