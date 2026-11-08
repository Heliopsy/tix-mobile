// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/section.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

/// A labelled text field the way tix lays out a form: the label above in
/// small muted type, the field with an inset hairline, help and errors
/// under it. Capped at the field measure, so its width says what it wants.
///
/// Use it for every form input. The server's message for a refused value
/// goes in [error], next to the input that caused it.
class TixTextField extends StatelessWidget {
  /// A field labelled [label].
  const TixTextField({
    required this.label,
    this.controller,
    this.hint,
    this.help,
    this.info,
    this.error,
    this.enabled = true,
    this.obscure = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.fieldKey,
    this.width = TixMeasure.field,
    super.key,
  });

  /// What the field holds.
  final String label;

  /// The text.
  final TextEditingController? controller;

  /// An example, italic and muted, never mistaken for a value.
  final String? hint;

  /// One visible line on what to enter.
  final String? help;

  /// A longer explanation behind an (i).
  final String? info;

  /// Why the value was refused.
  final String? error;

  /// Whether it takes input.
  final bool enabled;

  /// Whether it hides what is typed.
  final bool obscure;

  /// Whether it takes focus when shown.
  final bool autofocus;

  /// Lines; more than one makes it a text area.
  final int maxLines;

  /// The keyboard.
  final TextInputType? keyboardType;

  /// The keyboard's action button.
  final TextInputAction? textInputAction;

  /// Autofill hints.
  final Iterable<String>? autofillHints;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Called on every change.
  final ValueChanged<String>? onChanged;

  /// Called on the keyboard's action.
  final ValueChanged<String>? onSubmitted;

  /// A control at the end of the field, such as a visibility toggle.
  final Widget? suffix;

  /// The key of the inner [TextField], for tests.
  final Key? fieldKey;

  /// The widest it may grow.
  final double width;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final field = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
          ),
          const SizedBox(height: TixSpace.s1),
          TextField(
            key: fieldKey,
            controller: controller,
            enabled: enabled,
            obscureText: obscure,
            autofocus: autofocus,
            maxLines: obscure ? 1 : maxLines,
            minLines: maxLines > 1 ? 4 : null,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: const TextStyle(fontSize: TixText.md),
            decoration: InputDecoration(
              semanticCounterText: label,
              hintText: hint,
              helperText: help,
              errorText: error,
              suffixIcon: suffix,
            ),
          ),
        ],
      ),
    );
    return Align(alignment: AlignmentDirectional.centerStart, child: field);
  }
}

/// A search or filter input: a magnifier, the text, and a clear button
/// once there is text.
class TixSearchField extends StatefulWidget {
  /// A search field hinting [hint].
  const TixSearchField({
    required this.hint,
    required this.onChanged,
    this.onSubmitted,
    this.controller,
    this.fieldKey,
    this.focusNode,
    super.key,
  });

  /// The field's focus, when the caller moves focus to it.
  final FocusNode? focusNode;

  /// The example query.
  final String hint;

  /// Called on every change.
  final ValueChanged<String> onChanged;

  /// Called on Enter.
  final ValueChanged<String>? onSubmitted;

  /// The text, when the caller owns it.
  final TextEditingController? controller;

  /// The inner field's key.
  final Key? fieldKey;

  @override
  State<TixSearchField> createState() => _TixSearchFieldState();
}

class _TixSearchFieldState extends State<TixSearchField> {
  late final TextEditingController _own = TextEditingController();

  TextEditingController get _text => widget.controller ?? _own;

  @override
  void dispose() {
    _own.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _text,
    builder: (context, _) => TextField(
      key: widget.fieldKey,
      controller: _text,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: TixText.sm),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: _text.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: () {
                  _text.clear();
                  widget.onChanged('');
                },
              ),
      ),
    ),
  );
}

/// A labelled on/off row for a settings section; the whole row is the
/// target.
class TixSwitchRow extends StatelessWidget {
  /// A switch labelled [title].
  const TixSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  /// What it turns on.
  final String title;

  /// One line on what that means.
  final String? subtitle;

  /// Whether it is on.
  final bool value;

  /// Called with the new value; null disables it.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    value: value,
    onChanged: onChanged,
  );
}
