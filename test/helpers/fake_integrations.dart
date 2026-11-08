// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';

import 'fake_tix.dart';

/// Webhooks, external sync, retention, housekeeping, the trash listing and
/// the audit log on a [FakeTix], answered as tix answers them.
class FakeIntegrations {
  /// Installs the routes on [server].
  FakeIntegrations(this.server) {
    server.routes.add(_handle);
  }

  /// The server the routes answer on.
  final FakeTix server;

  /// Webhook endpoints, as listed: never with their secret.
  final webhooks = <Map<String, Object?>>[];

  /// The secret each endpoint was last saved with, by id.
  final secrets = <String, String>{};

  /// The delivery log, newest first.
  final deliveries = <Map<String, Object?>>[];

  /// Deliveries queued again, by id.
  final redelivered = <String>[];

  /// Sync sources.
  final sources = <Map<String, Object?>>[];

  /// The credentials each source was saved with, by name.
  final credentials = <String, Map<String, Object?>>{};

  /// What a sync run answers.
  Map<String, Object?> runResult = {
    'source': 'jira-main',
    'system': 'jira',
    'created': {'task': 3},
    'updated': {'task': 1},
    'skipped': {'task': 7},
    'warnings': <String>[],
  };

  /// Sync runs asked for: the body of each.
  final runs = <Map<String, dynamic>>[];

  /// Audit entries, newest first.
  final audit = <Map<String, Object?>>[];

  /// The retention policy.
  Map<String, Object?> retention = {
    'tenant_id': 'id-default',
    'events': '720h0m0s',
    'audit_entries': '8760h0m0s',
    'webhook_deliveries': '720h0m0s',
  };

  /// Prune requests: whether each was a dry run.
  final prunes = <bool>[];

  /// The tenant's housekeeping rules, in days; null is off.
  final rules = <String, int?>{'done': null, 'cancelled': null, 'trash': null};

  /// Whether the trash is off, which pauses housekeeping.
  bool paused = false;

  /// Housekeeping runs: whether each was a dry run.
  final housekeepingRuns = <bool>[];

  var _ids = 0;

  Map<String, Object?> _page(List<Map<String, Object?>> rows, String? cursor) {
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + server.pageSize).clamp(0, rows.length);
    return {
      'items': rows.sublist(start, end),
      'next_cursor': end < rows.length ? '$end' : '',
    };
  }

  FakeResponse _invalid(String message) =>
      FakeResponse(400, envelope('invalid', message));

  Map<String, Object?> _housekeeping() => {
    'tenant': rules,
    'effective': {for (final e in rules.entries) e.key: e.value ?? 0},
    'paused': paused,
    'pending': {'done': 4, 'cancelled': 1, 'trash': 2},
  };

  FakeResponse? _handle(RequestOptions o, String path, FakeCaller caller) {
    final q = o.uri.queryParametersAll;
    String? one(String k) => o.uri.queryParameters[k];
    final body = o.data is Map<String, dynamic>
        ? o.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final s = path.split('/').skip(3).toList();
    switch ((o.method, s)) {
      case ('GET', ['tasks']) when one('trashed') == 'true':
        return FakeResponse(
          200,
          _page(server.trash.values.toList(), one('cursor')),
        );
      case ('GET', ['webhooks']):
        return FakeResponse(200, {'items': webhooks});
      case ('PUT', ['webhooks']):
        final url = (body['url'] as String?) ?? '';
        if (!url.startsWith('https://')) {
          return _invalid('webhook url "$url" must use https');
        }
        final id = (body['id'] as String?) ?? 'wh${++_ids}';
        final secret = body['secret'] as String?;
        if (secret != null) secrets[id] = secret;
        final endpoint = {
          'id': id,
          'url': url,
          'event_types': body['event_types'] ?? <String>[],
          'active': body['active'] ?? false,
          'created_at': '2026-11-01T10:00:00Z',
        };
        webhooks
          ..removeWhere((e) => e['id'] == id)
          ..add(endpoint);
        return FakeResponse(200, endpoint);
      case ('DELETE', ['webhooks', final id]):
        if (!webhooks.any((e) => e['id'] == id)) {
          return FakeResponse(404, envelope('not_found', 'webhook "$id"'));
        }
        webhooks.removeWhere((e) => e['id'] == id);
        return const FakeResponse(204);
      case ('GET', ['webhooks', 'deliveries']):
        final rows = [
          for (final d in deliveries)
            if ((one('endpoint_id') == null ||
                    d['endpoint_id'] == one('endpoint_id')) &&
                (q['status'] == null || q['status']!.contains(d['status'])))
              d,
        ];
        return FakeResponse(200, _page(rows, one('cursor')));
      case ('POST', ['webhooks', 'deliveries', final id, 'redeliver']):
        redelivered.add(id);
        for (final d in deliveries) {
          if (d['id'] == id) d['status'] = 'pending';
        }
        return const FakeResponse(204);
      case ('GET', ['sync', 'sources']):
        return FakeResponse(200, {'items': sources});
      case ('PUT', ['sync', 'sources']):
        final config = (body['config'] as Map?) ?? const {};
        if (config['file'] != null) {
          return _invalid(
            'this server does not read a file named by a tenant; upload '
            'the document instead',
          );
        }
        final name = body['name'] as String? ?? '';
        final secret = {
          for (final k in ['token', 'user', 'password'])
            if (body[k] != null) k: body[k],
        };
        final stored = secret.isNotEmpty
            ? secret
            : (credentials[name] ?? const <String, Object?>{});
        final source = {
          'id': body['check'] == true ? '' : (body['id'] ?? 'src${++_ids}'),
          'name': name,
          'system': body['system'],
          'config': config,
          'mapping': body['mapping'] ?? '',
          'credentials': [
            for (final MapEntry(:key, :value) in stored.entries)
              {
                'name': key,
                'hint': (value! as String).length > 8
                    ? (value as String).substring(value.length - 4)
                    : '',
              },
          ],
          'resolved': {
            'mapping': {'from': body['mapping'] == null ? 'missing' : 'stored'},
            'credentials': {'from': stored.isEmpty ? 'missing' : 'stored'},
            'settings': [
              for (final MapEntry(:key, :value) in config.entries)
                {'key': key, 'from': 'stored', 'value': value},
            ],
            'missing': [
              if (body['mapping'] == null) 'a mapping document',
              if (stored.isEmpty) 'credentials',
            ],
          },
        };
        if (body['check'] == true) return FakeResponse(200, source);
        if (secret.isNotEmpty) credentials[name] = secret;
        sources
          ..removeWhere((x) => x['id'] == source['id'])
          ..add(source);
        return FakeResponse(200, source);
      case ('DELETE', ['sync', 'sources', final id]):
        sources.removeWhere((x) => x['id'] == id);
        return const FakeResponse(204);
      case ('POST', ['sync', 'run']):
        runs.add(body);
        return FakeResponse(200, {
          ...runResult,
          'dry_run': body['dry_run'] ?? false,
        });
      case ('GET', ['audit']):
        bool any(String key, Object? value) =>
            q[key] == null || q[key]!.contains(value);
        final text = one('text')?.toLowerCase();
        final rows = [
          for (final e in audit)
            if (any('action', e['action']) &&
                any('actor_id', e['actor_id']) &&
                any('source', e['source']) &&
                any('via', (e['via'] as Map?)?['kind']) &&
                any('token', (e['via'] as Map?)?['token_name']) &&
                (one('subject_type') == null ||
                    e['subject_type'] == one('subject_type')) &&
                (text == null ||
                    '${e['action']} ${e['subject_type']} ${e['after']}'
                        .toLowerCase()
                        .contains(text)))
              e,
        ];
        return FakeResponse(200, _page(rows, one('cursor')));
      case ('GET', ['retention']):
        return FakeResponse(200, retention);
      case ('PUT', ['retention']):
        for (final k in ['events', 'audit_entries', 'webhook_deliveries']) {
          final v = body[k] as String?;
          if (v == null) continue;
          if (!RegExp(r'^\d+h$').hasMatch(v)) {
            return _invalid('retention $k "$v" is not a duration');
          }
          retention[k] = '${v}0m0s';
        }
        return FakeResponse(200, retention);
      case ('POST', ['prune']):
        final dry = body['dry_run'] == true;
        prunes.add(dry);
        return FakeResponse(200, {
          'events': 172,
          'audit_entries': 3,
          'webhook_deliveries': 0,
          'retained_for_subscribers': dry ? 0 : 5,
          'dry_run': dry,
        });
      case ('GET', ['housekeeping']):
        return FakeResponse(200, _housekeeping());
      case ('PUT', ['housekeeping']):
        for (final k in ['done', 'cancelled', 'trash']) {
          final v = body[k] as String?;
          if (v == null || v.isEmpty) continue;
          if (v == 'off') {
            rules[k] = null;
          } else {
            final days = int.tryParse(v.replaceFirst(RegExp(r'd$'), ''));
            if (days == null) return _invalid('housekeeping $k "$v"');
            rules[k] = days;
          }
        }
        return FakeResponse(200, _housekeeping());
      case ('POST', ['housekeeping', 'run']):
        final dry = body['dry_run'] == true;
        housekeepingRuns.add(dry);
        return FakeResponse(200, {
          'dry_run': dry,
          'paused': paused,
          'done': paused ? 0 : 4,
          'cancelled': paused ? 0 : 1,
          'trash': paused ? 0 : 2,
        });
    }
    return null;
  }
}

/// An audit entry as tix lists it.
Map<String, Object?> auditJson(
  int seq, {
  String action = 'task.create',
  String subjectType = 'task',
  String subjectId = 'infra-1',
  String actor = 'me',
  String source = 'api',
  String via = 'web',
  String token = '',
  Object? before,
  Object? after,
}) => {
  'seq': seq,
  'tenant_id': 'id-default',
  'actor_id': actor,
  'action': action,
  'subject_type': subjectType,
  'subject_id': subjectId,
  'source': source,
  'via': {
    'kind': via,
    if (token.isNotEmpty) 'token_name': token,
    if (token.isNotEmpty) 'token_id': 'tok-$token',
  },
  'before': ?before,
  'after': ?after,
  'occurred_at': '2026-11-01T0${seq % 10}:00:00Z',
};

/// A webhook delivery as tix lists it.
Map<String, Object?> deliveryJson(
  String id, {
  String endpoint = 'wh1',
  String status = 'delivered',
  int attempts = 1,
  int code = 200,
  String error = '',
}) => {
  'id': id,
  'endpoint_id': endpoint,
  'event_seq': 40,
  'status': status,
  'attempts': attempts,
  'last_status_code': code,
  'last_error': error,
  'created_at': '2026-11-01T09:00:00Z',
  'next_attempt_at': '2026-11-01T09:05:00Z',
};
