// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

/// One reaction under a comment: its emoji and how many made it, on the
/// accent's tint when the reader is one of them. Tapping toggles it.
class ReactionChip extends StatelessWidget {
  /// A chip of [emoji] made [count] times, [mine] when the reader made it.
  const ReactionChip({
    required this.emoji,
    required this.count,
    required this.mine,
    required this.label,
    this.onTap,
    super.key,
  });

  /// The glyph.
  final String emoji;

  /// How many reacted with it.
  final int count;

  /// Whether the reader is one of them.
  final bool mine;

  /// What a screen reader says, such as "thumbs up, 2, you reacted".
  final String label;

  /// Toggles the reader's reaction; null draws it read-only.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TixRadius.pill),
      side: BorderSide(color: mine ? t.accent : t.line),
    );
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: TixSize.target,
            minWidth: TixSize.target,
          ),
          child: Center(
            widthFactor: 1,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: mine ? t.accentSoft : t.bg,
                shape: shape,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TixSpace.s2,
                  vertical: TixSpace.s1,
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: emoji),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: '$count',
                        style: TextStyle(
                          fontWeight: mine ? FontWeight.w600 : FontWeight.w500,
                          color: mine ? t.accent : t.ink,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: TixText.xs),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A comment's reactions in a wrapping row, then the button that adds one.
class ReactionBar extends StatelessWidget {
  /// [chips] followed, when [onAdd] is set, by an add button saying
  /// [addLabel].
  const ReactionBar({
    required this.chips,
    required this.addLabel,
    this.onAdd,
    this.addKey,
    super.key,
  });

  /// The [ReactionChip]s.
  final List<Widget> chips;

  /// The add button's tooltip and spoken label.
  final String addLabel;

  /// Opens the picker; null hides the button.
  final VoidCallback? onAdd;

  /// The add button's key.
  final Key? addKey;

  @override
  Widget build(BuildContext context) {
    final add = onAdd;
    if (chips.isEmpty && add == null) return const SizedBox.shrink();
    return Wrap(
      spacing: TixSpace.s1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...chips,
        if (add != null)
          TixIconButton(
            key: addKey,
            icon: Icons.add_reaction_outlined,
            tooltip: addLabel,
            onPressed: add,
          ),
      ],
    );
  }
}

/// One emoji in a reaction picker, on the accent's tint when the reader has
/// already made it.
class ReactionOption extends StatelessWidget {
  /// A choice of [emoji], read as [label].
  const ReactionOption({
    required this.emoji,
    required this.label,
    required this.onTap,
    this.mine = false,
    super.key,
  });

  /// The glyph.
  final String emoji;

  /// The reaction's name, for the tooltip and screen readers.
  final String label;

  /// Whether the reader has made it.
  final bool mine;

  /// Picks it.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: mine,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: mine ? t.accentSoft : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TixRadius.md),
            side: BorderSide(color: mine ? t.accent : Colors.transparent),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: TixSize.target,
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: TixText.xl),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
