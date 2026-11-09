// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/pinned_shortcuts.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/widgets/pin_shortcut_button.dart';
import 'package:tix_mobile/src/data/models/saved_filter.dart';
import 'package:tix_mobile/src/data/query/filter_expression.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/bulk_bar.dart';

/// The task screen's filter bar: the expression, one-tap chips, saved
/// filters, the sort and the drawing.
class TaskFilterPanel extends ConsumerStatefulWidget {
  /// The bar of the task screen over [scope].
  const TaskFilterPanel({required this.scope, this.focusNode, super.key});

  /// The screen's scope.
  final TaskScope scope;

  /// The field's focus, for the `/` shortcut.
  final FocusNode? focusNode;

  @override
  ConsumerState<TaskFilterPanel> createState() => _TaskFilterPanelState();
}

class _TaskFilterPanelState extends ConsumerState<TaskFilterPanel> {
  late final _text = TextEditingController(
    text: ref.read(taskScreenProvider(widget.scope)).expression,
  );

  Timer? _typing;

  /// How long typing pauses before the filter applies.
  static const settle = Duration(milliseconds: 450);

  @override
  void dispose() {
    _typing?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _changed(String text) {
    _typing?.cancel();
    _typing = Timer(settle, () {
      if (mounted) _screen.setExpression(text);
    });
  }

  void _submit(String text) {
    _typing?.cancel();
    _screen.setExpression(text);
  }

  TaskScreen get _screen => ref.read(taskScreenProvider(widget.scope).notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(taskScreenProvider(widget.scope));
    ref.listen(taskScreenProvider(widget.scope).select((s) => s.expression), (
      _,
      next,
    ) {
      if (_text.text.trim() != next) _text.text = next;
    });
    final expr = state.expression;
    TixFilterChip term(String key, String label, String t, IconData icon) =>
        TixFilterChip(
          key: Key('chip.$key'),
          label: label,
          icon: icon,
          selected: hasFilterTerm(expr, t),
          onSelected: (_) => _screen.toggleTerm(t),
        );
    TixFilterChip due(String window, String label) => TixFilterChip(
      key: Key('chip.due.$window'),
      label: label,
      icon: Icons.event,
      selected: hasFilterTerm(expr, 'due:$window'),
      onSelected: (_) => _screen.setDue(window),
    );
    final chips = <Widget>[
      if (widget.scope is! MineScope)
        term('mine', l10n.filterMine, 'assignee:me', Icons.person_outline),
      term('starred', l10n.starred, 'is:starred', Icons.star_outline),
      term('snoozed', l10n.filterSnoozed, 'is:snoozed', Icons.snooze),
      term('blocked', l10n.filterBlocked, 'is:blocked', Icons.block),
      due('overdue', l10n.filterOverdue),
      due('today', l10n.filterDueToday),
      due('week', l10n.filterDueWeek),
      if (state.view == TaskView.list && widget.scope is! MineScope)
        TixFilterChip(
          key: const Key('chip.finished'),
          label: l10n.filterFinished,
          icon: Icons.done_all,
          selected: state.showFinished,
          onSelected: (on) => _screen.setShowFinished(show: on),
        ),
      if (state.view == TaskView.lanes)
        TixFilterChip(
          key: const Key('chip.lanesFinished'),
          label: l10n.filterFinished,
          icon: Icons.done_all,
          selected: state.showFinished,
          onSelected: (on) => _screen.setShowFinished(show: on),
        ),
    ];
    return TixFilterBar(
      controller: _text,
      focusNode: widget.focusNode,
      fieldKey: const Key('filter.field'),
      hint: l10n.filterHint,
      error: state.filterError,
      onQuery: _changed,
      onSubmitted: _submit,
      chips: chips,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.scope is! MineScope) _SortMenu(scope: widget.scope),
          if (viewsFor(widget.scope).length > 1)
            _ViewSwitch(scope: widget.scope),
        ],
      ),
      below: widget.scope is MineScope
          ? null
          : _SavedFilterRow(scope: widget.scope),
    );
  }
}

class _ViewSwitch extends ConsumerWidget {
  const _ViewSwitch({required this.scope});

  final TaskScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = ref.watch(taskScreenProvider(scope).select((s) => s.view));
    final views = viewsFor(scope);
    (IconData, String) look(TaskView v) => switch (v) {
      TaskView.list => (Icons.view_list_outlined, l10n.viewList),
      TaskView.board => (Icons.view_column_outlined, l10n.viewBoard),
      TaskView.lanes => (Icons.view_week_outlined, l10n.viewLanes),
    };
    void pick(TaskView v) =>
        ref.read(taskScreenProvider(scope).notifier).setView(v);
    if (context.isCompact) {
      return PopupMenuButton<TaskView>(
        key: const Key('view.menu'),
        tooltip: l10n.viewSwitch,
        icon: Icon(look(view).$1),
        onSelected: pick,
        itemBuilder: (_) => [
          for (final v in views)
            CheckedPopupMenuItem(
              key: Key('view.${v.name}'),
              value: v,
              checked: v == view,
              child: Text(look(v).$2),
            ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: TixSpace.s2),
      child: SegmentedButton<TaskView>(
        key: const Key('view.switch'),
        showSelectedIcon: false,
        segments: [
          for (final v in views)
            ButtonSegment(
              value: v,
              icon: Icon(look(v).$1, key: Key('view.${v.name}'), size: 18),
              tooltip: look(v).$2,
            ),
        ],
        selected: {view},
        onSelectionChanged: (s) => pick(s.first),
      ),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu({required this.scope});

  final TaskScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(taskScreenProvider(scope));
    final screen = ref.read(taskScreenProvider(scope).notifier);
    String label(String sort) => switch (sort) {
      'priority' => l10n.fieldPriority,
      'due_at' => l10n.fieldDue,
      'created_at' => l10n.sortCreated,
      'updated_at' => l10n.sortUpdated,
      'seq' => l10n.sortNumber,
      'title' => l10n.sortTitle,
      _ => l10n.sortUrgency,
    };
    return PopupMenuButton<Object>(
      key: const Key('sort.menu'),
      tooltip: l10n.sortMenu,
      icon: const Icon(Icons.sort),
      onSelected: (v) => switch (v) {
        final String s => screen.setSort(s),
        final TaskGrouping g => screen.setGrouping(g),
        _ => screen.toggleDirection(),
      },
      itemBuilder: (_) => [
        for (final s in taskSorts)
          CheckedPopupMenuItem<Object>(
            key: Key('sort.${s.isEmpty ? 'urgency' : s}'),
            value: s,
            checked: state.sort == s,
            child: Text(label(s)),
          ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem<Object>(
          key: const Key('sort.desc'),
          value: false,
          checked: state.descending,
          child: Text(l10n.sortDescending),
        ),
        if (state.view == TaskView.list) ...[
          const PopupMenuDivider(),
          for (final (g, text) in [
            (TaskGrouping.none, l10n.groupNone),
            (TaskGrouping.status, l10n.groupStatus),
            if (scope is AllScope) (TaskGrouping.project, l10n.groupProject),
          ])
            CheckedPopupMenuItem<Object>(
              key: Key('group.by.${g.name}'),
              value: g,
              checked: state.grouping == g,
              child: Text(text),
            ),
        ],
      ],
    );
  }
}

class _SavedFilterRow extends ConsumerWidget {
  const _SavedFilterRow({required this.scope});

  final TaskScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(taskScreenProvider(scope));
    final filters = ref.watch(savedFiltersProvider).value ?? const [];
    final screen = ref.read(taskScreenProvider(scope).notifier);
    if (filters.isEmpty && state.expression.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: TixSpace.s1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in filters) ...[
              GestureDetector(
                onLongPress: hasSavedFilterMenu(ref, f)
                    ? () => manageSavedFilter(context, ref, f)
                    : null,
                onSecondaryTap: hasSavedFilterMenu(ref, f)
                    ? () => manageSavedFilter(context, ref, f)
                    : null,
                child: TixFilterChip(
                  key: Key('saved.${f.id}'),
                  label: f.name,
                  icon: f.shared
                      ? Icons.group_outlined
                      : Icons.bookmark_outline,
                  selected: state.savedFilterId == f.id,
                  onSelected: (on) => on
                      ? unawaited(_openSaved(context, ref, scope, f))
                      : screen.clear(),
                ),
              ),
              const SizedBox(width: TixSpace.s2),
            ],
            if (state.expression.isNotEmpty && state.savedFilterId == null)
              TixButton.quiet(
                key: const Key('saved.save'),
                label: l10n.filterSave,
                icon: Icons.bookmark_add_outlined,
                size: TixButtonSize.small,
                onPressed: () => saveCurrentFilter(context, ref, scope),
              ),
            if (state.expression.isNotEmpty)
              TixButton.quiet(
                key: const Key('filter.clear'),
                label: l10n.filterClear,
                size: TixButtonSize.small,
                onPressed: screen.clear,
              ),
          ],
        ),
      ),
    );
  }
}

/// Asks for a name and whether to share, then saves the screen's filter.
Future<void> _openSaved(
  BuildContext context,
  WidgetRef ref,
  TaskScope scope,
  SavedFilter filter,
) async {
  final screen = ref.read(taskScreenProvider(scope).notifier)
    ..applySaved(filter);
  try {
    final fresh = await ref
        .read(savedFiltersProvider.notifier)
        .fetch(filter.id);
    screen.refreshSaved(filter, fresh);
  } on TixException catch (e) {
    if (e.kind == TixErrorKind.notFound) screen.dropSaved(filter.id);
    if (context.mounted) {
      showTixToast(
        context,
        errorMessage(context.l10n, e),
        tone: TixTone.danger,
      );
    }
  }
}

/// Opens the saved filter [nameOrId] on the task screen over [scope], as a
/// link names it, and says so when it cannot.
Future<void> openSavedFilterNamed(
  BuildContext context,
  WidgetRef ref,
  TaskScope scope,
  String nameOrId,
) async {
  try {
    final filter = await ref
        .read(savedFiltersProvider.notifier)
        .fetch(nameOrId);
    ref.read(taskScreenProvider(scope).notifier).applySaved(filter);
  } on TixException catch (e) {
    if (context.mounted) {
      showTixToast(
        context,
        errorMessage(context.l10n, e),
        tone: TixTone.danger,
      );
    }
  }
}

Future<void> saveCurrentFilter(
  BuildContext context,
  WidgetRef ref,
  TaskScope scope,
) async {
  final state = ref.read(taskScreenProvider(scope));
  final answer = await showTixSheet<(String, bool)>(
    context,
    builder: (_) => const _SaveSheet(),
  );
  if (answer == null || !context.mounted) return;
  final l10n = context.l10n;
  try {
    final saved = await ref
        .read(savedFiltersProvider.notifier)
        .save(
          name: answer.$1,
          query: state.expression,
          sort: state.sort,
          view: state.view.name,
          shared: answer.$2,
        );
    ref.read(taskScreenProvider(scope).notifier).applySaved(saved);
    if (context.mounted) showTixToast(context, l10n.filterSaved(saved.name));
  } on Object catch (e) {
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    }
  }
}

class _SaveSheet extends StatefulWidget {
  const _SaveSheet();

  @override
  State<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<_SaveSheet> {
  final _name = TextEditingController();
  var _shared = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.of(context).pop((name, _shared));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.filterSaveTitle,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('save.ok'),
          label: l10n.filterSave,
          onPressed: _submit,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixTextField(
            label: l10n.filterName,
            controller: _name,
            autofocus: true,
            fieldKey: const Key('save.name'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: TixSpace.s3),
          TixSwitchRow(
            key: const Key('save.shared'),
            title: l10n.filterShared,
            subtitle: l10n.filterSharedHelp,
            value: _shared,
            onChanged: (v) => setState(() => _shared = v),
          ),
        ],
      ),
    );
  }
}

enum _FilterAction { rename, share, earlier, later, delete, pin }

/// Whether [filter] has a menu: the reader may change it, or this device can
/// put it on the home screen.
bool hasSavedFilterMenu(WidgetRef ref, SavedFilter filter) =>
    filter.editable || ref.watch(pinSupportedProvider).value == true;

/// The menu of a saved filter: changes the reader may make, and Add to home
/// screen where the launcher can pin it.
Future<void> manageSavedFilter(
  BuildContext context,
  WidgetRef ref,
  SavedFilter filter,
) async {
  final l10n = context.l10n;
  final pinnable = await ref.read(pinSupportedProvider.future);
  if (!context.mounted) return;
  final action = await showActionSheet<_FilterAction>(
    context,
    title: filter.name,
    actions: [
      if (pinnable)
        TixSheetAction(
          key: const Key('saved.pin'),
          value: _FilterAction.pin,
          label: l10n.pinToHome,
          icon: Icons.add_to_home_screen,
        ),
      if (filter.editable) ...[
        TixSheetAction(
          key: const Key('saved.rename'),
          value: _FilterAction.rename,
          label: l10n.filterRename,
          icon: Icons.edit_outlined,
        ),
        TixSheetAction(
          key: const Key('saved.share'),
          value: _FilterAction.share,
          label: filter.shared ? l10n.filterUnshare : l10n.filterShare,
          icon: filter.shared ? Icons.person_outline : Icons.group_outlined,
        ),
        if (filter.mine) ...[
          TixSheetAction(
            key: const Key('saved.earlier'),
            value: _FilterAction.earlier,
            label: l10n.boardMoveUp,
            icon: Icons.arrow_upward,
          ),
          TixSheetAction(
            key: const Key('saved.later'),
            value: _FilterAction.later,
            label: l10n.boardMoveDown,
            icon: Icons.arrow_downward,
          ),
        ],
        TixSheetAction(
          key: const Key('saved.delete'),
          value: _FilterAction.delete,
          label: l10n.filterDelete,
          icon: Icons.delete_outline,
          destructive: true,
        ),
      ],
    ],
  );
  if (action == null || !context.mounted) return;
  final filters = ref.read(savedFiltersProvider.notifier);
  try {
    switch (action) {
      case _FilterAction.pin:
        await pinToHomeScreen(
          context,
          ref,
          (ctx) => PinnedShortcut.savedFilter(
            context: ctx,
            id: filter.id,
            name: filter.name,
          ),
        );
      case _FilterAction.rename:
        final name = await askText(
          context,
          title: l10n.filterRename,
          label: l10n.filterName,
          action: l10n.filterRename,
          initial: filter.name,
        );
        if (name != null) await filters.rename(filter, name);
      case _FilterAction.share:
        await filters.share(filter, shared: !filter.shared);
      case _FilterAction.earlier:
        await filters.move(filter, -1);
      case _FilterAction.later:
        await filters.move(filter, 1);
      case _FilterAction.delete:
        final ok = await confirmDestructive(
          context,
          title: l10n.filterDeleteTitle(filter.name),
          body: l10n.filterDeleteBody,
          action: l10n.filterDelete,
        );
        if (ok) await filters.delete(filter);
    }
  } on Object catch (e) {
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    }
  }
}
