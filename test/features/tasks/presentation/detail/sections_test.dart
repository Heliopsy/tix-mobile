// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Finder box(int item) => find.descendant(
    of: find.byKey(ValueKey('checklist.$item')),
    matching: find.byType(Checkbox),
  );

  group('checklist', () {
    setUp(
      () => server.tasks['infra']![0]['body'] =
          '- [ ] one\n- [ ] two\n  - [x] nested\n\n```\n- [ ] code\n```\n\n'
          '- [ ] three',
    );

    testWidgets('a tick shows at once and sends its number and version', (
      tester,
    ) async {
      await pumpTask(tester, server);
      expect(tester.widget<Checkbox>(box(3)).value, isTrue);
      await tester.tap(box(2));
      await tester.pump();
      expect(tester.widget<Checkbox>(box(2)).value, isTrue);
      await tester.pumpAndSettle();
      expect(bodies(server, 'POST', '/tasks/infra-1/checklist'), [
        {'item': 2, 'done': true, 'version': 1},
      ]);
      expect(tester.widget<Checkbox>(box(2)).value, isTrue);
    });

    testWidgets('an item after fenced code keeps tix numbering', (
      tester,
    ) async {
      await pumpTask(tester, server);
      expect(box(5), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('checklist.4')),
          matching: find.byType(Checkbox),
        ),
        findsOneWidget,
      );
      await tester.tap(box(4));
      await tester.pumpAndSettle();
      expect(bodies(server, 'POST', '/tasks/infra-1/checklist').single, {
        'item': 4,
        'done': true,
        'version': 1,
      });
    });

    testWidgets('two quick ticks are sent in turn, each on the new version', (
      tester,
    ) async {
      await pumpTask(tester, server);
      await tester.tap(box(1));
      await tester.tap(box(2));
      await tester.pumpAndSettle();
      expect(bodies(server, 'POST', '/tasks/infra-1/checklist'), [
        {'item': 1, 'done': true, 'version': 1},
        {'item': 2, 'done': true, 'version': 2},
      ]);
      expect(tester.widget<Checkbox>(box(1)).value, isTrue);
      expect(tester.widget<Checkbox>(box(2)).value, isTrue);
    });

    testWidgets('clearing a ticked item sends done false', (tester) async {
      await pumpTask(tester, server);
      await tester.tap(box(3));
      await tester.pumpAndSettle();
      expect(bodies(server, 'POST', '/tasks/infra-1/checklist').single, {
        'item': 3,
        'done': false,
        'version': 1,
      });
    });
  });

  group('description', () {
    testWidgets('is edited as Markdown with a preview', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('description.edit')));
      await tester.enterText(
        find.byKey(const Key('description.field')),
        '**Bold** plan',
      );
      await press(tester, find.text('Preview'));
      expect(find.byKey(const Key('description.field')), findsNothing);
      expect(
        find.textContaining('Bold plan', findRichText: true),
        findsWidgets,
      );
      await press(tester, find.byKey(const Key('description.save')));
      expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
        {'body': '**Bold** plan', 'version': 1},
      ]);
    });

    testWidgets('an empty one opens the editor when pressed', (tester) async {
      await pumpTask(tester, server, ref: 'infra-2');
      await press(tester, find.text('No description.'));
      expect(find.byKey(const Key('description.field')), findsOneWidget);
      await press(tester, find.text('Cancel').last);
      expect(count(server, 'PATCH', '/tasks/infra-2'), 0);
    });

    testWidgets('a description changed elsewhere is refused, not clobbered', (
      tester,
    ) async {
      await pumpTask(tester, server);
      server.tasks['infra']![0]['version'] = 5;
      await press(tester, find.byKey(const Key('description.edit')));
      await tester.enterText(
        find.byKey(const Key('description.field')),
        'mine',
      );
      await press(tester, find.byKey(const Key('description.save')));
      expect(bodies(server, 'PATCH', '/tasks/infra-1').single['version'], 1);
      expect(server.tasks['infra']![0]['body'], isNot('mine'));
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('subtasks', () {
    testWidgets('are listed and open their task', (tester) async {
      server.tasks['infra']!.add(
        taskJson('infra-3', title: 'Child step', parentId: 'id-infra-1'),
      );
      await pumpTask(tester, server);
      expect(find.text('1 task'), findsOneWidget);
      await press(tester, find.byKey(const Key('related.infra-3')));
      expect(find.text('route:/projects/infra/tasks/infra-3'), findsOneWidget);
    });

    testWidgets('an empty list says so', (tester) async {
      await pumpTask(tester, server);
      expect(find.text('No subtasks.'), findsOneWidget);
    });

    testWidgets('Add subtask creates one under this task', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('subtask.add')));
      await tester.enterText(find.byKey(const Key('text.field')), 'Write test');
      await press(tester, find.byKey(const Key('text.save')));
      final sent = bodies(server, 'POST', '/api/v1/tasks').single;
      expect(sent['parent_ref'], 'infra-1');
      expect(sent['project_ref'], 'infra');
      expect(sent['title'], 'Write test');
      expect(find.text('No subtasks.'), findsNothing);
    });
  });

  group('dependencies', () {
    testWidgets('are listed with title and removed', (tester) async {
      server.deps['id-infra-1'] = ['id-infra-2'];
      await pumpTask(tester, server);
      expect(
        find.descendant(
          of: find.byKey(const Key('related.infra-2')),
          matching: find.text('Rotate keys'),
        ),
        findsOneWidget,
      );
      await press(tester, find.byKey(const Key('related.remove.infra-2')));
      expect(count(server, 'DELETE', '/tasks/infra-1/deps/id-infra-2'), 1);
      expect(find.byKey(const Key('related.infra-2')), findsNothing);
      expect(find.text('Waiting on nothing.'), findsOneWidget);
    });

    testWidgets('are added by reference', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('dependency.add')));
      await tester.enterText(find.byKey(const Key('text.field')), 'infra-2');
      await press(tester, find.byKey(const Key('text.save')));
      expect(bodies(server, 'POST', '/tasks/infra-1/deps'), [
        {'depends_on': 'infra-2'},
      ]);
      expect(find.byKey(const Key('related.infra-2')), findsOneWidget);
    });

    testWidgets('an unknown reference is refused with the reason', (
      tester,
    ) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('dependency.add')));
      await tester.enterText(find.byKey(const Key('text.field')), 'nope-9');
      await press(tester, find.byKey(const Key('text.save')));
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('no task nope-9'),
        ),
        findsOneWidget,
      );
      expect(find.text('Waiting on nothing.'), findsOneWidget);
    });
  });

  testWidgets('a related task drawn as a row is a TaskRow', (tester) async {
    server.deps['id-infra-1'] = ['id-infra-2'];
    await pumpTask(tester, server);
    expect(
      find.descendant(
        of: find.byKey(const Key('related.infra-2')),
        matching: find.byType(TaskCheck),
      ),
      findsOneWidget,
    );
  });
}
