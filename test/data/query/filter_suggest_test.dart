// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/query/filter_suggest.dart';

void main() {
  const data = FilterSuggestData(
    projects: [(key: 'web', name: 'Website'), (key: 'infra', name: 'Infra')],
    tags: ['ops', 'backend', 'on call'],
    people: ['raj', 'ana'],
    statuses: ['todo', 'in_progress', 'done'],
  );

  List<String> labels(String text, [int? caret]) {
    final word = filterWordAt(text, caret ?? text.length);
    return word == null
        ? const []
        : [for (final s in filterSuggest(data, word)) s.label];
  }

  group('filterWordAt', () {
    test('finds the word, its minus and its key', () {
      expect(filterWordAt('tag:ops -s:do', 13), (
        start: 8,
        end: 13,
        negated: true,
        key: 'status',
        typed: 'do',
      ));
      expect(filterWordAt('@ra x', 2)?.key, '@');
      expect(filterWordAt('#op', 3)?.key, '#');
      expect(filterWordAt('prio', 4)?.key, '');
    });

    test('a word inside an open quote is free text', () {
      expect(filterWordAt('"two wo', 7), isNull);
    });
  });

  group('filterSuggest', () {
    test('a bare word completes to keys', () {
      expect(labels('pr'), ['project:', 'priority:']);
      expect(labels(''), isEmpty);
    });

    test('a scoped screen does not offer project', () {
      const scoped = FilterSuggestData(scoped: true);
      final word = filterWordAt('pr', 2)!;
      expect(
        [for (final s in filterSuggest(scoped, word)) s.label],
        ['priority:'],
      );
    });

    test('values complete after their key', () {
      expect(labels('status:in'), ['status:in_progress']);
      expect(labels('priority:h'), ['priority:highest', 'priority:high']);
      expect(labels('due:'), [
        'due:overdue',
        'due:today',
        'due:week',
        'due:month',
      ]);
      expect(labels('a:'), ['assignee:raj', 'assignee:ana', 'assignee:me']);
    });

    test('a project matches its name, which is the note', () {
      final word = filterWordAt('project:zz', 10)!;
      expect(filterSuggest(data, word), isEmpty);
      final site = filterWordAt('project:site', 12)!;
      expect(filterSuggest(data, site).single, (
        label: 'project:web',
        insert: 'project:web',
        note: 'Website',
      ));
    });

    test('a handle and a hash tag', () {
      expect(labels('@r'), ['@raj']);
      expect(labels('#op'), ['tag:ops']);
    });

    test('a value with a space is quoted', () {
      final word = filterWordAt('tag:on', 6)!;
      expect(filterSuggest(data, word).single.insert, 'tag:"on call"');
    });

    test('a word that is already its only suggestion gets nothing', () {
      expect(labels('tag:ops'), isEmpty);
      expect(labels('@raj'), isEmpty);
    });
  });

  group('filterInsert', () {
    test('replaces the word and keeps the minus', () {
      final word = filterWordAt('tag:ops -s:do x', 13)!;
      expect(filterInsert('tag:ops -s:do x', word, 'status:done'), (
        text: 'tag:ops -status:done x',
        caret: 21,
      ));
    });

    test('a key gets no space after it', () {
      final word = filterWordAt('prio', 4)!;
      expect(filterInsert('prio', word, 'priority:'), (
        text: 'priority:',
        caret: 9,
      ));
    });
  });

  group('terms', () {
    test('split on spaces, a quoted phrase kept whole', () {
      expect(
        [for (final t in filterTerms('tag:ops  "two words" -@raj')) t.text],
        ['tag:ops', '"two words"', '-@raj'],
      );
    });

    test('one is taken out', () {
      const e = 'tag:ops status:todo tag:ops';
      final last = filterTerms(e).last;
      expect(removeFilterTerm(e, last), 'tag:ops status:todo');
    });

    test('a key is replaced, its short form and handles too', () {
      expect(
        setFilterKey('priority:low tag:ops', 'priority', 'high'),
        'tag:ops priority:high',
      );
      expect(
        setFilterKey('a:ana @raj -@mia tag:ops', 'assignee', null),
        '-@mia tag:ops',
      );
      expect(selectingValues('s:todo -status:done', 'status'), ['todo']);
      expect(selectingValues('@raj', 'assignee'), ['raj']);
    });
  });
}
