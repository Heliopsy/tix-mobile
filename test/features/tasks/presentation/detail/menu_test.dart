// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

import '../../../../helpers/app.dart';
import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<void> menu(WidgetTester tester, String item) async {
    await press(tester, find.byKey(const Key('task.menu')));
    await press(tester, find.byKey(Key('menu.$item')));
  }

  Iterable<Uri> deletes() => [
    for (final r in server.requestsTo('/tasks/infra-1'))
      if (r.method == 'DELETE') r.uri,
  ];

  group('copy', () {
    testWidgets('into another project with its subtasks, then open it', (
      tester,
    ) async {
      await pumpTask(tester, server);
      await menu(tester, 'copy');
      await press(tester, find.byKey(const Key('copy.project')));
      await press(tester, find.text('Web (web)').last);
      await press(tester, find.byKey(const Key('copy.subtasks')));
      await press(tester, find.byKey(const Key('copy.confirm')));
      expect(bodies(server, 'POST', '/tasks/infra-1/copy'), [
        {
          'project_ref': 'web',
          'with_subtasks': true,
          'with_comments': false,
          'with_dependencies': false,
          'keep_status': false,
          'link': true,
        },
      ]);
      expect(toast('Copied as web-1.'), findsOneWidget);
      await press(tester, find.byKey(const Key('toast.action')));
      expect(find.text('route:/projects/web/tasks/web-1'), findsOneWidget);
    });

    testWidgets('with a new title sends it', (tester) async {
      await pumpTask(tester, server);
      await menu(tester, 'copy');
      await tester.enterText(find.byKey(const Key('copy.title')), 'Again');
      await press(tester, find.byKey(const Key('copy.confirm')));
      final sent = bodies(server, 'POST', '/tasks/infra-1/copy').single;
      expect(sent['title'], 'Again');
      expect(sent['project_ref'], 'infra');
    });

    testWidgets('cancelled sends nothing', (tester) async {
      await pumpTask(tester, server);
      await menu(tester, 'copy');
      await press(tester, find.byKey(const Key('sheet.cancel')));
      expect(count(server, 'POST', '/tasks/infra-1/copy'), 0);
    });
  });

  group('delete', () {
    testWidgets('with a trash goes at once and Undo restores it', (
      tester,
    ) async {
      await pumpTask(tester, server);
      await menu(tester, 'delete');
      expect(find.byKey(const Key('confirm.ok')), findsNothing);
      expect(deletes().single.query, isEmpty);
      expect(find.text('route:/projects/infra'), findsOneWidget);
      expect(toast('Deleted infra-1.'), findsOneWidget);
      await press(tester, find.byKey(const Key('toast.action')));
      expect(count(server, 'POST', '/tasks/infra-1/restore'), 1);
      expect(server.task('infra-1'), isNotNull);
      expect(find.text('route:/projects/infra/tasks/infra-1'), findsOneWidget);
    });

    testWidgets('without a trash confirms first and offers no Undo', (
      tester,
    ) async {
      server.trashEnabled = false;
      await pumpTask(tester, server);
      await menu(tester, 'delete');
      expect(deletes(), isEmpty);
      expect(find.text('Delete infra-1?'), findsOneWidget);
      await press(tester, find.byKey(const Key('confirm.ok')));
      expect(deletes(), hasLength(1));
      expect(toast('Deleted infra-1.'), findsOneWidget);
      expect(find.byKey(const Key('toast.action')), findsNothing);
    });

    testWidgets('a cancelled confirmation deletes nothing', (tester) async {
      server.trashEnabled = false;
      await pumpTask(tester, server);
      await menu(tester, 'delete');
      await press(tester, find.text('Cancel').last);
      expect(deletes(), isEmpty);
      expect(find.text('Fix login'), findsOneWidget);
    });

    testWidgets('permanently confirms and sends hard', (tester) async {
      await pumpTask(tester, server);
      await menu(tester, 'purge');
      expect(deletes(), isEmpty);
      await press(tester, find.byKey(const Key('confirm.ok')));
      expect(deletes().single.queryParameters, {'hard': 'true'});
      expect(server.trash, isEmpty);
    });

    testWidgets('a task with subtasks confirms and takes them along', (
      tester,
    ) async {
      server.tasks['infra']!.add(
        taskJson('infra-3', title: 'Child', parentId: 'id-infra-1'),
      );
      await pumpTask(tester, server);
      await menu(tester, 'delete');
      expect(
        find.textContaining('Its subtask is deleted with it.'),
        findsOneWidget,
      );
      await press(tester, find.byKey(const Key('confirm.ok')));
      expect(deletes().single.queryParameters, {'cascade': 'true'});
    });
  });

  group('snooze', () {
    testWidgets('until tomorrow morning, then wake', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.snooze')));
      await press(tester, find.byKey(const Key('snooze.tomorrow')));
      expect(bodies(server, 'PUT', '/tasks/infra-1/snooze'), [
        {
          'until': SnoozePreset.tomorrow
              .from(fixedNow)
              .toUtc()
              .toIso8601String(),
        },
      ]);
      expect(
        tester
            .widget<Tooltip>(
              find.ancestor(
                of: find.byIcon(Icons.alarm_off),
                matching: find.byType(Tooltip),
              ),
            )
            .message,
        'Wake now',
      );
      await press(tester, find.byKey(const Key('task.snooze')));
      expect(count(server, 'DELETE', '/tasks/infra-1/snooze'), 1);
      expect(find.byIcon(Icons.alarm_off), findsNothing);
    });

    testWidgets('from the menu too', (tester) async {
      await pumpTask(tester, server);
      await menu(tester, 'snooze');
      await press(tester, find.byKey(const Key('snooze.nextWeek')));
      expect(count(server, 'PUT', '/tasks/infra-1/snooze'), 1);
    });
  });

  testWidgets('Copy reference puts it on the clipboard', (tester) async {
    final copied = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') copied.add(call.arguments);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpTask(tester, server);
    await menu(tester, 'ref');
    expect(copied, [
      {'text': 'infra-1'},
    ]);
    expect(toast('Reference copied.'), findsOneWidget);
  });

  testWidgets('Rename from the menu opens the title field', (tester) async {
    await pumpTask(tester, server);
    await menu(tester, 'rename');
    expect(find.byKey(const Key('title.field')), findsOneWidget);
  });

  testWidgets('Move from the menu opens the move sheet', (tester) async {
    await pumpTask(tester, server, size: tallDesktop);
    await menu(tester, 'move');
    expect(find.byKey(const Key('move.doing')), findsOneWidget);
  });
}
