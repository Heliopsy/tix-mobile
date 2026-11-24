// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/repositories/dav_repository.dart';

export 'package:tix_mobile/src/data/repositories/dav_repository.dart';

part 'dav.g.dart';

/// What the Tasks in other apps screen can offer for the active context.
sealed class DavStatus {
  const DavStatus();
}

/// A local instance: no other app could reach its engine.
class DavLocal extends DavStatus {
  /// Creates the state.
  const DavLocal();
}

/// A server without CalDAV: a tix before 0.69.0.
class DavNotOffered extends DavStatus {
  /// Creates the state.
  const DavNotOffered();
}

/// CalDAV is turned off on the server; passwords made before can still be
/// listed and revoked.
class DavOff extends DavStatus {
  /// Off, for tix's [reason] (empty when it gave none).
  const DavOff(this.reason);

  /// Why, in tix's words.
  final String reason;
}

/// This credential may not set CalDAV up, such as an agent's token.
class DavNotAllowed extends DavStatus {
  /// Refused with tix's [message]; [token] says the connection is a token,
  /// so signing in as the person may work instead.
  const DavNotAllowed(this.message, {required this.token});

  /// tix's message.
  final String message;

  /// Whether the active connection is an API token.
  final bool token;
}

/// CalDAV is served: what other apps are set up with.
class DavReady extends DavStatus {
  /// Ready with [info], reached at [address].
  const DavReady(this.info, this.address);

  /// tix's answer.
  final DavInfo info;

  /// The absolute address other apps use.
  final String address;

  /// Whether the caller's CalDAV requests may change tasks (phase 2).
  bool get write => info.write;
}

/// The state of CalDAV for the active context, asked once per visit. A
/// local instance sends nothing.
@riverpod
Future<DavStatus> davStatus(Ref ref) async {
  final session = ref.watch(sessionControllerProvider).value;
  if (session == null || session.instance.kind == InstanceKind.local) {
    return const DavLocal();
  }
  try {
    final info = await ref.watch(davRepositoryProvider).info();
    if (info == null) return const DavNotOffered();
    if (!info.enabled) return DavOff(info.reason);
    return DavReady(info, info.addressOn(session.baseUrl));
  } on TixException catch (e) {
    if (e.kind != TixErrorKind.forbidden) rethrow;
    return DavNotAllowed(
      e.message,
      token: session.connection.kind == ConnectionKind.token,
    );
  }
}

/// The caller's app passwords, live ones first, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// password goes straight back to the sheet that hands it off.
@riverpod
class AppPasswords extends _$AppPasswords {
  @override
  Future<List<DavPassword>> build() async {
    final repo = ref.watch(davRepositoryProvider);
    final now = ref.watch(clockProvider)();
    refreshOn(ref, EventTopics.tokens);
    final list = await repo.passwords();
    int live(DavPassword p) =>
        davPasswordState(p, now) == DavPasswordState.live ? 0 : 1;
    return [...list]..sort((a, b) {
      final byState = live(a).compareTo(live(b));
      if (byState != 0) return byState;
      return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    });
  }

  /// Issues an app password and returns it with its value, which the caller
  /// hands off and drops.
  Future<IssuedDavPassword> create({
    required String name,
    String? collections,
    bool? readOnly,
    DateTime? expiresAt,
  }) async {
    final issued = await ref
        .read(davRepositoryProvider)
        .create(
          name: name,
          collections: collections,
          readOnly: readOnly,
          expiresAt: expiresAt,
        );
    if (ref.mounted) ref.invalidateSelf();
    return issued;
  }

  /// Revokes [password]; the other app is refused from its next request.
  Future<void> revoke(DavPassword password) async {
    await ref.read(davRepositoryProvider).revoke(password.id);
    if (ref.mounted) ref.invalidateSelf();
  }
}

/// Where an app password stands.
enum DavPasswordState {
  /// It signs the other app in.
  live,

  /// Its expiry passed.
  expired,

  /// It was revoked.
  revoked,
}

/// The state of [p] at [now].
DavPasswordState davPasswordState(DavPassword p, DateTime now) {
  final revoked = p.revokedAt;
  if (revoked != null && !revoked.isAfter(now)) return DavPasswordState.revoked;
  final expires = p.expiresAt;
  if (expires != null && !expires.isAfter(now)) return DavPasswordState.expired;
  return DavPasswordState.live;
}
