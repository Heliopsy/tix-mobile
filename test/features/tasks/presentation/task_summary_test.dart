// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix(
      tasks: {
        'infra': [
          taskJson('infra-1', title: 'Fix login'),
          taskJson('infra-2', title: 'Rotate keys', status: 'doing'),
          taskJson('infra-3', title: 'Old work', status: 'done'),
        ],
        'web': [taskJson('web-1', title: 'Landing page')],
      },
    );
  });

  Future<ProviderContainer> pump(WidgetTester tester, Size size) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const TasksScreen(),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  Finder summary(String text) => find.descendant(
    of: find.byKey(const Key('tasks.summary')),
    matching: find.text(text, findRichText: true),
  );

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('sums up the open list as the web does', (tester) async {
        server.tasks['infra']![0]['blocked'] = true;
        server.tasks['web']![0]['blocked'] = true;
        await pump(tester, size);
        expect(summary('3 to go · across 2 projects'), findsOneWidget);
        expect(find.byKey(const Key('tasks.summary.waiting')), findsOneWidget);
        expect(find.text('2 waiting on other tasks'), findsOneWidget);
        expect(find.text('show finished too'), findsOneWidget);
      });

      testWidgets('the waiting count narrows the list to those tasks', (
        tester,
      ) async {
        server.tasks['infra']![0]['blocked'] = true;
        final c = await pump(tester, size);
        await tester.tap(find.byKey(const Key('tasks.summary.waiting')));
        await tester.pumpAndSettle();
        expect(
          c.read(taskScreenProvider(const AllScope())).expression,
          'is:waiting-on',
        );
      });

      testWidgets('show finished too brings the done tasks back', (
        tester,
      ) async {
        await pump(tester, size);
        expect(find.text('Old work'), findsNothing);
        await tester.tap(find.byKey(const Key('tasks.summary.showFinished')));
        await tester.pumpAndSettle();
        expect(find.text('Old work'), findsOneWidget);
        expect(summary('3 to go, 1 done · across 2 projects'), findsOneWidget);
        expect(
          find.byKey(const Key('tasks.summary.showFinished')),
          findsNothing,
        );
      });

      testWidgets('an empty open list says nothing is open', (tester) async {
        server.tasks
          ..['infra'] = [taskJson('infra-3', title: 'Old', status: 'done')]
          ..['web'] = [];
        await pump(tester, size);
        expect(summary('Nothing open.'), findsOneWidget);
        expect(find.byKey(const Key('tasks.summary.waiting')), findsNothing);
      });
    });
  }
}
