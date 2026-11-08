// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/section.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

/// A framed list of [TixPropertyRow]s, hairlines between them: a record's
/// attributes, as tix's task screen lists them beside the description.
class TixPropertyList extends StatelessWidget {
  /// Frames [children].
  const TixPropertyList({required this.children, super.key});

  /// The rows.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(TixRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: TixSpace.s4,
                  endIndent: TixSpace.s4,
                  color: t.line,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// One attribute: its label and its value, edited where it is read.
///
/// With [onTap] the whole row is a 48 dp target that opens the attribute's
/// editor, and a pencil says so. The label sits beside the value when the
/// row is wide enough and above it when not, so large text never squeezes
/// the value.
class TixPropertyRow extends StatelessWidget {
  /// The attribute [label] showing [child].
  const TixPropertyRow({
    required this.label,
    required this.child,
    this.onTap,
    this.info,
    this.editLabel,
    super.key,
  });

  /// The attribute's name.
  final String label;

  /// The value.
  final Widget child;

  /// Opens the editor; null for a value that cannot change here.
  final VoidCallback? onTap;

  /// A sentence behind an (i) beside the label.
  final String? info;

  /// What a screen reader says the row does when pressed, such as
  /// "Change priority"; the label when null.
  final String? editLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final labelText = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: TixText.xs,
              fontWeight: FontWeight.w500,
              color: t.muted,
            ),
          ),
        ),
        if (info != null) InfoTip(info!, size: 32),
      ],
    );
    final body = LayoutBuilder(
      builder: (context, c) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final side = c.maxWidth >= 300 && scale <= 1.5;
        final value = DefaultTextStyle.merge(
          style: const TextStyle(fontSize: TixText.sm),
          child: child,
        );
        final edit = onTap == null
            ? null
            : Icon(Icons.edit_outlined, size: 16, color: t.muted);
        if (side) {
          return Row(
            children: [
              SizedBox(width: 112, child: labelText),
              Expanded(child: value),
              ?edit,
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelText,
                  const SizedBox(height: TixSpace.s1),
                  value,
                ],
              ),
            ),
            ?edit,
          ],
        );
      },
    );
    final padded = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TixSize.target),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TixSpace.s4,
          vertical: TixSpace.s2,
        ),
        child: Align(alignment: AlignmentDirectional.centerStart, child: body),
      ),
    );
    if (onTap == null) return padded;
    return Semantics(
      button: true,
      label: editLabel ?? label,
      child: InkWell(onTap: onTap, child: padded),
    );
  }
}
