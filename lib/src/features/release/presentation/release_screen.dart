// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/release/application/release.dart';

/// What the active server runs, whether it is up to date, how to upgrade it
/// and what changed, as tix's web Release screen. The check is the server's,
/// cached and six-hourly; the app never asks the release feed itself.
class ReleaseScreen extends ConsumerWidget {
  /// Creates the screen.
  const ReleaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final release = ref.watch(serverReleaseProvider);
    return TixPage(
      title: l10n.releaseTitle,
      subtitle: l10n.releaseIntro,
      body: AsyncBody(
        value: release,
        onRetry: () => ref.invalidate(serverReleaseProvider),
        data: (r) => RefreshIndicator(
          onRefresh: () => ref.refresh(serverReleaseProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: TixSpace.s7),
            children: [
              _Status(release: r),
              if (r.methods.isNotEmpty) _Upgrade(methods: r.methods),
              if (r.notes.isNotEmpty)
                TixSection(
                  key: const Key('release.notes'),
                  title: l10n.releaseWhatChanged(r.latest),
                  subtitle: l10n.releaseNotesNote,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(TixSpace.s3),
                      child: TixMarkdown(data: r.notes),
                    ),
                  ],
                ),
              _Changes(release: r),
            ],
          ),
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.release});

  final ReleaseBody release;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final r = release;
    final (badge, tone, heading, line) = switch (r.status) {
      'newer' => (
        l10n.releaseUpdateAvailable,
        TixTone.accent,
        l10n.releaseAvailable(r.latest),
        l10n.releaseRunsOlder(r.running),
      ),
      'current' => (
        l10n.releaseUpToDate,
        TixTone.ok,
        l10n.releaseCurrentTitle,
        l10n.releaseNewest(r.latest),
      ),
      'unknown' => (
        l10n.releaseNotComparable,
        TixTone.neutral,
        l10n.releaseUnknownTitle,
        l10n.releaseUnknown(r.latest, r.running),
      ),
      'failed' => (
        l10n.releaseCheckFailed,
        TixTone.neutral,
        l10n.releaseFailedTitle,
        l10n.releaseFailed,
      ),
      _ => (
        l10n.releaseNotChecked,
        TixTone.neutral,
        l10n.releasePendingTitle,
        l10n.releasePending,
      ),
    };
    return TixSection(
      key: Key('release.status.${r.status}'),
      title: l10n.releaseStatus,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TixBadge(badge, tone: tone),
              const SizedBox(height: TixSpace.s2),
              Text(heading, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TixSpace.s1),
              Text(line, style: TextStyle(color: t.muted)),
              const SizedBox(height: TixSpace.s3),
              TixPropertyList(
                children: [
                  TixPropertyRow(
                    label: l10n.releaseRunningHere,
                    child: Text(
                      'v${r.running}',
                      key: const Key('release.running'),
                    ),
                  ),
                  TixPropertyRow(
                    label: l10n.releaseNewestPublished,
                    child: r.latest.isEmpty
                        ? Text(
                            l10n.releaseNotKnown,
                            style: TextStyle(color: t.muted),
                          )
                        : Text(
                            'v${r.latest}',
                            key: const Key('release.latest'),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: TixSpace.s2),
              Text(
                l10n.releaseCheckedNote,
                style: TextStyle(color: t.muted, fontSize: TixText.sm),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Upgrade extends StatelessWidget {
  const _Upgrade({required this.methods});

  final List<ReleaseMethod> methods;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    return TixSection(
      key: const Key('release.upgrade'),
      title: l10n.releaseHowToUpgrade,
      subtitle: l10n.releaseUpgradeNote,
      children: [
        for (final m in methods)
          Padding(
            key: Key('release.method.${m.id}'),
            padding: const EdgeInsets.all(TixSpace.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _name(l10n, m),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  _help(l10n, m),
                  style: TextStyle(color: t.muted, fontSize: TixText.sm),
                ),
                const SizedBox(height: TixSpace.s2),
                Container(
                  padding: const EdgeInsetsDirectional.only(start: TixSpace.s3),
                  decoration: BoxDecoration(
                    color: t.surface,
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(TixRadius.md),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          m.command,
                          key: Key('release.command.${m.id}'),
                          style: tixMono(context, size: TixText.sm),
                        ),
                      ),
                      TixIconButton(
                        key: Key('release.copy.${m.id}'),
                        icon: Icons.copy,
                        tooltip: l10n.copyToClipboard,
                        onPressed: () {
                          unawaited(
                            Clipboard.setData(ClipboardData(text: m.command)),
                          );
                          showTixToast(context, l10n.copiedToClipboard);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Text(
            l10n.releasePackageManager,
            style: TextStyle(color: t.muted, fontSize: TixText.sm),
          ),
        ),
      ],
    );
  }

  static String _name(AppLocalizations l10n, ReleaseMethod m) => switch (m.id) {
    'binary' => l10n.releaseMethodBinary,
    'container' => l10n.releaseMethodContainer,
    'go' => l10n.releaseMethodGo,
    _ => m.name,
  };

  static String _help(AppLocalizations l10n, ReleaseMethod m) => switch (m.id) {
    'binary' => l10n.releaseMethodBinaryHelp,
    'container' => l10n.releaseMethodContainerHelp,
    'go' => l10n.releaseMethodGoHelp,
    _ => m.help,
  };
}

class _Changes extends StatelessWidget {
  const _Changes({required this.release});

  final ReleaseBody release;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = release.changes ?? const ReleaseChanges();
    final running = c.running;
    final String lead;
    if (running != null) {
      lead = l10n.releaseChangesRunning;
    } else if (c.earlier.isEmpty) {
      lead = l10n.releaseNoChangelog;
    } else if (c.untagged) {
      lead = l10n.releaseUntagged(release.running);
    } else {
      lead = l10n.releaseNoEntry(release.running);
    }
    return TixSection(
      key: const Key('release.changes'),
      title: l10n.releaseWhatsNew,
      subtitle: lead,
      children: [
        if (running != null) _Entry(entry: running, running: true, open: true),
        for (var i = 0; i < c.earlier.length; i++)
          _Entry(
            entry: c.earlier[i],
            running: false,
            open: running == null && i == 0,
          ),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.entry,
    required this.running,
    required this.open,
  });

  final ReleaseEntry entry;
  final bool running;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    return ExpansionTile(
      key: Key('release.entry.${entry.version}'),
      initiallyExpanded: open,
      title: Wrap(
        spacing: TixSpace.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('v${entry.version}'),
          if (entry.date.isNotEmpty)
            Text(entry.date, style: TextStyle(color: t.muted)),
          if (running) TixBadge(l10n.releaseYouRun, tone: TixTone.accent),
        ],
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        0,
        TixSpace.s4,
        TixSpace.s3,
      ),
      children: [TixMarkdown(data: entry.notes)],
    );
  }
}
