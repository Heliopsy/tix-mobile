// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';

import '../../../helpers/people_app.dart';

void main() {
  // The saved connection learns its tenant from a background whoami, which
  // rebuilds the session once; the access check settles after that.
  Future<void> pump(WidgetTester tester, PeopleRig rig) async {
    await rig.pump(tester, const SettingsScreen(), size: const Size(400, 2400));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets('an admin reaches account, feed and own tokens', (tester) async {
    final rig = PeopleRig();
    await pump(tester, rig);
    for (final k in [
      'settings.profile.account',
      'settings.calendar.open',
      'settings.security.tokens',
    ]) {
      expect(find.byKey(Key(k)), findsOneWidget, reason: k);
    }
    await tapIn(tester, find.byKey(const Key('settings.security.tokens')));
    expect(find.text('route:/settings/tokens'), findsOneWidget);
  });

  testWidgets('a viewer sees only what a viewer may do', (tester) async {
    final rig = PeopleRig();
    rig.people.me = {...rig.people.me, 'role': 'viewer'};
    await pump(tester, rig);
    expect(find.byKey(const Key('settings.profile.account')), findsOneWidget);
    expect(find.byKey(const Key('settings.calendar.open')), findsOneWidget);
    expect(find.byKey(const Key('settings.security.tokens')), findsNothing);
  });
}
