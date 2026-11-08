// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'inbox.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The inbox screen's filter.

@ProviderFor(InboxFilterState)
final inboxFilterStateProvider = InboxFilterStateProvider._();

/// The inbox screen's filter.
final class InboxFilterStateProvider
    extends $NotifierProvider<InboxFilterState, InboxFilter> {
  /// The inbox screen's filter.
  InboxFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxFilterStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxFilterStateHash();

  @$internal
  @override
  InboxFilterState create() => InboxFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxFilter>(value),
    );
  }
}

String _$inboxFilterStateHash() => r'd7fbccc6eb248cc5690e5221b5c3e17178fe0821';

/// The inbox screen's filter.

abstract class _$InboxFilterState extends $Notifier<InboxFilter> {
  InboxFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InboxFilter, InboxFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InboxFilter, InboxFilter>,
              InboxFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Rows that arrived with the last live refresh, for a moment's highlight.

@ProviderFor(FreshInboxIds)
final freshInboxIdsProvider = FreshInboxIdsProvider._();

/// Rows that arrived with the last live refresh, for a moment's highlight.
final class FreshInboxIdsProvider
    extends $NotifierProvider<FreshInboxIds, Set<String>> {
  /// Rows that arrived with the last live refresh, for a moment's highlight.
  FreshInboxIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'freshInboxIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$freshInboxIdsHash();

  @$internal
  @override
  FreshInboxIds create() => FreshInboxIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$freshInboxIdsHash() => r'd2ef120946f999fa710fe3b315adcbf0700ec34f';

/// Rows that arrived with the last live refresh, for a moment's highlight.

abstract class _$FreshInboxIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The caller's inbox, newest first, a page at a time; [unread] asks the
/// server for unread items only. Follows live events.

@ProviderFor(InboxList)
final inboxListProvider = InboxListFamily._();

/// The caller's inbox, newest first, a page at a time; [unread] asks the
/// server for unread items only. Follows live events.
final class InboxListProvider
    extends $AsyncNotifierProvider<InboxList, Paged<InboxItem>> {
  /// The caller's inbox, newest first, a page at a time; [unread] asks the
  /// server for unread items only. Follows live events.
  InboxListProvider._({
    required InboxListFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'inboxListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxListHash();

  @override
  String toString() {
    return r'inboxListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InboxList create() => InboxList();

  @override
  bool operator ==(Object other) {
    return other is InboxListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxListHash() => r'008ef113ad0e98bbeeae6e55dde1fbbba0b936a2';

/// The caller's inbox, newest first, a page at a time; [unread] asks the
/// server for unread items only. Follows live events.

final class InboxListFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxList,
          AsyncValue<Paged<InboxItem>>,
          Paged<InboxItem>,
          FutureOr<Paged<InboxItem>>,
          bool
        > {
  InboxListFamily._()
    : super(
        retry: null,
        name: r'inboxListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The caller's inbox, newest first, a page at a time; [unread] asks the
  /// server for unread items only. Follows live events.

  InboxListProvider call(bool unread) =>
      InboxListProvider._(argument: unread, from: this);

  @override
  String toString() => r'inboxListProvider';
}

/// The caller's inbox, newest first, a page at a time; [unread] asks the
/// server for unread items only. Follows live events.

abstract class _$InboxList extends $AsyncNotifier<Paged<InboxItem>> {
  late final _$args = ref.$arg as bool;
  bool get unread => _$args;

  FutureOr<Paged<InboxItem>> build(bool unread);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Paged<InboxItem>>, Paged<InboxItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<InboxItem>>, Paged<InboxItem>>,
              AsyncValue<Paged<InboxItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// How many of the caller's items are unread. Follows live events.

@ProviderFor(InboxUnread)
final inboxUnreadProvider = InboxUnreadProvider._();

/// How many of the caller's items are unread. Follows live events.
final class InboxUnreadProvider
    extends $AsyncNotifierProvider<InboxUnread, int> {
  /// How many of the caller's items are unread. Follows live events.
  InboxUnreadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxUnreadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxUnreadHash();

  @$internal
  @override
  InboxUnread create() => InboxUnread();
}

String _$inboxUnreadHash() => r'2c6375c75a55403d871971561aaa726065b66a21';

/// How many of the caller's items are unread. Follows live events.

abstract class _$InboxUnread extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Marking items, for every list and the badge at once. The inbox screen
/// watches it, which keeps it alive while marks are in flight.

@ProviderFor(InboxMarks)
final inboxMarksProvider = InboxMarksProvider._();

/// Marking items, for every list and the badge at once. The inbox screen
/// watches it, which keeps it alive while marks are in flight.
final class InboxMarksProvider extends $NotifierProvider<InboxMarks, void> {
  /// Marking items, for every list and the badge at once. The inbox screen
  /// watches it, which keeps it alive while marks are in flight.
  InboxMarksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxMarksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxMarksHash();

  @$internal
  @override
  InboxMarks create() => InboxMarks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$inboxMarksHash() => r'be4e113fb754b48292fdc4d35a5a3734b75e6d68';

/// Marking items, for every list and the badge at once. The inbox screen
/// watches it, which keeps it alive while marks are in flight.

abstract class _$InboxMarks extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The kinds muted on the server: they create no item at all.

@ProviderFor(InboxMuted)
final inboxMutedProvider = InboxMutedProvider._();

/// The kinds muted on the server: they create no item at all.
final class InboxMutedProvider
    extends $AsyncNotifierProvider<InboxMuted, Set<InboxKind>> {
  /// The kinds muted on the server: they create no item at all.
  InboxMutedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxMutedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxMutedHash();

  @$internal
  @override
  InboxMuted create() => InboxMuted();
}

String _$inboxMutedHash() => r'9c1278a12e7bec0fff67dfae2b2d155d57aaf5c0';

/// The kinds muted on the server: they create no item at all.

abstract class _$InboxMuted extends $AsyncNotifier<Set<InboxKind>> {
  FutureOr<Set<InboxKind>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<InboxKind>>, Set<InboxKind>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<InboxKind>>, Set<InboxKind>>,
              AsyncValue<Set<InboxKind>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The tenant's numbers and the caller's deadlines.

@ProviderFor(inboxSummary)
final inboxSummaryProvider = InboxSummaryProvider._();

/// The tenant's numbers and the caller's deadlines.

final class InboxSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<InboxSummary>,
          InboxSummary,
          FutureOr<InboxSummary>
        >
    with $FutureModifier<InboxSummary>, $FutureProvider<InboxSummary> {
  /// The tenant's numbers and the caller's deadlines.
  InboxSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxSummaryHash();

  @$internal
  @override
  $FutureProviderElement<InboxSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InboxSummary> create(Ref ref) {
    return inboxSummary(ref);
  }
}

String _$inboxSummaryHash() => r'ea2301f5375c710408cd162f2640847e7675cb37';
