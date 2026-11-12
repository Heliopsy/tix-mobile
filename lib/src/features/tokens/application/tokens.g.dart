// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'tokens.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tokens of [actorId], or the whole tenant's when null, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// token's value goes straight back to the sheet that shows it.

@ProviderFor(Tokens)
final tokensProvider = TokensFamily._();

/// The tokens of [actorId], or the whole tenant's when null, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// token's value goes straight back to the sheet that shows it.
final class TokensProvider
    extends $AsyncNotifierProvider<Tokens, List<APIToken>> {
  /// The tokens of [actorId], or the whole tenant's when null, newest first.
  ///
  /// Values never pass through here: a listing carries none, and an issued
  /// token's value goes straight back to the sheet that shows it.
  TokensProvider._({
    required TokensFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tokensProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tokensHash();

  @override
  String toString() {
    return r'tokensProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Tokens create() => Tokens();

  @override
  bool operator ==(Object other) {
    return other is TokensProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tokensHash() => r'b455fb8b057fd21cf3eb4a5395c0037e9b949a6f';

/// The tokens of [actorId], or the whole tenant's when null, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// token's value goes straight back to the sheet that shows it.

final class TokensFamily extends $Family
    with
        $ClassFamilyOverride<
          Tokens,
          AsyncValue<List<APIToken>>,
          List<APIToken>,
          FutureOr<List<APIToken>>,
          String?
        > {
  TokensFamily._()
    : super(
        retry: null,
        name: r'tokensProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tokens of [actorId], or the whole tenant's when null, newest first.
  ///
  /// Values never pass through here: a listing carries none, and an issued
  /// token's value goes straight back to the sheet that shows it.

  TokensProvider call(String? actorId) =>
      TokensProvider._(argument: actorId, from: this);

  @override
  String toString() => r'tokensProvider';
}

/// The tokens of [actorId], or the whole tenant's when null, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// token's value goes straight back to the sheet that shows it.

abstract class _$Tokens extends $AsyncNotifier<List<APIToken>> {
  late final _$args = ref.$arg as String?;
  String? get actorId => _$args;

  FutureOr<List<APIToken>> build(String? actorId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<APIToken>>, List<APIToken>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<APIToken>>, List<APIToken>>,
              AsyncValue<List<APIToken>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Actors by id, to name a token's owner.

@ProviderFor(tokenOwners)
final tokenOwnersProvider = TokenOwnersProvider._();

/// Actors by id, to name a token's owner.

final class TokenOwnersProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Actor>>,
          Map<String, Actor>,
          FutureOr<Map<String, Actor>>
        >
    with
        $FutureModifier<Map<String, Actor>>,
        $FutureProvider<Map<String, Actor>> {
  /// Actors by id, to name a token's owner.
  TokenOwnersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenOwnersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenOwnersHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, Actor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, Actor>> create(Ref ref) {
    return tokenOwners(ref);
  }
}

String _$tokenOwnersHash() => r'1f0bfabb0c1bce4eb76340c7663003e301a1c233';
