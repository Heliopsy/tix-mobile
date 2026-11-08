// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/markdown/checklist.dart';

List<ChecklistPart> items(String body) =>
    splitDescription(body).whereType<ChecklistPart>().toList();

void main() {
  test('plain Markdown is one part', () {
    final parts = splitDescription('# Steps\n\nSome **text**.');
    expect(parts, hasLength(1));
    expect((parts.single as MarkdownPart).text, '# Steps\n\nSome **text**.');
  });

  test('items are numbered in reading order, nested ones included', () {
    final list = items(
      '- [x] one\n- [ ] two\n  - [ ] two a\n  - [X] two b\n* [ ] three',
    );
    expect(list.map((i) => i.item), [1, 2, 3, 4, 5]);
    expect(list.map((i) => i.text), ['one', 'two', 'two a', 'two b', 'three']);
    expect(list.map((i) => i.done), [true, false, false, true, false]);
    expect(list.map((i) => i.depth), [0, 0, 1, 1, 0]);
  });

  test('ordered items count too', () {
    final list = items('1. [ ] first\n2) [x] second\n+ [ ] third');
    expect(list.map((i) => i.text), ['first', 'second', 'third']);
    expect(list[1].done, isTrue);
  });

  test('markers inside fenced code are not items', () {
    const body =
        '- [ ] real\n```\n- [ ] code\n```\n~~~md\n- [x] also code\n~~~\n'
        '- [ ] after';
    final list = items(body);
    expect(list.map((i) => i.text), ['real', 'after']);
    expect(list.map((i) => i.item), [1, 2]);
    final prose = splitDescription(body).whereType<MarkdownPart>().toList();
    expect(prose.single.text, contains('- [ ] code'));
  });

  test('a continuation line belongs to its item', () {
    final list = items('- [ ] ship the\n  collectors\nAfter.');
    expect(list.single.text, 'ship the\ncollectors');
    final parts = splitDescription('- [ ] ship the\n  collectors\nAfter.');
    expect((parts.last as MarkdownPart).text, 'After.');
  });

  test('prose between items keeps its place', () {
    final parts = splitDescription('Intro\n- [ ] a\n\nMiddle\n- [ ] b');
    expect(parts.map((p) => p.runtimeType), [
      MarkdownPart,
      ChecklistPart,
      MarkdownPart,
      ChecklistPart,
    ]);
  });

  test('a list item without a box is prose', () {
    expect(items('- plain\n- [] not a box'), isEmpty);
  });

  group('setChecklistItem', () {
    test('changes only that marker', () {
      const body = '- [ ] a\n  - [ ] b\n- [x] c';
      expect(
        setChecklistItem(body, 2, done: true),
        '- [ ] a\n  - [x] b\n- [x] c',
      );
      expect(
        setChecklistItem(body, 3, done: false),
        '- [ ] a\n  - [ ] b\n- [ ] c',
      );
    });

    test('counts past fenced code as tix does', () {
      const body = '```\n- [ ] code\n```\n- [ ] real';
      expect(
        setChecklistItem(body, 1, done: true),
        '```\n- [ ] code\n```\n- [x] real',
      );
    });

    test('leaves the text alone when there is no such item', () {
      expect(setChecklistItem('- [ ] a', 2, done: true), '- [ ] a');
      expect(setChecklistItem('no list', 1, done: true), 'no list');
    });
  });
}
