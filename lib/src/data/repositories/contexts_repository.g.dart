// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'contexts_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The saved servers.

@ProviderFor(contextsRepository)
final contextsRepositoryProvider = ContextsRepositoryProvider._();

/// The saved servers.

final class ContextsRepositoryProvider
    extends
        $FunctionalProvider<
          ContextsRepository,
          ContextsRepository,
          ContextsRepository
        >
    with $Provider<ContextsRepository> {
  /// The saved servers.
  ContextsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContextsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContextsRepository create(Ref ref) {
    return contextsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContextsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContextsRepository>(value),
    );
  }
}

String _$contextsRepositoryHash() =>
    r'ece57fc908f764e77ae81bf80ee4361cddbdca1a';
