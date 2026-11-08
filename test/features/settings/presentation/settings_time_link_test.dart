// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  testWidgets('Date and time is offered with a session and opens', (
    tester,
  ) async {
    final stores = signedInStores();
    await pumpScreen(
      tester,
      const SettingsScreen(),
      overrides: fakeOverrides(
        FakeTix(),
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    await tester.ensureVisible(find.byKey(const Key('settings.time')));
    await tester.tap(find.byKey(const Key('settings.time')));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/time'), findsOneWidget);
  });

  testWidgets('without a session there is nothing to set', (tester) async {
    await pumpScreen(
      tester,
      const SettingsScreen(),
      overrides: fakeOverrides(FakeTix()),
    );
    expect(find.byKey(const Key('settings.time')), findsNothing);
  });
}
