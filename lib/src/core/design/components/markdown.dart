// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/motion.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/markdown/checklist.dart';
import 'package:tix_mobile/src/core/markdown/mentions.dart';

/// The link schemes a description may open, as tix allows them.
const _safeSchemes = {'http', 'https', 'mailto'};

/// Markdown as tix draws it: images become links to their address and are
/// never loaded, only `http`, `https` and `mailto` links open, and every
/// checklist item is a tick of its own.
///
/// Use it for descriptions and comments. With [onToggle] the ticks are
/// pressable, each 48 dp to the finger, and report the item's number in
/// reading order, as `POST /tasks/{ref}/checklist` counts it.
class TixMarkdown extends StatelessWidget {
  /// Draws [data].
  const TixMarkdown({
    required this.data,
    this.onToggle,
    this.onLink,
    this.onMention,
    this.selectable = true,
    super.key,
  });

  /// The Markdown source.
  final String data;

  /// Called with an item's number and its new state when a tick is pressed;
  /// null leaves the ticks read-only.
  final void Function(int item, {required bool done})? onToggle;

  /// Opens a link the person pressed; only safe schemes reach it.
  final ValueChanged<Uri>? onLink;

  /// Opens the handle of an `@handle` the person pressed; null leaves
  /// mentions as text.
  final ValueChanged<String>? onMention;

  /// Whether the text can be selected.
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final mention = onMention;
    final parts = splitDescription(mention == null ? data : linkMentions(data));
    void link(Uri uri) => uri.scheme == mentionScheme
        ? mention?.call(uri.path)
        : onLink?.call(uri);
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: TixMeasure.text),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final part in parts)
              switch (part) {
                MarkdownPart(:final text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
                  child: _Body(
                    text: text,
                    selectable: selectable,
                    onLink: link,
                  ),
                ),
                final ChecklistPart item => _Item(
                  item: item,
                  onToggle: onToggle,
                  onLink: link,
                ),
              },
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.text, required this.selectable, this.onLink});

  final String text;
  final bool selectable;
  final ValueChanged<Uri>? onLink;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    // flutter_markdown_plus still reads package:flutter/material.dart's
    // theme; the bridge hands it ours until it moves to material_ui.
    // ignore: deprecated_member_use
    return MaterialUiCompatibilityBridge(
      child: MarkdownBody(
        data: text,
        selectable: selectable,
        softLineBreak: true,
        styleSheet: MarkdownStyleSheet(
          a: TextStyle(color: t.accent, decoration: TextDecoration.underline),
          code: tixMono(
            context,
            size: TixText.sm,
          ).copyWith(backgroundColor: t.surface),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: t.lineStrong, width: 3)),
          ),
          codeblockDecoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(TixRadius.md),
          ),
        ),
        imageBuilder: (uri, title, alt) =>
            _ImageLink(uri: uri, alt: alt ?? title ?? '', onLink: onLink),
        onTapLink: (_, href, _) => _open(href, onLink),
      ),
    );
  }
}

void _open(String? href, ValueChanged<Uri>? onLink) {
  final uri = href == null ? null : Uri.tryParse(href);
  if (uri == null || onLink == null) return;
  final scheme = uri.scheme.toLowerCase();
  if (!_safeSchemes.contains(scheme) && scheme != mentionScheme) return;
  onLink(uri);
}

class _ImageLink extends StatelessWidget {
  const _ImageLink({required this.uri, required this.alt, this.onLink});

  final Uri uri;
  final String alt;
  final ValueChanged<Uri>? onLink;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final label = alt.isEmpty ? uri.toString() : alt;
    return InkWell(
      onTap: () => _open(uri.toString(), onLink),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.image_outlined, size: 16, color: t.muted),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: label,
              style: TextStyle(
                color: t.accent,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, this.onToggle, this.onLink});

  final ChecklistPart item;
  final void Function(int item, {required bool done})? onToggle;
  final ValueChanged<Uri>? onLink;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final toggle = onToggle;
    final box = Checkbox(
      value: item.done,
      onChanged: toggle == null
          ? null
          : (v) {
              unawaited(TixHaptics.tick());
              toggle(item.item, done: v ?? false);
            },
      activeColor: t.ok,
      checkColor: t.onOk,
      side: BorderSide(color: t.lineStrong, width: 2),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(start: item.depth * TixSpace.s5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            key: ValueKey('checklist.${item.item}'),
            label: item.text,
            child: box,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: TixSpace.s3),
              child: DefaultTextStyle.merge(
                style: item.done ? TextStyle(color: t.muted) : null,
                child: _Body(
                  text: item.text,
                  selectable: false,
                  onLink: onLink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
