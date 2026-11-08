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

/// The reader's saved filters, then the ones shared with them, each with
/// the same menu the task list offers. Opened from Settings.
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
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: TixSpace.s3),
                children: [for (final f in filters) _FilterTile(f)],
              ),
      ),
    );
  }
}

class _FilterTile extends ConsumerWidget {
  const _FilterTile(this.filter);

  final SavedFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
        filter.editable
            ? filter.query
            : '${filter.query}\n${l10n.savedFilterTheirs}',
        style: tixMono(context, size: TixText.xs),
      ),
      trailing: filter.editable ? const Icon(Icons.more_vert) : null,
      onTap: filter.editable
          ? () => manageSavedFilter(context, ref, filter)
          : null,
    );
  }
}
