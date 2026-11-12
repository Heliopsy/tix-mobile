// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(
    () => server = FakeTix(
      tasks: {
        'infra': [
          for (var i = 1; i <= 30; i++)
            taskJson('infra-$i', title: 'Task number $i'),
        ],
      },
    ),
  );

  Future<ProviderContainer> pump(WidgetTester tester) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const TaskListScreen(projectKey: 'infra'),
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  /// Two tasks arrive at the top, and the listing refreshes as a live
  /// event refreshes it.
  Future<void> arrive(ProviderContainer c, WidgetTester tester) async {
    server.tasks['infra']!.insertAll(0, [
      taskJson('infra-31', title: 'Arrived first'),
      taskJson('infra-32', title: 'Arrived second'),
    ]);
    c.invalidate(taskListingProvider);
    await tester.pumpAndSettle();
  }

  final pill = find.byKey(const Key('list.newAbove'));

  testWidgets('rows arriving above the reader wait behind a pill', (
    tester,
  ) async {
    final c = await pump(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    final reading = find.text('Task number 12');
    expect(reading, findsOneWidget);
    final at = tester.getTopLeft(reading).dy;

    await arrive(c, tester);

    expect(tester.getTopLeft(reading).dy, at);
    expect(find.text('2 new, show'), findsOneWidget);

    await tester.tap(pill);
    await tester.pumpAndSettle();
    expect(pill, findsNothing);
    expect(find.text('Arrived first'), findsOneWidget);
    expect(find.text('Arrived second'), findsOneWidget);
  });

  testWidgets('at the top new rows are drawn at once', (tester) async {
    final c = await pump(tester);
    await arrive(c, tester);
    expect(pill, findsNothing);
    expect(find.text('Arrived first'), findsOneWidget);
  });

  testWidgets('scrolling back to the top shows the waiting rows', (
    tester,
  ) async {
    final c = await pump(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await arrive(c, tester);
    expect(pill, findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(pill, findsNothing);
    expect(find.text('Arrived first'), findsOneWidget);
  });
}
