// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix(
      tasks: {
        'infra': [
          taskJson('infra-1', title: 'Fix login', priority: 2, tags: ['ops']),
          taskJson('infra-2', title: 'Rotate keys', status: 'doing'),
        ],
      },
    );
  });

  Future<void> pump(WidgetTester tester, {Size size = phone}) async {
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

  final field = find.byKey(const Key('filter.field'));
  String text(WidgetTester tester) =>
      tester.widget<TextField>(field).controller!.text;
  List<String> offered(WidgetTester tester) => [
    for (final o
        in tester
            .widget<TixSuggestionList>(
              find.byKey(const Key('filter.suggestions')),
            )
            .options)
      o.label,
  ];
  Map<String, List<String>> lastListing() => server
      .requestsTo('/api/v1/tasks')
      .where((r) => r.method == 'GET')
      .last
      .uri
      .queryParametersAll;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: a status completes and a tap applies it', (
      tester,
    ) async {
      await pump(tester, size: size);
      await tester.enterText(field, 'status:do');
      await tester.pump();
      expect(offered(tester), ['status:doing', 'status:done', 'status:todo']);
      await tester.tap(find.text('status:doing'));
      await tester.pumpAndSettle();
      expect(text(tester), 'status:doing ');
      expect(lastListing()['status'], ['doing']);
      expect(find.text('Rotate keys'), findsOneWidget);
      expect(find.text('Fix login'), findsNothing);
      expect(find.byKey(const Key('filter.suggestions')), findsNothing);
    });
  }

  testWidgets('arrows reach a suggestion, Enter takes it, Escape closes', (
    tester,
  ) async {
    await pump(tester, size: desktop);
    await tester.enterText(field, 'prio');
    await tester.pump();
    expect(offered(tester), ['priority:']);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      tester
          .widget<TixSuggestionList>(
            find.byKey(const Key('filter.suggestions')),
          )
          .highlighted,
      0,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(text(tester), 'priority:');
    expect(offered(tester), contains('priority:high'));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byKey(const Key('filter.suggestions')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(offered(tester), contains('priority:high'));
  });

  testWidgets('a key still waiting for its value is not applied', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(field, 'tag:ops status:');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byKey(const Key('filter.error')), findsNothing);
    expect(offered(tester), contains('status:todo'));
  });

  testWidgets('Tab takes the first, a hash tag becomes tag:', (tester) async {
    await pump(tester, size: desktop);
    await tester.enterText(field, '#op');
    await tester.pump();
    expect(offered(tester), ['tag:ops']);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(text(tester), 'tag:ops ');
    expect(lastListing()['tag'], ['ops']);
  });

  testWidgets('each term is a chip that takes itself out', (tester) async {
    await pump(tester);
    await tester.enterText(field, 'tag:ops @ana');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(lastListing()['assignee'], ['ana']);
    expect(find.byType(TixTermChip), findsNWidgets(2));
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('term.@ana')),
        matching: find.byIcon(Icons.close),
      ),
    );
    await tester.pumpAndSettle();
    expect(text(tester), 'tag:ops');
    expect(lastListing().containsKey('assignee'), isFalse);
    expect(find.byKey(const Key('term.@ana')), findsNothing);
  });

  testWidgets('the Filters sheet replaces a key with the one picked', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(field, 'priority:low tag:ops');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter.pickers')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick.priority')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    expect(text(tester), 'tag:ops priority:high');
    expect(lastListing()['priority'], ['2']);
    await tester.tap(find.byKey(const Key('pick.tag')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any').last);
    await tester.pumpAndSettle();
    expect(text(tester), 'priority:high');
  });
}
