// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/profile_server.dart';

Future<(int, String, String?)> _get(Uri url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return (response.statusCode, body, response.headers.contentType?.mimeType);
  } finally {
    client.close(force: true);
  }
}

void main() {
  test('serves the profile once, on loopback, at a random path', () async {
    final server = await ProfileServer.start('<plist/>');
    addTearDown(server.close);
    final url = server.url;
    expect(url.host, '127.0.0.1');
    expect(url.path, endsWith('.mobileconfig'));
    expect(url.pathSegments.single.length, greaterThan(40));

    final (status, body, type) = await _get(url);
    expect(status, 200);
    expect(body, '<plist/>');
    expect(type, 'application/x-apple-aspen-config');
    expect(await server.served, isTrue);

    await expectLater(_get(url), throwsA(isA<SocketException>()));
  });

  test('a wrong path is 404 and leaves it serving', () async {
    final server = await ProfileServer.start('<plist/>');
    addTearDown(server.close);
    final wrong = server.url.replace(path: '/guess.mobileconfig');
    expect((await _get(wrong)).$1, 404);
    expect((await _get(server.url)).$1, 200);
    expect(await server.served, isTrue);
  });

  test('two starts have different paths', () async {
    final a = await ProfileServer.start('a');
    final b = await ProfileServer.start('b');
    addTearDown(a.close);
    addTearDown(b.close);
    expect(a.url.path, isNot(b.url.path));
  });

  test('closing before a request reports it unserved', () async {
    final server = await ProfileServer.start('<plist/>');
    await server.close();
    expect(await server.served, isFalse);
  });

  test('closes unserved after its lifetime', () async {
    final server = await ProfileServer.start(
      '<plist/>',
      lifetime: const Duration(milliseconds: 50),
    );
    expect(await server.served, isFalse);
    await expectLater(_get(server.url), throwsA(isA<SocketException>()));
  });
}
