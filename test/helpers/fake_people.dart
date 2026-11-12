// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:dio/dio.dart';

import 'fake_tix.dart';

/// Users, memberships, invites, API tokens, the account log, the calendar
/// feed, and task export and import, for [FakeTix]; `FakePeople.on` installs
/// them.
///
/// `whoami` answers with [me] for a token, so a test chooses the caller's
/// role and scopes.
class FakePeople {
  /// Serves on [server].
  FakePeople.on(this.server) {
    server.routes.add(_route);
  }

  /// The server this answers for.
  final FakeTix server;

  /// What `whoami` answers for a token.
  Map<String, Object?> me = {
    'id': 'me',
    'handle': 'ana',
    'display_name': 'Ana',
    'kind': 'user',
    'role': 'admin',
    'tenant_id': 'id-default',
    'tenant_key': 'default',
    'email': 'ana@example.com',
    'memberships': [
      {
        'tenant_key': 'default',
        'tenant_name': 'Default',
        'role': 'admin',
        'handle': 'ana',
      },
      {
        'tenant_key': 'acme',
        'tenant_name': 'Acme',
        'role': 'viewer',
        'handle': 'ana',
      },
    ],
  };

  /// The tenant's users.
  final users = <Map<String, Object?>>[
    {
      'id': 'me',
      'email': 'ana@example.com',
      'display_name': 'Ana',
      'created_at': '2026-10-01T00:00:00Z',
    },
    {
      'id': 'a1',
      'email': 'raj@example.com',
      'display_name': 'Raj',
      'created_at': '2026-10-02T00:00:00Z',
    },
    {
      'id': 'u3',
      'email': 'bo@example.com',
      'disabled_at': '2026-10-20T00:00:00Z',
      'created_at': '2026-10-03T00:00:00Z',
    },
  ];

  /// Roles by actor id; a missing actor has no membership.
  final roles = <String, String>{'me': 'admin', 'a1': 'member', 'u3': 'viewer'};

  /// Whether `member.list` is refused, as for a caller without
  /// `tenant:admin`.
  bool membersForbidden = false;

  /// Pending invites.
  final invites = <Map<String, Object?>>[
    {
      'id': 'inv1',
      'email': 'kim@example.com',
      'role': 'member',
      'invited_by_handle': 'ana',
      'expires_at': '2026-11-05T00:00:00Z',
    },
  ];

  /// API tokens, metadata only.
  final tokens = <Map<String, Object?>>[
    {
      'id': 't1',
      'name': 'ci',
      'actor_id': 'me',
      'scopes': ['task:read'],
      'created_at': '2026-10-01T00:00:00Z',
    },
    {
      'id': 't2',
      'name': 'raj-laptop',
      'actor_id': 'a1',
      'scopes': ['task:read', 'task:write'],
      'created_at': '2026-10-05T00:00:00Z',
      'expires_at': '2027-01-01T00:00:00Z',
      'last_used_at': '2026-10-30T10:00:00Z',
    },
  ];

  /// Every secret this server ever issued, so a test can look for them.
  final issued = <String>[];

  /// The account log, oldest first.
  final log = <Map<String, Object?>>[
    {
      'seq': 1,
      'action': 'user.password_changed',
      'tenant_key': 'default',
      'by_email': 'ana@example.com',
      'via': 'web',
      'occurred_at': '2026-10-10T09:00:00Z',
    },
  ];

  /// The live calendar feed, without its secret, or null.
  Map<String, Object?>? feed;

  /// What the last task export asked for.
  Map<String, dynamic>? lastExport;

  /// What each task import asked for.
  final imports = <Map<String, dynamic>>[];

  var _n = 0;

  /// When a rotation happens, as the tests' clock reads it.
  static final _rotatedAt = DateTime.utc(2026, 11, 1, 12);

  /// The graces a rotation may ask for.
  static const _graces = {
    '10m': Duration(minutes: 10),
    '1h': Duration(hours: 1),
    '24h': Duration(hours: 24),
  };

  String _secret(String prefix) {
    final s = '$prefix-secret-${++_n}-x9Qz';
    issued.add(s);
    return s;
  }

  FakeResponse? _route(RequestOptions o, String path, FakeCaller caller) {
    final body = o.data is Map<String, dynamic>
        ? o.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final s = path.substring('/api/v1/'.length).split('/');
    switch ((o.method, s)) {
      case ('GET', ['whoami']) when caller.email == null:
        return FakeResponse(200, me);
      case ('GET', ['users']):
        return FakeResponse(200, _page(users, o.uri.queryParameters['cursor']));
      case ('POST', ['users']):
        final u = {
          'id': 'u${100 + ++_n}',
          'email': body['email'],
          'display_name': body['display_name'] ?? '',
          'require_password_change': body['require_password_change'] ?? false,
        };
        users.add(u);
        roles[u['id']! as String] = body['role'] as String;
        return FakeResponse(201, u);
      case ('PATCH', ['users', final id]):
        final u = users.where((u) => u['id'] == id).firstOrNull;
        if (u == null) return FakeResponse(404, envelope('not_found', id));
        for (final MapEntry(:key, :value) in body.entries) {
          switch (key) {
            case 'role':
              roles[id] = value as String;
            case 'disabled':
              if (value == true) {
                u['disabled_at'] = '2026-11-01T12:00:00Z';
              } else {
                u.remove('disabled_at');
              }
            default:
              u[key] = value;
          }
        }
        return FakeResponse(200, u);
      case ('DELETE', ['users', final id]):
        users.removeWhere((u) => u['id'] == id);
        roles.remove(id);
        return const FakeResponse(204);
      case ('GET', ['members']):
        if (membersForbidden) {
          return FakeResponse(403, envelope('forbidden', 'tenant:admin'));
        }
        return FakeResponse(200, {
          'items': [
            for (final MapEntry(:key, :value) in roles.entries)
              {'actor_id': key, 'role': value, 'tenant_id': 'id-default'},
          ],
        });
      case ('POST', ['members']):
        roles[body['actor_id'] as String] = body['role'] as String;
        return FakeResponse(201, {
          'actor_id': body['actor_id'],
          'role': body['role'],
        });
      case ('DELETE', ['members', final id]):
        roles.remove(id);
        return const FakeResponse(204);
      case ('GET', ['invites']):
        return FakeResponse(200, {'items': invites});
      case ('POST', ['invites']):
        final token = _secret('invite');
        final i = {
          'id': 'inv${++_n}',
          'email': body['email'],
          'role': body['role'],
          'expires_at': '2026-11-08T12:00:00Z',
        };
        invites.add(i);
        return FakeResponse(201, {
          ...i,
          'token': token,
          'path': '/invite/$token',
          'url': '',
        });
      case ('POST', ['invites', final id, 'reissue']):
        final i = invites.where((i) => i['id'] == id).firstOrNull;
        if (i == null) return FakeResponse(404, envelope('not_found', id));
        final token = _secret('invite');
        i['expires_at'] = '2026-11-08T12:00:00Z';
        return FakeResponse(200, {
          ...i,
          'token': token,
          'url': 'https://tix.example/invite/$token',
        });
      case ('DELETE', ['invites', final id]):
        invites.removeWhere((i) => i['id'] == id);
        return const FakeResponse(204);
      case ('GET', ['tokens']):
        final actor = o.uri.queryParameters['actor_id'];
        return FakeResponse(200, {
          'items': [
            for (final t in tokens)
              if (actor == null || t['actor_id'] == actor) t,
          ],
        });
      case ('POST', ['tokens']):
        if (tokens.any((t) => t['name'] == body['name'])) {
          return FakeResponse(409, envelope('conflict', 'name taken'));
        }
        final t = {
          'id': 't${++_n}',
          'name': body['name'],
          'actor_id': body['actor_id'] ?? 'me',
          'scopes': body['scopes'],
          'expires_at': body['expires_at'],
          'created_at': '2026-11-01T12:00:00Z',
        };
        tokens.add(t);
        return FakeResponse(201, {...t, 'token': _secret('tix')});
      case ('POST', ['tokens', final id, 'rotate']):
        final old = tokens.where(
          (t) => t['id'] == id && t['revoked_at'] == null,
        );
        if (old.isEmpty) return FakeResponse(404, envelope('not_found', id));
        final retired = old.single;
        final grace = _graces[body['grace']] ?? Duration.zero;
        final t = {
          ...retired,
          'id': 't${++_n}',
          'created_at': '2026-11-01T12:00:00Z',
        };
        retired['revoked_at'] = _rotatedAt.add(grace).toIso8601String();
        tokens.add(t);
        final value = _secret('tix');
        server.tokens[value] = caller.tenant;
        return FakeResponse(200, {...t, 'token': value});
      case ('DELETE', ['tokens', final id]):
        for (final t in tokens) {
          if (t['id'] == id) t['revoked_at'] = '2026-11-01T12:00:00Z';
        }
        return const FakeResponse(204);
      case ('GET', ['account', 'log']):
        final rows = o.uri.queryParameters['direction'] == 'desc'
            ? log.reversed.toList()
            : log;
        return FakeResponse(200, _page(rows, o.uri.queryParameters['cursor']));
      case ('GET', ['calendar']):
        final f = feed;
        return f == null
            ? FakeResponse(404, envelope('not_found', 'no feed'))
            : FakeResponse(200, f);
      case ('POST', ['calendar']):
        feed = {
          'id': 'cal${++_n}',
          'filter': body['filter'] ?? '',
          'created_at': '2026-11-01T12:00:00Z',
        };
        return FakeResponse(201, _issuedFeed());
      case ('POST', ['calendar', 'rotate']):
        if (feed == null) return FakeResponse(404, envelope('not_found', ''));
        return FakeResponse(200, _issuedFeed());
      case ('PATCH', ['calendar']):
        if (body['filter'] == 'bogus:') {
          return FakeResponse(400, envelope('invalid', 'cannot read filter'));
        }
        feed?['filter'] = body['filter'];
        return FakeResponse(200, feed);
      case ('DELETE', ['calendar']):
        feed = null;
        return const FakeResponse(204);
      case ('POST', ['projects', final key, 'tasks', 'export']):
        lastExport = body;
        return switch (body['format']) {
          'json' => FakeResponse(200, [
            {'ref': '$key-1'},
          ]),
          _ => FakeResponse(200, 'ref,title\n$key-1,Fix login\n', 'text/csv'),
        };
      case ('POST', ['projects', _, 'tasks', 'import']):
        imports.add(body);
        final dry = body['dry_run'] == true;
        return FakeResponse(200, {
          'dry_run': dry,
          'committed': !dry,
          'rows': 2,
          'created': 2,
          'updated': 0,
          'skipped': 0,
          'failed': 0,
          'format': 'csv',
        });
      case ('POST', ['export']):
        return FakeResponse(
          200,
          '${jsonEncode({'kind': 'project', 'key': 'infra'})}\n',
          'application/x-ndjson',
        );
    }
    return null;
  }

  Map<String, Object?> _issuedFeed() {
    final token = _secret('cal');
    return {
      ...?feed,
      'token': token,
      'path': '/api/v1/calendar/feeds/$token.ics',
      'url': '',
    };
  }

  Map<String, Object?> _page(List<Map<String, Object?>> rows, String? cursor) {
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + server.pageSize).clamp(0, rows.length);
    return {
      'items': rows.sublist(start, end),
      'next_cursor': end < rows.length ? '$end' : '',
    };
  }
}
