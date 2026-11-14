// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/markdown/format.dart';

/// [text] with `«` and `»` marking the selection, or `|` a cursor.
TextEditingValue v(String text) {
  final cursor = text.indexOf('|');
  if (cursor >= 0) {
    return TextEditingValue(
      text: text.replaceFirst('|', ''),
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
  final s = text.indexOf('«');
  final e = text.indexOf('»') - 1;
  return TextEditingValue(
    text: text.replaceFirst('«', '').replaceFirst('»', ''),
    selection: TextSelection(baseOffset: s, extentOffset: e),
  );
}

/// [value] drawn as [v] reads it.
String show(TextEditingValue value) {
  final s = value.selection;
  final t = value.text;
  if (s.isCollapsed) return t.replaceRange(s.start, s.start, '|');
  return t.replaceRange(s.end, s.end, '»').replaceRange(s.start, s.start, '«');
}

String apply(String text, MarkdownFormat f, {String? href}) =>
    show(applyMarkdownFormat(v(text), f, href: href));

/// What typing Enter at the cursor in [text] gives.
String enter(String text) {
  final old = v(text);
  final c = old.selection.baseOffset;
  final next = TextEditingValue(
    text: old.text.replaceRange(c, c, '\n'),
    selection: TextSelection.collapsed(offset: c + 1),
  );
  return show(const MarkdownListFormatter().formatEditUpdate(old, next));
}

void main() {
  group('inline', () {
    test('bold wraps the selection the way the web writes it', () {
      expect(apply('a «plan» b', MarkdownFormat.bold), 'a **«plan»** b');
      expect(apply('a **«plan»** b', MarkdownFormat.bold), 'a «plan» b');
      expect(apply('a «**plan**» b', MarkdownFormat.bold), 'a «plan» b');
    });

    test('italic is one asterisk and tells itself apart from bold', () {
      expect(apply('«x»', MarkdownFormat.italic), '*«x»*');
      expect(apply('*«x»*', MarkdownFormat.italic), '«x»');
      expect(apply('**«x»**', MarkdownFormat.italic), '***«x»***');
      expect(apply('***«x»***', MarkdownFormat.italic), '**«x»**');
      expect(apply('***«x»***', MarkdownFormat.bold), '*«x»*');
    });

    test('strike and inline code toggle', () {
      expect(apply('«gone»', MarkdownFormat.strike), '~~«gone»~~');
      expect(apply('~~«gone»~~', MarkdownFormat.strike), '«gone»');
      expect(apply('run «ls»', MarkdownFormat.code), 'run `«ls»`');
      expect(apply('run `«ls»`', MarkdownFormat.code), 'run «ls»');
    });

    test('whitespace at the selection edges stays outside the markers', () {
      expect(apply('a« plan »b', MarkdownFormat.bold), 'a **«plan»** b');
    });

    test('an empty selection opens a pair and closes an empty one', () {
      expect(apply('a |', MarkdownFormat.bold), 'a **|**');
      expect(apply('a **|**', MarkdownFormat.bold), 'a |');
    });

    test('across lines each line is wrapped after its list marker', () {
      expect(
        apply('«- one\n- two»', MarkdownFormat.bold),
        '«- **one**\n- **two**»',
      );
      expect(
        apply('«- **one**\n- **two**»', MarkdownFormat.bold),
        '«- one\n- two»',
      );
    });

    test('a toggle twice gives back the text it started from', () {
      const texts = ['a «b» c', 'x «**y**» z', '«- one\n\n- two»', '«q»'];
      for (final f in [
        MarkdownFormat.bold,
        MarkdownFormat.italic,
        MarkdownFormat.strike,
        MarkdownFormat.code,
      ]) {
        for (final t in texts) {
          final once = applyMarkdownFormat(v(t), f);
          expect(applyMarkdownFormat(once, f).text, v(t).text, reason: '$f $t');
        }
      }
    });
  });

  group('lines', () {
    test("heading is the web's level two and comes off again", () {
      expect(apply('Plan|', MarkdownFormat.heading), '## Plan|');
      expect(apply('### Plan|', MarkdownFormat.heading), 'Plan|');
    });

    test('bullets, numbers and checklist prefix every touched line', () {
      expect(apply('«a\nb»', MarkdownFormat.bullets), '«- a\n- b»');
      expect(apply('«a\nb»', MarkdownFormat.numbers), '«1. a\n2. b»');
      expect(apply('«a\nb»', MarkdownFormat.checklist), '«- [ ] a\n- [ ] b»');
    });

    test('the same tool again takes the prefix off', () {
      expect(apply('«- a\n- b»', MarkdownFormat.bullets), '«a\nb»');
      expect(apply('«1. a\n2. b»', MarkdownFormat.numbers), '«a\nb»');
      expect(
        apply('«- [ ] a\n- [x] b»', MarkdownFormat.checklist),
        '«- a\n- b»',
      );
    });

    test('a list changes kind instead of nesting', () {
      expect(apply('«- a\n- b»', MarkdownFormat.numbers), '«1. a\n2. b»');
      expect(apply('«1. a\n2. b»', MarkdownFormat.bullets), '«- a\n- b»');
      expect(apply('- a|', MarkdownFormat.checklist), '- [ ] a|');
    });

    test('quote joins paragraphs into one quote', () {
      expect(apply('«a\n\nb»', MarkdownFormat.quote), '«> a\n>\n> b»');
      expect(apply('«> a\n>\n> b»', MarkdownFormat.quote), '«a\n\nb»');
    });

    test('blank lines are left alone and lines outside are untouched', () {
      expect(
        apply('keep\n«a\n\nb»\nkeep', MarkdownFormat.bullets),
        'keep\n«- a\n\n- b»\nkeep',
      );
    });

    test('a cursor keeps its place in the line', () {
      expect(apply('pl|an', MarkdownFormat.bullets), '- pl|an');
      expect(apply('- pl|an', MarkdownFormat.bullets), 'pl|an');
    });
  });

  group('code block', () {
    test('an empty selection fences its line, and again unfences it', () {
      expect(apply('|', MarkdownFormat.code), '```\n|\n```');
      expect(apply('```\n|\n```', MarkdownFormat.code), '|');
    });

    test('a selection over lines is fenced as a block', () {
      expect(apply('«a\nb»', MarkdownFormat.code), '```\n«a\nb»\n```');
      expect(apply('```\n«a\nb»\n```', MarkdownFormat.code), '«a\nb»');
    });
  });

  group('link', () {
    test('a selection becomes its text with the address escaped', () {
      expect(
        apply('see «docs»', MarkdownFormat.link, href: 'https://tix.example'),
        'see [docs](https://tix.example)|',
      );
      expect(
        apply('«a»', MarkdownFormat.link, href: 'https://x.example/a b(c)'),
        r'[a](https://x.example/a%20b\(c\))|',
      );
    });

    test(
      'with nothing selected an address is written as the web writes it',
      () {
        expect(
          apply('|', MarkdownFormat.link, href: 'https://tix.example'),
          '<https://tix.example>|',
        );
        expect(
          apply('|', MarkdownFormat.link, href: 'tix.example'),
          '[tix.example](tix.example)|',
        );
      },
    );

    test('no address changes nothing', () {
      expect(apply('«a»', MarkdownFormat.link), '«a»');
      expect(apply('«a»', MarkdownFormat.link, href: '  '), '«a»');
    });

    test('unlink keeps the text', () {
      final out = unlinkMarkdown(v('see [d|ocs](https://tix.example) now'));
      expect(show(out!), 'see «docs» now');
      expect(unlinkMarkdown(v('no |link')), isNull);
    });
  });

  group('table', () {
    test('goes on its own lines with the cursor in the first cell', () {
      expect(
        apply('|', MarkdownFormat.table),
        '| | |  |\n| --- | --- |\n|  |  |',
      );
      expect(
        apply('intro|\nnext', MarkdownFormat.table),
        'intro\n\n| | |  |\n| --- | --- |\n|  |  |\n\nnext',
      );
    });
  });

  group('Enter', () {
    test('continues bullets, numbers, checklists and quotes', () {
      expect(enter('- one|'), '- one\n- |');
      expect(enter('2. two|'), '2. two\n3. |');
      expect(enter('9) nine|'), '9) nine\n10) |');
      expect(enter('- [x] done|'), '- [x] done\n- [ ] |');
      expect(enter('> said|'), '> said\n> |');
      expect(enter('  * deep|'), '  * deep\n  * |');
    });

    test('an empty item ends the list', () {
      expect(enter('- one\n- |'), '- one\n|');
      expect(enter('- one\n- [ ] |'), '- one\n|');
      expect(enter('> a\n> |'), '> a\n|');
    });

    test('a plain line, a heading and fenced code get a plain newline', () {
      expect(enter('plain|'), 'plain\n|');
      expect(enter('## head|'), '## head\n|');
      expect(enter('```\n- code|\n```'), '```\n- code\n|\n```');
    });

    test('anything but one typed newline passes through', () {
      final old = v('- a|');
      const pasted = TextEditingValue(
        text: '- a\n\n',
        selection: TextSelection.collapsed(offset: 5),
      );
      expect(continueMarkdownList(old, pasted), isNull);
    });
  });
}
