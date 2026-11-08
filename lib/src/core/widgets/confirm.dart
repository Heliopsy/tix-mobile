// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// Asks before a destructive [action] titled [title]; true when confirmed.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirm.ok'),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

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
        decoration: InputDecoration(helperText: l10n.codeHelp),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('code.ok'),
          onPressed: () => Navigator.of(context).pop(_code.text),
          child: Text(l10n.verifyButton),
        ),
      ],
    );
  }
}
