// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/features/admin/application/global_admin.dart';

/// Every change to one account, newest first: its password, second
/// factor, disabled state, global admin standing and memberships, in every
/// tenant, with who made it and through what.
class AccountLogScreen extends ConsumerWidget {
  /// The log of the account [email].
  const AccountLogScreen({required this.email, super.key});

  /// The account's email.
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return TixPage(
      title: l10n.adminAccountLogTitle,
      subtitle: email,
      body: AsyncBody(
        value: ref.watch(accountLogProvider(email)),
        onRetry: () => ref.invalidate(accountLogProvider(email)),
        data: (paged) => PagedListView(
          paged: paged,
          empty: EmptyState(
            icon: Icons.history,
            title: l10n.adminAccountLogEmpty,
            body: l10n.adminAccountLogEmptyBody,
          ),
          onRefresh: () => ref.refresh(accountLogProvider(email).future),
          onLoadMore: () =>
              ref.read(accountLogProvider(email).notifier).loadMore(),
          itemBuilder: (context, e) => AccountLogRow(entry: e),
        ),
      ),
    );
  }
}

/// One change to an account.
class AccountLogRow extends StatelessWidget {
  /// Draws [entry].
  const AccountLogRow({required this.entry, super.key});

  /// The change.
  final AccountLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final when = entry.occurredAt;
    final by = entry.byEmail.isEmpty
        ? l10n.adminAccountLogSystem
        : entry.byEmail;
    final detail = [
      for (final MapEntry(:key, :value) in entry.detail.entries)
        '$key: ${value is String ? value : jsonEncode(value)}',
    ];
    return Container(
      key: Key('accountLog.${entry.seq}'),
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
            runSpacing: TixSpace.s1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                entry.action,
                style: tixMono(context, size: TixText.sm, color: t.ink),
              ),
              if (entry.tenantKey.isNotEmpty) TixBadge(entry.tenantKey),
              if (entry.byGlobalAdmin)
                TixBadge(l10n.globalAdminBadge, tone: TixTone.accent),
            ],
          ),
          const SizedBox(height: TixSpace.s1),
          Text(
            [
              l10n.adminAccountLogBy(by),
              if (entry.via.isNotEmpty) l10n.adminAccountLogVia(entry.via),
              if (when != null) context.times.stamp(when),
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s1),
            Text(detail.join('\n'), style: tixMono(context)),
          ],
        ],
      ),
    );
  }
}
