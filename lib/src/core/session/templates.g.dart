// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'templates.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Task templates for the active session.

@ProviderFor(templatesRepository)
final templatesRepositoryProvider = TemplatesRepositoryProvider._();

/// Task templates for the active session.

final class TemplatesRepositoryProvider
    extends
        $FunctionalProvider<
          TemplatesRepository,
          TemplatesRepository,
          TemplatesRepository
        >
    with $Provider<TemplatesRepository> {
  /// Task templates for the active session.
  TemplatesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templatesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templatesRepositoryHash();

  @$internal
  @override
  $ProviderElement<TemplatesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TemplatesRepository create(Ref ref) {
    return templatesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TemplatesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TemplatesRepository>(value),
    );
  }
}

String _$templatesRepositoryHash() =>
    r'a6c4932a2093ec4d9e4dcb88236da60692969720';
