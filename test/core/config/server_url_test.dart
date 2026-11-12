// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';

void main() {
  test('normalizeServerUrl', () {
    const cases = {
      'tix.example': 'https://tix.example',
      '  https://tix.example/  ': 'https://tix.example',
      'http://127.0.0.1:8080': 'http://127.0.0.1:8080',
      'https://tix.example/api/v1': 'https://tix.example',
      'https://tix.example/api/v1/': 'https://tix.example',
      'https://host/tix//': 'https://host/tix',
      'https://tix.example/?q=1#top': 'https://tix.example',
      'https://tix.example.com/': 'https://tix.example.com',
      'https://tix.example.com///': 'https://tix.example.com',
      ' tix.example.com/ ': 'https://tix.example.com',
      'tix.example.com:8443//': 'https://tix.example.com:8443',
      'http://tix.example.com/': 'http://tix.example.com',
      '\thttps://tix.example.com/tix/\n': 'https://tix.example.com/tix',
    };
    for (final MapEntry(key: input, value: want) in cases.entries) {
      expect(normalizeServerUrl(input), want, reason: input);
    }
  });

  test('normalizeServerUrl refuses what is not a web address', () {
    for (final input in [
      '',
      '   ',
      '///',
      'ftp://tix.example',
      'https://',
      '::',
    ]) {
      expect(normalizeServerUrl(input), isNull, reason: input);
    }
  });

  test('withoutTrailingSlash leaves room for one slash before a path', () {
    const cases = {
      'https://tix.example': 'https://tix.example',
      'https://tix.example/': 'https://tix.example',
      'https://tix.example///': 'https://tix.example',
      '/tix/': '/tix',
      '': '',
    };
    for (final MapEntry(key: input, value: want) in cases.entries) {
      expect(withoutTrailingSlash(input), want, reason: input);
    }
  });

  test('noRetry never retries', () {
    expect(noRetry(0, Exception()), isNull);
  });
}
