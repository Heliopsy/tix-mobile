// SPDX-License-Identifier: AGPL-3.0-or-later

import '../helpers/fake_tix.dart';

/// The moment every store screenshot is taken at.
final demoNow = DateTime.utc(2026, 11, 12, 9, 41);

String _at(Duration ago) => demoNow.subtract(ago).toIso8601String();

String _due(int days, {int hour = 17}) => DateTime.utc(
  demoNow.year,
  demoNow.month,
  demoNow.day + days,
  hour,
).toIso8601String();

/// A fictional six-person software team on `tix.example`: four projects,
/// people and agents, tasks in every state, comments and history. Nothing
/// in it names a real person, company or server.
FakeTix demoTeam() {
  final server = FakeTix(projects: _projects, tasks: _tasks())
    ..workflow = _workflow
    ..tagNames.clear()
    ..tagNames.addAll(_tags)
    ..inbox.clear()
    ..inbox.addAll(_inbox)
    ..inboxStats = {
      'by_category': [
        {'category': 'todo', 'count': 11},
        {'category': 'in_progress', 'count': 9},
        {'category': 'blocked', 'count': 1},
        {'category': 'done', 'count': 23},
      ],
      'completed': 7,
      'created': 9,
    };
  server.workflows
    ..clear()
    ..add(_workflow);
  server.actors
    ..clear()
    ..addAll(_actors);
  server.tenants
    ..clear()
    ..addAll({
      'lumen': (name: 'Lumen Labs', host: ''),
      'garden': (name: 'Garden club', host: ''),
      'home': (name: 'Home', host: ''),
    });
  server.fields
    ..clear()
    ..addAll(_fields);
  server.comments.addAll(_comments);
  server.audit.addAll(_audit);
  server.deps['id-app-14'] = ['id-api-31'];
  return server;
}

final _workflow = <String, Object?>{
  'id': 'wf1',
  'key': 'delivery',
  'name': 'Delivery',
  'definition': {
    'initial': 'todo',
    'states': [
      {'key': 'todo', 'label': 'To do', 'category': 'todo'},
      {'key': 'doing', 'label': 'In progress', 'category': 'in_progress'},
      {'key': 'review', 'label': 'In review', 'category': 'in_progress'},
      {'key': 'blocked', 'label': 'Blocked', 'category': 'blocked'},
      {'key': 'done', 'label': 'Done', 'category': 'done', 'terminal': true},
      {
        'key': 'cancelled',
        'label': 'Cancelled',
        'category': 'cancelled',
        'terminal': true,
      },
    ],
    'transitions': [
      for (final (a, b) in const [
        ('todo', 'doing'),
        ('todo', 'cancelled'),
        ('doing', 'review'),
        ('doing', 'blocked'),
        ('doing', 'todo'),
        ('review', 'done'),
        ('review', 'doing'),
        ('blocked', 'doing'),
        ('done', 'todo'),
        ('cancelled', 'todo'),
      ])
        {'from': a, 'to': b},
    ],
  },
};

const _tags = [
  'android',
  'ios',
  'release',
  'crash',
  'perf',
  'a11y',
  'auth',
  'docs',
  'billing',
  'infra',
];

final _actors = <String, Map<String, Object?>>{
  'me': {'id': 'me', 'handle': 'ana', 'display_name': 'Ana', 'kind': 'user'},
  'mira': {
    'id': 'mira',
    'handle': 'mira',
    'display_name': 'Mira',
    'kind': 'user',
  },
  'tomas': {
    'id': 'tomas',
    'handle': 'tomas',
    'display_name': 'Tomas',
    'kind': 'user',
  },
  'jun': {'id': 'jun', 'handle': 'jun', 'display_name': 'Jun', 'kind': 'user'},
  'leo': {'id': 'leo', 'handle': 'leo', 'display_name': 'Leo', 'kind': 'user'},
  'review-bot': {
    'id': 'review-bot',
    'handle': 'review-bot',
    'display_name': 'Review bot',
    'kind': 'agent',
  },
  'triage': {
    'id': 'triage',
    'handle': 'triage',
    'display_name': 'Triage agent',
    'kind': 'agent',
  },
  'deploy': {
    'id': 'deploy',
    'handle': 'deploy',
    'display_name': 'Deploy agent',
    'kind': 'agent',
  },
};

final _projects = <Map<String, Object?>>[
  {
    'id': 'p-app',
    'key': 'app',
    'name': 'Mobile app',
    'color': 'violet',
    'icon_name': 'rocket',
    'description': 'The phone and tablet app.',
    'workflow_id': 'wf1',
  },
  {
    'id': 'p-api',
    'key': 'api',
    'name': 'API',
    'color': 'blue',
    'description': 'Public API and webhooks.',
    'workflow_id': 'wf1',
  },
  {
    'id': 'p-web',
    'key': 'web',
    'name': 'Website',
    'color': 'green',
    'description': 'Marketing site and docs.',
    'workflow_id': 'wf1',
  },
  {
    'id': 'p-ops',
    'key': 'ops',
    'name': 'Infrastructure',
    'color': 'amber',
    'description': 'Servers, CI and on-call.',
    'workflow_id': 'wf1',
  },
];

Map<String, Object?> _task(
  String ref,
  String title, {
  String status = 'todo',
  int priority = 3,
  String assignee = '',
  String creator = 'mira',
  List<String> tags = const [],
  String? due,
  String body = '',
  String? claimedBy,
  bool starred = false,
  Map<String, Object?> fields = const {},
  Duration age = const Duration(days: 6),
}) => {
  ...taskJson(
    ref,
    title: title,
    status: status,
    priority: priority,
    assignee: assignee,
    due: due,
    tags: tags,
    body: body,
    starred: starred,
    fields: fields,
    completed: status == 'done' ? _at(const Duration(hours: 20)) : null,
  ),
  'creator_actor_id': creator,
  'created_at': _at(age),
  'updated_at': _at(Duration(minutes: 7 + ref.hashCode % 300)),
  if (status == 'doing' || status == 'review')
    'started_at': _at(const Duration(days: 1, hours: 3)),
  if (claimedBy != null) ...{
    'claimed_by_actor_id': claimedBy,
    'claimed_at': _at(const Duration(minutes: 25)),
    'lease_expires_at': demoNow
        .add(const Duration(minutes: 35))
        .toIso8601String(),
  },
};

const _offlineBody = '''
Edits made without a connection should queue up and sync once the phone is back online, instead of failing with an error.

## Acceptance

- [x] Queue edits, comments and status changes
- [x] Show a badge with the number waiting
- [ ] Resolve conflicts when someone else changed the task
- [ ] Retry with backoff, give up after 24 hours''';

Map<String, List<Map<String, Object?>>> _tasks() => {
  'app': [
    _task(
      'app-12',
      'Offline mode: queue edits and sync later',
      status: 'doing',
      priority: 2,
      assignee: 'me',
      tags: ['android', 'ios', 'release'],
      due: _due(2),
      body: _offlineBody,
      starred: true,
      fields: {'platform': 'Both', 'estimate': 5},
      age: const Duration(days: 9),
    ),
    _task(
      'app-14',
      'Crash when opening a task from a notification',
      status: 'blocked',
      priority: 1,
      assignee: 'tomas',
      tags: ['android', 'crash'],
      due: _due(0),
      creator: 'triage',
    ),
    _task(
      'app-15',
      'Dark mode contrast on the board columns',
      status: 'review',
      assignee: 'jun',
      tags: ['a11y'],
      claimedBy: 'review-bot',
    ),
    _task(
      'app-16',
      'Swipe to complete on the task list',
      status: 'doing',
      assignee: 'mira',
      tags: ['ios', 'android'],
      due: _due(4),
    ),
    _task(
      'app-17',
      'Release notes for 2.4',
      assignee: 'me',
      tags: ['release', 'docs'],
      due: _due(3),
    ),
    _task(
      'app-18',
      'Home screen widget shows stale counts',
      priority: 2,
      assignee: 'tomas',
      tags: ['android'],
      creator: 'triage',
      due: _due(5),
    ),
    _task(
      'app-19',
      'Haptic feedback when a task is ticked',
      priority: 4,
      tags: ['ios'],
    ),
    _task(
      'app-20',
      'Larger tap targets in the filter bar',
      status: 'review',
      assignee: 'jun',
      tags: ['a11y'],
    ),
    _task(
      'app-11',
      'Sign in with a passkey',
      status: 'done',
      priority: 2,
      assignee: 'mira',
      tags: ['auth'],
    ),
    _task(
      'app-10',
      'Pull to refresh on the inbox',
      status: 'done',
      priority: 4,
      assignee: 'jun',
    ),
    _task(
      'app-21',
      'Tablet layout for the settings screen',
      assignee: 'leo',
      due: _due(9),
    ),
  ],
  'api': [
    _task(
      'api-31',
      'Push notification payload is missing the task ref',
      status: 'doing',
      priority: 1,
      assignee: 'leo',
      tags: ['crash'],
      due: _due(1),
      claimedBy: 'triage',
    ),
    _task(
      'api-32',
      'Rate limit headers on every response',
      assignee: 'leo',
      tags: ['perf'],
    ),
    _task(
      'api-33',
      'Webhook retries with exponential backoff',
      status: 'review',
      priority: 2,
      assignee: 'review-bot',
      tags: ['infra'],
    ),
    _task(
      'api-34',
      'Paginate the activity feed',
      status: 'done',
      assignee: 'leo',
      tags: ['perf'],
    ),
    _task(
      'api-35',
      'Deprecate the v0 token endpoint',
      priority: 4,
      tags: ['auth', 'docs'],
      due: _due(20),
    ),
  ],
  'web': [
    _task(
      'web-8',
      'Pricing page copy review',
      status: 'doing',
      assignee: 'mira',
      tags: ['billing'],
      due: _due(1),
    ),
    _task(
      'web-9',
      'Docs search returns stale results',
      priority: 2,
      assignee: 'me',
      tags: ['docs'],
      due: _due(-1),
    ),
    _task(
      'web-10',
      'Screenshot set for the 2.4 release',
      assignee: 'jun',
      tags: ['release'],
      due: _due(3),
    ),
  ],
  'ops': [
    _task(
      'ops-41',
      'Rotate the staging database credentials',
      status: 'doing',
      priority: 2,
      assignee: 'deploy',
      tags: ['infra'],
      claimedBy: 'deploy',
      due: _due(0, hour: 18),
    ),
    _task(
      'ops-42',
      'Nightly backup restore drill',
      priority: 2,
      assignee: 'tomas',
      tags: ['infra'],
      due: _due(6),
    ),
    _task(
      'ops-43',
      'Build cache for the release pipeline',
      status: 'review',
      assignee: 'me',
      tags: ['perf', 'release'],
      due: _due(0, hour: 18),
      body:
          'Cache the Gradle and CocoaPods downloads between release builds. '
          'A cold build takes 24 minutes today; the goal is under 10.',
    ),
    _task(
      'ops-40',
      'Alert when the push queue backs up',
      status: 'done',
      priority: 2,
      assignee: 'tomas',
      tags: ['infra'],
    ),
  ],
};

final _fields = <String, List<Map<String, Object?>>>{
  'app': [
    {
      'key': 'platform',
      'label': 'Platform',
      'type': 'enum',
      'enum_options': ['Android', 'iOS', 'Both'],
    },
    {'key': 'estimate', 'label': 'Estimate (days)', 'type': 'number'},
  ],
};

Map<String, Object?> _comment(
  String id,
  String task,
  String author,
  String body,
  Duration ago,
) => {
  'id': id,
  'task_id': 'id-$task',
  'author_actor_id': author,
  'body': body,
  'created_at': _at(ago),
  'updated_at': _at(ago),
};

final _comments = <String, List<Map<String, Object?>>>{
  'ops-43': [
    _comment(
      'c5',
      'ops-43',
      'deploy',
      'Warm cache build finished in 8 min 40 s, cold build unchanged at '
          '23 min. Ready for review.',
      const Duration(hours: 2, minutes: 5),
    ),
    _comment(
      'c6',
      'ops-43',
      'tomas',
      'Nice. Can we key the cache on the lockfiles so a dependency bump '
          'starts clean?',
      const Duration(hours: 1, minutes: 20),
    ),
  ],
  'app-12': [
    _comment(
      'c1',
      'app-12',
      'mira',
      'The queue works on Android. iOS loses it when the app is killed in '
          'the background, so it needs to be written to disk too.',
      const Duration(days: 1, hours: 5),
    ),
    _comment(
      'c2',
      'app-12',
      'me',
      'Moved it to SQLite on both platforms. A badge on the sync button now '
          'shows how many edits are waiting.',
      const Duration(hours: 20),
    ),
    _comment(
      'c3',
      'app-12',
      'review-bot',
      'Reviewed the sync changes: 14 files, tests pass on both platforms. '
          'One suggestion: retry with backoff instead of a fixed 30 second '
          'interval.',
      const Duration(hours: 3),
    ),
    _comment(
      'c4',
      'app-12',
      'tomas',
      'Conflict handling next? Two of us edited the same task on the train '
          'this morning and the second save won.',
      const Duration(minutes: 40),
    ),
  ],
};

Map<String, Object?> _entry(
  int seq,
  String action,
  String actor,
  Duration ago, {
  Map<String, Object?> before = const {},
  Map<String, Object?> after = const {},
}) => {
  'seq': seq,
  'action': action,
  'actor_id': actor,
  'subject_type': 'task',
  'subject_id': 'id-app-12',
  'occurred_at': _at(ago),
  'before': before,
  'after': after,
};

final _audit = <String, List<Map<String, Object?>>>{
  'app-12': [
    _entry(
      5,
      'task.updated',
      'me',
      const Duration(hours: 20),
      before: {'priority': 3},
      after: {'priority': 2},
    ),
    _entry(
      4,
      'task.transitioned',
      'me',
      const Duration(days: 1, hours: 3),
      before: {'status': 'todo'},
      after: {'status': 'doing'},
    ),
    _entry(
      3,
      'task.assigned',
      'mira',
      const Duration(days: 2),
      after: {'assignee_actor_id': 'me'},
    ),
    _entry(1, 'task.created', 'mira', const Duration(days: 9)),
  ],
};

final _inbox = <Map<String, Object?>>[
  inboxJson(
    'i1',
    kind: 'comment',
    ref: 'app-12',
    title: 'Offline mode: queue edits and sync later',
    actor: 'tomas',
    created: _at(const Duration(minutes: 40)),
    excerpt: 'Conflict handling next? Two of us edited the same task',
  ),
  inboxJson(
    'i2',
    ref: 'app-14',
    title: 'Crash when opening a task from a notification',
    actor: 'triage',
    created: _at(const Duration(hours: 1, minutes: 12)),
    excerpt: '@ana this looks like the payload change in api-31',
  ),
  inboxJson(
    'i3',
    kind: 'status',
    ref: 'ops-43',
    title: 'Build cache for the release pipeline',
    actor: 'review-bot',
    created: _at(const Duration(hours: 2)),
    from: 'doing',
    to: 'review',
  ),
  inboxJson(
    'i4',
    kind: 'assigned',
    ref: 'web-9',
    title: 'Docs search returns stale results',
    actor: 'mira',
    created: _at(const Duration(hours: 5)),
    read: _at(const Duration(hours: 4)),
  ),
  inboxJson(
    'i5',
    kind: 'status',
    ref: 'app-11',
    title: 'Sign in with a passkey',
    actor: 'mira',
    created: _at(const Duration(hours: 20)),
    from: 'review',
    to: 'done',
    read: _at(const Duration(hours: 18)),
  ),
];
