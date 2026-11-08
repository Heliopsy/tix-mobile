// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/invite_link.dart';

void main() {
  test('reads the server and the token from a link', () {
    expect(
      InviteLink.parse('https://tix.example.com/invite/tix_inv_a-b'),
      const InviteLink(
        baseUrl: 'https://tix.example.com',
        token: 'tix_inv_a-b',
      ),
    );
  });

  test('keeps a port and a path prefix, and finds the link in a sentence', () {
    final link = InviteLink.parse(
      'Join us: http://10.0.0.5:8080/tix/invite/tix_inv_Zz9 (expires Friday)',
    );
    expect(link?.baseUrl, 'http://10.0.0.5:8080/tix');
    expect(link?.token, 'tix_inv_Zz9');
  });

  test('refuses what is not an invite link', () {
    for (final bad in [
      '',
      'tix_inv_abc',
      'https://tix.example.com/invite/',
      'https://tix.example.com/invite/abc',
      'https://tix.example.com/tasks/infra-1',
      'ftp://tix.example.com/invite/tix_inv_abc',
    ]) {
      expect(InviteLink.parse(bad), isNull, reason: bad);
    }
  });
}
