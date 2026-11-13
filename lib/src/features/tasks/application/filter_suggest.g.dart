// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'filter_suggest.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the filter field over [scope] suggests from: the projects, tags,
/// people and workflow states loaded so far. A list still loading or failed
/// is left out rather than holding the others back.

@ProviderFor(filterSuggestData)
final filterSuggestDataProvider = FilterSuggestDataFamily._();

/// What the filter field over [scope] suggests from: the projects, tags,
/// people and workflow states loaded so far. A list still loading or failed
/// is left out rather than holding the others back.

final class FilterSuggestDataProvider
    extends
        $FunctionalProvider<
          FilterSuggestData,
          FilterSuggestData,
          FilterSuggestData
        >
    with $Provider<FilterSuggestData> {
  /// What the filter field over [scope] suggests from: the projects, tags,
  /// people and workflow states loaded so far. A list still loading or failed
  /// is left out rather than holding the others back.
  FilterSuggestDataProvider._({
    required FilterSuggestDataFamily super.from,
    required TaskScope super.argument,
  }) : super(
         retry: null,
         name: r'filterSuggestDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filterSuggestDataHash();

  @override
  String toString() {
    return r'filterSuggestDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<FilterSuggestData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FilterSuggestData create(Ref ref) {
    final argument = this.argument as TaskScope;
    return filterSuggestData(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilterSuggestData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilterSuggestData>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilterSuggestDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filterSuggestDataHash() => r'bb89a23ca122a18733dbfb52fb5024a1602d8232';

/// What the filter field over [scope] suggests from: the projects, tags,
/// people and workflow states loaded so far. A list still loading or failed
/// is left out rather than holding the others back.

final class FilterSuggestDataFamily extends $Family
    with $FunctionalFamilyOverride<FilterSuggestData, TaskScope> {
  FilterSuggestDataFamily._()
    : super(
        retry: null,
        name: r'filterSuggestDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the filter field over [scope] suggests from: the projects, tags,
  /// people and workflow states loaded so far. A list still loading or failed
  /// is left out rather than holding the others back.

  FilterSuggestDataProvider call(TaskScope scope) =>
      FilterSuggestDataProvider._(argument: scope, from: this);

  @override
  String toString() => r'filterSuggestDataProvider';
}
