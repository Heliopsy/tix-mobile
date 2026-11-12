// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/query/filter_expression.dart';

void main() {
  final now = DateTime.utc(2026, 11, 1, 12);
  TaskParams parse(String e) => parseFilterExpression(e, now: now);

  test('terms become parameters, negated ones their not_ form', () {
    expect(parse('assignee:me tag:ops -status:done'), {
      'assignee': ['me'],
      'tag': ['ops'],
      'not_status': ['done'],
    });
    expect(parse('project:WEB p:ops -project:infra'), {
      'project': ['web', 'ops'],
      'not_project': ['infra'],
    });
    expect(parse('claimed-by:raj creator:me -a:tom'), {
      'claimed_by': ['raj'],
      'creator': ['me'],
      'not_assignee': ['tom'],
    });
  });

  test('a handle is an assignee term, as tix reads it', () {
    expect(parse('@raj -@mia'), {
      'assignee': ['raj'],
      'not_assignee': ['mia'],
    });
    expect(parse('@ mail@host'), {
      'q': ['@ mail@host'],
    });
  });

  test('free words and quoted text are the search', () {
    expect(parse('fix "status:odd words" login'), {
      'q': ['fix status:odd words login'],
    });
    expect(parse('text:api'), {
      'q': ['api'],
    });
    expect(parse('-flaky title~api body:"two words"'), {
      'text': ['-any~flaky', 'title~api', 'body:two words'],
    });
  });

  test('priority names become numbers', () {
    expect(parse('priority:high -prio:lowest priority:3'), {
      'priority': ['2', '3'],
      'not_priority': ['5'],
    });
  });

  test("is:waiting-on is tix's name for is:blocked", () {
    expect(parse('is:waiting-on'), {
      'blocked': ['true'],
    });
    expect(parse('-is:waiting-on'), {
      'blocked': ['false'],
    });
  });

  test('is, has, checklist and the boolean keys', () {
    expect(parse('is:starred -is:blocked is:snoozed is:recurring'), {
      'starred': ['true'],
      'blocked': ['true'].map((_) => 'false').toList(),
      'snoozed': ['true'],
      'recurring': ['true'],
    });
    expect(parse('starred:false claimed:true snoozed:any'), {
      'starred': ['false'],
      'claimed': ['true'],
      'snoozed': ['any'],
    });
    expect(parse('has:checklist checklist:done is:root'), {
      'checklist': ['true', 'true'],
      'checklist_open': ['false'],
      'root_only': ['true'],
    });
    expect(parse('is:deleted is:trashed parent:none'), {
      'include_deleted': ['true'],
      'trashed': ['true'],
      'root_only': ['true'],
    });
  });

  test('due windows are bounds against the clock', () {
    expect(parse('due:overdue')['due_before'], ['2026-11-01T12:00:00Z']);
    expect(parse('due:today')['due_before'], ['2026-11-02T00:00:00Z']);
    expect(parse('due:week')['due_before'], ['2026-11-08T12:00:00Z']);
    expect(parse('due:month')['due_before'], ['2026-12-01T12:00:00Z']);
    expect(parse('due:<2026-02-01 due-after:2026-01-01T10:00:00Z'), {
      'due_before': ['2026-02-01T00:00:00Z'],
      'due_after': ['2026-01-01T10:00:00Z'],
    });
  });

  test('custom fields pass through', () {
    expect(parse('field.severity:high'), {
      'field.severity': ['high'],
    });
  });

  for (final (expr, message) in [
    ('colour:red', 'unknown filter key "colour"'),
    ('tag:', 'has no value'),
    ('tag~ops', 'weak operator'),
    ('-due:today', 'cannot be negated'),
    ('priority:urgent', 'must be a name or a number'),
    ('priority:9', 'out of range'),
    ('due:someday', 'unknown due: value'),
    ('is:odd', 'unknown is: value'),
    ('"open', 'unterminated quote'),
    ('due-before:soon', 'must be RFC3339'),
  ]) {
    test('$expr is refused as tix words it', () {
      expect(
        () => parse(expr),
        throwsA(
          isA<TixException>()
              .having((e) => e.kind, 'kind', TixErrorKind.invalid)
              .having((e) => e.message, 'message', contains(message)),
        ),
      );
    });
  }

  test('terms toggle and drop as whole words', () {
    expect(toggleFilterTerm('tag:ops', 'is:starred'), 'tag:ops is:starred');
    expect(toggleFilterTerm('tag:ops IS:STARRED', 'is:starred'), 'tag:ops');
    expect(hasFilterTerm('tag:ops is:starred', 'is:starred'), isTrue);
    expect(hasFilterTerm('is:starredx', 'is:starred'), isFalse);
    expect(dropFilterTerms('due:week tag:a due:<2026', 'due:'), 'tag:a');
    expect(filterTermValues('project:web -project:x Project:ops', 'project'), [
      'web',
      'ops',
    ]);
  });
}
