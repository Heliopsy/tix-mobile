// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

/// The mapping an import request carried, decoded, or empty.
Map<String, dynamic> sentMapping(Map<String, dynamic> body) {
  final raw = body['mapping'] as String?;
  return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
}

/// A Jira CSV as tix answers it: line 3's status "In Review" is in error
/// until the mapping says what it becomes.
Map<String, Object?> jiraAnswer(Map<String, dynamic> body) {
  final mapping = sentMapping(body);
  final cols = (mapping['columns'] as Map?) ?? {};
  final vals = (mapping['values'] as Map?) ?? {};
  final status = (vals['status'] as Map?) ?? {};
  String target(String header, String guess) =>
      (cols[header] as String?) ?? guess;
  Map<String, Object?> value(
    String field,
    String raw,
    int count,
    String guess,
  ) {
    final chosen = (vals[field] as Map?)?[raw] as String?;
    return {
      'value': raw,
      'count': count,
      'mapped': chosen ?? guess,
      'suggested': chosen == null && guess.isNotEmpty,
    };
  }

  final reviewMapped = status.containsKey('In Review');
  final dry = body['dry_run'] == true;
  final failed = reviewMapped ? 0 : 1;
  return {
    'dry_run': dry,
    'committed': !dry && failed == 0,
    'confident': false,
    'source': 'jira',
    'format': 'csv',
    'mode': body['mode'] ?? 'upsert',
    'rows': 3,
    'created': 1 + (reviewMapped ? 1 : 0),
    'updated': 1,
    'skipped': 0,
    'failed': failed,
    'columns': [
      {
        'header': 'Summary',
        'target': target('Summary', 'title'),
        'sample': ['Fix login', 'Write docs'],
      },
      {
        'header': 'Status',
        'target': target('Status', 'status'),
        'sample': ['Open', 'In Review'],
      },
      {
        'header': 'Assignee',
        'target': target('Assignee', 'assignee'),
        'sample': ['jane@example.com'],
      },
      {
        'header': 'Priority',
        'target': target('Priority', 'priority'),
        'sample': ['P1'],
      },
      {
        'header': 'Sprint',
        'target': target('Sprint', 'append_body'),
        'suggested': !cols.containsKey('Sprint'),
        'sample': ['S1'],
      },
    ],
    'values': {
      'status': [
        value('status', 'Open', 2, 'todo'),
        value('status', 'In Review', 1, ''),
      ],
      'priority': [value('priority', 'P1', 1, 'high')],
      'assignee': [value('assignee', 'jane@example.com', 1, '')],
    },
    'preview': [
      {
        'line': 2,
        'action': 'create',
        'ref': 'infra-9',
        'title': 'Fix login',
        'status': 'todo',
        'priority': 2,
        'tags': ['auth'],
      },
      if (reviewMapped)
        {
          'line': 3,
          'action': 'create',
          'ref': 'infra-10',
          'title': '=Write docs',
          'status': status['In Review'],
          'priority': 3,
        }
      else
        {
          'line': 3,
          'action': 'error',
          'title': '=Write docs',
          'priority': 3,
          'assignee': 'jane',
          'errors': ['status "In Review" is not a state of this workflow'],
        },
      {
        'line': 4,
        'action': 'update',
        'ref': 'infra-1',
        'title': 'Old, "quoted" task',
        'status': 'doing',
        'priority': 3,
      },
    ],
    'errors': [
      if (!reviewMapped)
        {
          'line': 3,
          'message': 'status "In Review" is not a state of this workflow',
        },
    ],
  };
}

/// A pasted list as tix answers it: every line a new task.
Map<String, Object?> linesAnswer(Map<String, dynamic> body) {
  final lines = (body['content'] as String).split('\n');
  final dry = body['dry_run'] == true;
  return {
    'dry_run': dry,
    'committed': !dry,
    'format': 'lines',
    'mode': body['mode'] ?? 'upsert',
    'rows': lines.length,
    'created': lines.length,
    'preview': [
      for (var i = 0; i < lines.length; i++)
        {
          'line': i + 1,
          'action': 'create',
          'ref': 'infra-${10 + i}',
          'title': lines[i].split(' #').first,
          'status': 'todo',
          'priority': 3,
        },
    ],
  };
}

/// The error report of [jiraAnswer]'s dry run: line 3 with its fields, the
/// error quoted and the title guarded.
final String jiraErrorsCsv = [
  'line,error,ref,title,status,priority,assignee,tags,due,parent,external_id',
  [
    '3',
    '"status ""In Review"" is not a state of this workflow"',
    '',
    "'=Write docs",
    '',
    'normal',
    'jane',
    '',
    '',
    '',
    '',
  ].join(','),
  '',
].join('\n');
