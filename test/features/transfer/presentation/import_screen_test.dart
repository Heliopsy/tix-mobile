// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/features/transfer/presentation/import_screen.dart';

import '../../../helpers/fake_tix.dart';
import '../../../helpers/import_answers.dart';
import '../../../helpers/people_app.dart';

void main() {
  const tallPhone = Size(400, 3000);
  const tallDesktop = Size(1280, 3000);

  PeopleRig jira() {
    final rig = PeopleRig();
    rig.people.importAnswer = jiraAnswer;
    rig.files.picked = PickedFile(
      name: 'jira.csv',
      bytes: utf8.encode('Summary,Status\nFix login,Open\n'),
      mimeType: 'text/csv',
    );
    return rig;
  }

  Future<void> choose(WidgetTester tester, Key field, String option) async {
    await tapIn(tester, find.byKey(field));
    await tapIn(tester, find.text(option).last);
  }

  Finder step(String name) => find.byKey(ValueKey('import.step.$name'));

  for (final MapEntry(key: width, value: size) in {
    'compact': tallPhone,
    'expanded': tallDesktop,
  }.entries) {
    group(width, () {
      testWidgets('loading, then the first step', (tester) async {
        final rig = jira();
        rig.server.gate = Completer<void>();
        await rig.pump(
          tester,
          const ImportScreen(project: 'infra'),
          size: size,
          settle: false,
        );
        expect(find.byType(SkeletonList), findsOneWidget);
        rig.server.gate!.complete();
        await tester.pumpAndSettle();
        expect(step('source'), findsOneWidget);
        expect(
          find.textContaining('Step 1 of 5: Upload', findRichText: true),
          findsOneWidget,
        );
        expect(find.byKey(const Key('import.note')), findsOneWidget);
        expect(find.text('No file chosen'), findsOneWidget);
        final next = tester.widget<TixButton>(
          find.byKey(const Key('import.next')),
        );
        expect(next.onPressed, isNull);
      });

      testWidgets('no projects', (tester) async {
        final rig = jira();
        rig.server.projects.clear();
        await rig.pump(tester, const ImportScreen(), size: size);
        expect(find.byType(EmptyState), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final rig = jira();
        rig.server.override = FakeResponse(500, envelope('internal', 'x'));
        await rig.pump(tester, const ImportScreen(), size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });

      testWidgets('file, columns, values, preview and result', (tester) async {
        final rig = jira();
        await rig.pump(
          tester,
          const ImportScreen(project: 'infra'),
          size: size,
        );
        await tapIn(tester, find.byKey(const Key('import.pick')));
        expect(find.text('jira.csv'), findsOneWidget);
        await tapIn(tester, find.byKey(const Key('import.next')));

        expect(step('columns'), findsOneWidget);
        expect(
          find.textContaining('Step 2 of 5: Map columns', findRichText: true),
          findsOneWidget,
        );
        final sprint = find.byKey(const ValueKey('import.column.Sprint'));
        expect(
          find.descendant(of: sprint, matching: find.text('suggested')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: sprint, matching: find.text('S1')),
          findsOneWidget,
        );
        await choose(tester, const Key('import.target.Sprint'), 'Ignore');
        await tapIn(tester, find.byKey(const Key('import.next')));

        expect(step('valueMap'), findsOneWidget);
        expect(
          (sentMapping(rig.people.imports.last)['columns'] as Map)['Sprint'],
          'ignore',
        );
        final review = find.byKey(
          const ValueKey('import.value.status.In Review'),
        );
        expect(review, findsOneWidget);
        await choose(
          tester,
          const Key('import.becomes.status.In Review'),
          'Doing',
        );
        await tester.enterText(
          find.descendant(
            of: find.byKey(
              const Key('import.becomes.assignee.jane@example.com'),
            ),
            matching: find.byType(EditableText),
          ),
          'jane',
        );
        await choose(
          tester,
          const Key('import.policy.assignee'),
          'Skip the row',
        );
        await tapIn(tester, find.byKey(const Key('import.next')));

        expect(step('preview'), findsOneWidget);
        final mapping = sentMapping(rig.people.imports.last);
        expect(mapping['values'], {
          'status': {'Open': 'todo', 'In Review': 'doing'},
          'priority': {'P1': 'high'},
          'assignee': {'jane@example.com': 'jane'},
        });
        expect(mapping['unknown'], {'assignee': 'skip_row'});
        expect(find.byKey(const Key('import.errors')), findsNothing);
        await tapIn(tester, find.byKey(const Key('import.commit')));

        expect(step('result'), findsOneWidget);
        expect(rig.people.imports.last['dry_run'], false);
        expect(find.byKey(const Key('import.done')), findsOneWidget);
        expect(find.text('2 created, 1 updated, 0 skipped.'), findsOneWidget);
        await tapIn(tester, find.byKey(const Key('import.openProject')));
        expect(find.text('route:/projects/infra'), findsOneWidget);
      });

      testWidgets('rows in error are drawn in danger and block the import', (
        tester,
      ) async {
        final rig = jira();
        await rig.pump(
          tester,
          const ImportScreen(project: 'infra'),
          size: size,
        );
        await tapIn(tester, find.byKey(const Key('import.pick')));
        await tapIn(tester, find.byKey(const Key('import.skip')));

        expect(step('preview'), findsOneWidget);
        expect(find.byKey(const Key('import.failed')), findsOneWidget);
        final error = tester.widget<Text>(
          find.byKey(const Key('import.row.3.error')),
        );
        expect(
          error.data,
          'status "In Review" is not a state of this workflow',
        );
        final ctx = tester.element(find.byKey(const Key('import.row.3')));
        expect(error.style?.color, ctx.tix.danger);
        final box = tester.widget<ColoredBox>(
          find
              .descendant(
                of: find.byKey(const Key('import.row.3')),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
        expect(box.color, ctx.tix.dangerSoft);
        final fine = tester.widget<ColoredBox>(
          find
              .descendant(
                of: find.byKey(const Key('import.row.2')),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
        expect(fine.color, isNot(ctx.tix.dangerSoft));
        final commit = tester.widget<TixButton>(
          find.byKey(const Key('import.commit')),
        );
        expect(commit.onPressed, isNull);
        expect(commit.label, 'Fix the rows in error first');

        await tapIn(tester, find.byKey(const Key('import.errorsCsv')));
        final saved = rig.files.saved.single;
        expect(saved.name, 'infra-import-errors.csv');
        expect(saved.mimeType, 'text/csv');
        expect(utf8.decode(saved.bytes), jiraErrorsCsv);
      });
    });
  }

  testWidgets('the mode runs the dry run again', (tester) async {
    final rig = jira();
    await rig.pump(
      tester,
      const ImportScreen(project: 'infra'),
      size: tallDesktop,
    );
    await tapIn(tester, find.byKey(const Key('import.pick')));
    await tapIn(tester, find.byKey(const Key('import.skip')));
    await tapIn(tester, find.text('Create every row as a new task'));
    expect(rig.people.imports.last['mode'], 'create');
    expect(rig.people.imports.last['dry_run'], true);
    expect(rig.people.imports, hasLength(2));
  });

  testWidgets('a pasted list goes straight to the preview as lines', (
    tester,
  ) async {
    final rig = PeopleRig();
    rig.people.importAnswer = linesAnswer;
    await rig.pump(
      tester,
      const ImportScreen(project: 'infra'),
      size: tallPhone,
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('import.lines')),
        matching: find.byType(EditableText),
      ),
      'Fix login #bug\nWrite docs',
    );
    await tester.pumpAndSettle();
    expect(find.text('Next: preview'), findsOneWidget);
    expect(find.byKey(const Key('import.skip')), findsNothing);
    await tapIn(tester, find.byKey(const Key('import.next')));
    expect(step('preview'), findsOneWidget);
    expect(rig.people.imports.single['format'], 'lines');
    expect(rig.people.imports.single['content'], 'Fix login #bug\nWrite docs');
    expect(rig.people.imports.single.containsKey('mapping'), isFalse);
    expect(find.text('Import 2 tasks'), findsOneWidget);
    await tapIn(tester, find.byKey(const Key('import.back')));
    expect(step('source'), findsOneWidget);
    expect(find.text('Fix login #bug\nWrite docs'), findsOneWidget);
  });

  testWidgets('every step goes back, keeping what was chosen', (tester) async {
    final rig = jira();
    await rig.pump(
      tester,
      const ImportScreen(project: 'infra'),
      size: tallPhone,
    );
    await tapIn(tester, find.byKey(const Key('import.pick')));
    await tapIn(tester, find.byKey(const Key('import.next')));
    await choose(tester, const Key('import.target.Summary'), 'Description');
    await tapIn(tester, find.byKey(const Key('import.next')));
    expect(step('valueMap'), findsOneWidget);
    await tapIn(tester, find.byKey(const Key('import.back')));
    expect(step('columns'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('import.column.Summary')),
        matching: find.text('Description'),
      ),
      findsOneWidget,
    );
    await tapIn(tester, find.byKey(const Key('import.back')));
    expect(step('source'), findsOneWidget);
    expect(find.text('jira.csv'), findsOneWidget);
    await tapIn(tester, find.byKey(const Key('import.cancel')));
    expect(find.text('route:/manage/transfer'), findsOneWidget);
  });

  testWidgets('a failed import keeps the report and goes back', (tester) async {
    final rig = jira();
    rig.people.importAnswer = (body) => {
      ...jiraAnswer(body),
      if (body['dry_run'] == false) ...{
        'committed': false,
        'failed': 1,
        'errors': [
          {'line': 4, 'message': 'parent "x" names nothing'},
        ],
      } else ...{
        'failed': 0,
        'errors': <Object>[],
      },
    };
    await rig.pump(
      tester,
      const ImportScreen(project: 'infra'),
      size: tallDesktop,
    );
    await tapIn(tester, find.byKey(const Key('import.pick')));
    await tapIn(tester, find.byKey(const Key('import.skip')));
    await tapIn(tester, find.byKey(const Key('import.commit')));
    expect(find.byKey(const Key('import.rolledBack')), findsOneWidget);
    expect(find.text('Line 4: parent "x" names nothing'), findsOneWidget);
    expect(find.byKey(const Key('import.errorsCsv')), findsOneWidget);
    await tapIn(tester, find.byKey(const Key('import.back')));
    expect(step('preview'), findsOneWidget);
    await tapIn(tester, find.byKey(const Key('import.commit')));
    await tapIn(tester, find.byKey(const Key('import.another')));
    expect(step('source'), findsOneWidget);
    expect(find.text('No file chosen'), findsOneWidget);
  });

  testWidgets('a refusal is shown on the step that sent it', (tester) async {
    final rig = jira();
    await rig.pump(
      tester,
      const ImportScreen(project: 'infra'),
      size: tallPhone,
    );
    await tapIn(tester, find.byKey(const Key('import.pick')));
    rig.server.override = FakeResponse(
      413,
      envelope('too_large', 'the import is over 32 MiB'),
    );
    await tapIn(tester, find.byKey(const Key('import.next')));
    expect(step('source'), findsOneWidget);
    expect(find.byKey(const Key('import.error')), findsOneWidget);
  });
}
