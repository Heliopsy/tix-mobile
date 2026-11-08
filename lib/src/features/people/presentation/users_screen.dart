// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/dates.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/repositories/people_repository.dart';
import 'package:tix_mobile/src/features/people/application/people.dart';
import 'package:tix_mobile/src/features/people/presentation/people_sheets.dart';

/// The tenant's accounts with their roles, and the invites not used yet.
class UsersScreen extends ConsumerWidget {
  /// Creates the screen.
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value;
    final users = ref.watch(usersProvider);
    final counts = users.value?.counts;
    final add = TixAction(
      key: const Key('people.add'),
      label: l10n.peopleAdd,
      icon: Icons.add,
      onPressed: () => showCreateUserSheet(context),
    );
    return CommandScope(
      commands: [
        TixCommand(
          id: 'people.new',
          label: l10n.peopleAdd,
          group: l10n.peopleTitle,
          icon: Icons.add,
          run: add.onPressed,
        ),
      ],
      child: TixPage(
        title: l10n.peopleTitle,
        subtitle: counts == null
            ? null
            : counts.$2 == 0
            ? l10n.peopleActive(counts.$1)
            : '${l10n.peopleActive(counts.$1)} · '
                  '${l10n.peopleDisabledCount(counts.$2)}',
        primaryAction: add,
        actions: [
          if (access?.can(Scopes.tenantAdmin) ?? false)
            TixIconButton(
              key: const Key('people.addMember'),
              icon: Icons.group_add_outlined,
              tooltip: l10n.peopleAddMember,
              onPressed: () => showAddMemberSheet(context),
            ),
        ],
        body: AsyncBody(
          value: users,
          onRetry: () => ref.invalidate(usersProvider),
          data: (view) => PagedListView(
            paged: view.people,
            header: const _InvitesSection(),
            padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
            empty: EmptyState(
              icon: Icons.people_outline,
              title: l10n.peopleEmpty,
              action: add,
            ),
            onRefresh: () async {
              ref.invalidate(invitesProvider);
              return await ref.refresh(usersProvider.future);
            },
            onLoadMore: () => ref.read(usersProvider.notifier).loadMore(),
            itemBuilder: (context, person) => PersonTile(
              person: person,
              rolesKnown: view.rolesKnown,
              self: person.user.id == access?.me.id,
            ),
          ),
        ),
      ),
    );
  }
}

/// One account in the list: initials, name, email, role and state.
class PersonTile extends StatelessWidget {
  /// Draws [person]; [self] marks the caller's own account.
  const PersonTile({
    required this.person,
    required this.rolesKnown,
    this.self = false,
    super.key,
  });

  /// The account.
  final Person person;

  /// Whether the role is known; without memberships it is left out.
  final bool rolesKnown;

  /// Whether this is the caller.
  final bool self;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final role = person.role;
    return InkWell(
      key: Key('person.${person.user.id}'),
      onTap: () => context.push(Routes.user(person.user.id)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: TixSpace.s4,
          vertical: TixSpace.s3,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: Opacity(
          opacity: person.disabled ? 0.6 : 1,
          child: Row(
            children: [
              TixAvatar(
                label: person.label,
                seed: person.user.email,
                hued: true,
              ),
              const SizedBox(width: TixSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: TixSpace.s2,
                      runSpacing: TixSpace.s1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          person.label,
                          style: const TextStyle(
                            fontSize: TixText.md,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (self)
                          TixBadge(l10n.peopleYou, tone: TixTone.accent),
                      ],
                    ),
                    if (person.user.email != person.label)
                      Text(person.user.email, style: tixMono(context)),
                  ],
                ),
              ),
              const SizedBox(width: TixSpace.s2),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    spacing: TixSpace.s1,
                    runSpacing: TixSpace.s1,
                    alignment: WrapAlignment.end,
                    children: [
                      if (rolesKnown && role == null)
                        TixBadge(l10n.peopleNoRole)
                      else if (rolesKnown && role != null)
                        TixBadge(
                          roleLabel(l10n, role),
                          tone: role == Role.admin
                              ? TixTone.accent
                              : TixTone.neutral,
                        ),
                      if (person.disabled)
                        TixBadge(l10n.peopleDisabled, tone: TixTone.warn),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: t.lineStrong),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitesSection extends ConsumerWidget {
  const _InvitesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final invites = ref.watch(invitesProvider);
    return switch (invites) {
      AsyncData(:final value) when value.isNotEmpty => Padding(
        padding: const EdgeInsets.only(bottom: TixSpace.s4),
        child: TixSection(
          key: const Key('people.invites'),
          title: l10n.peopleInvites,
          info: l10n.peopleInvitesInfo,
          children: [for (final i in value) _InviteTile(invite: i)],
        ),
      ),
      AsyncError(:final error) => Padding(
        padding: const EdgeInsets.all(TixSpace.s4),
        child: ErrorState(
          error: error,
          compact: true,
          onRetry: () => ref.invalidate(invitesProvider),
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _InviteTile extends ConsumerWidget {
  const _InviteTile({required this.invite});

  final Invite invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final expires = invite.expiresAt;
    final now = ref.watch(clockProvider)();
    final expired = expires != null && !expires.isAfter(now);
    final role = invite.role;
    return Padding(
      key: Key('invite.${invite.id}'),
      padding: const EdgeInsets.all(TixSpace.s3),
      child: Wrap(
        spacing: TixSpace.s3,
        runSpacing: TixSpace.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(invite.email, style: tixMono(context, size: TixText.sm)),
              Text(
                invite.invitedByHandle.isEmpty
                    ? l10n.peopleInvited
                    : l10n.peopleInvitedBy('@${invite.invitedByHandle}'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (role != null) TixBadge(roleLabel(l10n, role)),
              if (expired)
                TixBadge(l10n.peopleInviteExpired, tone: TixTone.warn)
              else if (expires != null)
                TixBadge(l10n.peopleInviteExpires(formatDay(context, expires))),
              TixButton(
                key: Key('invite.${invite.id}.reissue'),
                label: l10n.peopleReissue,
                size: TixButtonSize.small,
                onPressed: () => _reissue(context, ref),
              ),
              TixButton.danger(
                key: Key('invite.${invite.id}.revoke'),
                label: l10n.peopleRevoke,
                size: TixButtonSize.small,
                onPressed: () => _revoke(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _reissue(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      final issued = await ref.read(invitesProvider.notifier).reissue(invite);
      if (!context.mounted) return;
      await showInviteLinkSheet(context, issued);
    } on Exception catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.peopleRevokeInviteTitle(invite.email),
      body: l10n.peopleRevokeInviteBody,
      action: l10n.peopleRevoke,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(invitesProvider.notifier).revoke(invite);
      if (context.mounted) {
        showTixToast(context, l10n.peopleInviteRevoked(invite.email));
      }
    } on Exception catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

/// The word for [role].
String roleLabel(AppLocalizations l10n, Role role) => switch (role) {
  Role.viewer => l10n.roleViewer,
  Role.member => l10n.roleMember,
  Role.admin => l10n.roleAdmin,
};
