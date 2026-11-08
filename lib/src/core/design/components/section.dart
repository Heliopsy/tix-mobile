// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// A section's heading: tix's `h2`, with an optional (i) tip and an action
/// on the right, such as the section's create button.
class SectionHeader extends StatelessWidget {
  /// Heads a section [title].
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.info,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      TixSpace.s4,
      TixSpace.s5,
      TixSpace.s4,
      TixSpace.s2,
    ),
    super.key,
  });

  /// The heading.
  final String title;

  /// A line under it, muted.
  final String? subtitle;

  /// An explanation behind an (i) tip. Visible text is better when short.
  final String? info;

  /// A control on the right: a `TixButton` or an icon button.
  final Widget? trailing;

  /// Space round it.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Semantics(
                        header: true,
                        child: Text(title, style: theme.textTheme.titleLarge),
                      ),
                    ),
                    if (info != null) InfoTip(info!),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: TixSpace.headSub),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: TixSpace.s2),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// An (i) that explains on tap or hover. For a sentence too long to sit
/// under a control; never for anything a person needs to act.
class InfoTip extends StatelessWidget {
  /// Explains with [message], in a [size] square target.
  const InfoTip(this.message, {this.size = TixSize.target, super.key});

  /// The explanation.
  final String message;

  /// The target's side; 32 inline beside a label, as tix allows for marks
  /// that share a line.
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: message,
    triggerMode: TooltipTriggerMode.tap,
    showDuration: const Duration(seconds: 6),
    child: Semantics(
      label: context.l10n.moreInfo,
      hint: message,
      button: true,
      child: SizedBox.square(
        dimension: size,
        child: Icon(Icons.info_outline, size: 16, color: context.tix.muted),
      ),
    ),
  );
}

/// An always-visible headed group: a settings section, a block of a task's
/// properties. Never a fold.
///
/// [children] sit in one bordered group, divided by hairlines, the way tix
/// draws a settings list.
class TixSection extends StatelessWidget {
  /// A section [title] holding [children].
  const TixSection({
    required this.title,
    required this.children,
    this.subtitle,
    this.info,
    this.trailing,
    this.danger = false,
    super.key,
  });

  /// The heading.
  final String title;

  /// A line under the heading.
  final String? subtitle;

  /// An (i) explanation.
  final String? info;

  /// A control right of the heading.
  final Widget? trailing;

  /// The rows.
  final List<Widget> children;

  /// Draws the group's border in the danger colour, for destructive
  /// settings.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          info: info,
          trailing: trailing,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: danger ? t.danger : t.line),
              borderRadius: BorderRadius.circular(TixRadius.lg),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TixRadius.lg - 1),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) const Divider(),
                      children[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
