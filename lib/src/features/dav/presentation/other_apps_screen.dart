// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/help/screen_help.dart';
import 'package:tix_mobile/src/core/l10n/dates.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/dav/application/dav.dart';
import 'package:tix_mobile/src/features/dav/presentation/dav_details.dart';
import 'package:tix_mobile/src/features/dav/presentation/dav_setup_sheet.dart';

/// The first tix release whose server answers CalDAV.
const davFirstTixRelease = '0.69.0';

/// Tasks in other apps: hands the active context's tasks to Reminders,
/// DAVx5 or Thunderbird over CalDAV with an app password, and lists and
/// revokes those passwords.
class OtherAppsScreen extends ConsumerWidget {
  /// Creates the screen.
  const OtherAppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(davStatusProvider);
    final ready = switch (status.value) {
      final DavReady r => r,
      _ => null,
    };
    final setUp = ready == null
        ? null
        : TixAction(
            key: const Key('dav.setUp'),
            label: l10n.davSetUp,
            icon: Icons.add,
            onPressed: () => unawaited(openDavSetup(context, ref, ready)),
          );
    return TixPage(
      title: l10n.davTitle,
      subtitle: l10n.davSubtitle,
      primaryAction: setUp,
      body: AsyncBody(
        value: status,
        onRetry: () => ref.invalidate(davStatusProvider),
        data: (s) => switch (s) {
          DavLocal() => EmptyState(
            key: const Key('dav.local'),
            icon: Icons.phonelink_off_outlined,
            title: l10n.davLocalTitle,
            body: l10n.davLocalBody,
          ),
          DavNotOffered() => EmptyState(
            key: const Key('dav.old'),
            icon: Icons.update_outlined,
            title: l10n.davOldTitle,
            body: l10n.davOldBody(davFirstTixRelease),
          ),
          DavNotAllowed(:final message, :final token) => EmptyState(
            key: const Key('dav.forbidden'),
            icon: Icons.block_outlined,
            title: l10n.davForbiddenTitle,
            body: [
              if (message.isEmpty) l10n.davForbiddenBody else message,
              if (token) l10n.davForbiddenToken,
            ].join('\n\n'),
          ),
          DavOff(:final reason) => ListView(
            key: const Key('dav.off'),
            padding: const EdgeInsets.only(bottom: TixSpace.s7),
            children: [
              Padding(
                padding: const EdgeInsets.all(TixSpace.s4),
                child: TixNotice(
                  reason.isEmpty ? l10n.davOffBody : reason,
                  title: l10n.davOffTitle,
                  tone: TixNoticeTone.warn,
                ),
              ),
              const _Passwords(ready: null),
            ],
          ),
          final DavReady r => _Ready(ready: r, setUp: setUp!),
        },
      ),
    );
  }
}

/// Opens the setup sheet against [ready]. With [replacing], offers to
/// revoke that password once the new one is handed off.
Future<void> openDavSetup(
  BuildContext context,
  WidgetRef ref,
  DavReady ready, {
  DavPassword? replacing,
}) async {
  final issued = await showTixSheet<bool>(
    context,
    dismissible: false,
    builder: (_) => DavSetupSheet(ready: ready, replacing: replacing),
  );
  if (issued != true || replacing == null || !context.mounted) return;
  final l10n = context.l10n;
  final ok = await confirmDestructive(
    context,
    title: l10n.davReplaceRevokeTitle(replacing.name),
    body: l10n.davReplaceRevokeBody,
    action: l10n.davRevokeNamed(replacing.name),
  );
  if (!ok || !context.mounted) return;
  await _revoke(context, ref, replacing);
}

Future<void> _revoke(
  BuildContext context,
  WidgetRef ref,
  DavPassword password,
) async {
  final l10n = context.l10n;
  try {
    await ref.read(appPasswordsProvider.notifier).revoke(password);
    if (context.mounted) {
      showTixToast(context, l10n.davRevokedToast(password.name));
    }
  } on TixException catch (e) {
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    }
  }
}

class _Ready extends StatelessWidget {
  const _Ready({required this.ready, required this.setUp});

  final DavReady ready;
  final TixAction setUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListView(
      key: const Key('dav.ready'),
      padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TixSpace.s4,
            TixSpace.s3,
            TixSpace.s4,
            TixSpace.s2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.davLead, style: theme.textTheme.bodyMedium),
              const SizedBox(height: TixSpace.s2),
              Text(
                ready.write ? l10n.davLeadWrite : l10n.davLeadRead,
                key: const Key('dav.lead.mode'),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: TixSpace.s2),
              Text(
                l10n.davPrivacy,
                key: const Key('dav.privacy'),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        TixSection(
          title: l10n.davDetails,
          info: l10n.davDetailsInfo,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TixSpace.s4,
                vertical: TixSpace.s2,
              ),
              child: DavDetails(
                address: ready.address,
                username: ready.info.username,
              ),
            ),
          ],
        ),
        _Passwords(ready: ready, setUp: setUp),
        const _Guides(),
      ],
    );
  }
}

class _Passwords extends ConsumerWidget {
  const _Passwords({required this.ready, this.setUp});

  final DavReady? ready;
  final TixAction? setUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final list = ref.watch(appPasswordsProvider);
    return TixSection(
      title: l10n.davPasswords,
      info: l10n.davPasswordsInfo,
      children: [
        AsyncBody(
          value: list,
          onRetry: () => ref.invalidate(appPasswordsProvider),
          loading: const Padding(
            padding: EdgeInsets.all(TixSpace.s4),
            child: SkeletonBox(height: TixSpace.s7),
          ),
          data: (items) => items.isEmpty
              ? EmptyState(
                  key: const Key('dav.none'),
                  icon: Icons.key_outlined,
                  title: l10n.davPasswordsEmpty,
                  action: setUp,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final p in items)
                      DavPasswordTile(password: p, ready: ready),
                  ],
                ),
        ),
      ],
    );
  }
}

/// One app password: its name, state, lists and dates, and Revoke; Replace
/// for a read-only one once the server takes writes.
class DavPasswordTile extends ConsumerWidget {
  /// Draws [password]; [ready] is null while CalDAV is off.
  const DavPasswordTile({required this.password, this.ready, super.key});

  /// The password, metadata only.
  final DavPassword password;

  /// What the server answered, when it serves CalDAV.
  final DavReady? ready;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final now = ref.watch(clockProvider)();
    final state = davPasswordState(password, now);
    final live = state == DavPasswordState.live;
    final ready = this.ready;
    final replaceable =
        live && ready != null && ready.write && password.readOnly;
    final created = password.createdAt;
    final expires = password.expiresAt;
    final used = password.lastUsedAt;
    return Container(
      key: Key('dav.password.${password.id}'),
      padding: const EdgeInsets.all(TixSpace.s4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                password.name,
                style: const TextStyle(
                  fontSize: TixText.md,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TixBadge(
                switch (state) {
                  DavPasswordState.live => l10n.davStateLive,
                  DavPasswordState.expired => l10n.davStateExpired,
                  DavPasswordState.revoked => l10n.davStateRevoked,
                },
                key: Key('dav.password.${password.id}.state'),
                tone: switch (state) {
                  DavPasswordState.live => TixTone.ok,
                  DavPasswordState.expired => TixTone.warn,
                  DavPasswordState.revoked => TixTone.neutral,
                },
              ),
              if (replaceable)
                TixBadge(
                  l10n.davReadOnly,
                  key: Key('dav.password.${password.id}.readOnly'),
                  tone: TixTone.warn,
                ),
            ],
          ),
          const SizedBox(height: TixSpace.s1),
          Text(
            [
              davCollectionsLabel(l10n, password.collections),
              if (created != null)
                l10n.davCreatedOn(formatDay(context, created)),
              if (expires == null)
                l10n.davNeverExpires
              else
                l10n.davExpiresOn(formatDay(context, expires)),
              if (used == null)
                l10n.davNotUsed
              else
                l10n.davLastUsed(formatMoment(context, used)),
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (live) ...[
            const SizedBox(height: TixSpace.s2),
            Wrap(
              spacing: TixSpace.s2,
              runSpacing: TixSpace.s2,
              children: [
                if (replaceable)
                  TixButton(
                    key: Key('dav.password.${password.id}.replace'),
                    label: l10n.davReplace,
                    size: TixButtonSize.small,
                    onPressed: () => unawaited(
                      openDavSetup(context, ref, ready, replacing: password),
                    ),
                  ),
                TixButton.danger(
                  key: Key('dav.password.${password.id}.revoke'),
                  label: l10n.davRevoke,
                  size: TixButtonSize.small,
                  onPressed: () => _confirmRevoke(context, ref),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRevoke(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.davRevokeTitle(password.name),
      body: l10n.davRevokeBody,
      action: l10n.davRevokeNamed(password.name),
    );
    if (!ok || !context.mounted) return;
    await _revoke(context, ref, password);
  }
}

class _Guides extends ConsumerWidget {
  const _Guides();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    Widget guide(String key, String label, String anchor) => ListTile(
      key: Key('dav.guide.$key'),
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(label),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => unawaited(openDocs(ref, DocSection('caldav.md', anchor))),
    );
    return TixSection(
      title: l10n.davGuides,
      children: [
        guide('reminders', l10n.davGuideReminders, 'apple-reminders'),
        guide('davx5', l10n.davGuideDavx5, 'davx5-and-tasksorg'),
        guide('thunderbird', l10n.davGuideThunderbird, 'thunderbird'),
        guide('evolution', l10n.davGuideEvolution, 'evolution'),
        guide(
          'troubleshooting',
          l10n.davGuideTroubleshooting,
          'troubleshooting',
        ),
      ],
    );
  }
}
