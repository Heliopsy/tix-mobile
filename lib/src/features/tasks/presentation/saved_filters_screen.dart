// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/saved_filter.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/filter_panel.dart';

/// The reader's saved filters, which drag into order, then the ones shared
/// with them, each with the same menu the task list offers. Opened from
/// Settings.
class SavedFiltersScreen extends ConsumerWidget {
  /// Creates the screen.
  const SavedFiltersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return TixPage(
      title: l10n.settingsFiltersTitle,
      subtitle: l10n.settingsScopeAccount,
      body: AsyncBody(
        value: ref.watch(savedFiltersProvider),
        onRetry: () => ref.invalidate(savedFiltersProvider),
        data: (filters) => filters.isEmpty
            ? EmptyState(
                icon: Icons.filter_list,
                title: l10n.savedFiltersEmpty,
                body: l10n.savedFiltersEmptyBody,
                action: TixAction(
                  label: l10n.goTasks,
                  icon: Icons.checklist,
                  onPressed: () => context.go(Routes.tasks),
                ),
              )
            : _FilterList(filters),
      ),
    );
  }
}

class _FilterList extends ConsumerWidget {
  const _FilterList(this.filters);

  final List<SavedFilter> filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final own = [
      for (final f in filters)
        if (f.mine) f,
    ];
    final shared = [
      for (final f in filters)
        if (!f.mine) f,
    ];
    final reorderable = own.length > 1;
    return ReorderableListView(
      key: const Key('savedFilters.list'),
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: TixSpace.s3),
      header: reorderable
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                TixSpace.s4,
                0,
                TixSpace.s4,
                TixSpace.s2,
              ),
              child: Text(
                l10n.savedFiltersOrderHelp,
                style: TextStyle(
                  fontSize: TixText.sm,
                  color: context.tix.muted,
                ),
              ),
            )
          : null,
      footer: shared.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final f in shared) _FilterTile(f)],
            ),
      onReorderItem: (from, to) async {
        try {
          await ref.read(savedFiltersProvider.notifier).reorder(from, to);
        } on Object catch (e) {
          if (context.mounted) {
            showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
          }
        }
      },
      children: [
        for (final (i, f) in own.indexed)
          _FilterTile(
            f,
            key: ValueKey(f.id),
            dragIndex: reorderable ? i : null,
          ),
      ],
    );
  }
}

class _FilterTile extends ConsumerWidget {
  const _FilterTile(this.filter, {this.dragIndex, super.key});

  final SavedFilter filter;

  /// The filter's place among the reader's own, when it drags.
  final int? dragIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = TaskView.named(filter.view);
    final menu = hasSavedFilterMenu(ref, filter);
    final index = dragIndex;
    return ListTile(
      key: Key('savedFilter.${filter.id}'),
      leading: Icon(filter.shared ? Icons.group_outlined : Icons.filter_list),
      title: Wrap(
        spacing: TixSpace.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(filter.name),
          if (filter.shared) TixBadge(l10n.savedFilterSharedBadge),
        ],
      ),
      subtitle: Text(
        [
          filter.query,
          if (view != null) l10n.savedFilterView(taskViewLabel(l10n, view)),
          if (!filter.editable) l10n.savedFilterTheirs,
        ].join('\n'),
        style: tixMono(context, size: TixText.xs),
      ),
      trailing: menu || index != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (menu) const Icon(Icons.more_vert),
                if (index != null)
                  ReorderableDragStartListener(
                    key: Key('savedFilter.drag.${filter.id}'),
                    index: index,
                    child: Tooltip(
                      message: l10n.savedFilterDrag(filter.name),
                      child: SizedBox.square(
                        dimension: TixSize.target,
                        child: Icon(
                          Icons.drag_handle,
                          color: context.tix.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : null,
      onTap: menu ? () => manageSavedFilter(context, ref, filter) : null,
    );
  }
}
