// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/components/toast.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// A value tix shows exactly once: a generated password, a signing secret,
/// recovery codes. tix's `oneTimeSecret` panel: a heading, why it will not
/// come back, the values in mono, and Copy.
///
/// The values live only in the widget that shows them. Never cache, log or
/// put them in a route; once the panel is gone, so are they.
class OneTimeSecret extends StatelessWidget {
  /// Shows [values] under [heading], explained by [note].
  const OneTimeSecret({
    required this.heading,
    required this.note,
    required this.values,
    super.key,
  });

  /// What to do, such as "Copy this signing secret now".
  final String heading;

  /// Why: it is shown once and what to do if it is lost.
  final String note;

  /// The values, one per line.
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(TixSpace.s4),
      decoration: BoxDecoration(
        color: t.warnSoft,
        border: Border.all(color: t.warn),
        borderRadius: BorderRadius.circular(TixRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key_outlined, color: t.warn, size: 20),
              const SizedBox(width: TixSpace.s2),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(heading, style: theme.textTheme.titleMedium),
                ),
              ),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          Text(note, style: theme.textTheme.bodySmall?.copyWith(color: t.ink)),
          const SizedBox(height: TixSpace.s3),
          Container(
            key: const Key('secret.values'),
            width: double.infinity,
            padding: const EdgeInsets.all(TixSpace.s3),
            decoration: BoxDecoration(
              color: t.bg,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(TixRadius.md),
            ),
            child: SelectableText(
              values.join('\n'),
              style: tixMono(context, size: TixText.sm, color: t.ink),
            ),
          ),
          const SizedBox(height: TixSpace.s3),
          TixButton(
            key: const Key('secret.copy'),
            label: l10n.copyToClipboard,
            icon: Icons.copy,
            size: TixButtonSize.small,
            onPressed: () {
              unawaited(
                Clipboard.setData(ClipboardData(text: values.join('\n'))),
              );
              showTixToast(context, l10n.copiedToClipboard);
            },
          ),
        ],
      ),
    );
  }
}
