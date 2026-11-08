// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/health.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';

/// The tix HTTP API under `/api/v1`. Marshals and nothing else.
class TixApi {
  /// Talks to the server at [baseUrl], sending [token] as a bearer token.
  TixApi({required String baseUrl, String? token, HttpClientAdapter? adapter})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          headers: {
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      ) {
    if (adapter != null) _dio.httpClientAdapter = adapter;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (r, h) {
          log(
            '${r.requestOptions.method} ${r.requestOptions.path} '
            '${r.statusCode}',
          );
          h.next(r);
        },
        onError: (e, h) {
          log(
            '${e.requestOptions.method} ${e.requestOptions.path} '
            '${e.response?.statusCode ?? e.type.name}',
          );
          h.next(e);
        },
      ),
    );
  }

  final Dio _dio;

  /// `GET /healthz`: whether a tix server answers at all, and its version.
  Future<Health> health() async => Health.fromJson(await _get('/healthz'));

  /// `GET /whoami`: the identity the token belongs to.
  Future<Actor> whoami() async => Actor.fromJson(await _get('/api/v1/whoami'));

  /// `GET /projects`: one page of projects, ordered by key.
  Future<Page<Project>> projects({
    String? cursor,
    int limit = pageSize,
  }) async => Page.fromJson(
    await _get('/api/v1/projects', query: {'limit': limit, 'cursor': ?cursor}),
    Project.fromJson,
  );

  /// `GET /tasks?project=KEY`: one page of a project's tasks, most urgent first.
  Future<Page<Task>> tasks({
    required String project,
    String? cursor,
    int limit = pageSize,
  }) async => Page.fromJson(
    await _get(
      '/api/v1/tasks',
      query: {'project': project, 'limit': limit, 'cursor': ?cursor},
    ),
    Task.fromJson,
  );

  /// `GET /tasks/REF`.
  Future<Task> task(String ref) async =>
      Task.fromJson(await _get('/api/v1/tasks/${Uri.encodeComponent(ref)}'));

  /// `GET /actors/ID`.
  Future<Actor> actor(String id) async =>
      Actor.fromJson(await _get('/api/v1/actors/${Uri.encodeComponent(id)}'));

  /// `POST /tasks`.
  Future<Task> createTask(CreateTaskRequest request) async => Task.fromJson(
    await _send(
      () => _dio.post<Object?>('/api/v1/tasks', data: request.toJson()),
    ),
  );

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, Object?>? query,
  }) => _send(() => _dio.get<Object?>(path, queryParameters: query));

  Future<Map<String, dynamic>> _send(
    Future<Response<Object?>> Function() call,
  ) async {
    final Response<Object?> response;
    try {
      response = await call();
    } on DioException catch (e) {
      throw TixException.fromDio(e);
    }
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw TixException(TixErrorKind.notTix, status: response.statusCode);
    }
    return data;
  }
}
