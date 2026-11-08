// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';

/// What a request presents to prove who it is.
@immutable
sealed class Credential {
  const Credential(this.secret);

  /// The token itself. Never log it.
  final String secret;

  /// The headers that present this credential.
  Map<String, String> get headers;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is Credential &&
      other.secret == secret;

  @override
  int get hashCode => Object.hash(runtimeType, secret);

  @override
  String toString() => 'Credential(…)';
}

/// An API token, sent as `Authorization: Bearer`.
final class BearerCredential extends Credential {
  /// Presents the API token [secret].
  const BearerCredential(super.secret);

  @override
  Map<String, String> get headers => {'Authorization': 'Bearer $secret'};
}

/// A sign-in session. tix accepts it only as the `tix_session` cookie: its
/// bearer authenticator checks API tokens alone, and refuses the request when
/// a session token arrives there, even beside a good cookie.
final class SessionCredential extends Credential {
  /// Presents the session token [secret].
  const SessionCredential(super.secret);

  /// The cookie tix reads a session from.
  static const cookieName = 'tix_session';

  @override
  Map<String, String> get headers => {'Cookie': '$cookieName=$secret'};
}
