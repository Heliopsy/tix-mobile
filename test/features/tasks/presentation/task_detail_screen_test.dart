// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<void> pump(
    WidgetTester tester,
    String ref, {
    Locale? locale,
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      TaskDetailScreen(taskRef: ref),
      size: size,
      settle: settle,
      locale: locale ?? const Locale('en'),
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: loading, then the task', (tester) async {
      server.gate = Completer<void>();
      await pump(tester, 'infra-1', size: size, settle: false);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      server.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Fix login'), findsOneWidget);
    });

    testWidgets('$width: a missing task can be retried', (tester) async {
      await pump(tester, 'infra-99', size: size);
      expect(find.textContaining('Not found.'), findsOneWidget);
      server.tasks['infra']!.add(taskJson('infra-99', title: 'Late'));
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Late'), findsOneWidget);
    });
  }

  testWidgets('shows the fields, the assignee by name and the Markdown body', (
    tester,
  ) async {
    await pump(tester, 'infra-1');
    expect(find.text('infra-1'), findsOneWidget);
    expect(find.text('Fix login'), findsOneWidget);
    expect(find.text('todo'), findsOneWidget);
    expect(find.text('Highest'), findsOneWidget);
    expect(find.text('Raj'), findsOneWidget);
    expect(find.textContaining('Nov 20, 2026'), findsOneWidget);
    expect(find.text('#auth'), findsOneWidget);
    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(markdown.data, startsWith('# Steps'));
    expect(find.text('Steps'), findsOneWidget);
  });

  testWidgets('says what is missing', (tester) async {
    await pump(tester, 'infra-2');
    expect(find.text('Unassigned'), findsOneWidget);
    expect(find.text('No due date'), findsOneWidget);
    expect(find.text('No description.'), findsOneWidget);
    expect(find.byType(MarkdownBody), findsNothing);
  });

  testWidgets('falls back to the id when the assignee cannot be read', (
    tester,
  ) async {
    server.actors.remove('a1');
    await pump(tester, 'infra-1');
    expect(find.text('a1'), findsOneWidget);
  });

  testWidgets('a missing task is not found', (tester) async {
    await pump(tester, 'infra-99');
    expect(find.textContaining('Not found.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('labels are Bulgarian in Bulgarian', (tester) async {
    await pump(tester, 'infra-2', locale: const Locale('bg'));
    expect(find.text('Изпълнител'), findsOneWidget);
    expect(find.text('Без краен срок'), findsOneWidget);
  });
}
