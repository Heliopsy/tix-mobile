// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/quick/presentation/task_create_form.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late List<Task?> closed;

  setUp(() {
    server = FakeTix();
    closed = [];
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    String title = '',
    String? project,
  }) async {
    final stores = signedInStores();
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              key: const Key('open'),
              onPressed: () async => closed.add(
                await showTaskCreateForm(
                  context,
                  title: title,
                  project: project,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  Finder field(String name) => find.byKey(Key('addDetails.$name'));

  Future<void> fill(WidgetTester tester, String name, String text) async {
    await tester.enterText(field(name), text);
    await tester.pump();
  }

  Future<void> create(WidgetTester tester) async {
    final button = find.byKey(const Key('addDetails.create'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  List<Map<String, dynamic>> creates() => [
    for (final r in server.requestsTo('/api/v1/tasks'))
      if (r.method == 'POST') r.body,
  ];

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: every field goes out as written, never parsed', (
      tester,
    ) async {
      await pump(tester, size: size, project: 'web');
      await fill(tester, 'title', 'Fix login !high #auth');
      await fill(tester, 'body', 'Steps to reproduce');
      await fill(tester, 'assignee', 'tom');
      await fill(tester, 'tags', 'auth, ui,');
      await fill(tester, 'repeat', 'every week');
      await fill(tester, 'parent', 'web-1');
      await fill(tester, 'dependsOn', 'web-2, web-3');
      await fill(tester, 'lease', '2h');
      await create(tester);
      expect(creates().single, {
        'project_ref': 'web',
        'title': 'Fix login !high #auth',
        'body': 'Steps to reproduce',
        'priority': 3,
        'assignee_actor_id': 'tom',
        'tags': ['auth', 'ui'],
        'recurrence': 'every week',
        'parent_ref': 'web-1',
        'depends_on': ['web-2', 'web-3'],
        'lease': '2h',
      });
      expect(closed.single!.ref, 'web-1');
    });
  }

  testWidgets('the priority picked is the one sent', (tester) async {
    await pump(tester, title: 'Ship it', project: 'infra');
    await tester.tap(field('priority'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest').last);
    await tester.pumpAndSettle();
    await create(tester);
    expect(creates().single, {
      'project_ref': 'infra',
      'title': 'Ship it',
      'priority': 1,
    });
  });

  testWidgets('a form without a title sends nothing and says why', (
    tester,
  ) async {
    await pump(tester, project: 'web');
    await fill(tester, 'title', '   ');
    await create(tester);
    expect(creates(), isEmpty);
    expect(
      find.descendant(
        of: find
            .ancestor(of: field('title'), matching: find.byType(Column))
            .first,
        matching: find.text('A task needs a title.'),
      ),
      findsOneWidget,
    );
    expect(closed, isEmpty);
  });

  testWidgets('a refusal naming a field shows under it and keeps the form', (
    tester,
  ) async {
    server.createRefusal = {
      'error': {
        'code': 'invalid',
        'message': 'task lease 0s must be positive',
        'details': {'field': 'lease'},
      },
    };
    await pump(tester, title: 'Renew cert', project: 'web');
    await fill(tester, 'lease', '0s');
    await create(tester);
    expect(creates(), hasLength(1));
    expect(
      find.descendant(
        of: find
            .ancestor(of: field('lease'), matching: find.byType(Column))
            .first,
        matching: find.text('task lease 0s must be positive'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('addDetails.error')), findsNothing);
    expect(
      tester.widget<TextField>(field('title')).controller!.text,
      'Renew cert',
    );
    expect(closed, isEmpty);
  });

  testWidgets('a refusal naming no field shows above the form', (tester) async {
    server.createRefusal = {
      'error': {'code': 'not_found', 'message': 'project "nope"'},
    };
    await pump(tester, title: 'Renew cert', project: 'web');
    await create(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('addDetails.error')),
        matching: find.textContaining('project "nope"'),
      ),
      findsOneWidget,
    );
    expect(closed, isEmpty);
  });

  testWidgets('without a network the task becomes a draft, as quick add '
      'does', (tester) async {
    await pump(tester, title: 'Offline task', project: 'infra');
    server.offline = true;
    await create(tester);
    expect(closed.single!.ref, 'infra-draft1');
    expect(closed.single!.title, 'Offline task');
  });
}
