// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<void> openSheet(WidgetTester tester) async {
    await press(tester, find.byKey(const Key('task.menu')));
    await press(tester, find.byKey(const Key('menu.moveProject')));
  }

  Finder explain() => find.byKey(const Key('moveProject.explain'));

  testWidgets('offers every other project and says the reference changes', (
    tester,
  ) async {
    await pumpTask(tester, server);
    await openSheet(tester);
    expect(find.byKey(const Key('moveProject.web')), findsOneWidget);
    expect(find.byKey(const Key('moveProject.infra')), findsNothing);
    expect(
      tester.widget<TixButton>(find.byKey(const Key('moveProject.confirm'))),
      isA<TixButton>().having((b) => b.onPressed, 'onPressed', isNull),
    );
    await press(tester, find.byKey(const Key('moveProject.web')));
    expect(
      tester.widget<Text>(explain()).data,
      allOf(
        contains('infra-1 takes the next number in web'),
        contains('infra-1 keeps leading to it'),
      ),
    );
  });

  testWidgets('moves, opens the new reference and says so', (tester) async {
    await pumpTask(tester, server);
    await openSheet(tester);
    await press(tester, find.byKey(const Key('moveProject.web')));
    await press(tester, find.byKey(const Key('moveProject.confirm')));
    expect(bodies(server, 'POST', '/tasks/infra-1/move'), [
      {'project_ref': 'web'},
    ]);
    expect(find.text('route:/projects/web/tasks/web-50'), findsOneWidget);
    expect(toast('infra-1 is now web-50.'), findsOneWidget);
  });

  testWidgets('a status the target lacks and fields left behind are said', (
    tester,
  ) async {
    server.failures['POST /api/v1/tasks/infra-1/move'] = const FakeResponse(200, {
      'task': {'id': 'id-infra-1', 'ref': 'web-7'},
      'from_ref': 'infra-1',
      'project': 'web',
      'status_kept': false,
      'dropped_fields': ['team', 'size'],
    });
    await pumpTask(tester, server);
    await openSheet(tester);
    await press(tester, find.byKey(const Key('moveProject.web')));
    await press(tester, find.byKey(const Key('moveProject.confirm')));
    expect(
      toast(
        "infra-1 is now web-7. It starts in the project's first status. "
        'Left behind: team, size.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a task claimed by somebody else is refused with why', (
    tester,
  ) async {
    server.failures['POST /api/v1/tasks/infra-1/move'] = FakeResponse(
      409,
      envelope('conflict', 'task "infra-1" is claimed by somebody else'),
    );
    await pumpTask(tester, server);
    await openSheet(tester);
    await press(tester, find.byKey(const Key('moveProject.web')));
    await press(tester, find.byKey(const Key('moveProject.confirm')));
    expect(find.text('route:/projects/web/tasks/web-50'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.textContaining('claimed by somebody else'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('task.menu')), findsOneWidget);
  });

  testWidgets('an older server hides it after refusing', (tester) async {
    server.moveSupported = false;
    await pumpTask(tester, server);
    await openSheet(tester);
    await press(tester, find.byKey(const Key('moveProject.web')));
    await press(tester, find.byKey(const Key('moveProject.confirm')));
    expect(
      toast('This server cannot move tasks to another project.'),
      findsOneWidget,
    );
    await press(tester, find.byKey(const Key('task.menu')));
    expect(find.byKey(const Key('menu.moveProject')), findsNothing);
  });

  testWidgets('no other project says so and offers no Move', (tester) async {
    server.projects.removeWhere((p) => p['key'] == 'web');
    await pumpTask(tester, server);
    await openSheet(tester);
    expect(find.byKey(const Key('moveProject.none')), findsOneWidget);
    expect(find.byKey(const Key('moveProject.confirm')), findsNothing);
  });

  testWidgets('the command palette lists it', (tester) async {
    final container = await pumpTask(tester, server, size: tallDesktop);
    final command = container
        .read(commandRegistryProvider)
        .commands
        .singleWhere((c) => c.id == 'taskDetail.moveProject');
    expect(command.label, 'Move to project…');
    command.run();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moveProject.web')), findsOneWidget);
  });
}
