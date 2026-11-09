// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/session/session.dart';

part 'security.g.dart';

/// The signed-in person's second factor: whether it is set up, and what
/// their tenant requires.
///
/// The authenticator secret and the recovery codes pass through as return
/// values and are never part of the state, so nothing keeps them once the
/// screen showing them is closed.
@riverpod
class SecondFactor extends _$SecondFactor {
  @override
  Future<TOTPStatus> build() => ref.watch(securityRepositoryProvider).status();

  SecurityRepository get _repo => ref.read(securityRepositoryProvider);

  /// Starts an enrolment and returns the secret for an authenticator.
  Future<TOTPEnrolment> enrol() => _repo.enrol();

  /// Confirms the enrolment with [code] and returns the recovery codes.
  Future<List<String>> confirm(String code) async {
    final codes = await _repo.confirm(code);
    if (ref.mounted) ref.invalidateSelf();
    return codes;
  }

  /// Replaces the recovery codes and returns the new set.
  Future<List<String>> newRecoveryCodes() async {
    final codes = await _repo.newRecoveryCodes();
    if (ref.mounted) ref.invalidateSelf();
    return codes;
  }

  /// Removes the second factor.
  Future<void> remove() async {
    await _repo.removeSecondFactor();
    if (ref.mounted) ref.invalidateSelf();
  }
}

/// The signed-in person's SSH keys, revoked ones included.
@riverpod
class SshKeys extends _$SshKeys {
  @override
  Future<List<SSHKey>> build() =>
      ref.watch(securityRepositoryProvider).sshKeys();

  /// Enrols a public key.
  Future<SSHKey> add(EnrolSSHKeyInput input) async {
    final key = await ref.read(securityRepositoryProvider).addSshKey(input);
    if (ref.mounted) ref.invalidateSelf();
    return key;
  }

  /// Revokes key [id].
  Future<void> revoke(String id) async {
    await ref.read(securityRepositoryProvider).revokeSshKey(id);
    if (ref.mounted) ref.invalidateSelf();
  }
}

/// The signed-in person's own sessions in this tenant, newest first, a page
/// at a time.
@riverpod
class ActiveSessions extends _$ActiveSessions {
  @override
  Future<Paged<SessionInfo>> build() async {
    final page = await ref.watch(securityRepositoryProvider).sessions();
    return Paged(items: page.items, cursor: page.nextCursor);
  }

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(securityRepositoryProvider).sessions(cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (s) => s.id,
  );

  /// Ends [session]. Ending the one this connection presented signs the
  /// connection out, since its credential no longer works.
  Future<void> revoke(SessionInfo session) async {
    final controller = ref.read(sessionControllerProvider.notifier);
    await ref.read(securityRepositoryProvider).revokeSession(session.id);
    if (session.current) {
      await controller.signOut();
      return;
    }
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final s in current.items)
            if (s.id != session.id) s,
        ],
      ),
    );
  }
}
