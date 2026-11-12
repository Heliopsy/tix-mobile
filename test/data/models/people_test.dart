// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/people.dart';

void main() {
  final now = DateTime.utc(2026, 11, 1, 12);
  APIToken token({DateTime? revoked, DateTime? expires}) =>
      APIToken(id: 't', name: 'ci', revokedAt: revoked, expiresAt: expires);

  test('a token reads as tix names it', () {
    expect(tokenState(token(), now), TokenState.active);
    expect(
      tokenState(token(expires: now.add(const Duration(days: 1))), now),
      TokenState.active,
    );
    expect(tokenState(token(expires: now), now), TokenState.expired);
    expect(tokenState(token(revoked: now), now), TokenState.revoked);
    expect(
      tokenState(token(revoked: now.subtract(const Duration(hours: 1))), now),
      TokenState.revoked,
    );
  });

  test('a rotated token inside its grace window is retiring', () {
    final later = now.add(const Duration(hours: 1));
    expect(tokenState(token(revoked: later), now), TokenState.retiring);
    expect(
      tokenState(token(revoked: later, expires: now), now),
      TokenState.expired,
    );
  });
}
