// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/settings/presentation/time_settings_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeParity parity;

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const TimeSettingsScreen(),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: loading, then what is in force and from where', (
      tester,
    ) async {
      server.gate = Completer<void>();
      await pump(tester, size: size, settle: false);
      await tester.pump();
      expect(find.byType(SkeletonBox), findsWidgets);
      server.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Now Short, from the tenant'), findsOneWidget);
      expect(find.text('Now UTC, from the server'), findsOneWidget);
      expect(find.text("Tenant's (Short)"), findsOneWidget);
      expect(find.byKey(const Key('time.zoneReset')), findsNothing);
    });

    testWidgets('$width: an error can be retried', (tester) async {
      server.failures['GET /api/v1/me/time'] = FakeResponse(
        500,
        envelope('internal', 'boom'),
      );
      await pump(tester, size: size);
      expect(find.byType(ErrorState), findsOneWidget);
      server.failures.clear();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('time.format')), findsOneWidget);
    });
  }

  testWidgets('picking a format saves it as the person own', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Long'));
    await tester.pumpAndSettle();
    expect(server.requests.last.body, {'time_format': 'long'});
    expect(find.text('Now Long, from you'), findsOneWidget);
    expect(find.text('Saved.'), findsOneWidget);
  });

  testWidgets('a zone is saved, a bad one refused, and reset', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('time.zone')), 'Mars');
    await tester.tap(find.byKey(const Key('time.zoneSave')));
    await tester.pumpAndSettle();
    expect(find.textContaining('unknown time zone'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('time.zone')), 'Europe/Sofia');
    await tester.tap(find.byKey(const Key('time.zoneSave')));
    await tester.pumpAndSettle();
    expect(find.text('Now Europe/Sofia, from you'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byType(TimeSettingsScreen)))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('time.zoneReset')));
    await tester.tap(find.byKey(const Key('time.zoneReset')));
    await tester.pumpAndSettle();
    expect(server.requests.last.body, {'timezone': ''});
  });

  testWidgets('an automated credential cannot keep its own', (tester) async {
    parity.time = {...parity.time, 'personal': false};
    await pump(tester);
    expect(find.byKey(const Key('time.automated')), findsOneWidget);
    expect(
      tester
          .widget<TixButton>(find.byKey(const Key('time.zoneSave')))
          .onPressed,
      isNull,
    );
  });
}
