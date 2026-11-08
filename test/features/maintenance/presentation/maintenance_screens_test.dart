// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/maintenance/presentation/housekeeping_screen.dart';
import 'package:tix_mobile/src/features/maintenance/presentation/retention_screen.dart';
import 'package:tix_mobile/src/features/maintenance/presentation/trash_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_integrations.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeIntegrations fake;

  setUp(() {
    server = FakeTix();
    fake = FakeIntegrations(server);
  });

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
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

  test('days are read from Go durations', () {
    expect(daysOf('720h0m0s'), 30);
    expect(daysOf('36h0m0s'), isNull);
    expect(daysOf(''), isNull);
    expect(daysOf(null), isNull);
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      for (final (name, screen) in [
        ('retention', const RetentionScreen()),
        ('housekeeping', const HousekeepingScreen()),
        ('trash', const TrashScreen()),
      ]) {
        testWidgets('$name loads, then shows', (tester) async {
          server
            ..trash['infra-5'] = taskJson('infra-5', title: 'Binned')
            ..gate = Completer<void>();
          await pump(tester, screen, size: size, settle: false);
          expect(find.byType(SkeletonList), findsOneWidget);
          server.gate!.complete();
          await tester.pumpAndSettle();
          expect(find.byType(SkeletonList), findsNothing);
          expect(find.byType(ErrorState), findsNothing);
        });

        testWidgets('$name fails with a retry', (tester) async {
          server.override = FakeResponse(500, envelope('internal', 'x'));
          await pump(tester, screen, size: size);
          expect(
            find.textContaining('The server had a problem.'),
            findsOneWidget,
          );
          server.override = null;
          await tester.tap(find.text('Retry'));
          await tester.pumpAndSettle();
          expect(find.byType(ErrorState), findsNothing);
        });
      }

      testWidgets('trash is empty', (tester) async {
        await pump(tester, const TrashScreen(), size: size);
        expect(find.text('The trash is empty.'), findsOneWidget);
      });
    });
  }

  group('retention', () {
    testWidgets('shows days and saves days as hours', (tester) async {
      await pump(tester, const RetentionScreen());
      final events = find.byKey(const Key('retention.events'));
      expect(
        find.descendant(of: events, matching: find.text('30')),
        findsOneWidget,
      );
      await tester.enterText(events, '10');
      await tester.tap(find.byKey(const Key('retention.save')));
      await tester.pumpAndSettle();
      expect(
        server.requests.lastWhere((r) => r.method == 'PUT').body['events'],
        '240h',
      );
      expect(fake.retention['events'], '240h0m0s');
      expect(find.text('Retention saved.'), findsOneWidget);
    });

    testWidgets('previews, then prunes only after confirming', (tester) async {
      await pump(tester, const RetentionScreen());
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('retention.preview')));
      await tester.pumpAndSettle();
      expect(
        find.text('Would remove 172 events, 3 audit entries and 0 deliveries.'),
        findsOneWidget,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('retention.prune')));
      await tester.pumpAndSettle();
      expect(fake.prunes, [true]);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(fake.prunes, [true]);
      await tester.tap(find.byKey(const Key('retention.prune')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      expect(fake.prunes, [true, false]);
      expect(find.textContaining('Removed 172 events'), findsOneWidget);
      expect(find.textContaining('5 events past'), findsOneWidget);
    });
  });

  group('housekeeping', () {
    testWidgets('saves rules and shows what is due', (tester) async {
      fake.rules['done'] = 30;
      await pump(tester, const HousekeepingScreen());
      expect(find.textContaining('4 tasks due now.'), findsOneWidget);
      final done = find.byKey(const Key('housekeeping.done'));
      expect(
        find.descendant(of: done, matching: find.text('30')),
        findsOneWidget,
      );
      await tester.enterText(done, '14');
      await tester.tap(find.byKey(const Key('housekeeping.save')));
      await tester.pumpAndSettle();
      expect(server.requests.lastWhere((r) => r.method == 'PUT').body, {
        'done': '14',
        'cancelled': 'off',
        'trash': 'off',
      });
      expect(fake.rules['done'], 14);
    });

    testWidgets('a refused rule says why', (tester) async {
      await pump(tester, const HousekeepingScreen());
      await tester.enterText(
        find.byKey(const Key('housekeeping.done')),
        'soon',
      );
      await tester.tap(find.byKey(const Key('housekeeping.save')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('housekeeping.error')), findsOneWidget);
    });

    testWidgets('says when it is paused', (tester) async {
      fake.paused = true;
      await pump(tester, const HousekeepingScreen());
      expect(find.byKey(const Key('housekeeping.paused')), findsOneWidget);
    });

    testWidgets('previews, then runs only after confirming', (tester) async {
      await pump(tester, const HousekeepingScreen(), size: desktop);
      await tester.ensureVisible(find.byKey(const Key('housekeeping.preview')));
      await tester.tap(find.byKey(const Key('housekeeping.preview')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Would move 4 done'), findsOneWidget);
      await tester.tap(find.byKey(const Key('housekeeping.run')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      expect(fake.housekeepingRuns, [true, false]);
      expect(find.textContaining('Moved 4 done'), findsOneWidget);
    });
  });

  testWidgets('trash restores a task', (tester) async {
    server.trash['infra-5'] = taskJson('infra-5', title: 'Binned');
    await pump(tester, const TrashScreen());
    expect(find.text('Binned'), findsOneWidget);
    await tester.tap(find.byKey(const Key('trash.infra-5.restore')));
    await tester.pumpAndSettle();
    expect(server.trash, isEmpty);
    expect(find.text('Binned'), findsNothing);
    expect(find.text('Restored infra-5.'), findsOneWidget);
  });
}
