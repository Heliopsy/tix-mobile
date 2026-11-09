// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/settings/application/offline.dart';

/// [bytes] as a person reads a size: `512 B`, `1.5 KB`, `12.3 MB`.
String formatBytes(int bytes, String locale) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final number = unit == 0
      ? NumberFormat.decimalPattern(locale).format(bytes)
      : NumberFormat.decimalPatternDigits(
          locale: locale,
          decimalDigits: 1,
        ).format(value);
  return '$number ${units[unit]}';
}

/// [at] as a date and time in [locale].
String formatMoment(DateTime at, String locale) =>
    DateFormat.yMMMd(locale).add_Hm().format(at.toLocal());

/// What stays available offline for the active context, the room it takes,
/// and its sync.
class OfflineScreen extends ConsumerWidget {
  /// Creates the screen.
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    final where = session == null
        ? null
        : [
            session.instance.name,
            if (session.connection.tenantKey.isNotEmpty)
              session.connection.tenantLabel,
          ].join(' · ');
    final local = ref.watch(offlineIsLocalProvider);
    return TixPage(
      title: l10n.offlineTitle,
      subtitle: where,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s6),
        children: local
            ? [
                TixSection(
                  title: l10n.offlineTitle,
                  children: [
                    Padding(
                      key: const Key('offline.local'),
                      padding: const EdgeInsets.all(TixSpace.s3),
                      child: Text(l10n.offlineLocal),
                    ),
                  ],
                ),
              ]
            : const [
                _ChoiceSection(),
                _StorageSection(),
                _SyncSection(),
                _ConflictSection(),
              ],
      ),
    );
  }
}

class _ChoiceSection extends ConsumerWidget {
  const _ChoiceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final choice = ref.watch(offlineChoicesProvider);
    final choices = ref.read(offlineChoicesProvider.notifier);
    final projects = ref.watch(offlineProjectsProvider);
    return TixSection(
      title: l10n.offlineAvailableTitle,
      subtitle: l10n.offlineAvailableSubtitle,
      children: [
        TixSwitchRow(
          key: const Key('offline.mywork'),
          title: l10n.myWorkTitle,
          value: choice.myWork,
          onChanged: (on) => unawaited(choices.setMyWork(on: on)),
        ),
        TixSwitchRow(
          key: const Key('offline.starred'),
          title: l10n.starred,
          value: choice.starred,
          onChanged: (on) => unawaited(choices.setStarred(on: on)),
        ),
        ...projects.when(
          loading: () => [
            const SizedBox(
              height: 120,
              child: SkeletonList(rows: 3, leading: false),
            ),
          ],
          error: (e, _) => [
            ErrorState(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(offlineProjectsProvider),
            ),
          ],
          data: (list) => [
            for (final p in list)
              TixSwitchRow(
                key: Key('offline.project.${p.key}'),
                title: p.name.isEmpty ? p.key : p.name,
                subtitle: p.key,
                value: choice.projects.contains(p.key),
                onChanged: (on) => unawaited(choices.setProject(p.key, on: on)),
              ),
          ],
        ),
      ],
    );
  }
}

class _StorageSection extends ConsumerWidget {
  const _StorageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final size = ref.watch(offlineStorageProvider);
    final running = ref.watch(offlineSyncProvider.select((s) => s.running));
    return TixSection(
      title: l10n.offlineStorageTitle,
      subtitle: l10n.offlineStorageSubtitle,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Wrap(
            spacing: TixSpace.s3,
            runSpacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(key: const Key('offline.size'), switch (size) {
                AsyncData(:final value) => l10n.offlineStorageUsed(
                  formatBytes(value, locale),
                ),
                AsyncError() => l10n.offlineStorageUnknown,
                _ => l10n.offlineStorageCounting,
              }),
              TixButton.danger(
                key: const Key('offline.clear'),
                label: l10n.offlineClear,
                icon: Icons.delete_outline,
                onPressed: running
                    ? null
                    : () => unawaited(_clear(context, ref)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.offlineClearTitle,
      body: l10n.offlineClearBody,
      action: l10n.offlineClear,
    );
    if (!ok) return;
    await ref.read(offlineSyncProvider.notifier).clear();
    ref.invalidate(offlineStorageProvider);
  }
}

class _SyncSection extends ConsumerWidget {
  const _SyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final sync = ref.watch(offlineSyncProvider);
    final last = sync.lastSyncedAt;
    final error = sync.error;
    return TixSection(
      title: l10n.offlineSyncTitle,
      subtitle: l10n.offlineSyncSubtitle,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Wrap(
            spacing: TixSpace.s3,
            runSpacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                key: const Key('offline.last'),
                last == null
                    ? l10n.offlineNeverSynced
                    : l10n.offlineLastSynced(formatMoment(last, locale)),
              ),
              TixButton(
                key: const Key('offline.sync'),
                label: l10n.offlineSyncNow,
                icon: Icons.sync,
                busy: sync.running,
                onPressed: () =>
                    unawaited(ref.read(offlineSyncProvider.notifier).syncNow()),
              ),
            ],
          ),
        ),
        if (error != null && !sync.running)
          ErrorState(
            key: const Key('offline.error'),
            error: error,
            compact: true,
            onRetry: () =>
                unawaited(ref.read(offlineSyncProvider.notifier).syncNow()),
          ),
      ],
    );
  }
}

/// Keeps [OfflineSync] running while someone is signed in, so background
/// sync follows the active context. Mounted around the signed-in screens by
/// the router.
class OfflineSyncScope extends ConsumerWidget {
  /// Keeps sync running around [child].
  const OfflineSyncScope({required this.child, super.key});

  /// The signed-in screens.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(offlineSyncProvider, (_, _) {});
    return child;
  }
}

class _ConflictSection extends ConsumerWidget {
  const _ConflictSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final policy = ref.watch(conflictPolicySettingProvider);
    final waiting = ref.watch(
      syncStateProvider.select((s) => s.value?.entries.length ?? 0),
    );
    return TixSection(
      key: const Key('offline.conflicts'),
      title: l10n.syncConflictsTitle,
      subtitle: l10n.syncPolicyHelp,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.syncPolicyLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: TixSpace.s2),
              TixChoices<ConflictPolicy>(
                key: const Key('offline.policy'),
                choices: [
                  TixChoice(ConflictPolicy.ask, l10n.syncPolicyAsk),
                  TixChoice(ConflictPolicy.keepMine, l10n.syncPolicyMine),
                  TixChoice(ConflictPolicy.keepTheirs, l10n.syncPolicyTheirs),
                ],
                selected: policy,
                onSelected: (p) => unawaited(
                  ref.read(conflictPolicySettingProvider.notifier).set(p),
                ),
              ),
              const SizedBox(height: TixSpace.s3),
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                children: [
                  TixButton(
                    key: const Key('offline.openConflicts'),
                    label: l10n.syncOpenConflicts,
                    icon: Icons.call_split,
                    onPressed: () => context.go(Routes.conflicts),
                  ),
                  if (waiting > 0)
                    TixButton.danger(
                      key: const Key('offline.discardAll'),
                      label: l10n.syncDiscardAll,
                      onPressed: () async {
                        final ok = await confirmDestructive(
                          context,
                          title: l10n.syncDiscardAllTitle,
                          body: l10n.syncDiscardAllBody(waiting),
                          action: l10n.syncDiscard,
                        );
                        if (ok) {
                          await ref
                              .read(outboxSyncProvider.notifier)
                              .discardAll();
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
