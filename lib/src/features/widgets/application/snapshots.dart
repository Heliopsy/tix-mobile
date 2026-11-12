// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/l10n/generated/app_localizations.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/design/colour.dart';
import 'package:tix_mobile/src/core/design/components/inbox_row.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/widget_snapshot.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';

/// The most tasks the My work snapshot carries.
const myWorkLimit = 12;

/// The most items the Inbox snapshot carries.
const inboxLimit = 8;

/// The most tasks per state the Project snapshot carries.
const projectGroupLimit = 6;

/// Everything read for one context, from which every snapshot is built.
class WidgetFeedData {
  /// What was read.
  const WidgetFeedData({
    required this.ctx,
    required this.accent,
    required this.projects,
    required this.workflows,
    required this.mine,
    required this.mineMore,
    required this.unread,
    required this.unreadMore,
    required this.inbox,
    this.projectTasks = const {},
  });

  /// Whose data it is.
  final WidgetContext ctx;

  /// The tenant's accent.
  final TixAccent accent;

  /// Every project.
  final List<Project> projects;

  /// Every workflow.
  final List<Workflow> workflows;

  /// Open tasks assigned to the reader, first page.
  final List<Task> mine;

  /// Whether more were assigned than [mine] holds.
  final bool mineMore;

  /// Unread inbox items.
  final int unread;

  /// Whether [unread] is a floor.
  final bool unreadMore;

  /// The newest unread items.
  final List<InboxItem> inbox;

  /// Open tasks of each wanted project, by key, with whether more exist.
  final Map<String, ({List<Task> tasks, bool more})> projectTasks;
}

/// The tenant's [accent] as widgets draw it, contrast-checked per scheme.
WidgetAccent widgetAccent(TixAccent accent) {
  final light = TixTokens.light.withAccent(accent);
  final dark = TixTokens.dark.withAccent(accent);
  return WidgetAccent(
    light: hexOf(light.accent),
    dark: hexOf(dark.accent),
    onLight: hexOf(light.onAccent),
    onDark: hexOf(dark.onAccent),
  );
}

/// A project's stored colour in both schemes, null for none.
WidgetColour? widgetColour(String value) {
  final light = TixTokens.light.projectColour(value);
  final dark = TixTokens.dark.projectColour(value);
  if (light == null || dark == null) return null;
  return WidgetColour(light: hexOf(light), dark: hexOf(dark));
}

/// tix's priority number as the word widgets key their colour off.
String widgetPriority(int p) => switch (p) {
  1 => 'highest',
  2 => 'high',
  4 => 'low',
  5 => 'lowest',
  _ => 'normal',
};

/// A workflow category key as widgets name it.
String widgetCategory(String category) => switch (category) {
  'in_progress' => 'doing',
  'blocked' || 'waiting' || 'done' || 'cancelled' => category,
  _ => 'todo',
};

/// The data widgets draw for one context.
class WidgetSnapshots {
  /// Builds from [data] in [l10n], stamped [now].
  WidgetSnapshots(this.data, this.l10n, this.now)
    : _byId = {for (final p in data.projects) p.id: p},
      _workflows = {for (final w in data.workflows) w.id: w};

  /// What was read.
  final WidgetFeedData data;

  /// The app's language.
  final AppLocalizations l10n;

  /// When.
  final DateTime now;

  final Map<String, Project> _byId;
  final Map<String, Workflow> _workflows;

  int get _at => now.millisecondsSinceEpoch;

  WidgetAccent get _accent => widgetAccent(data.accent);

  WidgetTask _task(Task t, {Project? project}) {
    final p = project ?? _byId[t.projectId];
    final w = p == null ? null : _workflows[p.workflowId];
    final state = w?.state(t.status);
    final key = p?.key ?? '';
    return WidgetTask(
      ref: t.ref,
      title: t.title,
      project: key,
      colour: p == null ? null : widgetColour(p.color),
      due: t.dueAt?.millisecondsSinceEpoch,
      priority: widgetPriority(t.priority),
      status: (state?.label ?? '').isNotEmpty ? state!.label! : t.status,
      category: widgetCategory(
        state == null ? _guess(t.status) : w!.categoryOf(state),
      ),
      route: key.isEmpty ? Routes.myWork : Routes.task(key, t.ref),
    );
  }

  static String _guess(String status) => switch (StatusCategory.guess(status)) {
    StatusCategory.inProgress => 'in_progress',
    StatusCategory.blocked => 'blocked',
    StatusCategory.waiting => 'waiting',
    StatusCategory.done => 'done',
    StatusCategory.cancelled => 'cancelled',
    _ => 'todo',
  };

  /// Overdue and due today first, then later, then undated; by priority
  /// within the same moment.
  static int byDue(Task a, Task b) {
    final da = a.dueAt;
    final db = b.dueAt;
    if (da == null && db != null) return 1;
    if (db == null && da != null) return -1;
    if (da != null && db != null) {
      final c = da.compareTo(db);
      if (c != 0) return c;
    }
    return _rank(a.priority).compareTo(_rank(b.priority));
  }

  static int _rank(int p) => p == 0 ? 3 : p;

  /// The My work widget's data.
  MyWorkSnapshot myWork() {
    final sorted = [...data.mine]..sort(byDue);
    final shown = sorted.take(myWorkLimit).toList();
    final rest = sorted.length - shown.length;
    return MyWorkSnapshot(
      at: _at,
      ctx: data.ctx,
      accent: _accent,
      total: sorted.length,
      more: data.mineMore,
      moreText: rest > 0 || data.mineMore
          ? l10n.widgetMore(rest > 0 ? rest : 1)
          : '',
      tasks: [for (final t in shown) _task(t)],
    );
  }

  /// The Inbox widget's data.
  InboxSnapshot inbox() {
    final items = [...data.inbox]
      ..sort((a, b) {
        final ta = a.createdAt;
        final tb = b.createdAt;
        if (ta == null || tb == null) return 0;
        return tb.compareTo(ta);
      });
    return InboxSnapshot(
      at: _at,
      ctx: data.ctx,
      accent: _accent,
      unread: data.unread,
      more: data.unreadMore,
      unreadText: l10n.widgetUnread(data.unread),
      items: [
        for (final i in items.take(inboxLimit))
          WidgetInboxItem(
            id: i.id,
            what: inboxWhat(l10n, i),
            task: i.taskRef.isEmpty
                ? i.taskTitle
                : '${i.taskRef} ${i.taskTitle}',
            excerpt: i.excerpt,
            at: i.createdAt?.millisecondsSinceEpoch,
            route: i.opensTask
                ? Routes.task(i.projectKey, i.taskRef)
                : Routes.inbox,
          ),
      ],
    );
  }

  /// The Project widget's data for [key], null when the context has no
  /// such project or it was not read.
  ProjectSnapshot? project(String key) {
    Project? project;
    for (final p in data.projects) {
      if (p.key.toLowerCase() == key.toLowerCase()) project = p;
    }
    final read = data.projectTasks[key];
    if (project == null || read == null) return null;
    final workflow = _workflows[project.workflowId];
    final states = [
      for (final s in workflow?.states ?? const <WorkflowState>[])
        if (!(s.terminal ?? false)) s,
    ];
    final groups = <WidgetGroup>[];
    for (final s in states) {
      final key = s.key ?? '';
      final tasks = [
        for (final t in read.tasks)
          if (t.status.toLowerCase() == key.toLowerCase()) t,
      ]..sort(byDue);
      groups.add(
        WidgetGroup(
          status: key,
          label: (s.label ?? '').isEmpty ? key : s.label!,
          category: widgetCategory(workflow!.categoryOf(s)),
          count: tasks.length,
          tasks: [
            for (final t in tasks.take(projectGroupLimit))
              _task(t, project: project),
          ],
        ),
      );
    }
    return ProjectSnapshot(
      at: _at,
      ctx: data.ctx,
      accent: _accent,
      project: WidgetProject(
        key: project.key,
        name: project.name,
        colour: widgetColour(project.color),
      ),
      open: read.tasks.length,
      more: read.more,
      groups: groups,
    );
  }

  /// The projects the pickers offer for this context, the reader's starred
  /// ones first.
  List<WidgetProject> catalog() => [
    for (final p in starredFirst(data.projects, (p) => p.starred))
      if (p.archivedAt == null)
        WidgetProject(key: p.key, name: p.name, colour: widgetColour(p.color)),
  ];
}

/// The labels every widget reads, in [l10n]'s language.
Map<String, String> widgetStrings(AppLocalizations l10n) => {
  'myWork': l10n.widgetMyWork,
  'inbox': l10n.widgetInbox,
  'quickAdd': l10n.widgetQuickAdd,
  'addTask': l10n.widgetAddTask,
  'nothingDue': l10n.widgetNothingDue,
  'allRead': l10n.widgetAllRead,
  'noOpenTasks': l10n.widgetNoOpenTasks,
  'updated': l10n.widgetUpdated,
  'openApp': l10n.widgetOpenApp,
  'localStale': l10n.widgetLocalStale,
  'overdue': l10n.widgetOverdue,
  'today': l10n.widgetToday,
  'complete': l10n.widgetComplete,
  'projectMissing': l10n.widgetProjectMissing,
  'signedOut': l10n.widgetSignedOut,
  'openUpdate': l10n.widgetOpenUpdate,
  'pickProject': l10n.widgetPickProject,
};

/// The stored colour scheme as widgets name it. Widgets have no Low
/// contrast palette, so it draws them dark.
String widgetTheme(String? stored) => switch (stored) {
  'light' => 'light',
  'dark' || 'dim' => 'dark',
  'oled' => 'black',
  _ => 'system',
};
