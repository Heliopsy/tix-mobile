// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tenant's external sync sources, each with what a run would use and
/// what it lacks. Not cached: sources carry credential hints.

@ProviderFor(SyncSources)
final syncSourcesProvider = SyncSourcesProvider._();

/// The tenant's external sync sources, each with what a run would use and
/// what it lacks. Not cached: sources carry credential hints.
final class SyncSourcesProvider
    extends $AsyncNotifierProvider<SyncSources, List<SyncSource>> {
  /// The tenant's external sync sources, each with what a run would use and
  /// what it lacks. Not cached: sources carry credential hints.
  SyncSourcesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncSourcesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncSourcesHash();

  @$internal
  @override
  SyncSources create() => SyncSources();
}

String _$syncSourcesHash() => r'a97597fdd7961e61005fb48b2315cb6016810b03';

/// The tenant's external sync sources, each with what a run would use and
/// what it lacks. Not cached: sources carry credential hints.

abstract class _$SyncSources extends $AsyncNotifier<List<SyncSource>> {
  FutureOr<List<SyncSource>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SyncSource>>, List<SyncSource>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SyncSource>>, List<SyncSource>>,
              AsyncValue<List<SyncSource>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Finished sync runs, newest first, a page at a time.

@ProviderFor(SyncRuns)
final syncRunsProvider = SyncRunsProvider._();

/// Finished sync runs, newest first, a page at a time.
final class SyncRunsProvider
    extends $AsyncNotifierProvider<SyncRuns, Paged<AuditEntry>> {
  /// Finished sync runs, newest first, a page at a time.
  SyncRunsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRunsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRunsHash();

  @$internal
  @override
  SyncRuns create() => SyncRuns();
}

String _$syncRunsHash() => r'42cc85e332923c9b54a13f1ddcde9d1a73ecee08';

/// Finished sync runs, newest first, a page at a time.

abstract class _$SyncRuns extends $AsyncNotifier<Paged<AuditEntry>> {
  FutureOr<Paged<AuditEntry>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Paged<AuditEntry>>, Paged<AuditEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<AuditEntry>>, Paged<AuditEntry>>,
              AsyncValue<Paged<AuditEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
