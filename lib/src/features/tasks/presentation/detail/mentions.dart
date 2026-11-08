// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

final _partial = RegExp(r'(?:^|\s)@([A-Za-z0-9_.-]*)$');

/// The handle being typed just before [selection] in [text], or null.
String? mentionAt(String text, int selection) {
  if (selection < 0 || selection > text.length) return null;
  return _partial.firstMatch(text.substring(0, selection))?.group(1);
}

/// [text] with the handle being typed before [selection] completed to
/// [handle], and where the cursor goes after it.
({String text, int cursor}) completeMention(
  String text,
  int selection,
  String handle,
) {
  final before = text.substring(0, selection);
  final m = _partial.firstMatch(before)!;
  final start = before.length - m.group(1)!.length;
  final inserted = '$handle ';
  return (
    text: text.replaceRange(start, selection, inserted),
    cursor: start + inserted.length,
  );
}

/// A text field that offers the tenant's handles after `@`, as the web's
/// comment and description boxes do.
class MentionTextField extends ConsumerStatefulWidget {
  /// A field labelled [label] editing [controller].
  const MentionTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 5,
    this.minLines = 1,
    this.autofocus = false,
    this.onSubmit,
    this.focusNode,
    this.fieldKey,
    super.key,
  });

  /// The text.
  final TextEditingController controller;

  /// The field's label.
  final String label;

  /// Placeholder text.
  final String? hint;

  /// The most lines it grows to.
  final int maxLines;

  /// The fewest lines it shows.
  final int minLines;

  /// Whether it takes focus at once.
  final bool autofocus;

  /// Called on Ctrl+Enter or Cmd+Enter.
  final VoidCallback? onSubmit;

  /// Its focus, when the screen moves focus to it.
  final FocusNode? focusNode;

  /// The text field's key, for tests.
  final Key? fieldKey;

  @override
  ConsumerState<MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends ConsumerState<MentionTextField> {
  String? _typing;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    final v = widget.controller.value;
    final typing = mentionAt(v.text, v.selection.baseOffset);
    if (typing != _typing) setState(() => _typing = typing);
  }

  void _complete(Actor a) {
    final v = widget.controller.value;
    final done = completeMention(v.text, v.selection.baseOffset, a.handle);
    widget.controller.value = TextEditingValue(
      text: done.text,
      selection: TextSelection.collapsed(offset: done.cursor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typing = _typing;
    final actors = typing == null
        ? const <Actor>[]
        : [
            for (final a
                in ref.watch(actorDirectoryProvider).value ?? <Actor>[])
              if (a.handle.isNotEmpty &&
                  (a.handle.toLowerCase().startsWith(typing.toLowerCase()) ||
                      a.displayName.toLowerCase().contains(
                        typing.toLowerCase(),
                      )))
                a,
          ].take(6).toList();
    final submit = widget.onSubmit;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CallbackShortcuts(
          bindings: {
            if (submit != null) ...{
              const SingleActivator(LogicalKeyboardKey.enter, control: true):
                  submit,
              const SingleActivator(LogicalKeyboardKey.enter, meta: true):
                  submit,
            },
          },
          child: TextField(
            key: widget.fieldKey ?? const Key('mention.field'),
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              alignLabelWithHint: true,
            ),
          ),
        ),
        if (actors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: TixSpace.s1),
            child: Wrap(
              spacing: TixSpace.s1,
              runSpacing: TixSpace.s1,
              children: [
                for (final a in actors)
                  ActionChip(
                    key: Key('mention.${a.handle}'),
                    avatar: TixAvatar(
                      label: a.label,
                      seed: a.handle,
                      size: 20,
                      hued: true,
                    ),
                    label: Text('@${a.handle}'),
                    onPressed: () => _complete(a),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
