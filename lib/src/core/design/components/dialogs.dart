// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/components/motion.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';

/// Opens [builder]'s content as a bottom sheet on a phone and as a dialog
/// anywhere wider: the one way a form or a chooser opens.
///
/// tix opens every create form in a dialog from a primary header button;
/// on a phone the platform's norm for that is a sheet. The content should
/// be a [TixSheetBody] so both look the same.
Future<T?> showTixSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  if (context.isCompact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: builder(context),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(TixSpace.s5),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.only(top: TixSpace.s5),
          child: builder(context),
        ),
      ),
    ),
  );
}

/// The inside of a [showTixSheet]: a title, the content, and the actions
/// at the end, primary last.
class TixSheetBody extends StatelessWidget {
  /// A sheet titled [title] holding [child].
  const TixSheetBody({
    required this.title,
    required this.child,
    this.actions = const [],
    super.key,
  });

  /// The heading.
  final String title;

  /// The content; scrolls when tall.
  final Widget child;

  /// The buttons, quiet first and primary last.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s5,
        0,
        TixSpace.s5,
        TixSpace.s5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: TixSpace.s4),
          Flexible(child: SingleChildScrollView(child: child)),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s4),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: TixSpace.s2,
              runSpacing: TixSpace.s2,
              children: actions,
            ),
          ],
        ],
      ),
    ),
  );
}

/// Asks before a destructive [action] titled [title]; true when confirmed.
///
/// Every action that cannot be undone goes through here: a red button that
/// opens this, whose own confirm button is red too and says the verb.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: TixMeasure.text),
        child: Text(body),
      ),
      actions: [
        TixButton.quiet(
          label: context.l10n.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TixButton.danger(
          key: const Key('confirm.ok'),
          label: action,
          onPressed: () {
            unawaited(TixHaptics.confirm());
            Navigator.of(context).pop(true);
          },
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// One choice in [showActionSheet].
@immutable
class TixSheetAction<T> {
  /// A choice labelled [label] answering [value].
  const TixSheetAction({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
    this.key,
  });

  /// What choosing it returns.
  final T value;

  /// The label.
  final String label;

  /// An icon before it.
  final IconData? icon;

  /// Draws it in the danger colour. It should still confirm.
  final bool destructive;

  /// Its key, for tests.
  final Key? key;
}

/// A list of things to do with one item: a sheet on a phone, a small
/// dialog elsewhere. The row's overflow menu on touch screens.
Future<T?> showActionSheet<T>(
  BuildContext context, {
  required String title,
  required List<TixSheetAction<T>> actions,
}) => showTixSheet<T>(
  context,
  builder: (context) {
    final t = context.tix;
    return TixSheetBody(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final a in actions)
            ListTile(
              key: a.key,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: TixSpace.s2,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(TixRadius.md)),
              ),
              leading: a.icon == null
                  ? null
                  : Icon(a.icon, color: a.destructive ? t.danger : t.muted),
              title: Text(
                a.label,
                style: a.destructive ? TextStyle(color: t.danger) : null,
              ),
              onTap: () => Navigator.of(context).pop(a.value),
            ),
        ],
      ),
    );
  },
);
