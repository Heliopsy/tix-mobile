// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'stats.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tenant's statistics, for the active session.

@ProviderFor(statsRepository)
final statsRepositoryProvider = StatsRepositoryProvider._();

/// The tenant's statistics, for the active session.

final class StatsRepositoryProvider
    extends
        $FunctionalProvider<StatsRepository, StatsRepository, StatsRepository>
    with $Provider<StatsRepository> {
  /// The tenant's statistics, for the active session.
  StatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsRepositoryHash();

  @$internal
  @override
  $ProviderElement<StatsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsRepository create(Ref ref) {
    return statsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsRepository>(value),
    );
  }
}

String _$statsRepositoryHash() => r'2d59d4176d70515988f6383351a7102c46013fd0';

/// The window and project the Statistics screen shows.

@ProviderFor(StatsFilter)
final statsFilterProvider = StatsFilterProvider._();

/// The window and project the Statistics screen shows.
final class StatsFilterProvider
    extends $NotifierProvider<StatsFilter, StatsQuery> {
  /// The window and project the Statistics screen shows.
  StatsFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsFilterHash();

  @$internal
  @override
  StatsFilter create() => StatsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsQuery>(value),
    );
  }
}

String _$statsFilterHash() => r'2c5706d35acfa7ebbf3a2afa3722c0eef63c58a1';

/// The window and project the Statistics screen shows.

abstract class _$StatsFilter extends $Notifier<StatsQuery> {
  StatsQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StatsQuery, StatsQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StatsQuery, StatsQuery>,
              StatsQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The figures for [query].

@ProviderFor(statsReport)
final statsReportProvider = StatsReportFamily._();

/// The figures for [query].

final class StatsReportProvider
    extends $FunctionalProvider<AsyncValue<Stats>, Stats, FutureOr<Stats>>
    with $FutureModifier<Stats>, $FutureProvider<Stats> {
  /// The figures for [query].
  StatsReportProvider._({
    required StatsReportFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'statsReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statsReportHash();

  @override
  String toString() {
    return r'statsReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Stats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Stats> create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return statsReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StatsReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statsReportHash() => r'65f45d36e6ceb19c237bdf143cbe1ab2e8f18e5f';

/// The figures for [query].

final class StatsReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Stats>, StatsQuery> {
  StatsReportFamily._()
    : super(
        retry: null,
        name: r'statsReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The figures for [query].

  StatsReportProvider call(StatsQuery query) =>
      StatsReportProvider._(argument: query, from: this);

  @override
  String toString() => r'statsReportProvider';
}

/// The tenant's projects for the picker, walked a page at a time up to
/// [statsProjectLimit].

@ProviderFor(statsProjects)
final statsProjectsProvider = StatsProjectsProvider._();

/// The tenant's projects for the picker, walked a page at a time up to
/// [statsProjectLimit].

final class StatsProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<StatsProjects>,
          StatsProjects,
          FutureOr<StatsProjects>
        >
    with $FutureModifier<StatsProjects>, $FutureProvider<StatsProjects> {
  /// The tenant's projects for the picker, walked a page at a time up to
  /// [statsProjectLimit].
  StatsProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsProjectsHash();

  @$internal
  @override
  $FutureProviderElement<StatsProjects> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StatsProjects> create(Ref ref) {
    return statsProjects(ref);
  }
}

String _$statsProjectsHash() => r'c7924e3ecec4a00f97ea5b04c8ea0a77ffeb9247';
