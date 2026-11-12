// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/components/dialogs.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// An (i) button beside a field that opens a short explanation titled
/// [title]: a sheet on a phone, a dialog wider. For what someone needs to
/// read before they can fill the field in, where an `InfoTip` is too slight.
class HelpButton extends StatelessWidget {
  /// Explains [title] with [body], whose paragraphs are split by blank lines.
  const HelpButton({required this.title, required this.body, super.key});

  /// What it explains, such as the field's label.
  final String title;

  /// The explanation.
  final String body;

  @override
  Widget build(BuildContext context) => TixIconButton(
    icon: Icons.info_outline,
    tooltip: context.l10n.helpAbout(title),
    onPressed: () => showHelp(context, title: title, body: body),
  );
}

/// Opens [body] titled [title] the way [HelpButton] does.
Future<void> showHelp(
  BuildContext context, {
  required String title,
  required String body,
}) => showTixSheet<void>(
  context,
  builder: (context) => TixSheetBody(
    title: title,
    actions: [
      TixButton(
        key: const Key('help.close'),
        label: context.l10n.close,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
    child: Column(
      key: const Key('help.body'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, paragraph) in body.split('\n\n').indexed) ...[
          if (i > 0) const SizedBox(height: TixSpace.s3),
          SelectableText(paragraph),
        ],
      ],
    ),
  ),
);
