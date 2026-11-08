// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/templates/presentation/templates_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const TemplatesScreen(),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  Finder row(String name) => find.byKey(Key('templates.row.$name'));

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then data', (tester) async {
        server
          ..addTemplate('weekly', project: 'infra', title: 'Review', uses: 3)
          ..addTemplate(
            'bug',
            title: 'Triage',
            subtasks: [
              {'title': 'Reproduce'},
            ],
          )
          ..gate = Completer<void>();
        await pump(tester, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(SkeletonList), findsNothing);
        expect(
          find.descendant(of: row('weekly'), matching: find.text('Review')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: row('weekly'),
            matching: find.text('Used 3 times'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: row('bug'), matching: find.text('Every project')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: row('bug'),
            matching: find.text('1 subtask · Never used'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('empty offers New template', (tester) async {
        await pump(tester, size: size);
        expect(find.text('No templates yet.'), findsOneWidget);
        expect(find.byKey(const Key('templates.empty.new')), findsOneWidget);
      });

      testWidgets('error offers Retry', (tester) async {
        server.override = FakeResponse(500, envelope('internal', 'boom'));
        await pump(tester, size: size);
        expect(find.byType(ErrorState), findsOneWidget);
        expect(find.byType(SkeletonList), findsNothing);
        server
          ..override = null
          ..addTemplate('weekly');
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(row('weekly'), findsOneWidget);
      });
    });
  }

  testWidgets('Use creates a task in one tap and offers Open', (tester) async {
    server.addTemplate('weekly', project: 'infra', title: 'Review');
    await pump(tester);
    await tester.tap(find.byKey(const Key('templates.use.weekly')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/use'), hasLength(1));
    expect(find.text('Created infra-3'), findsOneWidget);
    expect(
      find.descendant(of: row('weekly'), matching: find.text('Used once')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('toast.action')));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-3'), findsOneWidget);
  });

  testWidgets('delete asks first, in red, then removes it', (tester) async {
    server.addTemplate('weekly');
    await pump(tester);
    await tester.tap(find.byKey(const Key('templates.menu.weekly')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('templates.delete.weekly')));
    await tester.pumpAndSettle();
    expect(find.text('Delete weekly?'), findsOneWidget);
    expect(server.templates, hasLength(1));
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(server.templates, isEmpty);
    expect(row('weekly'), findsNothing);
  });

  testWidgets('New template saves a task by reference', (tester) async {
    await pump(tester, size: desktop);
    await tester.tap(find.byKey(const Key('templates.new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('template.name')), 'weekly');
    await tester.enterText(find.byKey(const Key('template.task')), 'infra-1');
    await tester.enterText(find.byKey(const Key('template.due')), '3d');
    await tester.tap(find.byKey(const Key('template.save')));
    await tester.pumpAndSettle();
    expect(
      server
          .requestsTo('/api/v1/templates')
          .where((r) => r.method == 'POST')
          .single
          .body,
      {
        'task_ref': 'infra-1',
        'name': 'weekly',
        'with_subtasks': true,
        'tenant_wide': false,
        'due_in': '3d',
      },
    );
    expect(row('weekly'), findsOneWidget);
    expect(find.text('Saved weekly'), findsOneWidget);
  });

  testWidgets('a taken name keeps the form open with the reason', (
    tester,
  ) async {
    server.addTemplate('weekly');
    await pump(tester, size: desktop);
    await tester.tap(find.byKey(const Key('templates.new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('template.name')), 'weekly');
    await tester.enterText(find.byKey(const Key('template.task')), 'infra-1');
    await tester.tap(find.byKey(const Key('template.save')));
    await tester.pumpAndSettle();
    expect(find.text('template "weekly" already exists'), findsOneWidget);
    expect(find.byKey(const Key('template.name')), findsOneWidget);
  });

  testWidgets('from scratch creates the task from a line, then saves it', (
    tester,
  ) async {
    await pump(tester, size: desktop);
    await tester.tap(find.byKey(const Key('templates.new')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('From scratch'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('this also adds the task to the project'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('template.name')), 'standup');
    await tester.enterText(
      find.byKey(const Key('template.line')),
      'Standup notes #team',
    );
    await tester.tap(find.byKey(const Key('template.save')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/tasks').single.body, {
      'title': 'Standup notes #team',
      'project_ref': 'infra',
      'parse': true,
    });
    expect(
      server
          .requestsTo('/api/v1/templates')
          .where((r) => r.method == 'POST')
          .single
          .body['task_ref'],
      'infra-3',
    );
    expect(row('standup'), findsOneWidget);
  });

  testWidgets('editing sends only what changed', (tester) async {
    server.addTemplate('weekly', project: 'infra', title: 'Review');
    await pump(tester, size: desktop);
    await tester.tap(row('weekly'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('template.name')),
      'weekly-review',
    );
    await tester.tap(find.byKey(const Key('template.priority.1')));
    await tester.tap(find.byKey(const Key('template.save')));
    await tester.pumpAndSettle();
    final patch = server.requests.where((r) => r.method == 'PATCH').single;
    expect(patch.body, {'name': 'weekly-review', 'priority': 1});
    expect(row('weekly-review'), findsOneWidget);
  });

  testWidgets('the editor deletes after a confirmation', (tester) async {
    server.addTemplate('weekly');
    await pump(tester, size: desktop);
    await tester.tap(row('weekly'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('template.delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(server.templates, isEmpty);
    expect(find.text('Deleted weekly'), findsOneWidget);
  });
}
