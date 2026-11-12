// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        APIToken,
        AccountLogEntry,
        CalendarFeed,
        FieldDef,
        Invite,
        IssuedCalendarFeed,
        IssuedInvite,
        IssuedToken,
        Role,
        TaskExportInput,
        TaskImportError,
        TaskImportResult,
        TaskImportRow,
        TenantMembership,
        UpdateUserInput,
        User;

/// A user of the tenant with the role its membership grants, null when it
/// has no membership here.
@immutable
class Person {
  /// [user] holding [role].
  const Person(this.user, this.role);

  /// The account.
  final User user;

  /// Its role in this tenant.
  final Role? role;

  /// The name to show: display name, else email.
  String get label =>
      user.displayName.isNotEmpty ? user.displayName : user.email;

  /// Whether the account may not sign in.
  bool get disabled => user.disabledAt != null;

  @override
  bool operator ==(Object other) =>
      other is Person && other.user == user && other.role == role;

  @override
  int get hashCode => Object.hash(user, role);
}

/// What a token's row says about it.
enum TokenState {
  /// It authenticates.
  active,

  /// Its expiry has passed.
  expired,

  /// It was revoked.
  revoked,

  /// It was rotated and still works until its `revoked_at`.
  retiring,
}

/// The state of a token at [now], as tix's `tokenState` names it.
TokenState tokenState(APIToken token, DateTime now) {
  final revoked = token.revokedAt;
  if (revoked != null && !revoked.isAfter(now)) return TokenState.revoked;
  final expires = token.expiresAt;
  if (expires != null && !expires.isAfter(now)) return TokenState.expired;
  if (revoked != null) return TokenState.retiring;
  return TokenState.active;
}
