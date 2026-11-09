// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'maintenance.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tenant's retention windows.

@ProviderFor(Retention)
final retentionProvider = RetentionProvider._();

/// The tenant's retention windows.
final class RetentionProvider
    extends $AsyncNotifierProvider<Retention, RetentionPolicy> {
  /// The tenant's retention windows.
  RetentionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'retentionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$retentionHash();

  @$internal
  @override
  Retention create() => Retention();
}

String _$retentionHash() => r'081daaf0afd90d6625120d8c242f33072d6e7a68';

/// The tenant's retention windows.

abstract class _$Retention extends $AsyncNotifier<RetentionPolicy> {
  FutureOr<RetentionPolicy> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RetentionPolicy>, RetentionPolicy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RetentionPolicy>, RetentionPolicy>,
              AsyncValue<RetentionPolicy>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The tenant's housekeeping rules and what they would act on now.

@ProviderFor(Housekeeping)
final housekeepingProvider = HousekeepingProvider._();

/// The tenant's housekeeping rules and what they would act on now.
final class HousekeepingProvider
    extends $AsyncNotifierProvider<Housekeeping, HousekeepingView> {
  /// The tenant's housekeeping rules and what they would act on now.
  HousekeepingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'housekeepingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$housekeepingHash();

  @$internal
  @override
  Housekeeping create() => Housekeeping();
}

String _$housekeepingHash() => r'87afce70cd825729426e7886c7363135ee4292d2';

/// The tenant's housekeeping rules and what they would act on now.

abstract class _$Housekeeping extends $AsyncNotifier<HousekeepingView> {
  FutureOr<HousekeepingView> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<HousekeepingView>, HousekeepingView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HousekeepingView>, HousekeepingView>,
              AsyncValue<HousekeepingView>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The tasks in the trash, a page at a time.

@ProviderFor(Trash)
final trashProvider = TrashProvider._();

/// The tasks in the trash, a page at a time.
final class TrashProvider extends $AsyncNotifierProvider<Trash, Paged<Task>> {
  /// The tasks in the trash, a page at a time.
  TrashProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trashProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trashHash();

  @$internal
  @override
  Trash create() => Trash();
}

String _$trashHash() => r'0f54464ead49cd530caf3ca5b28413d00910e7d5';

/// The tasks in the trash, a page at a time.

abstract class _$Trash extends $AsyncNotifier<Paged<Task>> {
  FutureOr<Paged<Task>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Paged<Task>>, Paged<Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<Task>>, Paged<Task>>,
              AsyncValue<Paged<Task>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
