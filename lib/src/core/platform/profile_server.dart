// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Serves one configuration profile on `127.0.0.1`, at a random path, to
/// one request, for at most two minutes. iOS installs a profile Safari
/// downloads; serving it here keeps the password on the device instead of
/// asking tix to hold it until Safari comes. It never logs.
class ProfileServer {
  ProfileServer._(this._server, this._path, Duration lifetime)
    : _port = _server.port {
    _timer = Timer(lifetime, () => unawaited(close()));
    _server.listen(_answer, onDone: _finish);
  }

  /// Starts serving [profile], on a port the OS chooses.
  static Future<ProfileServer> start(
    String profile, {
    Duration lifetime = const Duration(minutes: 2),
    Random? random,
  }) async {
    final r = random ?? Random.secure();
    final token = base64Url
        .encode([for (var i = 0; i < 32; i++) r.nextInt(256)])
        .replaceAll('=', '');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return ProfileServer._(server, '/$token.mobileconfig', lifetime)
      .._body = utf8.encode(profile);
  }

  final HttpServer _server;
  final String _path;
  final int _port;
  late final Timer _timer;
  List<int>? _body;
  final _served = Completer<bool>();

  /// The address to open in Safari.
  Uri get url => Uri.parse('http://127.0.0.1:$_port$_path');

  /// True once the profile was served, false when the server closed first.
  Future<bool> get served => _served.future;

  Future<void> _answer(HttpRequest request) async {
    final body = _body;
    final response = request.response;
    if (body == null || request.method != 'GET' || request.uri.path != _path) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    _body = null;
    response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType('application', 'x-apple-aspen-config')
      ..headers.set('Cache-Control', 'no-store')
      ..add(body);
    await response.close();
    if (!_served.isCompleted) _served.complete(true);
    await close();
  }

  void _finish() {
    if (!_served.isCompleted) _served.complete(false);
  }

  /// Stops serving and forgets the profile.
  Future<void> close() async {
    _timer.cancel();
    _body = null;
    await _server.close(force: true);
    _finish();
  }
}
