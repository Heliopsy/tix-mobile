// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' show DioExceptionType;
import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/events/live_events.dart';

/// Which way live updates travel right now.
enum LiveTransport {
  /// Nothing: refused, asleep or closed.
  none,

  /// The WebSocket.
  websocket,

  /// Long polling over HTTP.
  poll,

  /// Reading what is on screen again on a timer.
  refresh,
}

/// What was trying to reach the server when something failed.
enum LiveErrorSource {
  /// The WebSocket carrying live updates.
  websocket,

  /// A background WebSocket attempt while polling or refreshing.
  probe,

  /// A long poll.
  poll,
}

/// What kind of failure it was, which decides the hint shown with it.
enum LiveErrorKind {
  /// The host could not be reached: a name that does not resolve, a refused
  /// or reset connection, no network.
  unreachable,

  /// Nothing came back in time.
  timeout,

  /// The TLS handshake failed: a certificate problem.
  tls,

  /// The WebSocket upgrade was answered with an HTTP status instead.
  upgradeRefused,

  /// The WebSocket was closed by the server or something in between.
  closed,

  /// The server refused this credential live updates.
  refused,

  /// A poll was answered with an HTTP error.
  http,

  /// Anything else.
  other,
}

/// One failure, described without a credential.
@immutable
class LiveError {
  /// A failure of [kind] from [source] at [at].
  const LiveError({
    required this.at,
    required this.source,
    required this.kind,
    required this.type,
    this.message = '',
    this.httpStatus,
    this.tixKind,
    this.osErrorCode,
    this.osErrorMessage,
    this.closeCode,
    this.closeReason,
  });

  /// Describes [error], scrubbing [secrets] and anything that looks like
  /// one from its message.
  factory LiveError.from(
    Object? error, {
    required DateTime at,
    required LiveErrorSource source,
    Iterable<String> secrets = const [],
  }) {
    String clean(String? s) => _clip(redactSecrets(s ?? '', secrets));
    final tix = error is TixException ? error : null;
    final inner = tix?.cause ?? error;
    final os = switch (inner) {
      SocketException(:final osError) => osError,
      TlsException(:final osError) => osError,
      _ => null,
    };
    final kind = switch (inner) {
      _ when tix != null && _refusedKinds.contains(tix.kind) =>
        LiveErrorKind.refused,
      null when tix == null => LiveErrorKind.closed,
      EventSocketClosed() => LiveErrorKind.closed,
      WebSocketException(httpStatusCode: 401 || 403) => LiveErrorKind.refused,
      WebSocketException(httpStatusCode: final int _) =>
        LiveErrorKind.upgradeRefused,
      TlsException() || DioExceptionType.badCertificate => LiveErrorKind.tls,
      SocketException() => LiveErrorKind.unreachable,
      TimeoutException() => LiveErrorKind.timeout,
      Map<Object?, Object?>() => LiveErrorKind.refused,
      _ when tix?.kind == TixErrorKind.timeout => LiveErrorKind.timeout,
      _ when tix?.kind == TixErrorKind.network => LiveErrorKind.unreachable,
      _ when tix?.status != null => LiveErrorKind.http,
      _ => LiveErrorKind.other,
    };
    final message = switch (inner) {
      EventSocketClosed() => '',
      SocketException(:final message) => message,
      TlsException(:final message) => message,
      WebSocketException(:final message) => message,
      TimeoutException(:final message) => message ?? '',
      Map<Object?, Object?>() => [
        if (inner['code'] != null) '${inner['code']}',
        if (inner['message'] != null) '${inner['message']}',
      ].join(': '),
      DioExceptionType() => tix?.message ?? '',
      null => tix?.message ?? '',
      _ when tix != null => tix.message,
      _ => inner.toString(),
    };
    return LiveError(
      at: at,
      source: source,
      kind: kind,
      type: _typeOf(inner, tix),
      message: clean(message),
      httpStatus: switch (inner) {
        WebSocketException(:final httpStatusCode) => httpStatusCode,
        _ => tix?.status,
      },
      tixKind: tix?.kind,
      osErrorCode: os?.errorCode,
      osErrorMessage: os == null ? null : clean(os.message),
      closeCode: inner is EventSocketClosed ? inner.code : null,
      closeReason: inner is EventSocketClosed && inner.reason != null
          ? clean(inner.reason)
          : null,
    );
  }

  /// When it happened.
  final DateTime at;

  /// What was trying.
  final LiveErrorSource source;

  /// Its class.
  final LiveErrorKind kind;

  /// The underlying exception's type, such as `SocketException`.
  final String type;

  /// Its message, with secrets removed. Empty when it had none.
  final String message;

  /// The HTTP status of the poll or of the refused upgrade.
  final int? httpStatus;

  /// The app's classification when the failure came through the API client.
  final TixErrorKind? tixKind;

  /// The operating system's error code, for a socket or TLS failure.
  final int? osErrorCode;

  /// The operating system's error message.
  final String? osErrorMessage;

  /// The WebSocket close code, when the other end sent one.
  final int? closeCode;

  /// The WebSocket close reason.
  final String? closeReason;

  /// Everything known in one line of plain text, for a report.
  String describe() => [
    '${kind.name} on ${source.name}',
    type,
    if (httpStatus != null) 'HTTP $httpStatus',
    if (tixKind != null) 'kind ${tixKind!.name}',
    if (osErrorCode != null || osErrorMessage != null)
      'OS error ${osErrorCode ?? '?'} ${osErrorMessage ?? ''}'.trim(),
    if (closeCode != null) 'close code $closeCode',
    if (closeReason != null && closeReason!.isNotEmpty)
      'close reason "$closeReason"',
    if (message.isNotEmpty) message,
  ].join(', ');

  static const Set<TixErrorKind> _refusedKinds = {
    TixErrorKind.unauthenticated,
    TixErrorKind.forbidden,
  };

  static String _typeOf(Object? inner, TixException? tix) => switch (inner) {
    EventSocketClosed() => 'WebSocket closed',
    HandshakeException() => 'HandshakeException',
    CertificateException() => 'CertificateException',
    TlsException() => 'TlsException',
    SocketException() => 'SocketException',
    WebSocketException() => 'WebSocketException',
    TimeoutException() => 'TimeoutException',
    HttpException() => 'HttpException',
    Map<Object?, Object?>() => 'server error frame',
    DioExceptionType(:final name) => 'TixException ($name)',
    null when tix != null => 'TixException',
    null => 'WebSocket closed',
    _ => inner.runtimeType.toString(),
  };

  static String _clip(String s) =>
      s.length <= _maxMessage ? s : '${s.substring(0, _maxMessage)}…';

  static const _maxMessage = 300;
}

/// A mode change or a failure, as [LiveDiagnostics.history] keeps them.
@immutable
class LiveLogEntry {
  /// What happened at [at]: the [mode] reached, or the [error] met in it.
  const LiveLogEntry({
    required this.at,
    required this.mode,
    required this.transport,
    this.error,
  });

  /// When.
  final DateTime at;

  /// The mode, after the change or while failing.
  final LiveMode mode;

  /// The transport at that moment.
  final LiveTransport transport;

  /// The failure, null for a mode change.
  final LiveError? error;

  /// One line of plain text, for a report.
  String describe() => error == null
      ? '${_stamp(at)} ${mode.name} (${transport.name})'
      : '${_stamp(at)} error: ${error!.describe()}';
}

/// Why live updates are in the mode they are, for the connection details.
/// Holds no credential and no address beyond the server's host.
@immutable
class LiveDiagnostics {
  /// The facts.
  const LiveDiagnostics({
    required this.mode,
    required this.transport,
    required this.host,
    required this.modeSince,
    required this.failuresBeforeFallback,
    required this.failureWindow,
    this.lastContactAt,
    this.lastEventAt,
    this.consecutiveFailures = 0,
    this.windowFailures = 0,
    this.pollUnsupported = false,
    this.lastError,
    this.nextRetryAt,
    this.nextProbeAt,
    this.cursor = 0,
    this.history = const [],
  });

  /// The mode.
  final LiveMode mode;

  /// The transport.
  final LiveTransport transport;

  /// The server's scheme, host and port, with no path or query.
  final String host;

  /// When the current mode started.
  final DateTime modeSince;

  /// The last subscription acknowledged or poll answered.
  final DateTime? lastContactAt;

  /// The last event delivered.
  final DateTime? lastEventAt;

  /// Failures since the last success.
  final int consecutiveFailures;

  /// WebSocket failures counting towards the fallback now.
  final int windowFailures;

  /// WebSocket failures within [failureWindow] that switch to polling.
  final int failuresBeforeFallback;

  /// How long a WebSocket failure counts towards the fallback.
  final Duration failureWindow;

  /// Whether the server answered the poll with 404 or 405, so what is on
  /// screen is refreshed on a timer instead.
  final bool pollUnsupported;

  /// The most recent failure, kept after recovering from it.
  final LiveError? lastError;

  /// When the next attempt over the current transport is due.
  final DateTime? nextRetryAt;

  /// When the WebSocket is tried again in the background while polling or
  /// refreshing.
  final DateTime? nextProbeAt;

  /// The highest `seq` seen.
  final int cursor;

  /// The latest mode changes and failures, oldest first.
  final List<LiveLogEntry> history;

  /// A plain-text report for a bug or a server administrator, with [app]
  /// and [platform] at the top. Every message in it was redacted when it
  /// was recorded and is redacted again here.
  String toReport({String app = '', String platform = ''}) {
    final window =
        'WebSocket failures in the last ${failureWindow.inSeconds} s: '
        '$windowFailures of $failuresBeforeFallback before polling';
    final lines = [
      'tix-mobile live connection details',
      if (app.isNotEmpty) 'App: $app',
      if (platform.isNotEmpty) 'Platform: $platform',
      'Server: $host',
      'Mode: ${mode.name} over ${transport.name} since ${_stamp(modeSince)}',
      'Last contact: ${_stampOr(lastContactAt)}',
      'Last event: ${_stampOr(lastEventAt)}',
      'Failures in a row: $consecutiveFailures',
      window,
      'Poll endpoint: ${pollUnsupported ? 'missing (404/405)' : 'available'}',
      if (nextRetryAt != null) 'Next retry: ${_stamp(nextRetryAt!)}',
      if (nextProbeAt != null) 'Next WebSocket try: ${_stamp(nextProbeAt!)}',
      'Cursor: $cursor',
      if (lastError case final e?)
        'Last error: ${_stamp(e.at)} ${e.describe()}',
      if (history.isNotEmpty) ...[
        'History:',
        for (final h in history) '  ${h.describe()}',
      ],
    ];
    return redactSecrets(lines.join('\n'));
  }
}

/// The scheme, host and port of [baseUrl], with no credentials, path or
/// query.
String hostOf(String baseUrl) {
  final uri = Uri.tryParse(baseUrl);
  if (uri == null || uri.host.isEmpty) return '';
  return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
}

/// [text] with every one of [secrets] (six characters or longer) and
/// anything shaped like a credential replaced by `[redacted]`: bearer and
/// basic tokens, credential headers and parameters, long opaque strings,
/// and the user info, query and fragment of URLs.
String redactSecrets(String text, [Iterable<String> secrets = const []]) {
  var out = text;
  for (final s in secrets) {
    if (s.length >= 6) out = out.replaceAll(s, _hidden);
  }
  return out
      .replaceAllMapped(
        _url,
        (m) => '${m[1]}${m[2]}${m[3]}${m[4] == null ? '' : '?$_hidden'}',
      )
      .replaceAllMapped(_header, (m) => '${m[1]}$_hidden')
      .replaceAllMapped(_scheme, (m) => '${m[1]}$_hidden')
      .replaceAllMapped(_param, (m) => '${m[1]}$_hidden')
      .replaceAll(_opaque, _hidden);
}

const _hidden = '[redacted]';

final _url = RegExp(
  r'\b([a-z][a-z0-9+.-]*://)(?:[^\s/?#@]*@)?([^\s/?#]*)([^\s?#]*)([?#]\S*)?',
  caseSensitive: false,
);

final _header = RegExp(
  r'\b((?:proxy-)?(?:authorization|cookie|set-cookie)\s*:\s*)[^\r\n]+',
  caseSensitive: false,
);

final _scheme = RegExp(
  r'\b((?:bearer|basic)\s+)(?!\[redacted\])[^\s,;"]+',
  caseSensitive: false,
);

final _param = RegExp(
  r'\b((?:access_token|api_?key|token|password|passwd|secret|session|'
  r'tix_session)\s*[=:]\s*)(?!\[redacted\])[^\s,;&"]+',
  caseSensitive: false,
);

final _opaque = RegExp('(?<![A-Za-z0-9_-])[A-Za-z0-9_-]{32,}(?![A-Za-z0-9_-])');

String _stamp(DateTime t) => t.toUtc().toIso8601String();

String _stampOr(DateTime? t) => t == null ? 'never' : _stamp(t);
