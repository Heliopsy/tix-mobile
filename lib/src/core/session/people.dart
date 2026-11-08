// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/repositories/account_repository.dart';
import 'package:tix_mobile/src/data/repositories/people_repository.dart';
import 'package:tix_mobile/src/data/repositories/token_repository.dart';
import 'package:tix_mobile/src/data/repositories/transfer_repository.dart';

export 'package:tix_mobile/src/core/session/access.dart';
export 'package:tix_mobile/src/data/models/scopes.dart';

part 'people.g.dart';

/// Users, memberships and invites for the active session.
@riverpod
PeopleRepository peopleRepository(Ref ref) => PeopleRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// API tokens for the active session. It has no cache, by design.
@riverpod
TokenRepository tokenRepository(Ref ref) =>
    TokenRepository(ref.watch(sessionApiProvider));

/// The caller's account history and calendar feed.
@riverpod
AccountRepository accountRepository(Ref ref) => AccountRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// Exports and imports for the active session.
@riverpod
TransferRepository transferRepository(Ref ref) =>
    TransferRepository(ref.watch(sessionApiProvider));
