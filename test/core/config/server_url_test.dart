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
    };
    for (final MapEntry(key: input, value: want) in cases.entries) {
      expect(normalizeServerUrl(input), want, reason: input);
    }
  });

  test('normalizeServerUrl refuses what is not a web address', () {
    for (final input in ['', '   ', 'ftp://tix.example', 'https://', '::']) {
      expect(normalizeServerUrl(input), isNull, reason: input);
    }
  });

  test('noRetry never retries', () {
    expect(noRetry(0, Exception()), isNull);
  });
}
