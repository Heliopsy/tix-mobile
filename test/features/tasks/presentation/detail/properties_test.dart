// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../../helpers/app.dart';
import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Finder inRow(String row, Finder matching) =>
      find.descendant(of: find.byKey(Key(row)), matching: matching);

  group('title', () {
    testWidgets('renames in place, sending only the title', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.title')));
      await tester.enterText(find.byKey(const Key('title.field')), 'Fix SSO');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
        {'title': 'Fix SSO'},
      ]);
      expect(find.byKey(const Key('title.field')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('task.title')),
          matching: find.text('Fix SSO'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('cancelling sends nothing', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.title')));
      await tester.enterText(find.byKey(const Key('title.field')), 'Nope');
      await press(tester, find.byKey(const Key('title.cancel')));
      expect(count(server, 'PATCH', '/tasks/infra-1'), 0);
      expect(find.text('Fix login'), findsOneWidget);
    });
  });

  testWidgets('a priority change shows at once and Undo puts it back', (
    tester,
  ) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('prop.priority')));
    await press(tester, find.byKey(const Key('priority.2')));
    expect(inRow('prop.priority', find.text('high')), findsOneWidget);
    expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
      {'priority': 2},
    ]);
    await tester.tap(find.byKey(const Key('toast.action')));
    await tester.pumpAndSettle();
    expect(bodies(server, 'PATCH', '/tasks/infra-1').last, {'priority': 1});
    expect(inRow('prop.priority', find.text('highest')), findsOneWidget);
  });

  group('star', () {
    testWidgets('stars the task', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.star')));
      expect(count(server, 'PUT', '/tasks/infra-1/star'), 1);
      expect(
        tester
            .widget<TixIconButton>(find.byKey(const Key('task.star')))
            .selected,
        isTrue,
      );
      expect(toast('Starred.'), findsOneWidget);
    });

    testWidgets('a refused star rolls back with the reason', (tester) async {
      server.failures['PUT /api/v1/tasks/infra-1/star'] = FakeResponse(
        500,
        envelope('internal', 'boom'),
      );
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.star')));
      expect(count(server, 'PUT', '/tasks/infra-1/star'), 1);
      expect(
        tester
            .widget<TixIconButton>(find.byKey(const Key('task.star')))
            .selected,
        isFalse,
      );
      final bar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(bar.backgroundColor, isNot(Colors.transparent));
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('server'),
        ),
        findsOneWidget,
      );
      expect(toast('Starred.'), findsNothing);
    });
  });

  group('move', () {
    testWidgets('lists every reachable state, naming the states between', (
      tester,
    ) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('prop.status')));
      expect(
        find.descendant(
          of: find.byKey(const Key('move.done')),
          matching: find.text('via Doing'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('move.doing')),
          matching: find.textContaining('via'),
        ),
        findsNothing,
      );
      await press(tester, find.byKey(const Key('move.done')));
      expect(bodies(server, 'POST', '/tasks/infra-1/route'), [
        {'to': 'done'},
      ]);
      expect(toast('Moved infra-1 to done.'), findsOneWidget);
      expect(inRow('prop.status', find.text('done')), findsOneWidget);
    });

    testWidgets('a move that needs a comment asks for one', (tester) async {
      server.tasks['infra']![0]['status'] = 'doing';
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('prop.status')));
      await press(tester, find.byKey(const Key('move.blocked')));
      expect(count(server, 'POST', '/tasks/infra-1/route'), 0);
      await press(tester, find.byKey(const Key('move.confirm')));
      expect(count(server, 'POST', '/tasks/infra-1/route'), 0);
      await tester.enterText(
        find.byKey(const Key('move.comment')),
        'Waiting on DNS',
      );
      await press(tester, find.byKey(const Key('move.confirm')));
      expect(bodies(server, 'POST', '/tasks/infra-1/route'), [
        {'to': 'blocked', 'comment': 'Waiting on DNS'},
      ]);
    });

    testWidgets('a route that stops partway says where and why', (
      tester,
    ) async {
      server.routeStops['infra-1'] = (state: 'doing', reason: 'needs review');
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('prop.status')));
      await press(tester, find.byKey(const Key('move.done')));
      expect(toast('Stopped before doing: needs review'), findsOneWidget);
      expect(inRow('prop.status', find.text('to do')), findsOneWidget);
    });
  });

  testWidgets('the assignee comes from the directory, searched', (
    tester,
  ) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('prop.assignee')));
    expect(find.byKey(const Key('actor.a1')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('actor.search')), 'ana');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('actor.a1')), findsNothing);
    await press(tester, find.byKey(const Key('actor.me')));
    expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
      {'assignee_actor_id': 'me'},
    ]);
  });

  testWidgets('unassigning sends an empty assignee', (tester) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('prop.assignee')));
    await press(tester, find.byKey(const Key('actor.none')));
    expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
      {'assignee_actor_id': ''},
    ]);
    expect(inRow('prop.assignee', find.text('Unassigned')), findsOneWidget);
  });

  group('due', () {
    testWidgets('Tomorrow sets the next local midnight', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('prop.due')));
      await press(tester, find.byKey(const Key('due.tomorrow')));
      final local = fixedNow.toLocal();
      final tomorrow = DateTime(local.year, local.month, local.day + 1);
      expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
        {'due_at': tomorrow.toUtc().toIso8601String()},
      ]);
    });

    testWidgets('clearing sends a null due date', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('prop.due')));
      await press(tester, find.byKey(const Key('due.clear')));
      final sent = bodies(server, 'PATCH', '/tasks/infra-1').single;
      expect(sent.containsKey('due_at'), isTrue);
      expect(sent['due_at'], isNull);
      expect(inRow('prop.due', find.text('No due date')), findsOneWidget);
    });

    testWidgets('a task without one offers no clear', (tester) async {
      await pumpTask(tester, server, ref: 'infra-2');
      await press(tester, find.byKey(const Key('prop.due')));
      expect(find.byKey(const Key('due.clear')), findsNothing);
    });
  });

  group('tags', () {
    testWidgets('adds one the tenant offers', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('tag.open')));
      expect(find.byKey(const Key('tag.offer.auth')), findsNothing);
      await press(tester, find.byKey(const Key('tag.offer.ops')));
      expect(bodies(server, 'POST', '/tasks/infra-1/tags'), [
        {'name': 'ops'},
      ]);
      expect(inRow('prop.tags', find.text('#ops')), findsOneWidget);
    });

    testWidgets('adds a new one typed', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('tag.open')));
      await tester.enterText(find.byKey(const Key('tag.field')), '#urgent');
      await press(tester, find.byKey(const Key('tag.add')));
      expect(bodies(server, 'POST', '/tasks/infra-1/tags'), [
        {'name': 'urgent'},
      ]);
    });

    testWidgets('removes one with its cross', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('tag.remove.auth')));
      expect(count(server, 'DELETE', '/tasks/infra-1/tags/auth'), 1);
      expect(inRow('prop.tags', find.text('#auth')), findsNothing);
    });
  });

  group('custom fields', () {
    testWidgets('an enum offers its options', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('field.env')));
      expect(find.byKey(const Key('field.option.production')), findsOneWidget);
      await press(tester, find.byKey(const Key('field.option.staging')));
      expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
        {
          'custom_fields': {'env': 'staging'},
        },
      ]);
      expect(inRow('field.env', find.text('staging')), findsOneWidget);
    });

    testWidgets('a bool is a switch', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('field.paged.switch')));
      expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
        {
          'custom_fields': {'paged': true},
        },
      ]);
      expect(
        tester
            .widget<Switch>(find.byKey(const Key('field.paged.switch')))
            .value,
        isTrue,
      );
    });

    testWidgets('a string is typed', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('field.window')));
      await tester.enterText(find.byKey(const Key('text.field')), 'Sat 02:00');
      await press(tester, find.byKey(const Key('text.save')));
      expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
        {
          'custom_fields': {'window': 'Sat 02:00'},
        },
      ]);
    });
  });

  testWidgets('a refused repeat rule says why and keeps the old one', (
    tester,
  ) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('prop.repeat')));
    await tester.enterText(
      find.byKey(const Key('text.field')),
      'every blue moon',
    );
    await press(tester, find.byKey(const Key('text.save')));
    expect(bodies(server, 'PATCH', '/tasks/infra-1'), [
      {'recurrence': 'every blue moon'},
    ]);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.textContaining('cannot read rule'),
      ),
      findsOneWidget,
    );
    expect(inRow('prop.repeat', find.text('Does not repeat')), findsOneWidget);
    expect(inRow('prop.repeat', find.text('every blue moon')), findsNothing);
  });

  testWidgets('a subtask links its parent', (tester) async {
    server.tasks['infra']!.add(
      taskJson('infra-3', title: 'Child', parentId: 'id-infra-1'),
    );
    await pumpTask(tester, server, ref: 'infra-3');
    expect(inRow('prop.parent', find.text('Fix login')), findsOneWidget);
    await press(tester, inRow('prop.parent', find.text('Fix login')));
    expect(find.text('route:/projects/infra/tasks/infra-1'), findsOneWidget);
  });
}
