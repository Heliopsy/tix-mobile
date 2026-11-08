// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';

/// What a button is for. tix has four, and nothing else.
enum TixButtonIntent {
  /// The one action the screen or dialog is for. One per screen.
  primary,

  /// Everything else that deserves a frame.
  secondary,

  /// An action that should not draw the eye: Cancel, Close, a row's extra.
  quiet,

  /// The action that cannot be undone. Always opens a confirmation first.
  danger,
}

/// A button's size.
enum TixButtonSize {
  /// [TixSize.control] high, 44 on a touch-sized window.
  regular,

  /// [TixSize.controlSmall] high, for toolbars and dense rows.
  small,
}

/// tix's button: one shape, four intents, two sizes.
///
/// Use it for every labelled action. A [TixButtonIntent.primary] with a
/// [Icons.add] icon is the create action of a page header and of an empty
/// state. [busy] keeps the label's width and swaps the icon for a spinner.
/// The hit area is never under 48 dp, whatever the drawn height.
class TixButton extends StatelessWidget {
  /// A button labelled [label].
  const TixButton({
    required this.label,
    required this.onPressed,
    this.intent = TixButtonIntent.secondary,
    this.size = TixButtonSize.regular,
    this.icon,
    this.busy = false,
    this.expand = false,
    super.key,
  });

  /// The primary intent.
  const TixButton.primary({
    required this.label,
    required this.onPressed,
    this.size = TixButtonSize.regular,
    this.icon,
    this.busy = false,
    this.expand = false,
    super.key,
  }) : intent = TixButtonIntent.primary;

  /// The danger intent.
  const TixButton.danger({
    required this.label,
    required this.onPressed,
    this.size = TixButtonSize.regular,
    this.icon,
    this.busy = false,
    this.expand = false,
    super.key,
  }) : intent = TixButtonIntent.danger;

  /// The quiet intent.
  const TixButton.quiet({
    required this.label,
    required this.onPressed,
    this.size = TixButtonSize.regular,
    this.icon,
    this.busy = false,
    this.expand = false,
    super.key,
  }) : intent = TixButtonIntent.quiet;

  /// The label, one line.
  final String label;

  /// Called on press; null disables the button.
  final VoidCallback? onPressed;

  /// What the button is for.
  final TixButtonIntent intent;

  /// How tall it is.
  final TixButtonSize size;

  /// An icon before the label.
  final IconData? icon;

  /// Whether its action is in flight: shows a spinner and ignores presses.
  final bool busy;

  /// Whether it fills the width it is given.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final text = Theme.of(context).textTheme.labelLarge!;
    final small = size == TixButtonSize.small;
    final height = small
        ? TixSize.controlSmall
        : context.isCompact
        ? TixSize.controlTouch
        : TixSize.control;
    final (bg, fg, border) = switch (intent) {
      TixButtonIntent.primary => (t.accent, t.onAccent, Colors.transparent),
      TixButtonIntent.secondary => (t.surface, t.ink, t.lineStrong),
      TixButtonIntent.quiet => (
        Colors.transparent,
        t.muted,
        Colors.transparent,
      ),
      TixButtonIntent.danger => (t.danger, t.onDanger, Colors.transparent),
    };
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.disabled) && bg != Colors.transparent) {
          return bg.withValues(alpha: 0.45);
        }
        if (s.contains(WidgetState.hovered) &&
            intent == TixButtonIntent.quiet) {
          return t.surface;
        }
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.hovered) && intent == TixButtonIntent.quiet
            ? t.ink
            : fg,
      ),
      iconColor: WidgetStatePropertyAll(fg),
      overlayColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.pressed)) return fg.withValues(alpha: 0.14);
        if (s.contains(WidgetState.hovered)) return fg.withValues(alpha: 0.08);
        if (s.contains(WidgetState.focused)) return fg.withValues(alpha: 0.12);
        return null;
      }),
      side: WidgetStateProperty.resolveWith(
        (s) => BorderSide(
          color:
              s.contains(WidgetState.hovered) &&
                  intent == TixButtonIntent.secondary
              ? t.ink
              : border,
        ),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(TixRadius.md)),
        ),
      ),
      minimumSize: WidgetStatePropertyAll(Size(small ? 0 : 64, height)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: small ? TixSpace.s3 : TixSpace.s4),
      ),
      textStyle: WidgetStatePropertyAll(
        small ? text.copyWith(fontSize: TixText.xs) : text,
      ),
      elevation: const WidgetStatePropertyAll(0),
      tapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    final iconSize = small ? 14.0 : 16.0;
    final lead = busy
        ? SizedBox.square(
            dimension: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
              value: TixMotion.of(context, TixMotion.base) == Duration.zero
                  ? 0.7
                  : null,
            ),
          )
        : icon == null
        ? null
        : Icon(icon, size: iconSize);
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (lead != null) ...[lead, const SizedBox(width: TixSpace.s2)],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    return Semantics(
      button: true,
      enabled: onPressed != null && !busy,
      child: TextButton(
        style: style,
        onPressed: busy ? null : onPressed,
        child: child,
      ),
    );
  }
}

/// A square icon-only button with a tooltip, for toolbars and rows.
///
/// The tooltip doubles as the semantics label, so it is required.
class TixIconButton extends StatelessWidget {
  /// An icon button for [icon], described by [tooltip].
  const TixIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.selected = false,
    super.key,
  });

  /// The icon.
  final IconData icon;

  /// What pressing it does, shown on hover and read by screen readers.
  final String tooltip;

  /// Called on press; null disables it.
  final VoidCallback? onPressed;

  /// The icon's colour; muted by default, the accent when [selected].
  final Color? color;

  /// Whether it shows an on state.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      isSelected: selected,
      color: color ?? (selected ? t.accent : t.muted),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(TixSize.target),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(TixRadius.md)),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
