// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/page.dart';

export 'package:tix_mobile/src/data/models/security.dart';

/// The signed-in person's own second factor, SSH keys and sessions.
///
/// Nothing here is cached: an enrolment carries the authenticator secret
/// and a confirmation the recovery codes, both shown once.
class SecurityRepository {
  /// Talks to [_api].
  SecurityRepository(this._api);

  final TixApi _api;

  /// The caller's enrolment and what their tenant requires
  /// (`totp.status`).
  Future<TOTPStatus> status() => _api.totp.status();

  /// Starts an enrolment: a new secret for an authenticator
  /// (`totp.enrol`).
  Future<TOTPEnrolment> enrol() => _api.totp.enrol();

  /// Confirms the enrolment with [code] and returns the recovery codes,
  /// once (`totp.confirm`).
  Future<List<String>> confirm(String code) =>
      _api.totp.confirm(TOTPCodeRequest(code: code)).then((r) => r.codes);

  /// Replaces the recovery codes and returns the new set, once
  /// (`totp.codes`).
  Future<List<String>> newRecoveryCodes() =>
      _api.totp.codes().then((r) => r.codes);

  /// Drops the caller's second factor (`totp.remove`).
  Future<void> removeSecondFactor() => _api.totp.remove();

  /// The caller's SSH keys, revoked ones included (`sshkey.list`).
  Future<List<SSHKey>> sshKeys() => _api.sshkey.list().then((p) => p.items);

  /// Enrols a public key for the caller (`sshkey.enrol`).
  Future<SSHKey> addSshKey(EnrolSSHKeyInput input) => _api.sshkey.enrol(input);

  /// Stops the key [id] authenticating (`sshkey.revoke`).
  Future<void> revokeSshKey(String id) => _api.sshkey.revoke(id);

  /// One page of the caller's own sessions in this tenant, newest first
  /// (`session.list`).
  Future<Page<SessionInfo>> sessions({String? cursor}) =>
      _api.session.list(cursor: cursor, limit: pageSize);

  /// Ends the caller's session [id] (`session.revoke`).
  Future<void> revokeSession(String id) => _api.session.revoke(id);
}
