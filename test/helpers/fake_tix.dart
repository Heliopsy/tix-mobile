// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

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

/// An in-memory tix server: enough of `/api/v1` for the app's screens.
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
           };

  final String token;
  final List<Map<String, Object?>> projects;
  final Map<String, List<Map<String, Object?>>> tasks;
  final actors = <String, Map<String, Object?>>{
    'me': {'id': 'me', 'handle': 'ana', 'kind': 'user'},
    'a1': {'id': 'a1', 'handle': 'raj', 'display_name': 'Raj', 'kind': 'user'},
  };

  /// Answers every request with this when set, for failure paths.
  FakeResponse? override;

  /// Holds every answer until completed, for loading states.
  Completer<void>? gate;

  /// Rows per page, so tests can force pagination.
  int pageSize = 50;

  late final adapter = FakeAdapter(_handle);

  /// A factory override that sends every client to this server.
  TixApiFactory get factory =>
      (baseUrl, token) =>
          TixApi(baseUrl: baseUrl, token: token, adapter: adapter);

  List<RequestOptions> get requests => adapter.requests;

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
    if (o.headers['Authorization'] != 'Bearer $token') {
      return FakeResponse(401, envelope('unauthenticated', 'bad token'));
    }
    final q = o.uri.queryParameters;
    switch ((o.method, path)) {
      case ('GET', '/api/v1/whoami'):
        return FakeResponse(200, actors['me']);
      case ('GET', '/api/v1/projects'):
        return FakeResponse(200, _page(projects, q['cursor']));
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

  Map<String, Object?> _page(List<Map<String, Object?>> rows, String? cursor) {
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + pageSize).clamp(0, rows.length);
    return {
      'items': rows.sublist(start, end),
      'next_cursor': end < rows.length ? '$end' : '',
    };
  }
}
