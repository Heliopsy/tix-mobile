// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:math' show max;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/events/tix_event.dart' show TixEventTypes;

/// The JSON body a request sent.
extension SentBody on RequestOptions {
  /// The body as a JSON object.
  Map<String, dynamic> get body => data as Map<String, dynamic>;
}

/// A canned HTTP answer.
class FakeResponse {
  const FakeResponse(
    this.status, [
    this.body,
    this.contentType = 'application/json',
  ]);

  final int status;
  final Object? body;
  final String contentType;
}

/// A Dio adapter that answers from [handler] and records every request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final FutureOr<FakeResponse> Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final r = await handler(options);
    final body = r.body;
    return ResponseBody.fromString(
      body is String ? body : jsonEncode(body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [r.contentType],
        'x-request-id': ['req-1'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> envelope(String code, String message) => {
  'error': {'code': code, 'message': message},
};

Map<String, Object?> taskJson(
  String ref, {
  String title = 'A task',
  String status = 'todo',
  int priority = 3,
  String body = '',
  String assignee = '',
  String? due,
  List<String> tags = const [],
  String parentId = '',
  String recurrence = '',
  Map<String, Object?> fields = const {},
  bool starred = false,
  String? snoozed,
  String? completed,
}) => {
  'id': 'id-$ref',
  'ref': ref,
  'project_id': ref.substring(0, ref.lastIndexOf('-')),
  'version': 1,
  'parent_id': parentId,
  'recurrence': recurrence,
  'custom_fields': fields,
  'title': title,
  'status': status,
  'priority': priority,
  'body': body,
  'assignee_actor_id': assignee,
  'due_at': due,
  'tags': tags,
  if (starred) 'starred': true,
  'snoozed_until': ?snoozed,
  'completed_at': ?completed,
};

/// tix's built-in workflow, as `GET /workflows` reports it.
Map<String, Object?> workflowJson({
  String id = 'wf1',
  String key = 'default',
  String name = 'Default',
  List<String> states = const ['todo', 'doing', 'blocked', 'done', 'cancelled'],
}) => {
  'id': id,
  'key': key,
  'name': name,
  'definition': {
    'initial': states.first,
    'states': [
      for (final s in states)
        {
          'key': s,
          'label': s[0].toUpperCase() + s.substring(1),
          'category': switch (s) {
            'todo' => 'todo',
            'doing' => 'in_progress',
            'blocked' => 'blocked',
            'done' => 'done',
            'cancelled' => 'cancelled',
            _ => 'in_progress',
          },
          'terminal': s == 'done' || s == 'cancelled',
        },
    ],
    'transitions': [
      for (final a in states)
        for (final b in states)
          if (a != b) {'from': a, 'to': b},
    ],
  },
};

Map<String, Object?> inboxJson(
  String id, {
  String kind = 'mention',
  String ref = 'infra-1',
  String title = 'Fix login',
  String actor = 'raj',
  String created = '2026-11-01T11:30:00Z',
  String? read,
  String excerpt = '',
  String from = '',
  String to = '',
  bool gone = false,
}) => {
  'id': id,
  'kind': kind,
  'task_id': 'id-$ref',
  'task_ref': ref,
  'task_title': title,
  'task_gone': gone,
  'actor_id': 'a-$actor',
  'actor_handle': actor,
  'recipient_id': 'me',
  'excerpt': excerpt,
  'from_status': from,
  'to_status': to,
  'created_at': created,
  'read_at': read,
};

/// Who a request to [FakeTix] is: the tenant it reaches, and the account
/// when it is a sign-in rather than a token.
typedef FakeCaller = ({String tenant, String? email});

/// One extra route on [FakeTix]: the answer for the request at [path], or
/// null when the route does not serve it.
typedef FakeRoute = FutureOr<FakeResponse?> Function(
  RequestOptions o,
  String path,
  FakeCaller caller,
);

/// One extra route answered without a credential, before the caller is
/// known.
typedef FakePublicRoute = FutureOr<FakeResponse?> Function(
  RequestOptions o,
  String path,
);

/// A person who can sign in: their password and their tenants.
class FakeAccount {
  FakeAccount({
    required this.password,
    this.tenants = const ['default'],
    this.handle = 'ana',
  });

  final String password;
  final List<String> tenants;
  final String handle;
}

/// An in-memory tix server: enough of `/api/v1` for the app's screens, with
/// API tokens, sign-in, the second factor and tenant switching. Like tix, it
/// takes a session only as the `tix_session` cookie and refuses a request
/// whose bearer token it does not know.
class FakeTix {
  FakeTix({
    this.token = 'tok',
    List<Map<String, Object?>>? projects,
    Map<String, List<Map<String, Object?>>>? tasks,
  }) : projects =
           projects ??
           [
             {
               'id': 'p1',
               'key': 'infra',
               'name': 'Infrastructure',
               'color': 'blue',
               'workflow_id': 'wf1',
             },
             {
               'id': 'p2',
               'key': 'web',
               'name': 'Web',
               'color': 'violet',
               'workflow_id': 'wf1',
             },
           ],
       tasks =
           tasks ??
           {
             'infra': [
               taskJson(
                 'infra-1',
                 title: 'Fix login',
                 priority: 1,
                 body: '# Steps\n\n- [ ] reproduce',
                 assignee: 'a1',
                 due: '2026-11-20T00:00:00Z',
                 tags: ['auth'],
               ),
               taskJson('infra-2', title: 'Rotate keys'),
             ],
           } {
    tokens[token] = 'default';
  }

  /// The default API token, in the tenant `default`.
  final String token;
  final List<Map<String, Object?>> projects;
  final Map<String, List<Map<String, Object?>>> tasks;
  final actors = <String, Map<String, Object?>>{
    'me': {'id': 'me', 'handle': 'ana', 'kind': 'user'},
    'a1': {'id': 'a1', 'handle': 'raj', 'display_name': 'Raj', 'kind': 'user'},
  };

  /// API tokens and the tenant each was minted in.
  final tokens = <String, String>{};

  /// Tenants by key: their name and their own host, empty when shared.
  final tenants = <String, ({String name, String host})>{
    'default': (name: 'Default', host: ''),
  };

  /// Projects per tenant; a tenant not listed sees [projects].
  final tenantProjects = <String, List<Map<String, Object?>>>{};

  /// People who can sign in, by email.
  final accounts = <String, FakeAccount>{
    'ana@example.com': FakeAccount(password: 'pw'),
  };

  /// Live sessions: email and tenant.
  final sessions = <String, ({String email, String tenant})>{};

  /// Whether a password sign-in asks for a code first.
  bool requireCode = false;

  /// The challenge kind a password sign-in answers with when set.
  String? challengeKind;

  /// The theme each tenant names, as `GET /tenants/{ref}` reports it.
  final tenantThemes = <String, String>{};

  /// API tokens refused `GET /tenants/{id}`, as tix refuses a token
  /// without `tenant:admin`.
  final narrowTokens = <String>{};

  /// Tenants a switch into asks for a second factor this account lacks.
  final switchNeedsSetup = <String>{};

  /// Tenants a switch into asks for a code first.
  final switchNeedsCode = <String>{};

  /// The code the second factor accepts.
  static const goodCode = '123456';

  var _sessions = 0;

  /// Answers every request with this when set, for failure paths.
  FakeResponse? override;

  /// Holds every answer until completed, for loading states.
  Completer<void>? gate;

  /// Extra routes, asked in order before the built-in ones once the caller
  /// is known. Each answers what it serves and returns null for the rest.
  final routes = <FakeRoute>[];

  /// Extra routes asked before any credential is checked.
  final publicRoutes = <FakePublicRoute>[];

  /// Rows per page, so tests can force pagination.
  int pageSize = 50;

  /// The caller's inbox, newest first.
  final inbox = <Map<String, Object?>>[
    inboxJson('i1', excerpt: '@ana can you look at this?'),
    inboxJson(
      'i2',
      kind: 'status',
      ref: 'infra-2',
      title: 'Rotate keys',
      created: '2026-10-31T09:00:00Z',
      from: 'todo',
      to: 'doing',
      read: '2026-10-31T10:00:00Z',
    ),
    inboxJson(
      'i3',
      kind: 'assigned',
      ref: 'web-7',
      title: 'Ship the banner',
      actor: 'lee',
      created: '2026-10-20T09:00:00Z',
    ),
  ];

  /// The kinds the caller muted.
  final inboxMuted = <String>[];

  /// The caller's channels.
  final channels = <Map<String, Object?>>[];

  /// Deliveries per channel id, newest first.
  final deliveries = <String, List<Map<String, Object?>>>{};

  /// What `GET /stats` answers for the inbox summary, in place of the
  /// counts worked out from [tasks]; null leaves those.
  Map<String, Object?>? inboxStats;

  /// What `GET /tasks?assignee=me` answers for the inbox summary; null
  /// leaves the ordinary listing.
  List<Map<String, Object?>>? dueTasks;

  /// Sets [inboxStats] and [dueTasks] to a summary with one overdue task
  /// and one due today.
  void withSummary() {
    inboxStats = {
      'by_category': [
        {'category': 'todo', 'count': 5},
        {'category': 'in_progress', 'count': 2},
        {'category': 'blocked', 'count': 1},
        {'category': 'done', 'count': 9},
      ],
      'completed': 4,
      'created': 6,
    };
    dueTasks = [
      taskJson('infra-1', title: 'Fix login', due: '2026-10-30T00:00:00Z'),
      taskJson('infra-5', title: 'Renew cert', due: '2026-11-01T18:00:00Z'),
    ];
  }

  /// Whether `/me/time` exists; an older server answers 404.
  bool keepsTime = false;

  /// Whether project stars exist; an older server answers 404.
  bool keepsProjectStars = false;

  /// The keys of the projects the caller starred, in order.
  final projectStars = <String>[];

  List<Map<String, Object?>> _starMarked(List<Map<String, Object?>> list) => [
    for (final p in list)
      if (keepsProjectStars && projectStars.contains(p['key']))
        {...p, 'starred': true}
      else
        p,
  ];

  /// The date preferences at each level, as `/me/time` reports them.
  final timeGlobal = <String, String>{'time_format': '', 'timezone': ''};
  final timeTenant = <String, String>{'time_format': '', 'timezone': ''};
  final timeUser = <String, String>{'time_format': '', 'timezone': ''};

  /// Whether the caller may hold a date preference of their own.
  bool timePersonal = true;

  Map<String, Object?> _timeSettings() {
    (String, String) pick(String field) {
      if (timeUser[field]!.isNotEmpty) return (timeUser[field]!, 'user');
      if (timeTenant[field]!.isNotEmpty) return (timeTenant[field]!, 'tenant');
      return (timeGlobal[field]!, 'global');
    }

    final (format, formatSource) = pick('time_format');
    final (zone, zoneSource) = pick('timezone');
    return {
      'global': {...timeGlobal},
      'tenant': {...timeTenant},
      'user': {...timeUser},
      'effective': {'time_format': format, 'timezone': zone},
      'format_source': formatSource,
      'timezone_source': zoneSource,
      'personal': timePersonal,
    };
  }

  /// Answers to these paths with this, for one route's failure.
  final failing = <String, FakeResponse>{};

  late final adapter = FakeAdapter(_handle);

  /// The event log `GET /api/v1/events/poll` reads, oldest first.
  final eventLog = <Map<String, Object?>>[];

  /// Whether the poll endpoint exists; false answers 404 as a tix older
  /// than it does.
  bool pollSupported = true;

  /// Answers every poll with this when set, for refusals.
  FakeResponse? pollAnswer;

  /// Fails every poll as an unreachable server would.
  bool pollOffline = false;

  /// The longest poll wait this server takes, as one with a short request
  /// timeout refuses a longer one.
  int maxWait = 25;

  /// The oldest event the log still keeps; a poll from before it is
  /// refused as tix refuses an expired cursor.
  int oldestRetained = 0;

  Completer<void> _logged = Completer<void>();

  /// Commits an event with [seq] and [type], waking polls waiting for one.
  void addEvent(
    int seq,
    String type, {
    String subjectId = 'id-infra-1',
    String projectId = 'p1',
  }) {
    eventLog.add({
      'seq': seq,
      'type': type,
      'subject_type': type.split('.').first,
      'subject_id': subjectId,
      'project_id': projectId,
      'occurred_at': '2026-11-08T10:00:00Z',
    });
    final woke = _logged;
    _logged = Completer<void>();
    woke.complete();
  }

  /// Requests to the poll endpoint, in order.
  List<RequestOptions> get polls => requestsTo('/api/v1/events/poll');

  Future<FakeResponse> _poll(
    Map<String, String> q, [
    Map<String, List<String>> all = const {},
  ]) async {
    if (pollOffline) {
      throw const SocketException('network is unreachable');
    }
    final answer = pollAnswer;
    if (answer != null) return answer;
    if (!pollSupported) {
      return FakeResponse(404, envelope('not_found', 'no such route'));
    }
    final head = eventLog.isEmpty ? 0 : eventLog.last['seq']! as int;
    final requested = int.tryParse(q['since_seq'] ?? '') ?? 0;
    if (requested > 0 && requested < oldestRetained - 1) {
      return FakeResponse(
        400,
        envelope(
          'invalid',
          'cursor $requested is no longer available; '
              'the oldest retained event is $oldestRetained',
        ),
      );
    }
    final since = requested == 0 ? head : requested;
    final limit = int.tryParse(q['limit'] ?? '') ?? 200;
    final wait = int.tryParse((q['wait'] ?? '0s').replaceAll('s', '')) ?? 0;
    final types = [
      for (final t in all['types'] ?? const <String>[]) ...t.split(','),
    ];
    final projects = [
      for (final p in all['project_ids'] ?? const <String>[]) ...p.split(','),
    ];
    bool kept(Map<String, Object?> e) =>
        (types.isEmpty ||
            types.any((t) => TixEventTypes.matches(t, e['type']! as String))) &&
        (projects.isEmpty || projects.contains(e['project_id']));
    List<Map<String, Object?>> after() => [
      for (final e in eventLog)
        if ((e['seq']! as int) > since && kept(e)) e,
    ].take(limit).toList();
    int read() =>
        eventLog.isEmpty ? since : max(since, eventLog.last['seq']! as int);
    if (wait > maxWait) {
      return FakeResponse(
        400,
        envelope(
          'invalid',
          "wait ${wait}s must be shorter than this server's request timeout",
        ),
      );
    }
    var events = after();
    if (events.isEmpty && wait > 0) {
      await Future.any([
        _logged.future,
        Future<void>.delayed(Duration(seconds: wait)),
      ]);
      events = after();
    }
    return FakeResponse(200, {
      'events': events,
      'next_seq': events.length == limit ? events.last['seq'] : read(),
    });
  }

  /// A factory override that sends every client to this server.
  TixApiFactory get factory =>
      (baseUrl, credential, {tenant}) => TixApi(
        baseUrl: baseUrl,
        credential: credential,
        tenant: tenant,
        adapter: adapter,
      );

  List<RequestOptions> get requests => adapter.requests;

  /// Requests to [path], in order.
  List<RequestOptions> requestsTo(String path) => [
    for (final r in requests)
      if (r.uri.path.endsWith(path)) r,
  ];

  /// Starts a session for [email] in [tenant] and returns its token.
  String startSession(String email, String tenant) {
    final t = 'sess-${++_sessions}';
    sessions[t] = (email: email, tenant: tenant);
    return t;
  }

  Map<String, Object?> _session(String email, String tenant) => {
    'session': {
      'token': startSession(email, tenant),
      'actor_id': 'me',
      'tenant_id': 'id-$tenant',
      'expires_at': '2026-11-09T00:00:00Z',
    },
  };

  Map<String, Object?> _membership(String key, String handle) => {
    'tenant_id': 'id-$key',
    'tenant_key': key,
    'tenant_name': tenants[key]?.name ?? key,
    'actor_id': 'me-$key',
    'handle': handle,
    'role': 'admin',
    'host': tenants[key]?.host ?? '',
  };

  /// Who the request is, or a refusal.
  ({String tenant, String? email})? _caller(RequestOptions o) {
    final auth = o.headers['Authorization'] as String?;
    if (auth != null) {
      final tenant = tokens[_bearer(o)];
      return tenant == null ? null : (tenant: tenant, email: null);
    }
    final cookie = o.headers['Cookie'] as String?;
    final session = sessions[cookie?.replaceFirst('tix_session=', '')];
    return session == null
        ? null
        : (tenant: session.tenant, email: session.email);
  }

  static String? _bearer(RequestOptions o) =>
      (o.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');

  Future<FakeResponse> _handle(RequestOptions o) async {
    if (offline) {
      throw DioException.connectionError(requestOptions: o, reason: 'offline');
    }
    final held = gate;
    if (held != null) await held.future;
    final forced = override;
    if (forced != null) return forced;
    final path = o.uri.path.replaceFirst(
      RegExp(r'^.*?(?=/api/v1/|/healthz$)'),
      '',
    );
    if (path == '/healthz') {
      return const FakeResponse(200, {'status': 'ok', 'version': 'v1.2.3'});
    }
    if (o.method == 'POST' && path == '/api/v1/auth/login') {
      return _login(o.data as Map<String, dynamic>);
    }
    for (final route in publicRoutes) {
      final answer = await route(o, path);
      if (answer != null) return answer;
    }
    final caller = _caller(o);
    if (caller == null) {
      return FakeResponse(401, envelope('unauthenticated', 'bad token'));
    }
    final q = o.uri.queryParameters;
    final failure = failing[path];
    if (failure != null) return failure;
    for (final route in routes) {
      final failure = failures['${o.method} $path'];
      if (failure != null) return failure;
      final answer = await route(o, path, caller);
      if (answer != null) return answer;
    }
    final inboxAnswer = _inbox(o, path, q);
    if (inboxAnswer != null) return inboxAnswer;
    final quick = await _quick(o, path);
    if (quick != null) return quick;
    switch ((o.method, path)) {
      case ('GET', '/api/v1/events/poll'):
        return await _poll(q, o.uri.queryParametersAll);
      case ('GET', '/api/v1/me/time') when keepsTime:
        return FakeResponse(200, _timeSettings());
      case ('GET', '/api/v1/me/starred-projects') when keepsProjectStars:
        return FakeResponse(200, {
          'items': [
            for (final key in projectStars)
              for (final p in projects)
                if (p['key'] == key) {...p, 'starred': true},
          ],
        });
      case ('PATCH', '/api/v1/me/time') when keepsTime:
        if (!timePersonal) {
          return FakeResponse(403, envelope('forbidden', 'not a person'));
        }
        final body = o.data as Map<String, dynamic>;
        for (final f in ['time_format', 'timezone']) {
          if (body[f] case final String v) timeUser[f] = v;
        }
        return FakeResponse(200, _timeSettings());
      case ('GET', '/api/v1/whoami'):
        final account = accounts[caller.email];
        if (account == null) {
          // A token answers as an agent with its tenant's id alone.
          return FakeResponse(200, {
            ...actors['me']!,
            'kind': 'agent',
            'tenant_id': 'id-${caller.tenant}',
            ...identity,
          });
        }
        return FakeResponse(200, {
          ...actors['me']!,
          'handle': account.handle,
          'tenant_id': 'id-${caller.tenant}',
          'tenant_key': caller.tenant,
          'tenant_name': tenants[caller.tenant]?.name ?? caller.tenant,
          'email': caller.email,
          'memberships': [
            for (final t in account.tenants) _membership(t, account.handle),
          ],
          ...identity,
        });
      case ('POST', '/api/v1/auth/switch'):
        return _switch(o, caller, o.data as Map<String, dynamic>);
      case ('POST', '/api/v1/auth/logout'):
        sessions.remove(
          (o.headers['Cookie'] as String?)?.replaceFirst('tix_session=', ''),
        );
        return const FakeResponse(204);
      case ('GET', '/api/v1/projects'):
        return FakeResponse(
          200,
          _page(
            _starMarked(tenantProjects[caller.tenant] ?? projects),
            q['cursor'],
          ),
        );
      case ('GET', '/api/v1/tasks'):
        return FakeResponse(200, _page(_list(o.uri), q['cursor']));
      case ('POST', '/api/v1/tasks/bulk'):
        return FakeResponse(200, _bulk(o.data as Map<String, dynamic>));
      case ('GET', '/api/v1/workflows'):
        return FakeResponse(200, {'items': _allWorkflows, 'next_cursor': ''});
      case ('GET', '/api/v1/stats'):
        return _stats(q['project']);
      case ('GET', '/api/v1/filters'):
        return FakeResponse(200, {'items': filters, 'next_cursor': ''});
      case ('POST', '/api/v1/filters'):
        final body = o.data as Map<String, dynamic>;
        if (filters.any((f) => f['name'] == body['name'])) {
          return FakeResponse(409, envelope('conflict', 'name in use'));
        }
        final f = <String, Object?>{
          'id': 'f${++_filterIds}',
          ...body,
          'mine': true,
          'editable': true,
          'position': filters.length + 1,
        };
        filters.add(f);
        return FakeResponse(201, f);
      case ('PUT', '/api/v1/filters/order'):
        final ids = ((o.data as Map)['filters'] as List).cast<String>();
        filters.sort(
          (a, b) => ids
              .indexOf(a['id']! as String)
              .compareTo(ids.indexOf(b['id']! as String)),
        );
        return FakeResponse(200, {'items': filters, 'next_cursor': ''});
      case ('POST', '/api/v1/tasks'):
        final body = o.data as Map<String, dynamic>;
        final project = body['project_ref'] as String;
        final list = tasks.putIfAbsent(project, () => []);
        final created = taskJson(
          '$project-${list.length + 1}',
          title: (body['title'] as String).split(' !').first,
        );
        list.insert(0, created);
        return FakeResponse(201, created);
    }
    final detail = _detail(o, path);
    if (detail != null) return detail;
    final segments = path.substring(1).split('/');
    final more = _more(o, segments);
    if (more != null) return more;
    if (o.method == 'GET' && segments.length == 4) {
      final id = segments[3];
      if (segments[2] == 'tenants') {
        if (narrowTokens.contains(_bearer(o))) {
          return FakeResponse(403, envelope('forbidden', 'tenant:admin'));
        }
        if (id != 'id-${caller.tenant}' && id != caller.tenant) {
          return FakeResponse(404, envelope('not_found', 'tenant'));
        }
        return FakeResponse(200, {
          'id': 'id-${caller.tenant}',
          'key': caller.tenant,
          'name': tenants[caller.tenant]?.name ?? caller.tenant,
          'theme': tenantThemes[caller.tenant] ?? '',
        });
      }
      if (segments[2] == 'tasks') {
        for (final list in tasks.values) {
          for (final t in list) {
            if (t['ref'] == id) return FakeResponse(200, t);
          }
        }
        return FakeResponse(404, envelope('not_found', 'task "$id"'));
      }
      if (segments[2] == 'actors' && actors.containsKey(id)) {
        return FakeResponse(200, actors[id]);
      }
    }
    return FakeResponse(404, envelope('not_found', path));
  }

  var _channelSeq = 0;

  FakeResponse? _inbox(RequestOptions o, String path, Map<String, String> q) {
    final segments = path.substring(1).split('/');
    switch ((o.method, path)) {
      case ('GET', '/api/v1/inbox'):
        final rows = q['unread'] == 'true'
            ? [
                for (final i in inbox)
                  if (i['read_at'] == null) i,
              ]
            : inbox;
        return FakeResponse(200, _page(rows, q['cursor']));
      case ('GET', '/api/v1/inbox/count'):
        return FakeResponse(200, {
          'unread': inbox.where((i) => i['read_at'] == null).length,
        });
      case ('POST', '/api/v1/inbox/read-all'):
        var marked = 0;
        for (final i in inbox) {
          if (i['read_at'] == null) {
            i['read_at'] = '2026-11-01T12:00:00Z';
            marked++;
          }
        }
        return FakeResponse(200, {'marked': marked});
      case ('GET', '/api/v1/inbox/prefs'):
        return FakeResponse(200, {'muted': inboxMuted});
      case ('PUT', '/api/v1/inbox/prefs'):
        final muted = ((o.data as Map)['muted'] as List).cast<String>();
        inboxMuted
          ..clear()
          ..addAll(muted);
        return FakeResponse(200, {'muted': inboxMuted});
      case ('GET', '/api/v1/stats') when inboxStats != null:
        return FakeResponse(200, inboxStats);
      case ('GET', '/api/v1/tasks')
          when q['assignee'] == 'me' && dueTasks != null:
        return FakeResponse(200, {'items': dueTasks, 'next_cursor': ''});
      case ('GET', '/api/v1/channels'):
        return FakeResponse(200, {'items': channels, 'next_cursor': ''});
      case ('POST', '/api/v1/channels'):
        final body = o.data as Map<String, dynamic>;
        if ((body['url'] as String? ?? '').startsWith('http:')) {
          return const FakeResponse(400, {
            'error': {
              'code': 'invalid',
              'message': 'url must be https',
              'details': {'field': 'url'},
            },
          });
        }
        final channel = {
          'id': 'ch${++_channelSeq}',
          'name': body['name'],
          'url': body['url'],
          'format': body['format'] ?? 'generic',
          'kinds':
              body['kinds'] ?? ['mention', 'assigned', 'status', 'comment'],
          'active': body['active'] ?? true,
        };
        channels.add(channel);
        return FakeResponse(201, {...channel, 'secret': 'whsec_test'});
    }
    if (segments.length >= 4 &&
        segments[2] == 'inbox' &&
        segments.last == 'read') {
      final item = inbox.where((i) => i['id'] == segments[3]).firstOrNull;
      if (item == null) return FakeResponse(404, envelope('not_found', 'item'));
      item['read_at'] = o.method == 'PUT' ? '2026-11-01T12:00:00Z' : null;
      return FakeResponse(200, item);
    }
    if (segments.length >= 4 && segments[2] == 'channels') {
      final channel = channels.where((c) => c['id'] == segments[3]).firstOrNull;
      if (channel == null) {
        return FakeResponse(404, envelope('not_found', 'channel'));
      }
      final id = channel['id']! as String;
      if (segments.length == 4 && o.method == 'PATCH') {
        final body = o.data as Map<String, dynamic>;
        channel.addAll({
          for (final e in body.entries)
            if (e.value != null) e.key: e.value,
        });
        return FakeResponse(200, channel);
      }
      if (segments.length == 4 && o.method == 'DELETE') {
        channels.remove(channel);
        return const FakeResponse(204);
      }
      if (segments.length == 5 && segments[4] == 'test') {
        final d = {
          'id': 'd${DateTime.now().microsecondsSinceEpoch}',
          'channel_id': id,
          'item_id': '',
          'status': 'delivered',
          'attempts': 1,
          'last_status_code': 200,
          'created_at': '2026-11-01T12:00:00Z',
        };
        deliveries.putIfAbsent(id, () => []).insert(0, d);
        return FakeResponse(200, d);
      }
      if (segments.length == 5 && segments[4] == 'deliveries') {
        return FakeResponse(200, _page(deliveries[id] ?? [], q['cursor']));
      }
    }
    if (segments.length == 5 &&
        segments[2] == 'channel-deliveries' &&
        segments[4] == 'redeliver') {
      for (final list in deliveries.values) {
        for (final d in list) {
          if (d['id'] == segments[3]) {
            d['status'] = 'pending';
            return const FakeResponse(204);
          }
        }
      }
      return FakeResponse(404, envelope('not_found', 'delivery'));
    }
    return null;
  }

  final _tickets = <String, String>{};

  FakeResponse _login(Map<String, dynamic> body) {
    final ticket = body['ticket'] as String?;
    if (ticket != null) {
      final email = _tickets[ticket];
      if (email == null || body['code'] != goodCode) {
        return FakeResponse(401, envelope('unauthenticated', 'bad code'));
      }
      _tickets.remove(ticket);
      return FakeResponse(200, _session(email, accounts[email]!.tenants.first));
    }
    final email = body['email'] as String?;
    final account = accounts[email];
    if (account == null || account.password != body['password']) {
      return FakeResponse(401, envelope('unauthenticated', 'bad password'));
    }
    final kind = challengeKind;
    if (kind != null) {
      return FakeResponse(200, {
        'challenge': {'kind': kind, 'ticket': ''},
      });
    }
    if (requireCode) {
      final t = 'ticket-${_tickets.length + 1}';
      _tickets[t] = email!;
      return FakeResponse(200, {
        'challenge': {'kind': 'code', 'ticket': t},
      });
    }
    return FakeResponse(200, _session(email!, account.tenants.first));
  }

  FakeResponse _switch(
    RequestOptions o,
    ({String tenant, String? email}) caller,
    Map<String, dynamic> body,
  ) {
    final email = caller.email;
    final target = body['tenant'] as String;
    if (email == null) {
      return FakeResponse(400, envelope('invalid', 'only a session switches'));
    }
    if (!accounts[email]!.tenants.contains(target)) {
      return FakeResponse(403, envelope('forbidden', 'not a member'));
    }
    final host = tenants[target]?.host ?? '';
    if (host.isNotEmpty && host != o.uri.host) {
      return FakeResponse(
        400,
        envelope('invalid', 'tenant "$target" is served at its own address'),
      );
    }
    if (switchNeedsSetup.contains(target)) {
      return const FakeResponse(403, {
        'error': {
          'code': 'forbidden',
          'message': 'requires a second factor',
          'details': {'reason': 'second_factor_required'},
        },
      });
    }
    if (switchNeedsCode.contains(target) && body['code'] != goodCode) {
      return const FakeResponse(200, {
        'challenge': {'kind': 'code', 'ticket': ''},
      });
    }
    sessions.remove(
      (o.headers['Cookie'] as String?)?.replaceFirst('tix_session=', ''),
    );
    return FakeResponse(200, _session(email, target));
  }

  /// The workflow every project follows: tix's default, with a comment
  /// required to block a task that is being worked on.
  Map<String, Object?> workflow = {
    'id': 'wf1',
    'key': 'default',
    'name': 'Default',
    'definition': {
      'initial': 'todo',
      'states': [
        {'key': 'todo', 'label': 'To do', 'category': 'todo'},
        {'key': 'doing', 'label': 'Doing', 'category': 'in_progress'},
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
        {'from': 'todo', 'to': 'doing'},
        {'from': 'todo', 'to': 'cancelled'},
        {'from': 'doing', 'to': 'todo'},
        {'from': 'doing', 'to': 'blocked', 'requires_comment': true},
        {'from': 'doing', 'to': 'done'},
        {'from': 'blocked', 'to': 'doing'},
        {'from': 'done', 'to': 'todo'},
        {'from': 'cancelled', 'to': 'todo'},
      ],
    },
  };

  /// Custom fields per project key.
  final fields = <String, List<Map<String, Object?>>>{
    'infra': [
      {
        'key': 'env',
        'label': 'Environment',
        'type': 'enum',
        'enum_options': ['production', 'staging'],
      },
      {'key': 'window', 'label': 'Change window', 'type': 'string'},
      {'key': 'paged', 'label': 'Paged', 'type': 'bool'},
    ],
  };

  /// Comments per task reference, oldest first.
  final comments = <String, List<Map<String, Object?>>>{};

  /// Ids of the tasks each task (by id) waits for.
  final deps = <String, List<String>>{};

  /// Artifacts per task reference.
  final artifacts = <String, List<Map<String, Object?>>>{};

  /// Audit entries per task reference, newest first.
  final audit = <String, List<Map<String, Object?>>>{};

  /// Whether the server predates comment reactions and answers 404.
  bool reactionsMissing = false;

  /// The tenant's tags.
  final tagNames = <String>['auth', 'ops', 'backend'];

  /// Whether deleted tasks go to the trash.
  bool trashEnabled = true;

  /// Deleted tasks, by reference.
  final trash = <String, Map<String, Object?>>{};

  /// Routes that stop at a state, by task reference: the state and why.
  final routeStops = <String, ({String state, String reason})>{};

  /// Canned answers by `'METHOD /api/v1/...'`, for failure paths.
  final failures = <String, FakeResponse>{};

  var _ids = 0;

  /// The tenant's workflows, [workflow] first, as `GET /workflows` lists them.
  late final workflows = <Map<String, Object?>>[workflow];

  /// The reader's view arrangements, by view then group.
  final views = <String, Map<String, Map<String, Object?>>>{};

  /// The reader's saved filters and those shared with them, in order.
  final filters = <Map<String, Object?>>[];

  /// Bulk refusals by reference: the error code and message.
  final refuse = <String, (String, String)>{};

  var _filterIds = 0;

  /// The task [ref], by reference or id.
  Map<String, Object?>? task(String ref) {
    for (final list in tasks.values) {
      for (final t in list) {
        if (t['ref'] == ref || t['id'] == ref) return t;
      }
    }
    return null;
  }

  FakeResponse _missing(String ref) =>
      FakeResponse(404, envelope('not_found', 'task "$ref"'));

  FakeResponse? _detail(RequestOptions o, String path) {
    final failure = failures['${o.method} $path'];
    if (failure != null) return failure;
    final body = o.data is Map<String, dynamic>
        ? o.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final s = path.substring('/api/v1/'.length).split('/');
    final managed = _manage(o, s, body);
    if (managed != null) return managed;
    switch ((o.method, s)) {
      case ('GET', ['actors']):
        return FakeResponse(200, {'items': actors.values.toList()});
      case ('GET', ['tags']):
        return FakeResponse(200, {
          'items': [
            for (final n in tagNames) {'id': 't-$n', 'name': n},
          ],
        });
      case ('GET', ['trash']):
        return FakeResponse(200, {
          'enabled': trashEnabled,
          'held': trash.length,
        });
      case ('GET', ['workflows', _]):
        return FakeResponse(200, workflow);
      case ('PUT' || 'DELETE', ['projects', final key, 'star'])
          when keepsProjectStars:
        if (!projects.any((p) => p['key'] == key)) {
          return FakeResponse(404, envelope('not_found', 'project "$key"'));
        }
        if (o.method == 'DELETE') {
          projectStars.remove(key);
        } else if (!projectStars.contains(key)) {
          projectStars.add(key);
        }
        return const FakeResponse(204);
      case ('GET', ['projects', final key]):
        for (final p in projects) {
          if (p['key'] == key || p['id'] == key) return FakeResponse(200, p);
        }
        return FakeResponse(404, envelope('not_found', 'project "$key"'));
      case ('GET', ['projects', final key, 'fields']):
        final project = projects.firstWhere(
          (p) => p['key'] == key || p['id'] == key,
          orElse: () => {'key': key},
        );
        return FakeResponse(200, {'items': fields[project['key']] ?? []});
      case ('PATCH', ['comments', final id]):
        for (final list in comments.values) {
          for (final c in list) {
            if (c['id'] == id) {
              c['body'] = body['body'];
              c['updated_at'] = '2026-11-08T12:00:00Z';
              return FakeResponse(200, c);
            }
          }
        }
        return FakeResponse(404, envelope('not_found', 'comment'));
      case (final m, ['comments', final id, 'reactions', final raw])
          when m == 'PUT' || m == 'DELETE':
        if (reactionsMissing) {
          return FakeResponse(404, envelope('not_found', 'no route'));
        }
        final emoji = Uri.decodeComponent(raw);
        for (final list in comments.values) {
          for (final c in list) {
            if (c['id'] != id) continue;
            final reactions = [
              for (final r in (c['reactions'] as List?) ?? const [])
                Map<String, Object?>.of(r as Map<String, Object?>),
            ];
            var r = reactions.where((r) => r['emoji'] == emoji).firstOrNull;
            if (r == null) {
              r = {'emoji': emoji, 'count': 0, 'actor_ids': <String>[]};
              reactions.add(r);
            }
            final ids = [...(r['actor_ids']! as List).cast<String>()]
              ..remove('me');
            if (m == 'PUT') ids.add('me');
            r['actor_ids'] = ids;
            r['count'] = ids.length;
            c['reactions'] = [
              for (final x in reactions)
                if ((x['count']! as int) > 0) x,
            ];
            return FakeResponse(200, c);
          }
        }
        return FakeResponse(404, envelope('not_found', 'comment'));
      case ('DELETE', ['comments', final id]):
        for (final list in comments.values) {
          list.removeWhere((c) => c['id'] == id);
        }
        return const FakeResponse(204);
      case ('POST', ['tasks', final ref, 'restore']):
        final t = trash.remove(ref);
        if (t == null) return _missing(ref);
        tasks[t['project_id']]!.add(t);
        return FakeResponse(200, t);
    }
    if (s.length < 2 || s[0] != 'tasks') return null;
    final ref = s[1];
    final t = task(ref);
    if (t == null) return null;
    final id = t['id']! as String;
    final tref = t['ref']! as String;
    void bump() => t['version'] = (t['version']! as int) + 1;
    switch ((o.method, s.sublist(2))) {
      case ('GET', []):
        return FakeResponse(200, t);
      case ('PATCH', []):
        final version = body['version'] as int?;
        if (version != null && version != 0 && version != t['version']) {
          return FakeResponse(409, envelope('conflict', 'stale version'));
        }
        if (body['recurrence'] == 'every blue moon') {
          return FakeResponse(400, envelope('invalid', 'cannot read rule'));
        }
        for (final MapEntry(:key, :value) in body.entries) {
          if (key == 'version') continue;
          if (key == 'custom_fields') {
            final merged = {...t['custom_fields']! as Map<String, Object?>};
            for (final e in (value as Map<String, dynamic>).entries) {
              if (e.value == null) {
                merged.remove(e.key);
              } else {
                merged[e.key] = e.value;
              }
            }
            t['custom_fields'] = merged;
          } else {
            t[key] = value;
          }
        }
        bump();
        return FakeResponse(200, t);
      case ('DELETE', []):
        if (o.uri.queryParameters['cascade'] != 'true' &&
            tasks.values.any((l) => l.any((x) => x['parent_id'] == id))) {
          return FakeResponse(
            422,
            envelope('precondition_failed', 'task has subtasks'),
          );
        }
        for (final list in tasks.values) {
          list.removeWhere((x) => x['id'] == id);
        }
        if (trashEnabled && o.uri.queryParameters['hard'] != 'true') {
          trash[tref] = t;
        }
        return const FakeResponse(204);
      case ('POST', ['checklist']):
        final version = body['version'] as int?;
        if (version != null && version != t['version']) {
          return FakeResponse(409, envelope('conflict', 'stale version'));
        }
        final lines = (t['body']! as String).split('\n');
        var n = 0;
        for (var i = 0; i < lines.length; i++) {
          final m = RegExp(r'^(\s*[-*+] \[)[ xX](\].*)$').firstMatch(lines[i]);
          if (m != null && ++n == body['item']) {
            lines[i] =
                '${m.group(1)}${body['done'] == true ? 'x' : ' '}${m.group(2)}';
          }
        }
        if ((body['item'] as int) > n) {
          return FakeResponse(400, envelope('invalid', 'no item'));
        }
        t['body'] = lines.join('\n');
        bump();
        return FakeResponse(200, t);
      case ('POST', ['route']):
        final from = t['status']! as String;
        final to = body['to'] as String;
        final stop = routeStops[tref];
        if (stop != null) {
          return FakeResponse(200, {
            'from': from,
            'route': [stop.state, to],
            'applied': <String>[],
            'stopped': stop.state,
            'reason': stop.reason,
            'task': t,
          });
        }
        t['status'] = to;
        bump();
        return FakeResponse(200, {
          'from': from,
          'route': [to],
          'applied': [to],
          'task': t,
        });
      case ('POST', ['transition']):
        t['status'] = body['to'];
        bump();
        return FakeResponse(200, t);
      case ('PUT', ['star']):
        t['starred'] = true;
        return const FakeResponse(204);
      case ('DELETE', ['star']):
        t['starred'] = false;
        return const FakeResponse(204);
      case ('PUT', ['snooze']):
        t['snoozed_until'] = body['until'];
        bump();
        return FakeResponse(200, t);
      case ('DELETE', ['snooze']):
        t.remove('snoozed_until');
        bump();
        return FakeResponse(200, t);
      case ('POST', ['copy']):
        final project = (body['project_ref'] as String?) ?? t['project_id'];
        final list = tasks.putIfAbsent(project! as String, () => []);
        final copy = {
          ...t,
          'id': 'id-$project-copy${list.length + 1}',
          'ref': '$project-${list.length + 1}',
          'title': body['title'] ?? t['title'],
          'project_id': project,
          if (body['link'] == true) 'copied_from_id': id,
        };
        list.add(copy);
        return FakeResponse(201, copy);
      case ('GET', ['tree']):
        return FakeResponse(200, {
          'items': [
            t,
            for (final list in tasks.values)
              for (final x in list)
                if (x['parent_id'] == id) x,
          ],
        });
      case ('GET', ['audit']):
        final actions = o.uri.queryParametersAll['action'];
        final rows = [
          for (final r in audit[tref] ?? const <Map<String, Object?>>[])
            if (actions == null || actions.contains(r['action'])) r,
        ];
        return FakeResponse(200, _page(rows, o.uri.queryParameters['cursor']));
      case ('POST', ['tags']):
        final tags = [...(t['tags']! as List).cast<String>()];
        if (!tags.contains(body['name'])) tags.add(body['name'] as String);
        t['tags'] = tags;
        if (!tagNames.contains(body['name'])) {
          tagNames.add(body['name'] as String);
        }
        return const FakeResponse(204);
      case ('DELETE', ['tags', final name]):
        t['tags'] = [
          for (final x in (t['tags']! as List).cast<String>())
            if (x != name) x,
        ];
        return const FakeResponse(204);
      case ('GET', ['comments']):
        return FakeResponse(200, {'items': comments[tref] ?? []});
      case ('POST', ['comments']):
        final c = {
          'id': 'c${++_ids}',
          'task_id': id,
          'author_actor_id': 'me',
          'body': body['body'],
          'created_at': '2026-11-08T10:00:00Z',
          'updated_at': '2026-11-08T10:00:00Z',
        };
        comments.putIfAbsent(tref, () => []).add(c);
        return FakeResponse(201, c);
      case ('GET', ['deps']):
        return FakeResponse(200, {
          'items': [
            for (final d in deps[id] ?? const <String>[])
              {'task_id': id, 'depends_on': d},
          ],
        });
      case ('POST', ['deps']):
        final other = task(body['depends_on'] as String);
        if (other == null) {
          return FakeResponse(
            400,
            envelope('invalid', 'no task ${body['depends_on']}'),
          );
        }
        deps.putIfAbsent(id, () => []).add(other['id']! as String);
        return const FakeResponse(204);
      case ('DELETE', ['deps', final dep]):
        final other = task(dep);
        deps[id]?.remove(other?['id'] ?? dep);
        return const FakeResponse(204);
      case ('GET', ['artifacts']):
        return FakeResponse(200, {'items': artifacts[tref] ?? []});
      case ('PUT', ['artifacts']):
        final a = {
          'id': 'a${++_ids}',
          'task_id': id,
          'actor_id': 'me',
          ...body,
          'created_at': '2026-11-08T10:00:00Z',
        };
        artifacts.putIfAbsent(tref, () => []).add(a);
        return FakeResponse(200, a);
    }
    return null;
  }

  String _projectKeyOf(Map<String, Object?> task) {
    for (final e in tasks.entries) {
      if (e.value.contains(task)) return e.key;
    }
    return '';
  }

  Map<String, Object?> _withProject(Map<String, Object?> t) {
    final key = _projectKeyOf(t);
    final p = projects.where((p) => p['key'] == key).firstOrNull;
    return {...t, 'project_id': p?['id'] ?? ''};
  }

  List<Map<String, Object?>> _list(Uri uri) {
    final q = uri.queryParametersAll;
    final keys = q['project'];
    var rows = [
      for (final e in tasks.entries)
        if (keys == null || keys.contains(e.key)) ...e.value,
    ];
    bool has(String k, Object? v) => q[k]?.contains('$v') ?? false;
    if (q['status'] case final List<String> s) {
      rows = [
        for (final t in rows)
          if (s.contains(t['status'])) t,
      ];
    }
    if (q['not_status'] case final List<String> s) {
      rows = [
        for (final t in rows)
          if (!s.contains(t['status'])) t,
      ];
    }
    for (final tag in q['tag'] ?? const <String>[]) {
      rows = [
        for (final t in rows)
          if ((t['tags']! as List).contains(tag)) t,
      ];
    }
    if (q['assignee'] case final List<String> a) {
      rows = [
        for (final t in rows)
          if (a.contains(t['assignee_actor_id']) ||
              (a.contains('me') && t['assignee_actor_id'] == 'me'))
            t,
      ];
    }
    if (q.containsKey('starred')) {
      rows = [
        for (final t in rows)
          if ((t['starred'] == true) == has('starred', true)) t,
      ];
    }
    final snoozed = q['snoozed']?.first;
    if (snoozed != 'any') {
      rows = [
        for (final t in rows)
          if ((t['snoozed_until'] != null) == (snoozed == 'true')) t,
      ];
    }
    if (q['q']?.first case final String text) {
      rows = [
        for (final t in rows)
          if ((t['title']! as String).toLowerCase().contains(
            text.toLowerCase(),
          ))
            t,
      ];
    }
    final sort = q['sort']?.first;
    if (sort == 'title' || sort == 'due_at') {
      rows.sort((a, b) => '${a[sort] ?? '~'}'.compareTo('${b[sort] ?? '~'}'));
    }
    if (q['direction']?.first == 'desc') rows = rows.reversed.toList();
    return [for (final t in rows) _withProject(t)];
  }

  Map<String, Object?> _bulk(Map<String, dynamic> body) {
    final action = body['action'] as String;
    final outcomes = <Map<String, Object?>>[];
    for (final ref in (body['refs'] as List).cast<String>()) {
      final refusal = refuse[ref];
      final task = this.task(ref);
      if (refusal != null || (task == null && action != 'restore')) {
        outcomes.add({
          'ref': ref,
          'applied': false,
          'code': refusal?.$1 ?? 'not_found',
          'error': refusal?.$2 ?? 'task "$ref"',
        });
        continue;
      }
      var copy = '';
      switch (action) {
        case 'move':
          task!['status'] = body['to'];
        case 'priority':
          task!['priority'] = body['priority'];
        case 'tag_add':
          final tags = (task!['tags']! as List).cast<String>();
          if (!tags.contains(body['tag'])) {
            task['tags'] = [...tags, body['tag'] as String];
          }
        case 'tag_remove':
          task!['tags'] = [
            for (final t in task['tags']! as List)
              if (t != body['tag']) t,
          ];
        case 'assign':
          task!['assignee_actor_id'] = body['assignee_actor_id'] ?? '';
        case 'star':
          task!['starred'] = true;
        case 'unstar':
          task!['starred'] = false;
        case 'copy':
          final to = body['project_ref'] as String;
          final list = tasks.putIfAbsent(to, () => []);
          copy = '$to-${list.length + 100}';
          list.add({...task!, 'id': 'id-$copy', 'ref': copy});
        case 'delete':
          tasks[_projectKeyOf(task!)]!.remove(task);
          trash[ref] = task;
        case 'restore':
          final gone = trash.remove(ref);
          if (gone == null) {
            outcomes.add({'ref': ref, 'applied': false, 'code': 'not_found'});
            continue;
          }
          tasks[gone['project_id']]!.add(gone);
      }
      outcomes.add({
        'ref': ref,
        'applied': true,
        'copy_ref': ?(copy.isEmpty ? null : copy),
      });
    }
    final applied = outcomes.where((o) => o['applied'] == true).length;
    return {
      'action': action,
      'applied': applied,
      'refused': outcomes.length - applied,
      'outcomes': outcomes,
    };
  }

  FakeResponse _stats(String? project) {
    final rows = project == null
        ? [for (final l in tasks.values) ...l]
        : tasks[project] ?? const [];
    final counts = <String, int>{};
    for (final t in rows) {
      final status = t['status']! as String;
      final c = switch (status) {
        'doing' => 'in_progress',
        'done' || 'cancelled' || 'blocked' || 'todo' => status,
        _ => 'todo',
      };
      counts[c] = (counts[c] ?? 0) + 1;
    }
    return FakeResponse(200, {
      'project_key': ?project,
      'by_category': [
        for (final e in counts.entries) {'category': e.key, 'count': e.value},
      ],
    });
  }

  FakeResponse? _more(RequestOptions o, List<String> segments) {
    final method = o.method;
    if (segments.length >= 5 && segments[2] == 'views') {
      final view = Uri.decodeComponent(segments[3]);
      final groups = views.putIfAbsent(view, () => {});
      List<Map<String, Object?>> items() => [
        for (final e in groups.entries)
          {'group': e.key, 'view': view, ...e.value},
      ];
      switch ((method, segments.length, segments[4])) {
        case ('GET', 5, 'groups'):
          return FakeResponse(200, {'items': items(), 'next_cursor': ''});
        case ('DELETE', 5, 'groups'):
          views.remove(view);
          return const FakeResponse(204);
        case ('PATCH', 6, 'groups'):
          final group = Uri.decodeComponent(segments[5]);
          final g = groups.putIfAbsent(group, () => {})
            ..addAll((o.data as Map).cast<String, Object?>());
          return FakeResponse(200, {'group': group, 'view': view, ...g});
        case ('PUT', 5, 'order'):
          final order = ((o.data as Map)['groups'] as List).cast<String>();
          for (var i = 0; i < order.length; i++) {
            groups.putIfAbsent(order[i], () => {})['position'] = i + 1;
          }
          return FakeResponse(200, {'items': items(), 'next_cursor': ''});
      }
    }
    if (segments.length == 4 && segments[2] == 'filters') {
      final f = filters.where((f) => f['id'] == segments[3]).firstOrNull;
      if (f == null) return FakeResponse(404, envelope('not_found', 'filter'));
      switch (method) {
        case 'PATCH':
          f.addAll((o.data as Map).cast<String, Object?>());
          return FakeResponse(200, f);
        case 'DELETE':
          filters.remove(f);
          return const FakeResponse(204);
      }
    }
    return null;
  }

  /// What `whoami` adds to the actor: its role and scopes. Everything by
  /// default, so a screen offers every action unless a test narrows it.
  Map<String, Object?> identity = {
    'scopes': ['*'],
  };

  /// What deleting a project would do, by project key: live and trashed
  /// tasks.
  final deletionCounts = <String, ({int tasks, int deleted})>{};

  /// The uploaded icon bytes per project key.
  final icons = <String, List<int>>{};

  List<Map<String, Object?>> get _allWorkflows => [
    for (final w in workflows)
      if (w['key'] == workflow['key']) {...w, 'builtin': true} else w,
  ];

  Map<String, Object?>? _project(String key) {
    for (final p in projects) {
      if (p['key'] == key || p['id'] == key) return p;
    }
    return null;
  }

  FakeResponse? _manage(
    RequestOptions o,
    List<String> s,
    Map<String, dynamic> body,
  ) {
    final q = o.uri.queryParameters;
    switch ((o.method, s)) {
      case ('POST', ['projects']):
        final key = (body['key'] as String? ?? '').toLowerCase();
        if (key.isEmpty || (body['name'] as String? ?? '').isEmpty) {
          return FakeResponse(
            400,
            envelope('invalid', 'name and key required'),
          );
        }
        if (_project(key) != null) {
          return FakeResponse(409, envelope('conflict', 'key "$key" in use'));
        }
        final p = <String, Object?>{
          'id': 'p${++_ids}',
          'key': key,
          'name': body['name'],
          'description': body['description'] ?? '',
          'color': body['color'] ?? '',
          'icon': body['icon'] ?? '',
          'icon_name': body['icon_name'] ?? '',
          'workflow_id': _allWorkflows.firstWhere(
            (w) => w['key'] == (body['workflow_key'] ?? 'default'),
            orElse: () => workflow,
          )['id'],
          'updated_at':
              '2026-11-08T10:00:${(_ids % 60).toString().padLeft(2, '0')}Z',
        };
        projects.add(p);
        return FakeResponse(201, p);
      case ('PATCH', ['projects', final key]):
        final p = _project(key);
        if (p == null) return FakeResponse(404, envelope('not_found', key));
        final wf = body['workflow_key'];
        if (wf != null && !_allWorkflows.any((w) => w['key'] == wf)) {
          return FakeResponse(404, envelope('not_found', 'workflow "$wf"'));
        }
        for (final MapEntry(:key, :value) in body.entries) {
          switch (key) {
            case 'workflow_key':
              p['workflow_id'] = _allWorkflows.firstWhere(
                (w) => w['key'] == value,
              )['id'];
            case 'icon':
              p['icon'] = value;
              p['icon_name'] = '';
            case 'icon_name':
              p['icon_name'] = value;
              p['icon'] = '';
            case 'icon_file':
              p['icon_image'] = 'digest${++_ids}';
            default:
              p[key] = value;
          }
        }
        p['updated_at'] =
            '2026-11-08T11:00:${(++_ids % 60).toString().padLeft(2, '0')}Z';
        return FakeResponse(200, p);
      case ('DELETE', ['projects', final key]):
        final p = _project(key);
        if (p == null) return FakeResponse(404, envelope('not_found', key));
        if (q['archive'] == 'true') {
          if (p['archived_at'] != null) {
            return FakeResponse(409, envelope('conflict', 'already archived'));
          }
          p['archived_at'] = '2026-11-08T12:00:00Z';
          p['updated_at'] = '2026-11-08T12:00:00Z';
          return const FakeResponse(204);
        }
        final counts = deletionCounts[p['key']] ?? (tasks: 0, deleted: 0);
        final holds = counts.tasks + counts.deleted > 0;
        if (holds &&
            q['move_tasks_to'] == null &&
            q['delete_tasks'] != 'true') {
          return FakeResponse(
            422,
            envelope('precondition_failed', 'the project holds tasks'),
          );
        }
        projects.remove(p);
        return FakeResponse(200, {
          'project': p['key'],
          'tasks': counts.tasks,
          'move_to': q['move_tasks_to'] ?? '',
          'delete_tasks': q['delete_tasks'] == 'true',
        });
      case ('GET', ['projects', final key, 'deletion']):
        final p = _project(key);
        if (p == null) return FakeResponse(404, envelope('not_found', key));
        final counts = deletionCounts[p['key']] ?? (tasks: 0, deleted: 0);
        final to = q['move_tasks_to'];
        return FakeResponse(200, {
          'project': p['key'],
          'dry_run': true,
          'tasks': counts.tasks,
          'deleted': counts.deleted,
          'move_to': to ?? '',
          'statuses': to == null
              ? <Object?>[]
              : [
                  {'from': 'todo', 'to': 'todo', 'tasks': counts.tasks},
                  {'from': 'doing', 'to': 'in_progress', 'tasks': 1},
                ],
        });
      case ('GET', ['projects', final key, 'icon']):
        final bytes = icons[key];
        if (bytes == null) return FakeResponse(404, envelope('not_found', key));
        return FakeResponse(200, String.fromCharCodes(bytes), 'image/png');
      case ('PUT', ['projects', final key, 'fields']):
        final p = _project(key);
        if (p == null) return FakeResponse(404, envelope('not_found', key));
        final fkey = body['key'] as String? ?? '';
        if (fkey.isEmpty) {
          return FakeResponse(400, envelope('invalid', 'field key required'));
        }
        if (body['type'] == 'enum' &&
            ((body['enum_options'] as List?) ?? const []).isEmpty) {
          return FakeResponse(
            400,
            envelope('invalid', 'an enum field needs options'),
          );
        }
        final f = <String, Object?>{
          'id': 'f-$fkey',
          ...body,
          'project_id': p['id'],
        };
        fields.putIfAbsent(p['key']! as String, () => [])
          ..removeWhere((x) => x['key'] == fkey)
          ..add(f);
        return FakeResponse(200, f);
      case ('DELETE', ['projects', final key, 'fields', final fkey]):
        final list = fields[_project(key)?['key']];
        final before = list?.length ?? 0;
        list?.removeWhere((x) => x['key'] == fkey);
        if ((list?.length ?? 0) == before) {
          return FakeResponse(404, envelope('not_found', 'field "$fkey"'));
        }
        return const FakeResponse(204);
      case ('GET', ['workflows', final key]):
        for (final w in _allWorkflows) {
          if (w['key'] == key || w['id'] == key) return FakeResponse(200, w);
        }
        return FakeResponse(404, envelope('not_found', 'workflow "$key"'));
      case ('PUT', ['workflows']) || ('PUT', ['workflows', _]):
        final key = s.length > 1 ? s[1] : body['key'] as String? ?? '';
        final def = body['definition'] as Map<String, dynamic>?;
        final states = (def?['states'] as List?) ?? const [];
        if (!states.any((x) => (x as Map)['key'] == def?['initial'])) {
          return FakeResponse(
            400,
            envelope(
              'invalid',
              'initial state "${def?['initial']}" is not defined',
            ),
          );
        }
        final w = <String, Object?>{
          'id': key == workflow['key'] ? workflow['id'] : 'wf-$key',
          'key': key,
          'name': body['name'] ?? key,
          'definition': def,
          'updated_at':
              '2026-11-08T13:00:${(++_ids % 60).toString().padLeft(2, '0')}Z',
        };
        final at = workflows.indexWhere((x) => x['key'] == key);
        if (at < 0) {
          workflows.add(w);
        } else {
          workflows[at] = w;
        }
        if (key == workflow['key']) workflow = w;
        lastWorkflowPut = body;
        return FakeResponse(
          200,
          key == workflow['key'] ? {...w, 'builtin': true} : w,
        );
      case ('DELETE', ['workflows', final key]):
        if (key == workflow['key']) {
          return FakeResponse(409, envelope('conflict', 'builtin workflow'));
        }
        final before = workflows.length;
        workflows.removeWhere((x) => x['key'] == key);
        if (workflows.length == before) {
          return FakeResponse(404, envelope('not_found', 'workflow "$key"'));
        }
        return const FakeResponse(204);
    }
    return null;
  }

  /// The last body a workflow was saved with.
  Map<String, dynamic>? lastWorkflowPut;

  Map<String, Object?> _page(List<Map<String, Object?>> rows, String? cursor) {
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + pageSize).clamp(0, rows.length);
    return {
      'items': rows.sublist(start, end),
      'next_cursor': end < rows.length ? '$end' : '',
    };
  }

  /// Templates by id, in the shape tix answers with.
  final templates = <String, Map<String, Object?>>{};

  /// Dry-run rows by line, recorded from a real tix; a line not listed
  /// becomes a plain row titled as typed.
  final previews = <String, Map<String, Object?>>{
    'x': {'action': 'create', 'title': 'x', 'status': 'todo', 'priority': 3},
  };

  /// Whether every request fails as if there were no network.
  bool offline = false;

  /// Dry runs of these lines wait until the completer completes.
  final previewHolds = <String, Completer<void>>{};

  /// Whether dry runs are refused, as for a credential without `import`.
  bool importForbidden = false;

  /// Every quick-add line the dry run was asked about, the plain one left
  /// out.
  List<String> get previewedLines => [
    for (final r in requests)
      if (r.uri.path.endsWith('/tasks/import'))
        ((r.data as Map<String, dynamic>)['content'] as String)
            .split('\n')
            .last,
  ];

  int _templateIds = 0;

  /// Adds a template [name] in [project] (empty for every project) shaped
  /// on [title].
  Map<String, Object?> addTemplate(
    String name, {
    String project = '',
    String title = 'A task',
    int uses = 0,
    List<Map<String, Object?>> subtasks = const [],
    String? dueIn,
  }) {
    final id = 'tpl-${++_templateIds}';
    return templates[id] = {
      'id': id,
      'name': name,
      'project_id': project.isEmpty ? '' : 'id-$project',
      'project_key': project,
      'task': {
        'title': title,
        'priority': 3,
        'tags': <String>[],
        'subtasks': subtasks,
      },
      'due_in': ?dueIn,
      'uses': uses,
    };
  }

  Map<String, Object?>? _template(String ref) {
    for (final t in templates.values) {
      if (t['id'] == ref ||
          (t['name']! as String).toLowerCase() == ref.toLowerCase()) {
        return t;
      }
    }
    return null;
  }

  Future<FakeResponse?> _quick(RequestOptions o, String path) async {
    final segments = path.substring(1).split('/');
    final body = o.data is Map<String, dynamic>
        ? o.data as Map<String, dynamic>
        : const <String, dynamic>{};
    switch ((o.method, path)) {
      case ('GET', '/api/v1/actors'):
        return FakeResponse(200, {'items': actors.values.toList()});
      case ('GET', '/api/v1/templates'):
        final rows = templates.values.toList()
          ..sort(
            (a, b) => (a['name']! as String).compareTo(b['name']! as String),
          );
        return FakeResponse(200, _page(rows, o.uri.queryParameters['cursor']));
      case ('POST', '/api/v1/templates'):
        final name = body['name'] as String? ?? '';
        if (_template(name) != null) {
          return FakeResponse(
            409,
            envelope('conflict', 'template "$name" already exists'),
          );
        }
        final ref = body['task_ref'] as String? ?? '';
        Map<String, Object?>? task;
        var project = '';
        for (final e in tasks.entries) {
          for (final t in e.value) {
            if (t['ref'] == ref) {
              task = t;
              project = e.key;
            }
          }
        }
        if (task == null) {
          return FakeResponse(404, envelope('not_found', 'task "$ref"'));
        }
        return FakeResponse(
          201,
          addTemplate(
            name,
            project: body['tenant_wide'] == true ? '' : project,
            title: task['title']! as String,
            dueIn: body['due_in'] as String?,
          ),
        );
    }
    if (segments.length == 6 &&
        segments[2] == 'projects' &&
        segments[4] == 'tasks' &&
        segments[5] == 'import' &&
        o.method == 'POST') {
      if (importForbidden) {
        return FakeResponse(403, envelope('forbidden', 'needs scope import'));
      }
      final lines = (body['content'] as String).split('\n');
      await previewHolds[lines.last]?.future;
      return FakeResponse(200, {
        'dry_run': true,
        'preview': [
          for (final (i, l) in lines.indexed)
            {
              'line': i + 1,
              ...previews[l] ??
                  {
                    'action': 'create',
                    'title': l,
                    'status': 'todo',
                    'priority': 3,
                  },
            },
        ],
      });
    }
    if (segments.length >= 4 && segments[2] == 'templates') {
      final template = _template(segments[3]);
      if (template == null) {
        return FakeResponse(404, envelope('not_found', 'template'));
      }
      if (segments.length == 5 && segments[4] == 'use' && o.method == 'POST') {
        final project =
            body['project_ref'] as String? ??
            ((template['project_key']! as String).isEmpty
                ? 'infra'
                : template['project_key']! as String);
        final list = tasks.putIfAbsent(project, () => []);
        final created = taskJson(
          '$project-${list.length + 1}',
          title: (template['task']! as Map)['title'] as String,
        );
        list.insert(0, created);
        template['uses'] = (template['uses']! as int) + 1;
        return FakeResponse(201, created);
      }
      switch (o.method) {
        case 'GET':
          return FakeResponse(200, template);
        case 'DELETE':
          templates.remove(template['id']);
          return const FakeResponse(204);
        case 'PATCH':
          final task = Map<String, Object?>.from(template['task']! as Map);
          for (final k in ['title', 'body', 'priority', 'tags', 'recurrence']) {
            if (body.containsKey(k)) task[k] = body[k];
          }
          template['task'] = task;
          if (body['name'] != null) template['name'] = body['name'];
          if (body['due_in'] != null) template['due_in'] = body['due_in'];
          if (body['project_ref'] != null) {
            template['project_key'] = body['project_ref'];
          }
          return FakeResponse(200, template);
      }
    }
    return null;
  }
}
