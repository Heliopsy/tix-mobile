// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';

/// One piece of a Markdown description: a run of ordinary Markdown, or one
/// checklist item.
@immutable
sealed class DescriptionPart {
  const DescriptionPart();
}

/// Ordinary Markdown between checklist items.
final class MarkdownPart extends DescriptionPart {
  /// Holds [text].
  const MarkdownPart(this.text);

  /// The Markdown source.
  final String text;
}

/// One checklist item: `- [ ] text` or `- [x] text`.
final class ChecklistPart extends DescriptionPart {
  /// Item number [item] (from 1), ticked when [done].
  const ChecklistPart({
    required this.item,
    required this.done,
    required this.text,
    required this.depth,
  });

  /// The item's number in reading order, counted from 1, as tix counts.
  final int item;

  /// Whether it is ticked.
  final bool done;

  /// The item's Markdown, its continuation lines included.
  final String text;

  /// How deeply it is nested, 0 at the top.
  final int depth;
}

final _item = RegExp(
  r'^(\s*)(?:[-*+]|\d{1,9}[.)])\s+\[([ xX])\](?:\s+|$)(.*)$',
);
final _fence = RegExp(r'^\s{0,3}(`{3,}|~{3,})');

/// Splits [body] into Markdown and checklist items, numbering the items in
/// reading order and skipping markers inside fenced code, as tix's
/// checklist does.
List<DescriptionPart> splitDescription(String body) {
  final parts = <DescriptionPart>[];
  final prose = <String>[];
  String? fence;
  var count = 0;
  ChecklistPart? open;
  var openIndent = 0;
  final lines = body.split('\n');

  void flushProse() {
    if (prose.isEmpty) return;
    final text = prose.join('\n');
    if (text.trim().isNotEmpty) parts.add(MarkdownPart(text));
    prose.clear();
  }

  void flushItem() {
    if (open == null) return;
    parts.add(open!);
    open = null;
  }

  for (final line in lines) {
    final f = _fence.firstMatch(line);
    if (fence != null) {
      prose.add(line);
      if (f != null && f.group(1)!.startsWith(fence)) fence = null;
      continue;
    }
    if (f != null) {
      flushItem();
      fence = f.group(1)!.substring(0, 3);
      prose.add(line);
      continue;
    }
    final m = _item.firstMatch(line);
    if (m != null) {
      flushItem();
      flushProse();
      final indent = m.group(1)!.replaceAll('\t', '    ').length;
      openIndent = indent;
      open = ChecklistPart(
        item: ++count,
        done: m.group(2) != ' ',
        text: m.group(3)!,
        depth: indent ~/ 2,
      );
      continue;
    }
    final current = open;
    if (current != null &&
        line.trim().isNotEmpty &&
        _leading(line) > openIndent) {
      open = ChecklistPart(
        item: current.item,
        done: current.done,
        text: '${current.text}\n${line.trim()}',
        depth: current.depth,
      );
      continue;
    }
    flushItem();
    prose.add(line);
  }
  flushItem();
  flushProse();
  return parts;
}

int _leading(String line) =>
    line.length - line.replaceFirst(RegExp(r'^\s+'), '').length;

/// [body] with checklist item [item] ticked or cleared, only its marker
/// changed; [body] itself when there is no such item.
String setChecklistItem(String body, int item, {required bool done}) {
  final lines = body.split('\n');
  String? fence;
  var count = 0;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final f = _fence.firstMatch(line);
    if (fence != null) {
      if (f != null && f.group(1)!.startsWith(fence)) fence = null;
      continue;
    }
    if (f != null) {
      fence = f.group(1)!.substring(0, 3);
      continue;
    }
    final m = _item.firstMatch(line);
    if (m == null || ++count != item) continue;
    final at = line.indexOf('[', m.group(1)!.length);
    lines[i] = line.replaceRange(at + 1, at + 2, done ? 'x' : ' ');
    return lines.join('\n');
  }
  return body;
}
