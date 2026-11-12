// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/dates.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/repositories/token_repository.dart';
import 'package:tix_mobile/src/features/tokens/application/tokens.dart';
import 'package:tix_mobile/src/features/tokens/presentation/token_sheets.dart';

/// API tokens: the caller's own when [personal], otherwise the tenant's for
/// a reader with `tenant:admin`, with whose each one is.
class TokensScreen extends ConsumerWidget {
  /// Creates the screen.
  const TokensScreen({this.personal = false, super.key});

  /// Whether to list only the caller's own tokens.
  final bool personal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value;
    if (access == null) {
      return TixPage(
        title: l10n.tokensTitle,
        body: AsyncBody(
          value: ref.watch(currentAccessProvider),
          onRetry: () => ref.invalidate(currentAccessProvider),
          data: (_) => const SizedBox.shrink(),
        ),
      );
    }
    final whole = !personal && access.can(Scopes.tenantAdmin);
    final actorId = whole ? null : access.me.id;
    final tokens = ref.watch(tokensProvider(actorId));
    final issue = TixAction(
      key: const Key('tokens.issue'),
      label: l10n.tokensIssue,
      icon: Icons.add,
      onPressed: () => showIssueTokenSheet(context, actorId: actorId),
    );
    return CommandScope(
      commands: [
        TixCommand(
          id: 'tokens.new',
          label: l10n.tokensIssue,
          group: l10n.tokensTitle,
          icon: Icons.add,
          run: issue.onPressed,
        ),
      ],
      child: TixPage(
        title: personal ? l10n.tokensMine : l10n.tokensTitle,
        subtitle: whole ? l10n.tokensWholeTenant : l10n.tokensOwn,
        primaryAction: issue,
        body: AsyncBody(
          value: tokens,
          onRetry: () => ref.invalidate(tokensProvider(actorId)),
          data: (list) => RefreshIndicator(
            onRefresh: () => ref.refresh(tokensProvider(actorId).future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TixSpace.s4,
                    TixSpace.s3,
                    TixSpace.s4,
                    TixSpace.s2,
                  ),
                  child: Text(
                    whole ? l10n.tokensWholeNote : l10n.tokensIntro,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (list.isEmpty)
                  EmptyState(
                    icon: Icons.key_outlined,
                    title: l10n.tokensEmpty,
                    action: issue,
                  )
                else
                  for (final token in list)
                    TokenTile(
                      token: token,
                      actorId: actorId,
                      showOwner: whole,
                      mine: token.actorId == access.me.id,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One token: its name, scopes, dates and state, Rotate and Revoke.
class TokenTile extends ConsumerWidget {
  /// Draws [token], listed under [actorId].
  const TokenTile({
    required this.token,
    required this.actorId,
    required this.showOwner,
    required this.mine,
    super.key,
  });

  /// The token, metadata only.
  final APIToken token;

  /// Whose listing it is in, null for the whole tenant's.
  final String? actorId;

  /// Whether to say whose it is.
  final bool showOwner;

  /// Whether it is the caller's.
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final now = ref.watch(clockProvider)();
    final state = tokenState(token, now);
    final owners = showOwner ? ref.watch(tokenOwnersProvider).value : null;
    final owner = owners == null ? null : owners[token.actorId];
    final ownerName = owner?.label ?? token.actorId;
    final created = token.createdAt;
    final expires = token.expiresAt;
    final used = token.lastUsedAt;
    final stops = state == TokenState.retiring ? token.revokedAt : null;
    final small = Theme.of(context).textTheme.bodySmall;
    return Container(
      key: Key('token.${token.id}'),
      padding: const EdgeInsets.all(TixSpace.s4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: TixSpace.s2,
                  runSpacing: TixSpace.s1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      token.name,
                      style: const TextStyle(
                        fontSize: TixText.md,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TixBadge(
                      switch (state) {
                        TokenState.active => l10n.tokensActive,
                        TokenState.expired => l10n.tokensExpired,
                        TokenState.revoked => l10n.tokensRevoked,
                        TokenState.retiring => l10n.tokensRetiring,
                      },
                      tone: switch (state) {
                        TokenState.active => TixTone.ok,
                        TokenState.expired => TixTone.warn,
                        TokenState.revoked => TixTone.neutral,
                        TokenState.retiring => TixTone.warn,
                      },
                    ),
                  ],
                ),
              ),
              if (state == TokenState.active) ...[
                TixButton(
                  key: Key('token.${token.id}.rotate'),
                  label: l10n.tokensRotate,
                  size: TixButtonSize.small,
                  onPressed: () => showRotateTokenSheet(
                    context,
                    token: token,
                    actorId: actorId,
                    owner: ownerName,
                    other: showOwner && !mine,
                  ),
                ),
                const SizedBox(width: TixSpace.s2),
              ],
              if (state != TokenState.revoked)
                TixButton.danger(
                  key: Key('token.${token.id}.revoke'),
                  label: l10n.tokensRevoke,
                  size: TixButtonSize.small,
                  onPressed: () => _revoke(context, ref, ownerName),
                ),
            ],
          ),
          if (showOwner) ...[
            const SizedBox(height: TixSpace.s1),
            Text(
              mine
                  ? l10n.tokensOwnerYou(ownerName)
                  : l10n.tokensOwner(ownerName),
              style: small,
            ),
          ],
          const SizedBox(height: TixSpace.s2),
          Wrap(
            spacing: TixSpace.s1,
            runSpacing: TixSpace.s1,
            children: [
              for (final s in token.scopes)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TixSpace.s1,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(TixRadius.sm),
                  ),
                  child: Text(s, style: tixMono(context)),
                ),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          Text(
            [
              if (stops != null) l10n.tokensStops(formatMoment(context, stops)),
              if (created != null)
                l10n.tokensCreated(formatDay(context, created)),
              if (expires == null)
                l10n.tokensNeverExpires
              else
                l10n.tokensExpires(formatDay(context, expires)),
              if (used == null)
                l10n.tokensNotUsed
              else
                l10n.tokensLastUsed(formatMoment(context, used)),
            ].join(' · '),
            style: small,
          ),
        ],
      ),
    );
  }

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    String owner,
  ) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.tokensRevokeTitle(token.name),
      body: [
        l10n.tokensRevokeBody,
        if (showOwner && !mine) l10n.tokensRevokeOther(owner),
      ].join(' '),
      action: l10n.tokensRevokeNamed(token.name),
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(tokensProvider(actorId).notifier).revoke(token);
      if (context.mounted) {
        showTixToast(context, l10n.tokensRevokedToast(token.name));
      }
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}
