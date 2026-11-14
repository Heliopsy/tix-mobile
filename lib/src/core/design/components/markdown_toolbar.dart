// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/components/dialogs.dart';
import 'package:tix_mobile/src/core/design/components/fields.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/markdown/format.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';

export 'package:tix_mobile/src/core/markdown/format.dart'
    show MarkdownListFormatter;

/// A Markdown text field with tix's web formatting toolbar: the toolbar
/// above [field] on a wide window and under it on a phone, where it sits
/// just above the keyboard, and Ctrl+B, Ctrl+I and Ctrl+` inside it.
///
/// [field] edits [controller], and should carry a
/// [MarkdownListFormatter] so lists continue on Enter.
class MarkdownEditor extends StatelessWidget {
  /// The toolbar and keys around [field].
  const MarkdownEditor({
    required this.controller,
    required this.field,
    this.focusNode,
    super.key,
  });

  /// The Markdown text.
  final TextEditingController controller;

  /// The field's focus, given back after a tool runs.
  final FocusNode? focusNode;

  /// The text field.
  final Widget field;

  @override
  Widget build(BuildContext context) {
    final toolbar = MarkdownToolbar(
      controller: controller,
      focusNode: focusNode,
    );
    final keyed = MarkdownShortcuts(controller: controller, child: field);
    final compact = context.isCompact;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: compact
          ? [keyed, const SizedBox(height: TixSpace.s1), toolbar]
          : [toolbar, const SizedBox(height: TixSpace.s1), keyed],
    );
  }
}

/// The formatting tools of tix's web description editor, in its order,
/// each a labelled icon button that edits [controller]'s Markdown.
class MarkdownToolbar extends StatelessWidget {
  /// Tools for [controller]; [focusNode] gets focus back after each.
  const MarkdownToolbar({required this.controller, this.focusNode, super.key});

  /// The Markdown text.
  final TextEditingController controller;

  /// The field's focus.
  final FocusNode? focusNode;

  static IconData _icon(MarkdownFormat f) => switch (f) {
    MarkdownFormat.bold => Icons.format_bold,
    MarkdownFormat.italic => Icons.format_italic,
    MarkdownFormat.strike => Icons.format_strikethrough,
    MarkdownFormat.heading => Icons.title,
    MarkdownFormat.bullets => Icons.format_list_bulleted,
    MarkdownFormat.numbers => Icons.format_list_numbered,
    MarkdownFormat.checklist => Icons.checklist,
    MarkdownFormat.quote => Icons.format_quote,
    MarkdownFormat.code => Icons.code,
    MarkdownFormat.link => Icons.link,
    MarkdownFormat.table => Icons.table_chart_outlined,
  };

  static String _label(AppLocalizations l10n, MarkdownFormat f) => switch (f) {
    MarkdownFormat.bold => l10n.markdownBold,
    MarkdownFormat.italic => l10n.markdownItalic,
    MarkdownFormat.strike => l10n.markdownStrike,
    MarkdownFormat.heading => l10n.markdownHeading,
    MarkdownFormat.bullets => l10n.markdownBullets,
    MarkdownFormat.numbers => l10n.markdownNumbers,
    MarkdownFormat.checklist => l10n.markdownChecklist,
    MarkdownFormat.quote => l10n.markdownQuote,
    MarkdownFormat.code => l10n.markdownCode,
    MarkdownFormat.link => l10n.markdownLink,
    MarkdownFormat.table => l10n.markdownTable,
  };

  Future<void> _run(BuildContext context, MarkdownFormat format) async {
    if (format == MarkdownFormat.link) {
      final unlinked = unlinkMarkdown(controller.value);
      if (unlinked != null) {
        controller.value = unlinked;
      } else {
        final kept = controller.value;
        final href = await showTixSheet<String>(
          context,
          builder: (_) => const _LinkPrompt(),
        );
        if (href != null) {
          controller.value = applyMarkdownFormat(kept, format, href: href);
        }
      }
    } else {
      controller.value = applyMarkdownFormat(controller.value, format);
    }
    focusNode?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFieldTapRegion(
      child: Semantics(
        container: true,
        label: l10n.markdownFormatting,
        child: SingleChildScrollView(
          key: const Key('markdown.toolbar'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in MarkdownFormat.values)
                TixIconButton(
                  key: Key('markdown.${f.name}'),
                  icon: _icon(f),
                  tooltip: _label(l10n, f),
                  onPressed: () => _run(context, f),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ctrl+B, Ctrl+I and Ctrl+` (Cmd on a Mac) toggling bold, italic and code
/// in [controller] while focus is inside [child], as on tix's web. Ctrl+K
/// is left to the command palette, which it opens inside fields too.
class MarkdownShortcuts extends StatelessWidget {
  /// The formatting keys for [child].
  const MarkdownShortcuts({
    required this.controller,
    required this.child,
    super.key,
  });

  /// The Markdown text.
  final TextEditingController controller;

  /// The field.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    VoidCallback toggle(MarkdownFormat f) =>
        () => controller.value = applyMarkdownFormat(controller.value, f);
    return CallbackShortcuts(
      bindings: {
        for (final (key, format) in const [
          (LogicalKeyboardKey.keyB, MarkdownFormat.bold),
          (LogicalKeyboardKey.keyI, MarkdownFormat.italic),
          (LogicalKeyboardKey.backquote, MarkdownFormat.code),
        ]) ...{
          SingleActivator(key, control: true): toggle(format),
          SingleActivator(key, meta: true): toggle(format),
        },
      },
      child: child,
    );
  }
}

class _LinkPrompt extends StatefulWidget {
  const _LinkPrompt();

  @override
  State<_LinkPrompt> createState() => _LinkPromptState();
}

class _LinkPromptState extends State<_LinkPrompt> {
  final _address = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _add() => Navigator.of(context).pop(_address.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.markdownLink,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('markdown.link.add'),
          label: l10n.markdownLinkAdd,
          onPressed: _add,
        ),
      ],
      child: TixTextField(
        fieldKey: const Key('markdown.link.address'),
        label: l10n.markdownLinkAddress,
        controller: _address,
        hint: 'https://',
        autofocus: true,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _add(),
      ),
    );
  }
}
