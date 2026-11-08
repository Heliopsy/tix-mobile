// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/board_view.dart';
import 'package:tix_mobile/src/features/tasks/presentation/bulk_bar.dart';
import 'package:tix_mobile/src/features/tasks/presentation/filter_panel.dart';
import 'package:tix_mobile/src/features/tasks/presentation/lanes_view.dart';
import 'package:tix_mobile/src/features/tasks/presentation/quick_add_sheet.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_actions.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_view.dart';

/// Every task on the server, as a list, a board or lanes.
class TasksScreen extends StatelessWidget {
  /// Creates the screen.
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) => const TaskScreenView(scope: AllScope());
}

/// The reader's open assigned tasks, under a heading per deadline.
class MyWorkScreen extends StatelessWidget {
  /// Creates the screen.
  const MyWorkScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const TaskScreenView(scope: MineScope());
}

/// The task screen over one scope: the filter bar, the drawing it picks,
/// the bulk bar while tasks are picked, and on wide windows the open task
/// beside it.
class TaskScreenView extends ConsumerStatefulWidget {
  /// The screen over [scope], with [selectedRef] open beside it.
  const TaskScreenView({required this.scope, this.selectedRef, super.key});

  /// What the screen covers.
  final TaskScope scope;

  /// The task open beside the list on wide windows, from the route.
  final String? selectedRef;

  /// How wide the list is beside an open task.
  static const listPaneWidth = 420.0;

  /// How wide the open task is beside a board or lanes.
  static const detailPaneWidth = 460.0;

  @override
  ConsumerState<TaskScreenView> createState() => _TaskScreenViewState();
}

class _TaskScreenViewState extends ConsumerState<TaskScreenView> {
  final _filterFocus = FocusNode(debugLabel: 'filter');
  String? _focused;
  String? _open;
  List<Task> _order = const [];

  TaskScope get _scope => widget.scope;

  @override
  void dispose() {
    _filterFocus.dispose();
    super.dispose();
  }

  void _openTask(Task task) {
    final scope = _scope;
    final context = this.context;
    setState(() => _focused = task.ref);
    if (scope is ProjectScope) {
      context.go(Routes.task(scope.key, task.ref));
      return;
    }
    final key = ref.read(taskContextProvider).value?.projectOf(task)?.key;
    if (key == null) return;
    if (context.isTwoPane) {
      setState(() => _open = task.ref);
    } else {
      unawaited(context.push(Routes.task(key, task.ref)));
    }
  }

  void _step(List<Task> order, int by) {
    if (order.isEmpty) return;
    final at = order.indexWhere((t) => t.ref == _focused);
    final next = at < 0
        ? (by > 0 ? 0 : order.length - 1)
        : (at + by).clamp(0, order.length - 1);
    setState(() => _focused = order[next].ref);
  }

  Task? _focusedTask(List<Task> order) {
    for (final t in order) {
      if (t.ref == _focused) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scope = _scope;
    final state = ref.watch(taskScreenProvider(scope));
    final query = state.query(scope);
    final listing = ref.watch(taskListingProvider(query));
    final taskContext = ref.watch(taskContextProvider).value;
    final selection = ref.watch(taskSelectionProvider(scope));
    final arrangement = _listGroups(state, taskContext, l10n);
    final prefs = arrangement.view.isEmpty
        ? const <String, GroupPref>{}
        : ref.watch(viewArrangementProvider(arrangement.view)).value ??
              const {};
    final layout = state.view == TaskView.board && taskContext != null
        ? boardLayout(query, taskContext)
        : null;
    final view = layout is BoardRefused ? TaskView.list : state.view;
    final paged = listing.value;
    final entries = paged == null
        ? const <ListEntry>[]
        : buildListEntries(
            paged.items,
            arrangement,
            prefs,
            categoryOf: state.grouping == TaskGrouping.status
                ? (g) => _categoryOf(g, taskContext)
                : null,
          );
    final order = view == TaskView.list
        ? [
            for (final e in entries)
              if (e is RowEntry) e.task,
          ]
        : paged?.items ?? const <Task>[];
    final selectedRef = widget.selectedRef ?? _open;
    final screen = ref.read(taskScreenProvider(scope).notifier);
    final selector = ref.read(taskSelectionProvider(scope).notifier);

    final content = AsyncBody(
      value: listing,
      onRetry: () => ref
        ..invalidate(taskContextProvider)
        ..invalidate(taskListingProvider(query)),
      data: (paged) => switch (view) {
        TaskView.board when layout is BoardColumns => BoardView(
          query: query,
          paged: paged,
          layout: layout,
          onOpen: _openTask,
          focusedRef: _focused,
        ),
        TaskView.board => const SkeletonList(),
        TaskView.lanes => LanesView(
          query: query,
          paged: paged,
          onOpen: _openTask,
          showFinished: state.showFinished,
          focusedRef: _focused,
        ),
        TaskView.list => TaskListView(
          query: query,
          paged: paged,
          entries: entries,
          onOpen: _openTask,
          selectedRef: selectedRef,
          focusedRef: _focused,
          empty: _Empty(scope: scope, filtered: state.expression.isNotEmpty),
        ),
      },
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaskFilterPanel(scope: scope, focusNode: _filterFocus),
        if (layout is BoardRefused) BoardRefusedNotice(layout: layout),
        Expanded(child: content),
        if (selection.isNotEmpty) BulkBar(query: query),
      ],
    );

    final Widget framed;
    if (context.isTwoPane && selectedRef != null) {
      final detail = TaskDetailView(
        key: ValueKey(selectedRef),
        taskRef: selectedRef,
      );
      framed = view == TaskView.list
          ? Row(
              children: [
                SizedBox(width: TaskScreenView.listPaneWidth, child: body),
                const VerticalDivider(width: 1),
                Expanded(child: detail),
              ],
            )
          : Row(
              children: [
                Expanded(child: body),
                const VerticalDivider(width: 1),
                SizedBox(width: TaskScreenView.detailPaneWidth, child: detail),
              ],
            );
    } else if (context.isTwoPane &&
        view == TaskView.list &&
        scope is ProjectScope) {
      framed = Row(
        children: [
          SizedBox(width: TaskScreenView.listPaneWidth, child: body),
          const VerticalDivider(width: 1),
          Expanded(
            child: EmptyState(
              icon: Icons.touch_app_outlined,
              title: l10n.noTaskSelected,
            ),
          ),
        ],
      );
    } else {
      framed = body;
    }

    final projectKey = scope is ProjectScope ? scope.key : null;
    void add() {
      if (projectKey != null) unawaited(showQuickAdd(context, projectKey));
    }

    _order = order;
    return CommandScope(
      commands: [
        if (projectKey != null)
          TixCommand(
            id: 'tasks.new',
            label: l10n.newTask,
            group: l10n.commandsTasks,
            icon: Icons.add,
            shortcut: const SingleActivator(LogicalKeyboardKey.keyN),
            run: add,
          ),
        TixCommand(
          id: 'tasks.refresh',
          label: l10n.refresh,
          group: l10n.commandsTasks,
          icon: Icons.refresh,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyR),
          run: () => ref.invalidate(taskListingProvider(query)),
        ),
        TixCommand(
          id: 'tasks.next',
          label: l10n.boardNext,
          group: l10n.commandsTasks,
          icon: Icons.arrow_downward,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyJ),
          run: () => _step(_order, 1),
        ),
        TixCommand(
          id: 'tasks.previous',
          label: l10n.boardPrevious,
          group: l10n.commandsTasks,
          icon: Icons.arrow_upward,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyK),
          run: () => _step(_order, -1),
        ),
        TixCommand(
          id: 'tasks.open',
          label: l10n.boardOpen,
          group: l10n.commandsTasks,
          icon: Icons.open_in_new,
          shortcut: const SingleActivator(LogicalKeyboardKey.enter),
          run: () {
            final focused = _focusedTask(_order);
            if (focused != null) _openTask(focused);
          },
        ),
        TixCommand(
          id: 'tasks.select',
          label: l10n.bulkSelect,
          group: l10n.commandsTasks,
          icon: Icons.check_box_outlined,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyX),
          run: () {
            final focused = _focusedTask(_order);
            if (focused != null) selector.toggle(focused.ref);
          },
        ),
        TixCommand(
          id: 'tasks.selectAll',
          label: l10n.bulkSelectAll,
          group: l10n.commandsTasks,
          icon: Icons.select_all,
          shortcut: const SingleActivator(
            LogicalKeyboardKey.keyA,
            control: true,
          ),
          run: () => selector.selectAll([for (final t in _order) t.ref]),
        ),
        TixCommand(
          id: 'tasks.clearSelection',
          label: l10n.bulkClear,
          group: l10n.commandsTasks,
          icon: Icons.close,
          shortcut: const SingleActivator(LogicalKeyboardKey.escape),
          run: selector.clear,
        ),
        TixCommand(
          id: 'tasks.filter',
          label: l10n.filterFocus,
          group: l10n.commandsTasks,
          icon: Icons.search,
          shortcut: const CharacterActivator('/'),
          run: _filterFocus.requestFocus,
        ),
        if (viewsFor(scope).length > 1)
          TixCommand(
            id: 'tasks.view',
            label: l10n.viewSwitch,
            group: l10n.commandsTasks,
            icon: Icons.view_column_outlined,
            shortcut: const SingleActivator(LogicalKeyboardKey.keyV),
            run: screen.cycleView,
          ),
      ],
      child: TixPage(
        title: _title(l10n, scope, taskContext),
        titleWidget: projectKey == null
            ? null
            : _ProjectTitle(projectKey: projectKey),
        subtitle: paged == null
            ? null
            : l10n.boardCount(paged.items.length, paged.hasMore ? '+' : ''),
        primaryAction: projectKey == null || selection.isNotEmpty
            ? null
            : TixAction(
                key: const Key('tasks.quickAdd'),
                label: l10n.newTask,
                icon: Icons.add,
                onPressed: add,
              ),
        body: framed,
      ),
    );
  }

  ListGroups _listGroups(
    TaskScreenState state,
    TaskIndex? taskContext,
    AppLocalizations l10n,
  ) {
    if (_scope is MineScope) {
      return ListGroups.deadline(ref.watch(clockProvider)(), l10n);
    }
    if (taskContext == null || state.view != TaskView.list) {
      return ListGroups.none;
    }
    return switch (state.grouping) {
      TaskGrouping.none => ListGroups.none,
      TaskGrouping.status => ListGroups.status(_scope, taskContext),
      TaskGrouping.project => ListGroups.project(taskContext),
    };
  }

  static StatusCategory? _categoryOf(String status, TaskIndex? context) {
    for (final w in context?.workflows ?? const <Workflow>[]) {
      final s = w.state(status);
      if (s != null) {
        return statusCategoryOf(s.resolvedCategory(w.initial));
      }
    }
    return null;
  }

  static String _title(
    AppLocalizations l10n,
    TaskScope scope,
    TaskIndex? context,
  ) => switch (scope) {
    AllScope() => l10n.tasksTitle,
    MineScope() => l10n.myWorkTitle,
    ProjectScope(:final key) => () {
      final p = context?.project(key);
      return p == null || p.name.isEmpty ? key : p.name;
    }(),
  };
}

class _Empty extends StatelessWidget {
  const _Empty({required this.scope, required this.filtered});

  final TaskScope scope;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scope = this.scope;
    if (filtered) {
      return EmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: l10n.filterNoMatch,
        body: l10n.filterNoMatchBody,
      );
    }
    return switch (scope) {
      MineScope() => EmptyState(
        icon: Icons.task_alt,
        title: l10n.myWorkEmpty,
        body: l10n.myWorkEmptyBody,
      ),
      ProjectScope(:final key) => EmptyState(
        icon: Icons.task_alt,
        title: l10n.tasksEmpty,
        body: l10n.tasksEmptyBody,
        action: TixAction(
          key: const Key('tasks.empty.add'),
          label: l10n.newTask,
          icon: Icons.add,
          onPressed: () => showQuickAdd(context, key),
        ),
      ),
      AllScope() => EmptyState(
        icon: Icons.task_alt,
        title: l10n.boardAllEmpty,
        body: l10n.boardAllEmptyBody,
      ),
    };
  }
}

class _ProjectTitle extends ConsumerWidget {
  const _ProjectTitle({required this.projectKey});

  final String projectKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final taskContext = ref.watch(taskContextProvider).value;
    final project = taskContext?.project(projectKey);
    final name = project == null || project.name.isEmpty
        ? projectKey
        : project.name;
    final projects = taskContext?.projects ?? const <Project>[];
    return InkWell(
      key: const Key('project.switch'),
      borderRadius: BorderRadius.circular(TixRadius.md),
      onTap: projects.length < 2
          ? null
          : () async {
              final key = await showActionSheet<String>(
                context,
                title: l10n.boardSwitchProject,
                actions: [
                  for (final p in projects)
                    if (p.archivedAt == null)
                      TixSheetAction(
                        key: Key('project.switch.${p.key}'),
                        value: p.key,
                        label: p.name.isEmpty ? p.key : '${p.name}  ${p.key}',
                      ),
                ],
              );
              if (key != null && context.mounted) {
                context.go(Routes.project(key));
              }
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProjectMark(
            name: name,
            colour: project?.color ?? '',
            icon: project?.icon ?? '',
          ),
          const SizedBox(width: TixSpace.s2),
          Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
          if (projects.length > 1)
            Icon(Icons.arrow_drop_down, color: context.tix.muted),
        ],
      ),
    );
  }
}
