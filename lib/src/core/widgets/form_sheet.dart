// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// The body of a form opened with [showTixSheet]: the fields, the server's
/// refusal under them, Cancel and the submit button, which spins while
/// [onSubmit] runs and closes the sheet when it succeeds, with what it
/// returned, or true when that is null.
///
/// A failure keeps the sheet open with what was typed, so the person can
/// correct the value the server named.
class FormSheet extends StatefulWidget {
  /// A form titled [title] that runs [onSubmit] from a button labelled
  /// [submitLabel].
  const FormSheet({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    required this.children,
    this.danger = false,
    this.describe,
    super.key,
  });

  /// The heading.
  final String title;

  /// The submit button's verb.
  final String submitLabel;

  /// Sends the form; a thrown error is shown and the sheet stays.
  final Future<Object?> Function() onSubmit;

  /// The fields.
  final List<Widget> children;

  /// Draws the submit button red, for a form whose action cannot be undone.
  final bool danger;

  /// Words a failure for this form; the shared error text when null or
  /// when it returns null.
  final String? Function(Object error)? describe;

  @override
  State<FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<FormSheet> {
  var _busy = false;
  Object? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final Object? result;
    try {
      result = await widget.onSubmit();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
      return;
    }
    if (mounted) Navigator.of(context).pop(result ?? true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return TixSheetBody(
      title: widget.title,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        ),
        if (widget.danger)
          TixButton.danger(
            key: const Key('form.submit'),
            label: widget.submitLabel,
            busy: _busy,
            onPressed: _submit,
          )
        else
          TixButton.primary(
            key: const Key('form.submit'),
            label: widget.submitLabel,
            busy: _busy,
            onPressed: _submit,
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.children,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: TixSpace.s3),
              child: Text(
                widget.describe?.call(error) ?? errorMessage(l10n, error),
                key: const Key('form.error'),
                style: TextStyle(color: context.tix.danger),
              ),
            ),
        ],
      ),
    );
  }
}

/// A space between two fields of a [FormSheet].
const formGap = SizedBox(height: TixSpace.s3);
