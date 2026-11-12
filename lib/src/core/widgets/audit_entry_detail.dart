// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/actor_link.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';

/// Everything one audit entry records: when, who, through what, and the
/// record before and after.
class AuditEntryDetail extends StatelessWidget {
  /// Shows [entry].
  const AuditEntryDetail({required this.entry, super.key});

  /// The entry.
  final AuditEntry entry;

  static const _pretty = JsonEncoder.withIndent('  ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final t = context.tix;
    final via = entry.via;
    final at = entry.occurredAt;
    final facts = <(String, String)>[
      (l10n.auditSeq, '${entry.seq}'),
      if (at != null) (l10n.auditWhen, context.times.stamp(at)),
      (
        l10n.auditActor,
        entry.actorId.isEmpty ? l10n.auditSystem : entry.actorId,
      ),
      (l10n.auditSubject, '${entry.subjectType} ${entry.subjectId}'),
      if (entry.source != null) (l10n.auditSource, entry.source!.value),
      if (via != null)
        for (final (label, value) in [
          (l10n.auditVia, via.kind),
          (l10n.auditToken, via.tokenName),
          (l10n.auditTokenId, via.tokenId),
          (l10n.auditSession, via.session),
          (l10n.auditKey, via.keyFingerprint),
          (l10n.auditClient, via.clientAddr),
          (l10n.auditOrigin, via.origin),
          (l10n.auditHost, via.host),
          (l10n.auditOsUser, via.osUser),
          (l10n.auditJob, via.job),
          (l10n.auditUserAgent, via.userAgent),
        ])
          if (value.isNotEmpty) (label, value),
    ];
    Widget json(String title, Object? value) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: TixSpace.s3),
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: TixSpace.s1),
        Container(
          padding: const EdgeInsets.all(TixSpace.s3),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(TixRadius.md),
          ),
          child: SelectableText(
            _pretty.convert(value),
            style: tixMono(context, color: t.ink),
          ),
        ),
      ],
    );
    return Column(
      key: Key('audit.detail.${entry.seq}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, value) in facts)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
            child: Wrap(
              spacing: TixSpace.s2,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                if (label == l10n.auditActor && ActorLink.links(entry.actorId))
                  ActorLink(
                    key: const Key('audit.detail.actor'),
                    actor: entry.actorId,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: t.accent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  SelectableText(value),
              ],
            ),
          ),
        if (entry.before != null) json(l10n.auditBefore, entry.before),
        if (entry.after != null) json(l10n.auditAfter, entry.after),
      ],
    );
  }
}
