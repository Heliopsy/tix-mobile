// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

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
}) => {
  'id': 'id-$ref',
  'ref': ref,
  'title': title,
  'status': status,
  'priority': priority,
  'body': body,
  'assignee_actor_id': assignee,
  'due_at': due,
  'tags': tags,
};

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
             {'id': 'p1', 'key': 'infra', 'name': 'Infrastructure'},
             {'id': 'p2', 'key': 'web', 'name': 'Web'},
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

  /// Rows per page, so tests can force pagination.
  int pageSize = 50;

  late final adapter = FakeAdapter(_handle);

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
    final caller = _caller(o);
    if (caller == null) {
      return FakeResponse(401, envelope('unauthenticated', 'bad token'));
    }
    final q = o.uri.queryParameters;
    switch ((o.method, path)) {
      case ('GET', '/api/v1/whoami'):
        final account = accounts[caller.email];
        if (account == null) {
          // A token answers as an agent with its tenant's id alone.
          return FakeResponse(200, {
            ...actors['me']!,
            'kind': 'agent',
            'tenant_id': 'id-${caller.tenant}',
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
          _page(tenantProjects[caller.tenant] ?? projects, q['cursor']),
        );
      case ('GET', '/api/v1/tasks'):
        return FakeResponse(200, _page(tasks[q['project']] ?? [], q['cursor']));
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
    final segments = path.substring(1).split('/');
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

  Map<String, Object?> _page(List<Map<String, Object?>> rows, String? cursor) {
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + pageSize).clamp(0, rows.length);
    return {
      'items': rows.sublist(start, end),
      'next_cursor': end < rows.length ? '$end' : '',
    };
  }
}
