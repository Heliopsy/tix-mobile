// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Map<String, Object?> task() => server.tasks['infra']!.first;

  void changeElsewhere({String? title, String? body}) {
    task()
      ..['version'] = ((task()['version'] as int?) ?? 1) + 1
      ..addAll({'title': ?title, 'body': ?body});
  }

  group('title', () {
    testWidgets('a change elsewhere keeps the edit and offers Reload', (
      tester,
    ) async {
      final c = await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.title')));
      await tester.enterText(find.byKey(const Key('title.field')), 'Mine');
      changeElsewhere(title: 'Theirs');
      c.invalidate(taskDetailControllerProvider('infra-1'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('title.changed')), findsOneWidget);
      final field = tester.widget<TextField>(
        find.byKey(const Key('title.field')),
      );
      expect(field.controller!.text, 'Mine');
      await press(tester, find.byKey(const Key('live.reload')));
      expect(find.byKey(const Key('title.field')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('task.title')),
          matching: find.text('Theirs'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('keep editing hides the banner and saves the edit', (
      tester,
    ) async {
      final c = await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.title')));
      await tester.enterText(find.byKey(const Key('title.field')), 'Mine');
      changeElsewhere(title: 'Theirs');
      c.invalidate(taskDetailControllerProvider('infra-1'));
      await tester.pumpAndSettle();
      await press(tester, find.byKey(const Key('live.keep')));
      expect(find.byKey(const Key('title.changed')), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(bodies(server, 'PATCH', '/tasks/infra-1').single['title'], 'Mine');
    });

    testWidgets('a change to something else shows no banner', (tester) async {
      final c = await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.title')));
      changeElsewhere();
      c.invalidate(taskDetailControllerProvider('infra-1'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('title.changed')), findsNothing);
    });
  });

  group('description', () {
    testWidgets('a change elsewhere keeps the text; Reload takes theirs', (
      tester,
    ) async {
      final c = await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('description.edit')));
      await tester.enterText(
        find.byKey(const Key('description.field')),
        'my notes',
      );
      changeElsewhere(body: 'their notes');
      c.invalidate(taskDetailControllerProvider('infra-1'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('description.changed')), findsOneWidget);
      expect(find.text('my notes'), findsOneWidget);
      await press(tester, find.byKey(const Key('live.reload')));
      expect(find.byKey(const Key('description.changed')), findsNothing);
      expect(find.text('their notes'), findsWidgets);
    });

    testWidgets('keep editing saves over the version it was shown', (
      tester,
    ) async {
      final c = await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('description.edit')));
      await tester.enterText(
        find.byKey(const Key('description.field')),
        'my notes',
      );
      changeElsewhere(body: 'their notes');
      c.invalidate(taskDetailControllerProvider('infra-1'));
      await tester.pumpAndSettle();
      await press(tester, find.byKey(const Key('live.keep')));
      final shown = task()['version'];
      await press(tester, find.byKey(const Key('description.save')));
      final sent = bodies(server, 'PATCH', '/tasks/infra-1').single;
      expect(sent['body'], 'my notes');
      expect(sent['version'], shown);
    });
  });
}
