// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'people.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Users, memberships and invites for the active session.

@ProviderFor(peopleRepository)
final peopleRepositoryProvider = PeopleRepositoryProvider._();

/// Users, memberships and invites for the active session.

final class PeopleRepositoryProvider
    extends
        $FunctionalProvider<
          PeopleRepository,
          PeopleRepository,
          PeopleRepository
        >
    with $Provider<PeopleRepository> {
  /// Users, memberships and invites for the active session.
  PeopleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'peopleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$peopleRepositoryHash();

  @$internal
  @override
  $ProviderElement<PeopleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PeopleRepository create(Ref ref) {
    return peopleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeopleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeopleRepository>(value),
    );
  }
}

String _$peopleRepositoryHash() => r'de401c867c57d3ad6eea9d5161f7878e65639a1d';

/// API tokens for the active session. It has no cache, by design.

@ProviderFor(tokenRepository)
final tokenRepositoryProvider = TokenRepositoryProvider._();

/// API tokens for the active session. It has no cache, by design.

final class TokenRepositoryProvider
    extends
        $FunctionalProvider<TokenRepository, TokenRepository, TokenRepository>
    with $Provider<TokenRepository> {
  /// API tokens for the active session. It has no cache, by design.
  TokenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenRepositoryHash();

  @$internal
  @override
  $ProviderElement<TokenRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenRepository create(Ref ref) {
    return tokenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenRepository>(value),
    );
  }
}

String _$tokenRepositoryHash() => r'a976dcd5313db6ad8f6d199bbfe55f949c2bbb64';

/// The caller's account history and calendar feed.

@ProviderFor(accountRepository)
final accountRepositoryProvider = AccountRepositoryProvider._();

/// The caller's account history and calendar feed.

final class AccountRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRepository,
          AccountRepository,
          AccountRepository
        >
    with $Provider<AccountRepository> {
  /// The caller's account history and calendar feed.
  AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRepository>(value),
    );
  }
}

String _$accountRepositoryHash() => r'bc83c8ec8b3fa5700fdfd42cb26e2bf569d33f61';

/// Exports and imports for the active session.

@ProviderFor(transferRepository)
final transferRepositoryProvider = TransferRepositoryProvider._();

/// Exports and imports for the active session.

final class TransferRepositoryProvider
    extends
        $FunctionalProvider<
          TransferRepository,
          TransferRepository,
          TransferRepository
        >
    with $Provider<TransferRepository> {
  /// Exports and imports for the active session.
  TransferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransferRepository create(Ref ref) {
    return transferRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransferRepository>(value),
    );
  }
}

String _$transferRepositoryHash() =>
    r'e0aec64bc833359f8827781675597b1ef095887b';
