// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/status/presentation/status_screen.dart';

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
      const StatusScreen(),
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
    testWidgets('$width: loading, then every part of the report', (
      tester,
    ) async {
      server.gate = Completer<void>();
      await pump(tester, size: size, settle: false);
      await tester.pump();
      expect(find.byType(SkeletonBox), findsWidgets);
      server.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('v0.50.0'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('status.server.srv-1')),
          matching: find.textContaining('up 3 h 25 min'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('status.server.srv-2')),
          matching: find.textContaining('Quiet since'),
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('status.totp')),
        300,
      );
      expect(find.text('1 of 2'), findsOneWidget);
    });

    testWidgets('$width: a refusal is shown and can be retried', (
      tester,
    ) async {
      server.failures['GET /api/v1/status'] = FakeResponse(
        403,
        envelope('forbidden', 'needs tenant:admin'),
      );
      await pump(tester, size: size);
      expect(find.byType(ErrorState), findsOneWidget);
      server.failures.clear();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('v0.50.0'), findsOneWidget);
    });
  }

  testWidgets('no registered process says why rather than nothing', (
    tester,
  ) async {
    parity.status = {...parity.status, 'servers': <Object>[]};
    await pump(tester);
    expect(find.textContaining('No process has registered'), findsOneWidget);
  });
}
