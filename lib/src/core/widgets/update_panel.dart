// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/update/updates.dart';

/// Where updates stand, with Check now, Restart to update, Download and
/// What's new as they apply. Shown in Settings and About; empty where
/// updates are off.
class UpdatePanel extends ConsumerWidget {
  /// Creates the panel.
  const UpdatePanel({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, Uri uri) async {
    final failed = context.l10n.aboutOpenFailed;
    final ok = await ref.read(attachmentsProvider).openLink(uri);
    if (!ok && context.mounted) {
      showTixToast(context, failed, tone: TixTone.danger);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(updateModeProvider).value ?? UpdateMode.off;
    if (mode == UpdateMode.off) return const SizedBox.shrink();
    final l10n = context.l10n;
    final s = ref.watch(updatesProvider);
    final auto = ref.watch(autoInstallSettingProvider);
    final running = ref.watch(appInfoProvider).value?.version ?? '';
    final offer = s.offer;
    final version = offer?.version.toString() ?? '';
    final (status, help) = switch (s.phase) {
      UpdatePhase.idle => (l10n.updateIdle, null),
      UpdatePhase.checking => (l10n.updateChecking, null),
      UpdatePhase.current => (l10n.updateCurrent(running), null),
      UpdatePhase.available => (
        l10n.updateAvailable(version),
        s.error == UpdateErrorKind.noAsset
            ? l10n.updateNoAsset
            : l10n.updateAvailableHelp,
      ),
      UpdatePhase.downloading => (
        l10n.updateDownloading(version, ((s.progress ?? 0) * 100).round()),
        null,
      ),
      UpdatePhase.ready => (
        l10n.updateReady(version),
        auto ? l10n.updateReadyAuto : null,
      ),
      UpdatePhase.failed => (
        switch (s.error) {
          UpdateErrorKind.unverified => l10n.updateFailedVerify,
          UpdateErrorKind.install => l10n.updateFailedInstall,
          UpdateErrorKind.noAsset => l10n.updateNoAsset,
          UpdateErrorKind.network || null => l10n.updateFailedNetwork,
        },
        offer == null ? null : l10n.updateAvailable(version),
      ),
    };
    final idle = !const {
      UpdatePhase.checking,
      UpdatePhase.downloading,
      UpdatePhase.ready,
    }.contains(s.phase);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            key: const Key('update.status'),
            style: theme.textTheme.bodyLarge,
          ),
          if (help != null)
            Text(
              help,
              key: const Key('update.help'),
              style: theme.textTheme.bodySmall,
            ),
          if (s.phase == UpdatePhase.downloading) ...[
            const SizedBox(height: TixSpace.s2),
            LinearProgressIndicator(value: s.progress),
          ],
          const SizedBox(height: TixSpace.s3),
          Wrap(
            spacing: TixSpace.s3,
            runSpacing: TixSpace.s2,
            children: [
              if (s.phase == UpdatePhase.ready)
                TixButton.primary(
                  key: const Key('update.restart'),
                  label: l10n.updateRestart,
                  icon: Icons.restart_alt,
                  onPressed: () =>
                      unawaited(ref.read(updatesProvider.notifier).restart()),
                ),
              if (offer != null &&
                  s.phase != UpdatePhase.ready &&
                  s.phase != UpdatePhase.downloading)
                TixButton(
                  key: const Key('update.download'),
                  label: l10n.updateDownload,
                  icon: Icons.download_outlined,
                  onPressed: () => unawaited(_open(context, ref, offer.page)),
                ),
              if (offer != null)
                TixButton.quiet(
                  key: const Key('update.notes'),
                  label: l10n.updateWhatsNew,
                  icon: Icons.open_in_new,
                  onPressed: () => unawaited(_open(context, ref, offer.page)),
                ),
              TixButton.quiet(
                key: const Key('update.check'),
                label: l10n.updateCheckNow,
                icon: Icons.refresh,
                busy: s.phase == UpdatePhase.checking,
                onPressed: idle
                    ? () =>
                          unawaited(ref.read(updatesProvider.notifier).check())
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
