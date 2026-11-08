// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/dates.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/repositories/account_repository.dart';
import 'package:tix_mobile/src/features/account/application/account.dart';

/// Who I am: my profile, the tenants I belong to and, when this credential
/// may read it, my account's history.
class AccountScreen extends ConsumerWidget {
  /// Creates the screen.
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return TixPage(
      title: l10n.accountTitle,
      body: AsyncBody(
        value: ref.watch(currentAccessProvider),
        onRetry: () => ref.invalidate(currentAccessProvider),
        data: (access) {
          final me = access.actor;
          final head = _Profile(me: me, access: access);
          if (!access.can(Scopes.accountRead)) {
            return ListView(
              padding: const EdgeInsets.only(bottom: TixSpace.s7),
              children: [
                head,
                SectionHeader(title: l10n.accountHistory),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
                  child: Text(
                    l10n.accountHistoryNotReadable,
                    key: const Key('account.noHistory'),
                  ),
                ),
              ],
            );
          }
          return _History(head: head);
        },
      ),
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.head});

  final Widget head;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final log = ref.watch(accountLogProvider);
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        head,
        SectionHeader(
          title: l10n.accountHistory,
          subtitle: l10n.accountHistoryHelp,
        ),
      ],
    );
    return switch (log) {
      AsyncValue(:final value?) => PagedListView<AccountLogEntry>(
        paged: value,
        header: header,
        padding: const EdgeInsets.only(bottom: TixSpace.s7),
        empty: EmptyState(icon: Icons.history, title: l10n.accountHistoryEmpty),
        onRefresh: () async {
          ref.invalidate(currentAccessProvider);
          return await ref.refresh(accountLogProvider.future);
        },
        onLoadMore: () => ref.read(accountLogProvider.notifier).loadMore(),
        itemBuilder: (context, e) => _Entry(entry: e),
      ),
      AsyncError(:final error) => ListView(
        children: [
          header,
          ErrorState(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(accountLogProvider),
          ),
        ],
      ),
      _ => ListView(
        children: [header, const SkeletonList(rows: 4, inline: true)],
      ),
    };
  }
}

class _Profile extends ConsumerWidget {
  const _Profile({required this.me, required this.access});

  final Actor me;
  final Access access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final role = me.role;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Row(
            children: [
              TixAvatar(label: me.label, seed: me.handle, hued: true, size: 48),
              const SizedBox(width: TixSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      me.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (me.handle.isNotEmpty)
                      Text('@${me.handle}', style: tixMono(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
          child: TixPropertyList(
            children: [
              if (me.email.isNotEmpty)
                TixPropertyRow(
                  label: l10n.emailLabel,
                  child: SelectableText(me.email),
                ),
              TixPropertyRow(
                label: l10n.accountKind,
                child: Text(
                  access.isToken
                      ? l10n.accountKindToken
                      : me.kind == ActorKind.agent
                      ? l10n.accountKindAgent
                      : l10n.accountKindPerson,
                ),
              ),
              if (role != null)
                TixPropertyRow(
                  label: l10n.peopleRole,
                  child: Text(switch (role) {
                    Role.viewer => l10n.roleViewer,
                    Role.member => l10n.roleMember,
                    Role.admin => l10n.roleAdmin,
                  }),
                ),
              if (me.scopes.isNotEmpty)
                TixPropertyRow(
                  label: l10n.tokensScopes,
                  child: Text(me.scopes.join(' '), style: tixMono(context)),
                ),
              if (me.globalAdmin)
                TixPropertyRow(
                  label: l10n.accountGlobalAdmin,
                  child: Text(l10n.accountGlobalAdminYes),
                ),
            ],
          ),
        ),
        if (me.memberships.isNotEmpty)
          TixSection(
            key: const Key('account.memberships'),
            title: l10n.accountMemberships,
            subtitle: l10n.accountMembershipsHelp,
            children: [
              for (final m in me.memberships)
                ListTile(
                  key: Key('membership.${m.tenantKey}'),
                  leading: TixAvatar(
                    label: m.tenantName.isEmpty ? m.tenantKey : m.tenantName,
                    seed: m.tenantKey,
                    hued: true,
                    size: 32,
                  ),
                  title: Text(
                    m.tenantName.isEmpty ? m.tenantKey : m.tenantName,
                  ),
                  subtitle: Text(
                    [
                      m.tenantKey,
                      if (m.handle.isNotEmpty) '@${m.handle}',
                      if (m.host.isNotEmpty) m.host,
                    ].join(' · '),
                  ),
                  trailing: Wrap(
                    spacing: TixSpace.s1,
                    children: [
                      if (m.tenantKey == me.tenantKey)
                        TixBadge(l10n.accountCurrent, tone: TixTone.accent),
                      if (m.role case final r?)
                        TixBadge(switch (r) {
                          Role.viewer => l10n.roleViewer,
                          Role.member => l10n.roleMember,
                          Role.admin => l10n.roleAdmin,
                        }),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.entry});

  final AccountLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final when = entry.occurredAt;
    return Container(
      key: Key('log.${entry.seq}'),
      padding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s4,
        vertical: TixSpace.s3,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                entry.action,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (entry.tenantKey.isNotEmpty)
                Text(entry.tenantKey, style: tixMono(context)),
            ],
          ),
          Text(
            [
              if (when != null) formatMoment(context, when),
              if (entry.byEmail.isEmpty)
                l10n.accountBySystem
              else
                l10n.accountBy(entry.byEmail),
              if (entry.byGlobalAdmin) l10n.accountGlobalAdmin,
              if (entry.via.isNotEmpty) entry.via,
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (entry.detail.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s1),
            Wrap(
              spacing: TixSpace.s1,
              runSpacing: TixSpace.s1,
              children: [
                for (final MapEntry(:key, :value) in entry.detail.entries)
                  TixBadge('$key: $value'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
