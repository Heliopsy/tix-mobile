// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';

import 'fake_tix.dart';

/// An invite [FakeParity] answers for.
class FakeInvite {
  FakeInvite({
    required this.email,
    this.tenant = 'default',
    this.existing = false,
    this.codeRequired = false,
    this.displayName = '',
  });

  final String email;
  final String tenant;
  final bool existing;
  final bool codeRequired;
  final String displayName;
  bool used = false;
}

/// The operations the parity-rest change binds, on a [FakeTix]: invites,
/// a task's lease and tags, a saved filter by name,
/// the caller's date display, the status report, bundles and snapshot
/// imports. Install it with [FakeParity.on].
class FakeParity {
  FakeParity._(this.server);

  /// Adds the routes to [server].
  factory FakeParity.on(FakeTix server) {
    final p = FakeParity._(server);
    server.publicRoutes.add(p._public);
    server.routes.add(p._handle);
    return p;
  }

  final FakeTix server;

  /// Live invites by token.
  final invites = <String, FakeInvite>{};

  /// What `GET /tasks/{ref}/lease` answers.
  Map<String, Object?> lease = {
    'ttl': '2h0m0s',
    'source': 'project',
    'max': '24h0m0s',
    'max_source': 'tenant',
  };

  /// The caller's date display, as `GET /me/time` answers it.
  Map<String, Object?> time = {
    'effective': {'time_format': 'short', 'timezone': 'UTC'},
    'format_source': 'tenant',
    'timezone_source': 'global',
    'global': {'time_format': 'iso', 'timezone': 'UTC'},
    'tenant': {'time_format': 'short', 'timezone': ''},
    'user': {'time_format': '', 'timezone': ''},
    'personal': true,
  };

  /// What `GET /status` answers.
  Map<String, Object?> status = {
    'answering_server': 'srv-1',
    'installation': {
      'version': 'v0.50.0',
      'schema_version': 42,
      'engine': 'sqlite',
      'store': '/data/tix.db',
      'observed_at': '2026-11-01T12:00:00Z',
    },
    'servers': [
      {
        'id': 'srv-1',
        'address': ':8080',
        'version': 'v0.50.0',
        'attached': true,
        'uptime': '3h25m0s',
        'connections': 2,
        'last_seen_at': '2026-11-01T11:59:50Z',
      },
      {
        'id': 'srv-2',
        'address': ':8081',
        'version': 'v0.49.0',
        'attached': false,
        'last_seen_at': '2026-10-31T08:00:00Z',
      },
    ],
    'work': {
      'projects': 2,
      'tasks': 17,
      'claimed': 1,
      'leases_expired_unswept': 0,
      'webhooks_pending': 0,
      'webhooks_failed': 3,
    },
    'second_factor': {
      'key_configured': true,
      'require_web': true,
      'admins': 2,
      'enrolled_admins': 1,
    },
  };

  /// Every bundle import, with its query.
  final bundleImports = <Map<String, String>>[];

  /// Every snapshot import, with its query.
  final snapshotImports = <Map<String, String>>[];

  /// What a bundle import's outcomes are.
  List<Map<String, Object?>> outcomes = [
    {'kind': 'workflow', 'key': 'kanban', 'action': 'created'},
    {
      'kind': 'tag',
      'key': 'urgent',
      'action': 'renamed',
      'new_key': 'urgent-2',
      'reason': 'key taken',
    },
  ];

  Map<String, Object?> _session(String email, String tenant) => {
    'session': {
      'token': server.startSession(email, tenant),
      'actor_id': 'me',
      'tenant_id': 'id-$tenant',
      'expires_at': '2026-11-09T00:00:00Z',
    },
  };

  FakeResponse? _public(RequestOptions o, String path) {
    const prefix = '/api/v1/auth/invites/';
    if (!path.startsWith(prefix)) return null;
    final token = Uri.decodeComponent(path.substring(prefix.length));
    final invite = invites[token];
    if (invite == null || invite.used) {
      return FakeResponse(404, envelope('not_found', 'invite'));
    }
    if (o.method == 'GET') {
      return FakeResponse(200, {
        'email': invite.email,
        'tenant_name': server.tenants[invite.tenant]?.name ?? invite.tenant,
        'existing_account': invite.existing,
        'code_required': invite.codeRequired,
        'display_name': invite.displayName,
        'expires_at': '2026-11-08T12:00:00Z',
      });
    }
    final body = o.data as Map<String, dynamic>;
    final password = body['password'] as String? ?? '';
    final account = server.accounts[invite.email];
    if (invite.existing) {
      if (account == null || account.password != password) {
        return FakeResponse(401, envelope('unauthenticated', 'bad password'));
      }
    } else if (password.length < 12) {
      return FakeResponse(400, envelope('invalid', 'password too short'));
    }
    if (invite.codeRequired && body['code'] != FakeTix.goodCode) {
      return FakeResponse(401, envelope('unauthenticated', 'bad code'));
    }
    invite.used = true;
    server.accounts[invite.email] = FakeAccount(
      password: password,
      tenants: {...?account?.tenants, invite.tenant}.toList(),
    );
    return FakeResponse(200, _session(invite.email, invite.tenant));
  }

  FakeResponse? _handle(RequestOptions o, String path, FakeCaller caller) {
    final s = path.substring('/api/v1/'.length).split('/');
    final q = o.uri.queryParameters;
    switch ((o.method, s)) {
      case ('GET', ['tasks', final ref, 'lease']):
        if (server.task(ref) == null) return _missing(ref);
        return FakeResponse(200, lease);
      case ('GET', ['tasks', final ref, 'tags']):
        final task = server.task(ref);
        if (task == null) return _missing(ref);
        return FakeResponse(200, {'items': task['tags'], 'next_cursor': ''});
      case ('GET', ['filters', final name]):
        final wanted = Uri.decodeComponent(name).toLowerCase();
        for (final f in server.filters) {
          if (f['id'] == wanted ||
              (f['name']! as String).toLowerCase() == wanted) {
            return FakeResponse(200, f);
          }
        }
        return FakeResponse(404, envelope('not_found', 'filter "$name"'));
      case ('GET', ['me', 'time']):
        return FakeResponse(200, time);
      case ('PATCH', ['me', 'time']):
        final body = o.data as Map<String, dynamic>;
        final user = {...time['user']! as Map<String, Object?>};
        final effective = {...time['effective']! as Map<String, Object?>};
        final zone = body['timezone'] as String?;
        if (zone != null && zone.isNotEmpty && !zone.contains('/')) {
          return FakeResponse(
            400,
            envelope('invalid', 'unknown time zone "$zone"'),
          );
        }
        for (final key in ['time_format', 'timezone']) {
          final value = body[key] as String?;
          if (value == null) continue;
          user[key] = value;
          if (value.isNotEmpty) effective[key] = value;
        }
        time = {
          ...time,
          'user': user,
          'effective': effective,
          if (body['time_format'] case final String f when f.isNotEmpty)
            'format_source': 'user',
          if (body['timezone'] case final String z when z.isNotEmpty)
            'timezone_source': 'user',
        };
        return FakeResponse(200, time);
      case ('GET', ['status']):
        return FakeResponse(200, status);
      case ('POST', ['bundles', 'export']):
        final body = o.data as Map<String, dynamic>? ?? const {};
        final kinds = (body['kinds'] as List?)?.length ?? 0;
        return FakeResponse(
          200,
          '{"record":"header","header":{"name":"${body['name'] ?? ''}"}}\n'
              '{"record":"component","kinds":$kinds}\n',
          'application/vnd.tix.bundle+json',
        );
      case ('POST', ['bundles', 'import']):
        bundleImports.add({...q, 'body': o.data as String});
        return FakeResponse(200, {
          'bundle_name': 'shared setup',
          'bundle_version': 1,
          'preview': q['preview'] == 'true',
          'outcomes': outcomes,
        });
      case ('POST', ['import']):
        snapshotImports.add({...q, 'body': o.data as String});
        return FakeResponse(200, {
          'dry_run': q['dry_run'] == 'true',
          'created': {'task': 4, 'project': 1},
          'updated': {'task': 2},
          'deleted': q['mode'] == 'replace' ? {'task': 1} : <String, int>{},
          'skipped': <String, int>{},
          'warnings': ['comment c9 names an unknown task'],
        });
    }
    return null;
  }

  FakeResponse _missing(String ref) =>
      FakeResponse(404, envelope('not_found', 'task "$ref"'));
}
