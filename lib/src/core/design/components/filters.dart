// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/components/fields.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// One choice in a [TixFilterBar]: a toggle that narrows a list.
class TixFilterChip extends StatelessWidget {
  /// A chip labelled [label].
  const TixFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.count,
    super.key,
  });

  /// What it narrows to.
  final String label;

  /// Whether it is on.
  final bool selected;

  /// Called with the new state.
  final ValueChanged<bool> onSelected;

  /// An icon before the label.
  final IconData? icon;

  /// How many rows it would show, when known.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null
          ? null
          : Icon(icon, size: 16, color: selected ? t.accent : t.muted),
      label: Text(count == null ? label : '$label  $count'),
      labelStyle: TextStyle(
        fontSize: TixText.xs,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? t.accent : t.ink,
      ),
      side: BorderSide(color: selected ? t.accent : t.line),
      backgroundColor: t.bg,
      selectedColor: t.accentSoft,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

/// A list's filter row: a query field and toggle chips, the chips
/// scrolling sideways on a phone rather than wrapping into a wall.
///
/// Changing a filter starts the listing again from its first page.
class TixFilterBar extends StatelessWidget {
  /// A bar with [chips] and, when [onQuery] is set, a query field.
  const TixFilterBar({
    this.chips = const [],
    this.onQuery,
    this.hint,
    this.trailing,
    this.controller,
    this.error,
    this.fieldKey,
    this.onSubmitted,
    this.focusNode,
    this.below,
    super.key,
  });

  /// The query's text, when the caller writes into it (a chip that adds a
  /// term, a saved filter that replaces it).
  final TextEditingController? controller;

  /// Why the query was refused, shown under the field.
  final String? error;

  /// The field's key.
  final Key? fieldKey;

  /// Called on Enter.
  final ValueChanged<String>? onSubmitted;

  /// The field's focus, so a shortcut can move to it.
  final FocusNode? focusNode;

  /// A second row of chips under the toggles, such as saved filters.
  final Widget? below;

  /// The toggles.
  final List<Widget> chips;

  /// Called as the query changes; null hides the field.
  final ValueChanged<String>? onQuery;

  /// The query's example, such as `status:todo tag:ops`.
  final String? hint;

  /// A control at the end, such as a sort menu.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final query = onQuery;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        0,
        TixSpace.s4,
        TixSpace.s3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (query != null)
            Row(
              children: [
                Expanded(
                  child: TixSearchField(
                    hint: hint ?? context.l10n.filterHint,
                    onChanged: query,
                    onSubmitted: onSubmitted,
                    controller: controller,
                    fieldKey: fieldKey,
                    focusNode: focusNode,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: TixSpace.s2),
                  trailing!,
                ],
              ],
            ),
          if (error case final String message) ...[
            const SizedBox(height: TixSpace.s1),
            Text(
              message,
              key: const Key('filter.error'),
              style: TextStyle(color: context.tix.danger, fontSize: TixText.xs),
            ),
          ],
          if (chips.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s2),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in chips) ...[
                    c,
                    const SizedBox(width: TixSpace.s2),
                  ],
                ],
              ),
            ),
          ],
          ?below,
        ],
      ),
    );
  }
}

/// What the server made of a quick-add line, as tix's preview chips: kind
/// and value on the accent's tint, an unknown one in danger.
class QuickChip extends StatelessWidget {
  /// A chip saying [kind] is [value].
  const QuickChip({
    required this.kind,
    required this.value,
    this.unknown = false,
    super.key,
  });

  /// What was recognised: project, tag, assignee, due.
  final String kind;

  /// What it was recognised as.
  final String value;

  /// Whether the server does not know it.
  final bool unknown;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final fg = unknown ? t.danger : t.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 1),
      decoration: BoxDecoration(
        color: unknown ? t.dangerSoft : t.accentSoft,
        borderRadius: BorderRadius.circular(TixRadius.pill),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$kind ',
              style: TextStyle(color: t.muted),
            ),
            TextSpan(text: value),
          ],
        ),
        style: TextStyle(fontSize: TixText.xs, color: fg),
      ),
    );
  }
}

/// One line that becomes a task: the field, then Add. The server parses
/// the line (`Fix login !high #auth @raj due:fri`); this never does.
///
/// [error] shows the server's refusal under the field; [busy] keeps the
/// line while the request is in flight.
class QuickAddField extends StatelessWidget {
  /// A quick-add row submitting through [onSubmit].
  const QuickAddField({
    required this.controller,
    required this.onSubmit,
    this.busy = false,
    this.error,
    this.help,
    this.autofocus = false,
    this.trailing,
    this.preview = const [],
    this.fieldKey,
    this.submitKey,
    this.focusNode,
    super.key,
  });

  /// The line.
  final TextEditingController controller;

  /// The field's focus, to keep typing after a send.
  final FocusNode? focusNode;

  /// Sends the line.
  final VoidCallback onSubmit;

  /// Whether a send is in flight.
  final bool busy;

  /// Why the server refused the line.
  final String? error;

  /// The syntax reminder under the field.
  final String? help;

  /// Whether it takes focus when shown.
  final bool autofocus;

  /// A control between the field and Add, such as a project menu.
  final Widget? trailing;

  /// What the server made of the line so far.
  final List<QuickChip> preview;

  /// The field's key.
  final Key? fieldKey;

  /// The Add button's key.
  final Key? submitKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: fieldKey,
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                enabled: !busy,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                style: const TextStyle(fontSize: TixText.base),
                decoration: InputDecoration(
                  hintText: l10n.quickAddHint,
                  helperText: help,
                  errorText: error,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: TixSpace.s2),
              trailing!,
            ],
            const SizedBox(width: TixSpace.s2),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: TixButton.primary(
                key: submitKey,
                label: l10n.quickAddButton,
                busy: busy,
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
        if (preview.isNotEmpty) ...[
          const SizedBox(height: TixSpace.s2),
          Wrap(
            spacing: TixSpace.s1,
            runSpacing: TixSpace.s1,
            children: preview,
          ),
        ],
      ],
    );
  }
}

/// One emoji reaction under a comment: the emoji and how many chose it,
/// filled when the viewer is one of them. A tap toggles it, a long press
/// says who.
class ReactionChip extends StatelessWidget {
  /// A chip for [emoji] chosen [count] times.
  const ReactionChip({
    required this.emoji,
    required this.count,
    required this.mine,
    required this.semanticLabel,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  /// The emoji.
  final String emoji;

  /// How many reacted with it.
  final int count;

  /// Whether the viewer is among them.
  final bool mine;

  /// What a screen reader says for it.
  final String semanticLabel;

  /// Toggles the viewer's reaction; null disables it.
  final VoidCallback? onTap;

  /// Shows who reacted.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TixRadius.pill),
      side: BorderSide(color: mine ? t.accent : t.line),
    );
    return Semantics(
      button: true,
      toggled: mine,
      label: semanticLabel,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TixSize.target),
        child: Center(
          widthFactor: 1,
          child: Material(
            color: mine ? t.accentSoft : t.bg,
            shape: shape,
            child: InkWell(
              customBorder: shape,
              onTap: onTap,
              onLongPress: onLongPress,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: TixSize.controlSmall,
                  minWidth: TixSize.target,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TixSpace.s2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji),
                      const SizedBox(width: TixSpace.s1),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: TixText.xs,
                          fontWeight: mine ? FontWeight.w600 : FontWeight.w500,
                          color: mine ? t.accent : t.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
