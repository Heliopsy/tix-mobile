// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

export 'package:tix_mobile/src/core/design/components/dialogs.dart'
    show confirmDestructive;

/// Asks for a second factor code; null when cancelled.
Future<String?> askForCode(BuildContext context) => showDialog<String>(
  context: context,
  builder: (context) => const _CodeDialog(),
);

class _CodeDialog extends StatefulWidget {
  const _CodeDialog();

  @override
  State<_CodeDialog> createState() => _CodeDialogState();
}

class _CodeDialogState extends State<_CodeDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.codeLabel),
      content: TextField(
        key: const Key('code.field'),
        controller: _code,
        autofocus: true,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        style: tixMono(context, size: TixText.lg, color: context.tix.ink),
        decoration: InputDecoration(helperText: l10n.codeHelp),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('code.ok'),
          label: l10n.verifyButton,
          onPressed: () => Navigator.of(context).pop(_code.text),
        ),
      ],
    );
  }
}
