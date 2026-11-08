// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';

/// Sends the generated client's requests over one connection's [Dio] and
/// maps every failure to a [TixException]. It marshals and nothing else.
class TixTransport {
  /// Sends through [dio], which already carries the base URL and credential.
  TixTransport(this.dio);

  /// The connection's HTTP client.
  final Dio dio;

  /// [value] escaped as one path segment.
  String segment(String value) => Uri.encodeComponent(value);

  /// A request answered with a JSON object. A raw [body] is sent as
  /// [contentType].
  Future<Map<String, dynamic>> json(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    String? contentType,
  }) async {
    final response = await _send(
      method,
      path,
      query: query,
      body: body,
      contentType: contentType,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw TixException(TixErrorKind.notTix, status: response.statusCode);
    }
    return data;
  }

  /// A request answered with a JSON object or with no content at all.
  Future<Map<String, dynamic>?> jsonOrNull(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    String? contentType,
  }) async {
    final response = await _send(
      method,
      path,
      query: query,
      body: body,
      contentType: contentType,
    );
    final data = response.data;
    if (response.statusCode == 204 || data == null || data == '') return null;
    if (data is! Map<String, dynamic>) {
      throw TixException(TixErrorKind.notTix, status: response.statusCode);
    }
    return data;
  }

  /// A request answered with a JSON array.
  Future<List<Object?>> jsonList(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    String? contentType,
  }) async {
    final response = await _send(
      method,
      path,
      query: query,
      body: body,
      contentType: contentType,
    );
    final data = response.data;
    if (data is! List<Object?>) {
      throw TixException(TixErrorKind.notTix, status: response.statusCode);
    }
    return data;
  }

  /// A request answered with no content.
  Future<void> empty(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
  }) => _send(method, path, query: query, body: body);

  /// A request answered with text in [accept], or sending a raw [body] of
  /// [contentType].
  Future<String> text(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    String? contentType,
    String accept = 'text/plain',
  }) async {
    final response = await _send(
      method,
      path,
      query: query,
      body: body,
      contentType: contentType,
      accept: accept,
      // Bytes, not plain: Dio decodes any +json body even when asked for
      // text, and a bundle is NDJSON served as application/vnd.tix.bundle+json.
      type: ResponseType.bytes,
    );
    final data = response.data;
    return data is List<int> ? utf8.decode(data, allowMalformed: true) : '';
  }

  /// A request answered with a file.
  Future<Uint8List> bytes(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
  }) async {
    final response = await _send(
      method,
      path,
      query: query,
      body: body,
      accept: '*/*',
      type: ResponseType.bytes,
    );
    final data = response.data;
    return data is List<int> ? Uint8List.fromList(data) : Uint8List(0);
  }

  /// A listing streamed as NDJSON: one decoded JSON value per line, with no
  /// envelope and no cursor.
  Stream<Object?> ndjson(
    String method,
    String path, {
    Map<String, Object?>? query,
  }) async* {
    final response = await _send(
      method,
      path,
      query: query,
      accept: 'application/x-ndjson',
      type: ResponseType.stream,
    );
    final body = response.data;
    if (body is! ResponseBody) {
      throw TixException(TixErrorKind.notTix, status: response.statusCode);
    }
    final lines = body.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        yield jsonDecode(line);
      } on FormatException {
        throw TixException(TixErrorKind.notTix, status: response.statusCode);
      }
    }
  }

  Future<Response<Object?>> _send(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    String? contentType,
    String? accept,
    ResponseType? type,
  }) async {
    try {
      return await dio.request<Object?>(
        path,
        data: body,
        queryParameters: query == null ? null : encodeQuery(query),
        options: Options(
          method: method,
          contentType: contentType,
          responseType: type,
          headers: {'Accept': ?accept},
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is ResponseBody) throw await _fromStream(e, data);
      if (data is List<int>) throw _fromBytes(e, data);
      throw TixException.fromDio(e);
    }
  }

  /// A failed request read as bytes carries its envelope undecoded.
  static TixException _fromBytes(DioException e, List<int> bytes) {
    final text = utf8.decode(bytes, allowMalformed: true);
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      decoded = text;
    }
    return TixException.fromResponse(
      Response<Object?>(
        requestOptions: e.requestOptions,
        statusCode: e.response?.statusCode,
        headers: e.response?.headers,
        data: decoded,
      ),
    );
  }

  /// A failed streamed request carries its envelope unread.
  static Future<TixException> _fromStream(
    DioException e,
    ResponseBody body,
  ) async {
    final text = await body.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .join();
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      decoded = text;
    }
    return TixException.fromResponse(
      Response<Object?>(
        requestOptions: e.requestOptions,
        statusCode: e.response?.statusCode,
        headers: e.response?.headers,
        data: decoded,
      ),
    );
  }

  /// [query] as tix reads it: absent values left out, instants in UTC
  /// RFC 3339, lists as repeated parameters.
  static Map<String, Object> encodeQuery(Map<String, Object?> query) => {
    for (final MapEntry(:key, :value) in query.entries)
      if (value != null) key: _encode(value),
  };

  static Object _encode(Object value) => switch (value) {
    final DateTime d => d.toUtc().toIso8601String(),
    final List<Object?> l => [
      for (final v in l)
        if (v != null) _encode(v).toString(),
    ],
    _ => value.toString(),
  };
}
