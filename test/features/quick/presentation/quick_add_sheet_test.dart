// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/quick/application/quick.dart';
import 'package:tix_mobile/src/features/quick/presentation/quick_add_sheet.dart';

import '../../../data/repositories/tasks_repository_quick_test.dart'
    show realRows;
import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late List<Task?> closed;

  setUp(() {
    server = FakeTix()..previews.addAll(realRows);
    closed = [];
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    String text = '',
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
                await showGlobalQuickAdd(
                  context,
                  draft: QuickAddDraft(text: text, project: project),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      size: size,
      overrides: [
        ...fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        previewDebounceProvider.overrideWithValue(Duration.zero),
      ],
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  Finder line() => find.byKey(const Key('quickAdd.line'));

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(line(), text);
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Finder chip(String kind, String value) => find.byWidgetPredicate(
    (w) => w is QuickChip && w.kind == kind && w.value == value,
  );

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: the preview shows what the server made of it', (
      tester,
    ) async {
      await pump(tester, size: size);
      await type(tester, 'Fix login !high #auth #ui @tom due:fri status:doing');
      expect(server.previewedLines.last, contains('@tom'));
      expect(chip('title', 'Fix login'), findsOneWidget);
      expect(chip('priority', 'high'), findsOneWidget);
      expect(chip('tag', 'auth'), findsOneWidget);
      expect(chip('tag', 'ui'), findsOneWidget);
      expect(chip('assignee', '@tom'), findsOneWidget);
      expect(chip('due', 'Fri, Nov 13'), findsOneWidget);
      expect(chip('status', 'doing'), findsOneWidget);
    });
  }

  testWidgets('a line the server would refuse says why and can still be '
      'sent', (tester) async {
    await pump(tester);
    await type(tester, 'Fix login !high @nobody');
    expect(find.byType(QuickChip), findsNothing);
    final refusal = find.byKey(const Key('quickAdd.refusal'));
    expect(
      find.descendant(
        of: refusal,
        matching: find.textContaining('"nobody" is not a tix actor'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('quickAdd.submit')));
    await tester.pumpAndSettle();
    expect(
      server.requestsTo('/api/v1/tasks').single.body['title'],
      'Fix login !high @nobody',
    );
  });

  testWidgets('the project starts as the one asked for and the line goes '
      'there with parse', (tester) async {
    await pump(tester, project: 'web', text: 'Ship it\n!high');
    expect(
      find.descendant(
        of: find.byKey(const Key('quickAdd.project')),
        matching: find.text('web'),
      ),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(line()).controller!.text, 'Ship it !high');
    await tester.tap(find.byKey(const Key('quickAdd.submit')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/tasks').single.body, {
      'title': 'Ship it !high',
      'project_ref': 'web',
      'parse': true,
    });
    expect(closed.single!.ref, 'web-1');
    expect(line(), findsNothing);
  });

  testWidgets('a tag completes the word under the cursor', (tester) async {
    await pump(tester);
    await type(tester, 'Fix #au');
    final suggestions = find.byKey(const Key('quickAdd.suggestions'));
    await tester.tap(
      find.descendant(
        of: suggestions,
        matching: find.byKey(const Key('quickAdd.suggest.auth')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(line()).controller!.text, 'Fix #auth ');
  });

  testWidgets('a person completes by handle or name', (tester) async {
    await pump(tester);
    await type(tester, 'Fix @Ra');
    await tester.tap(find.byKey(const Key('quickAdd.suggest.raj')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(line()).controller!.text, 'Fix @raj ');
  });

  testWidgets('a project moves to the picker and leaves the line', (
    tester,
  ) async {
    await pump(tester, project: 'infra');
    await type(tester, 'Fix +we now');
    final field = tester.widget<TextField>(line());
    field.controller!.selection = const TextSelection.collapsed(offset: 7);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quickAdd.suggest.web')));
    await tester.pumpAndSettle();
    expect(field.controller!.text, 'Fix now');
    expect(
      find.descendant(
        of: find.byKey(const Key('quickAdd.project')),
        matching: find.text('web'),
      ),
      findsOneWidget,
    );
    expect(server.previewedLines.last, 'Fix now');
    expect(
      server.requestsTo('/tasks/import').last.uri.path,
      '/api/v1/projects/web/tasks/import',
    );
  });

  testWidgets('add another keeps the sheet open for the next line', (
    tester,
  ) async {
    await pump(tester, project: 'infra');
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('quickAdd.another')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
    for (final l in ['One', 'Two']) {
      await type(tester, l);
      await tester.tap(find.byKey(const Key('quickAdd.submit')));
      await tester.pumpAndSettle();
    }
    expect(server.requestsTo('/api/v1/tasks').map((r) => r.body['title']), [
      'One',
      'Two',
    ]);
    expect(line(), findsOneWidget);
    expect(tester.widget<TextField>(line()).controller!.text, isEmpty);
    expect(
      find.descendant(
        of: find.byKey(const Key('quickAdd.added')),
        matching: find.text('Created infra-4'),
      ),
      findsOneWidget,
    );
    expect(closed, isEmpty);
  });

  testWidgets('without a network the line stays and says so', (tester) async {
    await pump(tester, project: 'infra');
    await type(tester, 'Offline line');
    server.offline = true;
    await tester.tap(find.byKey(const Key('quickAdd.submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Adding needs a connection'), findsOneWidget);
    expect(tester.widget<TextField>(line()).controller!.text, 'Offline line');
  });

  testWidgets('a template creates a task in one tap', (tester) async {
    server.addTemplate('weekly', project: 'infra', title: 'Review', uses: 2);
    await pump(tester);
    await tester.tap(find.byKey(const Key('quickAdd.template.weekly')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/use'), hasLength(1));
    expect(closed.single!.title, 'Review');
  });

  testWidgets('a refused preview turns previews off and says so', (
    tester,
  ) async {
    server.importForbidden = true;
    await pump(tester, project: 'infra');
    await type(tester, 'One');
    await type(tester, 'Two');
    expect(server.previewedLines, ['One']);
    expect(find.textContaining('cannot preview'), findsOneWidget);
  });
}
