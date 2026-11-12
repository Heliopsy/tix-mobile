// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/pinned_shortcuts.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/session/project_stars.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/theme/panes.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/pin_shortcut_button.dart';
import 'package:tix_mobile/src/core/widgets/project_star_button.dart';
import 'package:tix_mobile/src/core/widgets/saved_copy_mark.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
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
import 'package:tix_mobile/src/features/tasks/presentation/task_summary.dart';

/// Every task on the server, as a list, a board or lanes.
class TasksScreen extends ConsumerStatefulWidget {
  /// Creates the screen, opening the saved filter [filter] when given.
  const TasksScreen({this.filter = '', super.key});

  /// A saved filter's name or id, from the address.
  final String filter;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(TasksScreen old) {
    super.didUpdateWidget(old);
    if (old.filter != widget.filter) _open();
  }

  void _open() {
    final name = widget.filter.trim();
    if (name.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ref.read(sessionControllerProvider.future);
      if (!mounted) return;
      await openSavedFilterNamed(context, ref, const AllScope(), name);
    });
  }

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
/// the bulk bar in select mode, and on wide windows the open task beside
/// it. Back leaves select mode before it leaves the screen.
class TaskScreenView extends ConsumerStatefulWidget {
  /// The screen over [scope], with [selectedRef] open beside it.
  const TaskScreenView({required this.scope, this.selectedRef, super.key});

  /// What the screen covers.
  final TaskScope scope;

  /// The task open beside the list on wide windows, from the route.
  final String? selectedRef;

  @override
  ConsumerState<TaskScreenView> createState() => _TaskScreenViewState();
}

class _TaskScreenViewState extends ConsumerState<TaskScreenView> {
  final _filterFocus = FocusNode(debugLabel: 'filter');
  String? _focused;
  String? _open;
  String? _openAt;
  GoRouterDelegate? _router;
  List<Task> _order = const [];

  TaskScope get _scope => widget.scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.maybeOf(context)?.routerDelegate;
    if (identical(router, _router)) return;
    _router?.removeListener(_routeChanged);
    _router = router?..addListener(_routeChanged);
  }

  @override
  void dispose() {
    _router?.removeListener(_routeChanged);
    _filterFocus.dispose();
    super.dispose();
  }

  String? get _path {
    final router = _router;
    if (router == null || router.currentConfiguration.matches.isEmpty) {
      return null;
    }
    return router.state.matchedLocation;
  }

  void _routeChanged() {
    if (_open != null && _path != _openAt) setState(() => _open = null);
  }

  void _closeTask() {
    final scope = _scope;
    if (widget.selectedRef != null && scope is ProjectScope) {
      context.go(Routes.project(scope.key));
      return;
    }
    setState(() => _open = null);
  }

  void _openTask(Task task) {
    final scope = _scope;
    final context = this.context;
    if (scope is ProjectScope) {
      context.go(Routes.task(scope.key, task.ref));
      return;
    }
    final key = ref.read(taskContextProvider).value?.projectOf(task)?.key;
    if (key == null) return;
    if (context.isTwoPane) {
      setState(() {
        _open = task.ref;
        _openAt = _path;
      });
    } else {
      unawaited(context.push(Routes.task(key, task.ref)));
    }
  }

  static const _page = 10;

  void _step(List<Task> order, int by) {
    if (order.isEmpty) return;
    if (controlFocused() && !typingInField()) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    final at = order.indexWhere((t) => t.ref == _focused);
    final next = at < 0
        ? (by > 0 ? 0 : order.length - 1)
        : (at + by).clamp(0, order.length - 1);
    setState(() => _focused = order[next].ref);
  }

  /// The cursor is the keyboard's: a pointer on the list takes it away, so a
  /// task opened or ticked with a tap or a click is not left marked.
  void _dropCursor(PointerDownEvent _) {
    if (_focused != null) setState(() => _focused = null);
  }

  Task? _focusedTask(List<Task> order) {
    for (final t in order) {
      if (t.ref == _focused) return t;
    }
    return null;
  }

  void _pickFocused(TaskSelection selector) {
    if (_focusedTask(_order) == null) _step(_order, 1);
    final focused = _focusedTask(_order);
    if (focused != null) selector.toggle(focused.ref);
  }

  void _extend(TaskSelection selector, int by) {
    final from = _focusedTask(_order);
    _step(_order, by);
    final to = _focusedTask(_order);
    selector.selectAll([?from?.ref, ?to?.ref]);
  }

  void _markFocusedDone(TaskQuickActions actions) {
    if (!(ModalRoute.isCurrentOf(context) ?? true)) return;
    final focused = _focusedTask(_order);
    if (focused == null || actions.isDone(focused)) return;
    unawaited(actions.toggleDone(focused));
  }

  void _editFocused(Future<void> Function(Task) edit) {
    if (!(ModalRoute.isCurrentOf(context) ?? true)) return;
    final focused = _focusedTask(_order);
    if (focused != null) unawaited(edit(focused));
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
          selectedRef: context.isTwoPane ? selectedRef : null,
          focusedRef: _focused,
          empty: _Empty(scope: scope, filtered: state.expression.isNotEmpty),
        ),
      },
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaskFilterPanel(scope: scope, focusNode: _filterFocus),
        if (paged != null)
          TaskSummaryLine(query: query, tasks: paged.items, view: view),
        if (layout is BoardRefused) BoardRefusedNotice(layout: layout),
        Expanded(
          child: Listener(onPointerDown: _dropCursor, child: content),
        ),
        if (selection.active) BulkBar(query: query),
      ],
    );

    // The list takes the whole width until a task is opened; then the task
    // shows in a panel beside it that can be resized and closed.
    final Widget framed;
    if (context.isTwoPane && selectedRef != null) {
      framed = ResizableTaskPanel(
        list: body,
        panel: TaskPanel(
          key: ValueKey(selectedRef),
          taskRef: selectedRef,
          onClose: _closeTask,
        ),
      );
    } else {
      framed = body;
    }

    final projectKey = scope is ProjectScope ? scope.key : null;
    void add() {
      if (projectKey != null) unawaited(showQuickAdd(context, projectKey));
    }

    _order = order;
    final actions = TaskQuickActions(context, ref, query);
    final detailBeside = context.isTwoPane && selectedRef != null;
    return OwnListKeys(
      child: CommandScope(
        commands: [
          if (projectKey != null)
            TixCommand(
              id: 'tasks.new',
              label: l10n.newTask,
              group: l10n.commandsTasks,
              icon: Icons.add,
              action: KeyActions.listNew,
              run: add,
            ),
          TixCommand(
            id: 'tasks.refresh',
            label: l10n.refresh,
            group: l10n.commandsTasks,
            icon: Icons.refresh,
            action: KeyActions.listRefresh,
            run: () => ref.invalidate(taskListingProvider(query)),
          ),
          TixCommand(
            id: 'tasks.next',
            label: l10n.boardNext,
            group: l10n.commandsTasks,
            icon: Icons.arrow_downward,
            action: KeyActions.listNext,
            run: () => _step(_order, 1),
          ),
          TixCommand(
            id: 'tasks.previous',
            label: l10n.boardPrevious,
            group: l10n.commandsTasks,
            icon: Icons.arrow_upward,
            action: KeyActions.listPrev,
            run: () => _step(_order, -1),
          ),
          TixCommand(
            id: 'tasks.first',
            label: l10n.keysFirstTask,
            group: l10n.commandsTasks,
            icon: Icons.vertical_align_top,
            action: KeyActions.listTop,
            inPalette: false,
            run: () => _step(_order, -_order.length),
          ),
          TixCommand(
            id: 'tasks.last',
            label: l10n.keysLastTask,
            group: l10n.commandsTasks,
            icon: Icons.vertical_align_bottom,
            action: KeyActions.listBottom,
            inPalette: false,
            run: () => _step(_order, _order.length),
          ),
          TixCommand(
            id: 'tasks.pageDown',
            label: l10n.keysPageDown,
            group: l10n.commandsTasks,
            icon: Icons.keyboard_double_arrow_down,
            action: KeyActions.listPageDown,
            inPalette: false,
            run: () => _step(_order, _page),
          ),
          TixCommand(
            id: 'tasks.pageUp',
            label: l10n.keysPageUp,
            group: l10n.commandsTasks,
            icon: Icons.keyboard_double_arrow_up,
            action: KeyActions.listPageUp,
            inPalette: false,
            run: () => _step(_order, -_page),
          ),
          TixCommand(
            id: 'tasks.open',
            label: l10n.boardOpen,
            group: l10n.commandsTasks,
            icon: Icons.open_in_new,
            action: KeyActions.listOpen,
            when: () => !controlFocused(),
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
            action: KeyActions.listSelect,
            run: () => _pickFocused(selector),
          ),
          TixCommand(
            id: 'tasks.selectMode',
            label: l10n.bulkSelectMode,
            group: l10n.commandsTasks,
            icon: Icons.checklist,
            run: selector.enter,
          ),
          TixCommand(
            id: 'tasks.extendDown',
            label: l10n.bulkExtendDown,
            group: l10n.commandsTasks,
            icon: Icons.keyboard_double_arrow_down,
            action: KeyActions.listExtendDown,
            run: () => _extend(selector, 1),
          ),
          TixCommand(
            id: 'tasks.extendUp',
            label: l10n.bulkExtendUp,
            group: l10n.commandsTasks,
            icon: Icons.keyboard_double_arrow_up,
            action: KeyActions.listExtendUp,
            run: () => _extend(selector, -1),
          ),
          if (!detailBeside)
            TixCommand(
              id: 'tasks.done',
              label: l10n.markDone,
              group: l10n.commandsTasks,
              icon: Icons.check_circle_outline,
              action: KeyActions.listDone,
              run: () => _markFocusedDone(actions),
            ),
          if (!detailBeside) ...[
            TixCommand(
              id: 'tasks.move',
              label: l10n.boardMoveTo,
              group: l10n.commandsTasks,
              icon: Icons.arrow_forward,
              action: KeyActions.taskMove,
              run: () => _editFocused(actions.pickMove),
            ),
            TixCommand(
              id: 'tasks.priority',
              label: l10n.boardPriorityTo,
              group: l10n.commandsTasks,
              icon: Icons.flag_outlined,
              action: KeyActions.taskPriority,
              run: () => _editFocused(actions.setPriority),
            ),
            TixCommand(
              id: 'tasks.assign',
              label: l10n.boardAssignTo,
              group: l10n.commandsTasks,
              icon: Icons.people_outline,
              action: KeyActions.taskAssign,
              run: () => _editFocused(actions.pickAssignee),
            ),
            TixCommand(
              id: 'tasks.due',
              label: l10n.boardDueTo,
              group: l10n.commandsTasks,
              icon: Icons.event_outlined,
              action: KeyActions.taskDue,
              run: () => _editFocused(actions.setDue),
            ),
            TixCommand(
              id: 'tasks.tag',
              label: l10n.boardTagAdd,
              group: l10n.commandsTasks,
              icon: Icons.sell_outlined,
              action: KeyActions.taskTag,
              run: () => _editFocused(actions.addTag),
            ),
          ],
          TixCommand(
            id: 'tasks.selectAll',
            label: l10n.bulkSelectAll,
            group: l10n.commandsTasks,
            icon: Icons.select_all,
            action: KeyActions.listSelectAll,
            run: () => selector.selectAll([for (final t in _order) t.ref]),
          ),
          TixCommand(
            id: 'tasks.clearSelection',
            label: l10n.bulkExit,
            group: l10n.commandsTasks,
            icon: Icons.close,
            action: KeyActions.listClear,
            when: () => ref.read(taskSelectionProvider(scope)).active,
            run: selector.exit,
          ),
          if (detailBeside)
            TixCommand(
              id: 'tasks.closeDetail',
              label: l10n.taskPanelClose,
              group: l10n.commandsTasks,
              icon: Icons.close,
              action: KeyActions.navBack,
              when: () => !ref.read(taskSelectionProvider(scope)).active,
              run: _closeTask,
            ),
          TixCommand(
            id: 'tasks.filter',
            label: l10n.filterFocus,
            group: l10n.commandsTasks,
            icon: Icons.search,
            action: KeyActions.listFilter,
            run: _filterFocus.requestFocus,
          ),
          if (viewsFor(scope).length > 1)
            TixCommand(
              id: 'tasks.view',
              label: l10n.viewSwitch,
              group: l10n.commandsTasks,
              icon: Icons.view_column_outlined,
              action: KeyActions.listView,
              run: screen.cycleView,
            ),
        ],
        child: PopScope(
          canPop: !selection.active,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) selector.exit();
          },
          child: TixPage(
            title: _title(l10n, scope, taskContext),
            titleWidget: projectKey == null
                ? null
                : _ProjectTitle(projectKey: projectKey),
            subtitle: paged == null
                ? null
                : l10n.boardCount(paged.items.length, paged.hasMore ? '+' : ''),
            actions: [
              TixIconButton(
                key: const Key('tasks.selectMode'),
                icon: Icons.checklist,
                tooltip: selection.active ? l10n.bulkExit : l10n.bulkSelectMode,
                selected: selection.active,
                onPressed: selection.active ? selector.exit : selector.enter,
              ),
              if (projectKey != null && !selection.active)
                ProjectTransferButton(projectKey: projectKey),
            ],
            primaryAction: projectKey == null || selection.active
                ? null
                : TixAction(
                    key: const Key('tasks.quickAdd'),
                    label: l10n.newTask,
                    icon: Icons.add,
                    onPressed: add,
                  ),
            body: Column(
              children: [
                const SavedCopyMark(),
                Expanded(child: framed),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListGroups _listGroups(
    TaskScreenState state,
    TaskIndex? taskContext,
    AppLocalizations l10n,
  ) {
    if (_scope is MineScope) {
      return ListGroups.deadline(
        ref.watch(clockProvider)(),
        l10n,
        style: context.times.style,
      );
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
    final stars = ref.watch(projectStarsProvider).value;
    final switcher = InkWell(
      key: const Key('project.switch'),
      borderRadius: BorderRadius.circular(TixRadius.md),
      onTap: projects.length < 2
          ? null
          : () async {
              final key = await showProjectPicker(
                context,
                title: l10n.boardSwitchProject,
                keyPrefix: 'project.switch',
                current: project?.key ?? projectKey,
                starred: stars?.keys ?? const {},
                projects: [
                  for (final p in projects)
                    if (p.archivedAt == null || p.key == project?.key) p,
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
            key: const Key('project.switch.mark'),
            name: name,
            colour: project?.color ?? '',
            icon: project?.icon ?? '',
            iconName: project?.iconName ?? '',
          ),
          const SizedBox(width: TixSpace.s2),
          Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
          if (projects.length > 1)
            Icon(Icons.arrow_drop_down, color: context.tix.muted),
        ],
      ),
    );
    if (project == null) return switcher;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: switcher),
        ProjectStarButton(project: project),
        PinShortcutButton(
          key: Key('project.${project.key}.pin'),
          shortcut: (ctx) => PinnedShortcut.project(
            context: ctx,
            key: project.key,
            name: project.name,
          ),
        ),
      ],
    );
  }
}

/// Opens Import and export on the project [projectKey], as the web's
/// project header does; drawn only for a credential that may export or
/// import.
class ProjectTransferButton extends ConsumerWidget {
  /// A button for the project [projectKey].
  const ProjectTransferButton({required this.projectKey, super.key});

  /// The project's key.
  final String projectKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(currentAccessProvider).value;
    if (access == null ||
        !(access.hasValue('export') || access.hasValue('import'))) {
      return const SizedBox.shrink();
    }
    return TixIconButton(
      key: const Key('project.transfer'),
      icon: Icons.import_export,
      tooltip: context.l10n.manageTransferTitle,
      onPressed: () => context.go(Routes.projectTransfer(projectKey)),
    );
  }
}

/// An open task beside the list on a wide window, with a button among its
/// header's actions that closes it.
class TaskPanel extends StatelessWidget {
  /// Shows [taskRef]; [onClose] closes the panel.
  const TaskPanel({required this.taskRef, required this.onClose, super.key});

  /// The task's reference.
  final String taskRef;

  /// Closes the panel.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) =>
      TaskDetailView(taskRef: taskRef, onClose: onClose);
}

/// [list] beside [panel], which has a handle on its left edge that resizes
/// it, as the sidebar's does; the width is kept on the device.
class ResizableTaskPanel extends ConsumerWidget {
  /// Draws [list] and [panel] side by side.
  const ResizableTaskPanel({
    required this.list,
    required this.panel,
    super.key,
  });

  /// The list, board or lanes.
  final Widget list;

  /// The open task.
  final Widget panel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sizes = ref.watch(panesProvider);
    final panes = ref.read(panesProvider.notifier);
    return LayoutBuilder(
      builder: (context, box) {
        final width = sizes.detailIn(box.maxWidth);
        return Row(
          children: [
            Expanded(child: list),
            TixPaneResizer(
              key: const Key('tasks.detail.resize'),
              label: l10n.taskPanelResize,
              width: width,
              min: detailMinWidth,
              max: detailMaxFor(box.maxWidth),
              growsLeft: true,
              onResize: (w, {required done}) =>
                  unawaited(panes.resizeDetail(w, save: done)),
              onReset: () => unawaited(panes.resizeDetail(null)),
            ),
            SizedBox(
              key: const Key('tasks.detail.pane'),
              width: width,
              child: panel,
            ),
          ],
        );
      },
    );
  }
}
