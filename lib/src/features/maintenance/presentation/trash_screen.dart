// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/scopes.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/maintenance/application/maintenance.dart';

/// The tasks in the tenant's trash, each with Restore and, for a credential
/// holding `task:delete`, Delete for good after a confirmation.
class TrashScreen extends ConsumerWidget {
  /// Creates the screen.
  const TrashScreen({super.key});

  Future<void> _restore(BuildContext context, WidgetRef ref, Task task) async {
    final l10n = context.l10n;
    try {
      await ref.read(trashProvider.notifier).restore(task);
      if (context.mounted) {
        showTixToast(context, l10n.trashRestored(task.ref));
      }
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _purge(BuildContext context, WidgetRef ref, Task task) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.trashPurgeTitle,
      body: l10n.trashPurgeBody(task.ref, task.title),
      action: l10n.trashPurge,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(trashProvider.notifier).purge(task);
      if (context.mounted) {
        showTixToast(context, l10n.trashPurged(task.ref));
      }
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final canPurge =
        ref.watch(currentAccessProvider).value?.can(Scopes.taskDelete) ?? false;
    return TixPage(
      title: l10n.trashTitle,
      subtitle: l10n.trashSubtitle,
      body: AsyncBody(
        value: ref.watch(trashProvider),
        onRetry: () => ref.invalidate(trashProvider),
        data: (paged) => PagedListView(
          paged: paged,
          header: Padding(
            padding: const EdgeInsets.all(TixSpace.s4),
            child: Text(l10n.trashExplain, style: theme.textTheme.bodySmall),
          ),
          empty: EmptyState(
            icon: Icons.delete_outline,
            title: l10n.trashEmpty,
            body: l10n.trashEmptyBody,
          ),
          onRefresh: () => ref.refresh(trashProvider.future),
          onLoadMore: () => ref.read(trashProvider.notifier).loadMore(),
          itemBuilder: (context, task) {
            final deleted = task.deletedAt;
            return ListTile(
              key: Key('trash.${task.ref}'),
              title: Text(task.title),
              isThreeLine: true,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      task.ref,
                      if (deleted != null)
                        l10n.trashDeletedAt(context.times.style.date(deleted)),
                    ].join(' · '),
                  ),
                  const SizedBox(height: TixSpace.s2),
                  Wrap(
                    spacing: TixSpace.s2,
                    runSpacing: TixSpace.s2,
                    children: [
                      TixButton(
                        key: Key('trash.${task.ref}.restore'),
                        label: l10n.trashRestore,
                        icon: Icons.restore_from_trash_outlined,
                        size: TixButtonSize.small,
                        onPressed: () => _restore(context, ref, task),
                      ),
                      if (canPurge)
                        TixButton.danger(
                          key: Key('trash.${task.ref}.purge'),
                          label: l10n.trashPurge,
                          icon: Icons.delete_forever_outlined,
                          size: TixButtonSize.small,
                          onPressed: () => _purge(context, ref, task),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
