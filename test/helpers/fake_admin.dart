// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';

import 'fake_tix.dart';

/// Tenant and server administration on a [FakeTix]: tenants and their
/// users, domains, global admins, account logs, live connections, the
/// second factor and SSH keys. Install it with [FakeAdmin.on].
///
/// Like tix, only a global admin reaches the installation-wide routes, and
/// the authenticator secret and recovery codes leave it once.
class FakeAdmin {
  FakeAdmin._(this.server);

  /// Adds the admin routes to [server].
  factory FakeAdmin.on(FakeTix server) {
    final admin = FakeAdmin._(server);
    server.routes.add(admin._handle);
    return admin;
  }

  /// The server it answers for.
  final FakeTix server;

  /// Whether the caller is a global admin.
  bool globalAdmin = true;

  /// Every tenant by key, as `GET /tenants` reads it.
  final tenants = <String, Map<String, Object?>>{
    'default': {
      'id': 'id-default',
      'key': 'default',
      'name': 'Default',
      'theme': '',
      'created_at': '2026-10-01T09:00:00Z',
    },
    'acme': {
      'id': 'id-acme',
      'key': 'acme',
      'name': 'Acme',
      'theme': 'ember',
      'require_totp_web': true,
      'created_at': '2026-10-02T09:00:00Z',
    },
  };

  /// What `GET /auth/session-policy` answers.
  final sessionPolicy = <String, Object?>{
    'ttl': '12h0m0s',
    'idle_timeout': '0s',
    'remember_ttl': '720h0m0s',
    'server_ttl': '12h0m0s',
    'server_idle_timeout': '0s',
    'server_remember_ttl': '720h0m0s',
  };

  /// What `GET /artifact-limits` answers.
  final artifactLimits = <String, Object?>{
    'max_bytes': 1048576,
    'allowed_types': ['image/*', 'application/pdf', 'text/plain'],
    'server_max_bytes': 1048576,
    'server_allowed_types': ['image/*', 'application/pdf', 'text/plain'],
  };

  /// Tenant fields a `PATCH /tenants/{ref}` refuses, with the message.
  final refuse = <String, String>{};

  /// Users per tenant key.
  final users = <String, List<Map<String, Object?>>>{
    'default': [
      {
        'id': 'u1',
        'email': 'ana@example.com',
        'display_name': 'Ana',
        'role': 'admin',
        'global_admin': true,
        'totp_enrolled': true,
      },
      {'id': 'u2', 'email': 'raj@example.com', 'role': 'member'},
    ],
    'acme': [
      {'id': 'u3', 'email': 'ops@acme.example', 'role': 'admin'},
    ],
  };

  /// Domains per tenant key.
  final domains = <String, List<Map<String, Object?>>>{
    'default': [
      {
        'id': 'd1',
        'hostname': 'tix.example.com',
        'cert_mode': 'none',
        'shared': false,
        'verified_at': '2026-10-03T09:00:00Z',
      },
    ],
  };

  /// The global admins' emails.
  final globalAdmins = <String>['ana@example.com'];

  /// Account log entries by email, newest first.
  final accountLogs = <String, List<Map<String, Object?>>>{
    'raj@example.com': [
      {
        'seq': 2,
        'action': 'account.role_changed',
        'tenant_key': 'default',
        'by_email': 'ana@example.com',
        'by_global_admin': true,
        'via': 'web',
        'detail': {'role': 'member'},
        'occurred_at': '2026-10-05T09:00:00Z',
      },
      {
        'seq': 1,
        'action': 'account.created',
        'tenant_key': 'default',
        'via': 'cli',
        'occurred_at': '2026-10-04T09:00:00Z',
      },
    ],
  };

  /// The live connections of the caller's tenant.
  final connections = <Map<String, Object?>>[
    {
      'id': 'c1',
      'surface': 'events',
      'actor_handle': 'raj',
      'remote': '10.0.0.7',
      'since': '2026-11-01T10:00:00Z',
    },
    {
      'id': 'c2',
      'surface': 'ssh',
      'actor_handle': 'ana',
      'remote': '10.0.0.8',
      'fingerprint': 'SHA256:abc',
      'since': '2026-11-01T11:00:00Z',
    },
  ];

  /// The caller's second factor: off, pending or on.
  String totp = 'off';

  /// Recovery codes left once enrolled.
  int codesLeft = 0;

  /// What the tenant requires, as `GET /auth/totp` reports it.
  bool requiredWeb = false;

  /// The secret an enrolment hands out.
  static const secret = 'JBSWY3DPEHPK3PXP';

  /// The code that confirms an enrolment.
  static const goodCode = '123456';

  /// The recovery codes a confirmation hands out.
  static const codes = ['aaaa-1111', 'bbbb-2222', 'cccc-3333'];

  /// The caller's SSH keys.
  final sshKeys = <Map<String, Object?>>[
    {
      'id': 'k1',
      'label': 'laptop',
      'fingerprint': 'SHA256:laptop',
      'public_key': 'ssh-ed25519 AAAA laptop',
      'created_at': '2026-10-01T09:00:00Z',
      'last_used_at': '2026-11-01T09:00:00Z',
    },
  ];

  /// The caller's own sessions in this tenant, newest first; the first is
  /// the one presented.
  final accountSessions = <Map<String, Object?>>[
    {
      'id': 'sess-here',
      'current': true,
      'method': 'password',
      'second_factor': true,
      'user_agent': 'tix-mobile/0.6 (Android 15)',
      'created_at': '2026-11-08T09:00:00Z',
      'expires_at': '2026-12-08T09:00:00Z',
    },
    {
      'id': 'sess-laptop',
      'current': false,
      'method': 'ssh-key',
      'second_factor': false,
      'user_agent': 'tix-cli/1.4 (linux)',
      'created_at': '2026-11-01T09:00:00Z',
      'expires_at': '2026-12-01T09:00:00Z',
    },
  ];

  /// Ids of users whose second factor was cleared.
  final cleared = <String>[];

  var _ids = 0;

  static FakeResponse _ok(Object? body) => FakeResponse(200, body);

  static FakeResponse _list(List<Object?> items) =>
      FakeResponse(200, {'items': items});

  static FakeResponse _bad(String message) =>
      FakeResponse(400, envelope('invalid', message));

  FakeResponse? _requireGlobal() => globalAdmin
      ? null
      : FakeResponse(
          403,
          envelope('forbidden', 'only a global admin may do this'),
        );

  Map<String, Object?>? _tenant(String ref) {
    for (final t in tenants.values) {
      if (t['key'] == ref || t['id'] == ref) return t;
    }
    return null;
  }

  FakeResponse? _handle(
    RequestOptions options,
    String path,
    FakeCaller caller,
  ) {
    if (!path.startsWith('/api/v1/')) return null;
    final s = path.substring('/api/v1/'.length).split('/');
    final body = options.data is Map<String, dynamic>
        ? options.data as Map<String, dynamic>
        : const <String, dynamic>{};
    switch ((options.method, s)) {
      case ('GET', ['tenants']):
        final visible = globalAdmin
            ? tenants.values.toList()
            : [?tenants[caller.tenant]];
        return _list(visible);
      case ('POST', ['tenants']):
        if (_requireGlobal() case final refused?) return refused;
        final key = body['key'] as String? ?? '';
        if (key.isEmpty) return _bad('key is required');
        if (tenants.containsKey(key)) {
          return FakeResponse(409, envelope('conflict', 'tenant "$key"'));
        }
        final t = {'id': 'id-$key', 'key': key, 'name': body['name']};
        tenants[key] = t;
        final admins = (body['admins'] as List?) ?? const [];
        return _ok({
          ...t,
          'admins': [
            for (final a in admins)
              {
                'email': (a as Map)['email'],
                'password_generated': a['password'] == null,
              },
          ],
          'initial_credentials': [
            for (final a in admins)
              if ((a as Map)['password'] == null)
                {'email': a['email'], 'password': 'gen-pass-1234'},
          ],
        });
      case ('GET', ['tenants', final ref]):
        final t = _tenant(ref);
        if (t == null) return FakeResponse(404, envelope('not_found', ref));
        return _ok({...t, ...?server.tenantIcons[t['key']]});
      case ('PATCH', ['tenants', final ref]):
        final t = _tenant(ref);
        if (t == null) return FakeResponse(404, envelope('not_found', ref));
        if (body['name'] == '') return _bad('name must not be blank');
        for (final field in body.keys) {
          if (refuse[field] case final message?) return _bad(message);
        }
        const iconFields = {'icon', 'icon_name', 'icon_file'};
        if (body.keys.any(iconFields.contains)) {
          server.setTenantIcon(t['key']! as String, body);
        }
        t.addAll({
          for (final MapEntry(:key, :value) in body.entries)
            if (!iconFields.contains(key)) key: value,
        });
        return _ok({...t, ...?server.tenantIcons[t['key']]});
      case ('DELETE', ['tenants', final ref]):
        final t = _tenant(ref);
        if (t == null) return FakeResponse(404, envelope('not_found', ref));
        tenants.remove(t['key']);
        return const FakeResponse(204);
      case ('GET', ['tenants', final ref, 'users']):
        if (_requireGlobal() case final refused?) return refused;
        return FakeResponse(
          200,
          _pageOf(users[ref] ?? [], options.uri.queryParameters['cursor']),
        );
      case ('POST', ['tenants', final ref, 'users']):
        if (_requireGlobal() case final refused?) return refused;
        final u = {
          'id': 'u${++_ids + 10}',
          'email': body['email'],
          'display_name': body['display_name'] ?? '',
          'role': body['role'] ?? 'viewer',
        };
        users.putIfAbsent(ref, () => []).add(u);
        return _ok(u);
      case ('POST', ['tenants', final ref, 'members']):
        if (_requireGlobal() case final refused?) return refused;
        final u = {
          'id': 'm${++_ids}',
          'email': body['email'],
          'role': body['role'] ?? 'viewer',
        };
        users.putIfAbsent(ref, () => []).add(u);
        return _ok(u);
      case ('PATCH', ['tenants', final ref, 'users', final id]):
        if (_requireGlobal() case final refused?) return refused;
        for (final u in users[ref] ?? const <Map<String, Object?>>[]) {
          if (u['id'] == id) {
            final changes = {...body};
            final disabled = changes.remove('disabled');
            changes.remove('password');
            u.addAll(changes);
            if (disabled == true) u['disabled_at'] = '2026-11-01T12:00:00Z';
            if (disabled == false) u.remove('disabled_at');
            return _ok(u);
          }
        }
        return FakeResponse(404, envelope('not_found', id));
      case ('DELETE', ['tenants', final ref, 'users', final id]):
        if (_requireGlobal() case final refused?) return refused;
        users[ref]?.removeWhere((u) => u['id'] == id);
        return const FakeResponse(204);
      case ('GET', ['tenants', final ref, 'domains']):
        if (_requireGlobal() case final refused?) return refused;
        return _list(domains[ref] ?? []);
      case ('DELETE', ['users', final id, 'totp']):
        cleared.add(id);
        for (final list in users.values) {
          for (final u in list) {
            if (u['id'] == id) u['totp_enrolled'] = false;
          }
        }
        return const FakeResponse(204);
      case ('GET', ['domains']):
        return _list(domains[caller.tenant] ?? []);
      case ('POST', ['domains']):
        final host = (body['hostname'] as String? ?? '').toLowerCase();
        if (host.isEmpty) return _bad('hostname is required');
        final mode = body['cert_mode'] as String? ?? 'none';
        if (mode != 'none' && mode != 'file') {
          return _bad('cert mode "$mode" must be "none" or "file"');
        }
        final d = {
          'id': 'd${++_ids}',
          'hostname': host,
          'cert_mode': mode,
          'shared': false,
        };
        domains.putIfAbsent(caller.tenant, () => []).add(d);
        return _ok(d);
      case ('DELETE', ['domains', final host]):
        domains[caller.tenant]?.removeWhere((d) => d['hostname'] == host);
        return const FakeResponse(204);
      case ('PATCH', ['domains', final host]):
        if (_requireGlobal() case final refused?) return refused;
        for (final list in domains.values) {
          for (final d in list) {
            if (d['hostname'] == host) {
              d['shared'] = body['shared'];
              return _ok(d);
            }
          }
        }
        return FakeResponse(404, envelope('not_found', host));
      case ('GET', ['global-admins']):
        if (_requireGlobal() case final refused?) return refused;
        return _list([
          for (final e in globalAdmins) {'email': e, 'global_admin': true},
        ]);
      case ('POST', ['global-admins']):
        if (_requireGlobal() case final refused?) return refused;
        final email = body['email'] as String? ?? '';
        if (!email.contains('@')) return _bad('email "$email" is not valid');
        globalAdmins.add(email);
        return _ok({'email': email, 'global_admin': true});
      case ('DELETE', ['global-admins', final email]):
        if (_requireGlobal() case final refused?) return refused;
        globalAdmins.remove(Uri.decodeComponent(email));
        return const FakeResponse(204);
      case ('GET', ['accounts', final email, 'log']):
        if (_requireGlobal() case final refused?) return refused;
        return FakeResponse(
          200,
          _pageOf(
            accountLogs[Uri.decodeComponent(email)] ?? [],
            options.uri.queryParameters['cursor'],
          ),
        );
      case ('GET', ['auth', 'session-policy']):
        return _ok(sessionPolicy);
      case ('GET', ['artifact-limits']):
        return _ok(artifactLimits);
      case ('GET', ['connections']):
        return _ok({
          'server_id': 'srv-1',
          'connections': connections,
          'counts': {
            'events': connections.where((c) => c['surface'] == 'events').length,
            'ssh': connections.where((c) => c['surface'] == 'ssh').length,
            'tenant': connections.length,
            'process': connections.length + 3,
          },
        });
      case ('DELETE', ['connections', final id]):
        connections.removeWhere((c) => c['id'] == id);
        return const FakeResponse(204);
      case ('GET', ['auth', 'totp']):
        return _ok({
          'enrolled': totp == 'on',
          'pending': totp == 'pending',
          'recovery_codes_left': codesLeft,
          'required_web': requiredWeb,
          if (totp == 'on') 'confirmed_at': '2026-10-01T09:00:00Z',
        });
      case ('POST', ['auth', 'totp']):
        totp = 'pending';
        return _ok({
          'secret': secret,
          'uri': 'otpauth://totp/tix:ana?secret=$secret&issuer=tix',
          'issuer': 'tix',
          'account': 'ana',
        });
      case ('POST', ['auth', 'totp', 'confirm']):
        if (totp != 'pending') return _bad('no enrolment to confirm');
        if (body['code'] != goodCode) {
          return FakeResponse(
            401,
            envelope('unauthenticated', 'incorrect code'),
          );
        }
        totp = 'on';
        codesLeft = codes.length;
        return _ok({'codes': codes});
      case ('POST', ['auth', 'totp', 'recovery-codes']):
        if (totp != 'on') return _bad('no second factor');
        codesLeft = codes.length;
        return _ok({'codes': codes});
      case ('DELETE', ['auth', 'totp']):
        totp = 'off';
        codesLeft = 0;
        return const FakeResponse(204);
      case ('GET', ['ssh-keys']):
        return _list(sshKeys);
      case ('POST', ['ssh-keys']):
        final key = body['public_key'] as String? ?? '';
        if (!key.startsWith('ssh-')) return _bad('not an authorized_keys line');
        final k = {
          'id': 'k${++_ids + 1}',
          'label': body['label'] ?? '',
          'fingerprint': 'SHA256:new$_ids',
          'public_key': key,
          'created_at': '2026-11-01T12:00:00Z',
          if (body['all_tenants'] == true) 'enrolled_in': ['default', 'acme'],
        };
        sshKeys.add(k);
        return _ok(k);
      case ('GET', ['account', 'sessions']):
        return _ok(
          _pageOf(accountSessions, options.uri.queryParameters['cursor']),
        );
      case ('DELETE', ['account', 'sessions', final id]):
        final before = accountSessions.length;
        accountSessions.removeWhere((x) => x['id'] == id);
        if (accountSessions.length == before) {
          return FakeResponse(404, envelope('not_found', 'session "$id"'));
        }
        return const FakeResponse(204);
      case ('DELETE', ['ssh-keys', final id]):
        for (final k in sshKeys) {
          if (k['id'] == id) k['revoked_at'] = '2026-11-01T12:00:00Z';
        }
        return const FakeResponse(204);
    }
    return null;
  }

  Map<String, Object?> _pageOf(
    List<Map<String, Object?>> rows,
    String? cursor,
  ) {
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + server.pageSize).clamp(0, rows.length);
    return {
      'items': rows.sublist(start, end),
      'next_cursor': end < rows.length ? '$end' : '',
    };
  }
}
