// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

Map<String, Object?> _workflow(
  List<Map<String, Object?>> states,
  List<Map<String, Object?>> moves,
) => {
  'id': 'wf1',
  'key': 'default',
  'name': 'Default',
  'definition': {'initial': 'todo', 'states': states, 'transitions': moves},
};

const _todo = {'key': 'todo', 'label': 'To do', 'category': 'todo'};
const _review = {'key': 'review', 'label': 'Review', 'category': 'in_progress'};
const Map<String, Object> _done = {
  'key': 'done',
  'label': 'Done',
  'category': 'done',
  'terminal': true,
};
const Map<String, Object> _shipped = {
  'key': 'shipped',
  'label': 'Shipped',
  'category': 'done',
  'terminal': true,
};

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix(
      tasks: {
        'infra': [taskJson('infra-1', title: 'Fix login')],
      },
    );
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group('at $width width', () {
      Future<void> pump(WidgetTester tester) async {
        final stores = signedInStores();
        await pumpScreen(
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

      Finder tick() => find.byType(TaskCheck);

      testWidgets('two ways to done ask which, and send the route picked', (
        tester,
      ) async {
        server.workflow = _workflow(
          [_todo, _review, _done, _shipped],
          [
            {'from': 'todo', 'to': 'done'},
            {'from': 'todo', 'to': 'review'},
            {'from': 'review', 'to': 'shipped'},
          ],
        );
        await pump(tester);
        expect(tester.widget<TaskCheck>(tick()).locked, isFalse);
        await tester.tap(tick());
        await tester.pumpAndSettle();
        expect(find.text('Complete infra-1'), findsOneWidget);
        expect(find.byKey(const Key('tick.done')), findsOneWidget);
        expect(
          find.text('Shipped · todo → Review → Shipped · 2 steps'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('tick.review>shipped')));
        await tester.pumpAndSettle();
        expect(server.requestsTo('/tasks/infra-1/route').single.body, {
          'route': ['review', 'shipped'],
        });
        expect(server.requestsTo('/tasks/bulk'), isEmpty);
      });

      testWidgets('one way to done ticks at once', (tester) async {
        server.workflow = _workflow(
          [_todo, _done],
          [
            {'from': 'todo', 'to': 'done'},
          ],
        );
        await pump(tester);
        await tester.tap(tick());
        await tester.pumpAndSettle();
        expect(find.text('Complete infra-1'), findsNothing);
        expect(server.requestsTo('/tasks/bulk').single.body['to'], 'done');
      });

      testWidgets('no usable way is a dashed tick that says why', (
        tester,
      ) async {
        server.workflow = _workflow(
          [_todo, _done],
          [
            {'from': 'todo', 'to': 'done', 'requires_comment': true},
          ],
        );
        await pump(tester);
        expect(tester.widget<TaskCheck>(tick()).locked, isTrue);
        expect(
          find.descendant(
            of: tick(),
            matching: find.byKey(const Key('check.dashed')),
          ),
          findsOneWidget,
        );
        await tester.tap(tick());
        await tester.pumpAndSettle();
        expect(
          find.text('Not from here: finishing it needs a comment.'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('tick.close')));
        await tester.pumpAndSettle();
        expect(server.requestsTo('/tasks/bulk'), isEmpty);
        expect(server.requestsTo('/tasks/infra-1/route'), isEmpty);
      });
    });
  }
}
