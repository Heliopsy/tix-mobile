// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/l10n/generated/app_localizations.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/widget_snapshot.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/features/widgets/application/snapshots.dart';

import '../../../helpers/fake_tix.dart';

void main() {
  final now = DateTime.utc(2026, 11, 1, 12);
  final en = lookupAppLocalizations(const Locale('en'));
  const ctx = WidgetContext(id: 'c1.acme', instance: 'Work', tenant: 'Acme');

  Task task(
    String ref, {
    String? due,
    int priority = 3,
    String status = 'todo',
  }) => Task.fromJson(
    taskJson(ref, due: due, priority: priority, status: status)
      ..['project_id'] = 'p1',
  );

  final ops = Project.fromJson({
    'id': 'p1',
    'key': 'ops',
    'name': 'Operations',
    'color': 'blue',
    'workflow_id': 'wf1',
  });
  final workflow = Workflow.fromJson(workflowJson());

  WidgetSnapshots build({
    List<Task> mine = const [],
    bool mineMore = false,
    int unread = 0,
    List<InboxItem> inbox = const [],
    Map<String, ({List<Task> tasks, bool more})> projectTasks = const {},
    TixAccent accent = TixAccent.standard,
    AppLocalizations? l10n,
  }) => WidgetSnapshots(
    WidgetFeedData(
      ctx: ctx,
      accent: accent,
      projects: [ops],
      workflows: [workflow],
      mine: mine,
      mineMore: mineMore,
      unread: unread,
      unreadMore: false,
      inbox: inbox,
      projectTasks: projectTasks,
    ),
    l10n ?? en,
    now,
  );

  group('my work', () {
    test('puts overdue and today first, undated last, then priority', () {
      final snap = build(
        mine: [
          task('ops-1'),
          task('ops-2', due: '2026-11-08T00:00:00Z'),
          task('ops-3', due: '2026-10-30T00:00:00Z'),
          task('ops-4', due: '2026-11-01T09:00:00Z', priority: 4),
          task('ops-5', due: '2026-11-01T09:00:00Z', priority: 1),
        ],
      ).myWork();
      expect(snap.tasks.map((t) => t.ref), [
        'ops-3',
        'ops-5',
        'ops-4',
        'ops-2',
        'ops-1',
      ]);
      expect(snap.total, 5);
      expect(snap.moreText, isEmpty);
    });

    test('caps the rows and says how many more', () {
      final snap = build(mine: [for (var i = 1; i <= 15; i++) task('ops-$i')])
          .myWork();
      expect(snap.tasks, hasLength(myWorkLimit));
      expect(snap.moreText, '+3 more');
    });

    test('rows carry the route, the project colour and the category', () {
      final row = build(mine: [task('ops-1', status: 'doing', priority: 1)])
          .myWork()
          .tasks
          .single;
      expect(row.route, '/projects/ops/tasks/ops-1');
      expect(row.project, 'ops');
      expect(row.category, 'doing');
      expect(row.status, 'Doing');
      expect(row.priority, 'highest');
      expect(row.colour!.light, startsWith('#'));
      expect(row.colour!.light, isNot(row.colour!.dark));
    });

    test("the accent is the tenant's, checked per scheme", () {
      final snap = build(accent: TixAccent.resolve('#ffcc00')).myWork();
      expect(snap.accent.light, isNot('#ffcc00'));
      expect(snap.accent.onLight, anyOf('#ffffff', '#08231a'));
      expect(snap.v, widgetSchemaVersion);
    });
  });

  group('inbox', () {
    test('newest first, translated, with the count in words', () {
      final snap = build(
        unread: 2,
        inbox: [
          InboxItem.fromJson(inboxJson('i1', ref: 'ops-1')),
          InboxItem.fromJson(
            inboxJson('i2', ref: 'ops-2', created: '2026-11-01T11:50:00Z'),
          ),
        ],
        l10n: lookupAppLocalizations(const Locale('fr')),
      ).inbox();
      expect(snap.items.map((i) => i.id), ['i2', 'i1']);
      expect(snap.unreadText, '2 non lus');
      expect(snap.items.first.route, '/projects/ops/tasks/ops-2');
      expect(snap.items.first.task, startsWith('ops-2 '));
    });

    test('an item whose task is gone opens the inbox', () {
      final snap = build(
        unread: 1,
        inbox: [InboxItem.fromJson(inboxJson('i1', gone: true))],
      ).inbox();
      expect(snap.items.single.route, '/inbox');
    });
  });

  group('project', () {
    test('one group per open state, in workflow order, with counts', () {
      final snap = build(
        projectTasks: {
          'ops': (
            tasks: [
              task('ops-1', status: 'doing'),
              task('ops-2'),
              task('ops-3'),
            ],
            more: false,
          ),
        },
      ).project('ops')!;
      expect(snap.groups.map((g) => g.status), ['todo', 'doing', 'blocked']);
      expect(snap.groups.map((g) => g.count), [2, 1, 0]);
      expect(snap.groups[1].category, 'doing');
      expect(snap.open, 3);
      expect(snap.project.name, 'Operations');
    });

    test('a project not read or not there has no snapshot', () {
      expect(build().project('ops'), isNull);
      expect(build().project('nope'), isNull);
    });
  });

  test('every label is translated', () {
    final strings = widgetStrings(lookupAppLocalizations(const Locale('de')));
    expect(strings['myWork'], 'Meine Arbeit');
    expect(strings.values, everyElement(isNotEmpty));
  });

  test('the stored theme names', () {
    expect(widgetTheme('oled'), 'black');
    expect(widgetTheme(null), 'system');
    expect(widgetTheme('light'), 'light');
  });
}
