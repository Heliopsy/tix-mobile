// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/events/live_events.dart';

final _at = DateTime.utc(2026, 11, 9, 10);

LiveError _describe(Object? error, {List<String> secrets = const []}) =>
    LiveError.from(
      error,
      at: _at,
      source: LiveErrorSource.websocket,
      secrets: secrets,
    );

void main() {
  group('classifies', () {
    test('a failed lookup as unreachable, with the OS error', () {
      final e = _describe(
        const SocketException(
          'Failed host lookup',
          osError: OSError('No address associated with hostname', 7),
        ),
      );
      expect(e.kind, LiveErrorKind.unreachable);
      expect(e.type, 'SocketException');
      expect(e.message, 'Failed host lookup');
      expect(e.osErrorCode, 7);
      expect(e.osErrorMessage, 'No address associated with hostname');
    });

    test('a TLS handshake failure as a certificate problem', () {
      final e = _describe(
        const HandshakeException(
          'Handshake error in client',
          OSError('CERTIFICATE_VERIFY_FAILED', 1),
        ),
      );
      expect(e.kind, LiveErrorKind.tls);
      expect(e.type, 'HandshakeException');
      expect(e.osErrorMessage, 'CERTIFICATE_VERIFY_FAILED');
    });

    test('a refused upgrade with its status', () {
      final e = _describe(const WebSocketException('not upgraded', 502));
      expect(e.kind, LiveErrorKind.upgradeRefused);
      expect(e.httpStatus, 502);
    });

    test('a 401 or 403 upgrade as refused', () {
      expect(
        _describe(const WebSocketException('no', 401)).kind,
        LiveErrorKind.refused,
      );
      expect(
        _describe(const WebSocketException('no', 403)).kind,
        LiveErrorKind.refused,
      );
    });

    test('a close with its code and reason', () {
      final e = _describe(const EventSocketClosed(1006, 'abnormal'));
      expect(e.kind, LiveErrorKind.closed);
      expect(e.closeCode, 1006);
      expect(e.closeReason, 'abnormal');
      expect(_describe(null).kind, LiveErrorKind.closed);
    });

    test('a timeout, raw or through the API client', () {
      expect(_describe(TimeoutException('slow')).kind, LiveErrorKind.timeout);
      final e = _describe(
        const TixException(
          TixErrorKind.timeout,
          cause: DioExceptionType.receiveTimeout,
        ),
      );
      expect(e.kind, LiveErrorKind.timeout);
      expect(e.type, 'TixException (receiveTimeout)');
      expect(e.tixKind, TixErrorKind.timeout);
    });

    test('a network failure through the API client by its cause', () {
      final e = _describe(
        const TixException(
          TixErrorKind.network,
          cause: SocketException(
            'Connection refused',
            osError: OSError('Connection refused', 111),
          ),
        ),
      );
      expect(e.kind, LiveErrorKind.unreachable);
      expect(e.type, 'SocketException');
      expect(e.osErrorCode, 111);
    });

    test('an HTTP error on the poll', () {
      final e = _describe(
        const TixException(
          TixErrorKind.upstream,
          status: 504,
          message: 'gateway timeout',
        ),
      );
      expect(e.kind, LiveErrorKind.http);
      expect(e.httpStatus, 504);
      expect(e.message, 'gateway timeout');
    });

    test('a refused credential', () {
      expect(
        _describe(const TixException(TixErrorKind.forbidden, status: 403)).kind,
        LiveErrorKind.refused,
      );
      final frame = _describe({'code': 'forbidden', 'message': 'scope'});
      expect(frame.kind, LiveErrorKind.refused);
      expect(frame.message, 'forbidden: scope');
    });
  });

  group('redacts', () {
    test('the credential itself and its parts', () {
      final e = _describe(
        const WebSocketException('refused Bearer tok-do-not-leak-7f3a'),
        secrets: ['Bearer tok-do-not-leak-7f3a', 'tok-do-not-leak-7f3a'],
      );
      expect(e.message, isNot(contains('tok-do-not-leak')));
    });

    test('credential headers, parameters and query strings', () {
      final out = redactSecrets(
        'GET https://ana:pw@tix.example/api/v1/events?since=3&token=abc '
        'failed. Authorization: Bearer xyz123\n'
        'Cookie: tix_session=s3cr3t\n'
        'password=hunter22 sent with basic dXNlcjpwYXNz',
      );
      for (final leak in [
        'ana:pw',
        'token=abc',
        'since=3',
        'xyz123',
        's3cr3t',
        'hunter22',
        'dXNlcjpwYXNz',
      ]) {
        expect(out, isNot(contains(leak)), reason: leak);
      }
      expect(out, contains('https://tix.example/api/v1/events?[redacted]'));
    });

    test('long opaque strings', () {
      final token = 'a' * 40;
      expect(redactSecrets('got $token back'), 'got [redacted] back');
    });

    test('nothing else', () {
      const plain = 'Connection refused (OS error 111) by tix.example:443';
      expect(redactSecrets(plain), plain);
    });
  });

  test('the host keeps the scheme and port only', () {
    expect(
      hostOf('https://ana:pw@tix.example:8443/sub?x=1'),
      'https://tix.example:8443',
    );
    expect(hostOf('https://tix.example'), 'https://tix.example');
    expect(hostOf(''), '');
  });

  test('a report has no secrets and says what is known', () {
    final d = LiveDiagnostics(
      mode: LiveMode.offline,
      transport: LiveTransport.poll,
      host: 'https://tix.example',
      modeSince: _at,
      failuresBeforeFallback: 3,
      failureWindow: const Duration(minutes: 2),
      consecutiveFailures: 2,
      lastError: _describe(
        const SocketException('Authorization: Bearer leaked-value-123'),
      ),
    );
    final report = d.toReport(app: '0.8.0 (9)', platform: 'Android 15');
    expect(report, contains('App: 0.8.0 (9)'));
    expect(report, contains('Platform: Android 15'));
    expect(report, contains('Server: https://tix.example'));
    expect(report, contains('Mode: offline over poll'));
    expect(report, contains('Failures in a row: 2'));
    expect(report, contains('unreachable on websocket'));
    expect(report, isNot(contains('leaked-value-123')));
  });
}
