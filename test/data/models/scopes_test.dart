// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/models/scopes.dart';

void main() {
  test("a person's session reads its own account; a token needs the scope", () {
    const session = Access(
      Actor(id: 'p', kind: ActorKind.user, role: Role.viewer),
    );
    expect(session.can(Scopes.accountRead), isTrue);
    expect(session.isToken, isFalse);
    const token = Access(
      Actor(id: 'b', kind: ActorKind.user, tokenId: 't1', scopes: ['*']),
    );
    expect(token.can(Scopes.accountRead), isFalse);
    expect(token.can(Scopes.tokenAdmin), isTrue);
    expect(token.canAll, isTrue);
    const narrow = Access(
      Actor(id: 'b', tokenId: 't2', scopes: ['task:read', 'account:read']),
    );
    expect(narrow.can(Scopes.accountRead), isTrue);
    expect(narrow.can(Scopes.taskWrite), isFalse);
    expect(narrow.canAll, isFalse);
  });

  test('a role grants its scopes', () {
    const member = Access(Actor(id: 'm', role: Role.member));
    expect(member.can(Scopes.export), isTrue);
    expect(member.can(Scopes.userAdmin), isFalse);
    const admin = Access(Actor(id: 'a', role: Role.admin));
    expect(admin.can(Scopes.userAdmin), isTrue);
    expect(admin.canAll, isTrue);
    expect(admin.can(Scopes.globalAdmin), isFalse);
  });

  test('expiries count whole days from now, never is null', () {
    final now = DateTime.utc(2026, 11);
    expect(
      tokenExpiries.firstWhere((e) => e.key == '30d').from(now),
      DateTime.utc(2026, 12),
    );
    expect(tokenExpiries.last.from(now), isNull);
    expect(tokenExpiries.map((e) => e.key), contains(defaultTokenExpiry));
    expect(inviteExpiries.map((e) => e.key), contains(defaultInviteExpiry));
  });

  test('every scope tix lists is in a group', () {
    final grouped = Scopes.groups.values.expand((g) => g).toSet();
    for (final s in Scope.values) {
      if (s == Scope.all) continue;
      expect(grouped, contains(s.value), reason: s.value);
    }
  });
}
