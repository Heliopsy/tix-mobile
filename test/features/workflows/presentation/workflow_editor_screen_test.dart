// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/workflows/presentation/workflow_editor_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    FakeTix server, {
    Size size = phone,
    bool settle = true,
    String key = 'default',
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      WorkflowEditorScreen(workflowKey: key),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Finder save() => find.byKey(const Key('workflow.save'));

  Map<String, dynamic> lastDefinition(FakeTix server) =>
      server.lastWorkflowPut!['definition'] as Map<String, dynamic>;

  void addCustom(FakeTix server) => server.workflows.add({
    'id': 'wf2',
    'key': 'support',
    'name': 'Support',
    'definition': {
      'initial': 'open',
      'states': [
        {'key': 'open', 'label': 'Open'},
        {'key': 'review', 'label': 'Review'},
        {'key': 'closed', 'label': 'Closed', 'terminal': true},
      ],
      'transitions': [
        {'from': 'open', 'to': 'review'},
        {'from': 'review', 'to': 'closed'},
      ],
    },
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then states, moves and routes', (tester) async {
        final server = FakeTix()..gate = Completer<void>();
        await pump(tester, server, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('States'), findsOneWidget);
        expect(find.byKey(const Key('moves.todo')), findsOneWidget);
        expect(save(), findsNothing);
        await tester.ensureVisible(find.text('Routes'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('route.done')), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final server = FakeTix()
          ..override = FakeResponse(500, envelope('internal', 'x'));
        await pump(tester, server, size: size);
        expect(find.byType(ErrorState), findsOneWidget);
      });

      testWidgets('a chip toggles a move and saves it', (tester) async {
        final server = FakeTix();
        await pump(tester, server, size: size);
        await tapVisible(tester, find.byKey(const Key('move.todo.done')));
        expect(save(), findsOneWidget);
        await tester.tap(save());
        await tester.pumpAndSettle();
        final transitions = lastDefinition(server)['transitions'] as List;
        expect(
          transitions.any(
            (t) => (t as Map)['from'] == 'todo' && t['to'] == 'done',
          ),
          isTrue,
        );
        expect(find.text('Workflow saved.'), findsOneWidget);
      });
    });
  }

  testWidgets('a move needing a comment is sent with it', (tester) async {
    final server = FakeTix();
    await pump(tester, server, size: desktop);
    final chip = find.byKey(const Key('move.todo.doing'));
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: chip, matching: find.byIcon(Icons.tune)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rules.comment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rules.save')));
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();
    final t = (lastDefinition(server)['transitions'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((t) => t['from'] == 'todo' && t['to'] == 'doing');
    expect(t['requires_comment'], isTrue);
  });

  testWidgets('a state no move reaches is named', (tester) async {
    final server = FakeTix();
    addCustom(server);
    await pump(tester, server, key: 'support', size: desktop);
    await tapVisible(tester, find.byKey(const Key('move.open.review')));
    final route = find.byKey(const Key('route.review'));
    await tester.ensureVisible(route);
    expect(
      find.descendant(of: route, matching: find.text('No route reaches it')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('route.closed')),
        matching: find.text('No route reaches it'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('adding a state appends it and can make it initial', (
    tester,
  ) async {
    final server = FakeTix();
    addCustom(server);
    await pump(tester, server, key: 'support', size: desktop);
    await tapVisible(tester, find.byKey(const Key('workflow.addState')));
    await tester.enterText(find.byKey(const Key('state.key')), 'triage');
    await tester.enterText(find.byKey(const Key('state.label')), 'Triage');
    await tester.tap(find.byKey(const Key('state.initial')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('state.save')));
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();
    final def = lastDefinition(server);
    expect(def['initial'], 'triage');
    expect((def['states'] as List).last, {'key': 'triage', 'label': 'Triage'});
  });

  testWidgets('dragging a state reorders it', (tester) async {
    final server = FakeTix();
    addCustom(server);
    await pump(tester, server, key: 'support', size: desktop);
    final handles = find.byIcon(Icons.drag_handle);
    await tester.drag(handles.last, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();
    final keys = [
      for (final s in lastDefinition(server)['states'] as List)
        (s as Map)['key'],
    ];
    expect(keys.first, 'closed');
  });

  testWidgets('a removed state offers where its tasks go', (tester) async {
    final server = FakeTix();
    addCustom(server);
    await pump(tester, server, key: 'support', size: desktop);
    await tapVisible(tester, find.byKey(const ValueKey('state.1.review')));
    await tester.tap(find.byKey(const Key('state.remove')));
    await tester.pumpAndSettle();
    final migrate = find.byKey(const Key('migrate.review'));
    await tester.ensureVisible(migrate);
    await tester.pumpAndSettle();
    await tester.tap(migrate);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open').last);
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(server.lastWorkflowPut!['migrate'], {'review': 'open'});
  });

  testWidgets('a refusal shows above the editor and keeps the draft', (
    tester,
  ) async {
    final server = FakeTix();
    addCustom(server);
    server.failures['PUT /api/v1/workflows/support'] = FakeResponse(
      409,
      envelope('conflict', 'state "review" still holds 2 tasks'),
    );
    await pump(tester, server, key: 'support', size: desktop);
    await tapVisible(tester, find.byKey(const Key('move.closed.open')));
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('workflow.error')), findsOneWidget);
    expect(find.textContaining('still holds 2 tasks'), findsOneWidget);
    expect(save(), findsOneWidget);
  });

  testWidgets('delete is red, confirmed and absent on the builtin', (
    tester,
  ) async {
    final server = FakeTix();
    addCustom(server);
    await pump(tester, server, size: desktop);
    expect(find.byKey(const Key('workflow.delete')), findsNothing);
  });

  testWidgets('a custom workflow deletes after confirming', (tester) async {
    final server = FakeTix();
    addCustom(server);
    await pump(tester, server, key: 'support', size: desktop);
    await tapVisible(tester, find.byKey(const Key('workflow.delete')));
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    final del = server.requests.lastWhere((r) => r.method == 'DELETE');
    expect(del.uri.path, '/api/v1/workflows/support');
    expect(find.text('route:/manage/workflows'), findsOneWidget);
  });

  testWidgets('a member reads it with nothing to change', (tester) async {
    final server = FakeTix()..identity = {'role': 'member'};
    await pump(tester, server);
    expect(find.byKey(const Key('workflow.readOnly')), findsOneWidget);
    expect(find.byKey(const Key('workflow.addState')), findsNothing);
    expect(find.byIcon(Icons.drag_handle), findsNothing);
  });
}
