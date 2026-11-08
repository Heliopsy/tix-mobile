// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'audit.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the audit log screen is narrowed to.

@ProviderFor(AuditFilter)
final auditFilterProvider = AuditFilterProvider._();

/// What the audit log screen is narrowed to.
final class AuditFilterProvider
    extends $NotifierProvider<AuditFilter, AuditQuery> {
  /// What the audit log screen is narrowed to.
  AuditFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditFilterHash();

  @$internal
  @override
  AuditFilter create() => AuditFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditQuery>(value),
    );
  }
}

String _$auditFilterHash() => r'94a2c3a6d9c31d2a6895bb28c9dbb3c2d7e1c2b4';

/// What the audit log screen is narrowed to.

abstract class _$AuditFilter extends $Notifier<AuditQuery> {
  AuditQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuditQuery, AuditQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuditQuery, AuditQuery>,
              AuditQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The audit entries matching [query], newest first, a page at a time.

@ProviderFor(AuditLog)
final auditLogProvider = AuditLogFamily._();

/// The audit entries matching [query], newest first, a page at a time.
final class AuditLogProvider
    extends $AsyncNotifierProvider<AuditLog, Paged<AuditEntry>> {
  /// The audit entries matching [query], newest first, a page at a time.
  AuditLogProvider._({
    required AuditLogFamily super.from,
    required AuditQuery super.argument,
  }) : super(
         retry: null,
         name: r'auditLogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$auditLogHash();

  @override
  String toString() {
    return r'auditLogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AuditLog create() => AuditLog();

  @override
  bool operator ==(Object other) {
    return other is AuditLogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$auditLogHash() => r'61edbc5932177d412ef73a370609303a30e4e89c';

/// The audit entries matching [query], newest first, a page at a time.

final class AuditLogFamily extends $Family
    with
        $ClassFamilyOverride<
          AuditLog,
          AsyncValue<Paged<AuditEntry>>,
          Paged<AuditEntry>,
          FutureOr<Paged<AuditEntry>>,
          AuditQuery
        > {
  AuditLogFamily._()
    : super(
        retry: null,
        name: r'auditLogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The audit entries matching [query], newest first, a page at a time.

  AuditLogProvider call(AuditQuery query) =>
      AuditLogProvider._(argument: query, from: this);

  @override
  String toString() => r'auditLogProvider';
}

/// The audit entries matching [query], newest first, a page at a time.

abstract class _$AuditLog extends $AsyncNotifier<Paged<AuditEntry>> {
  late final _$args = ref.$arg as AuditQuery;
  AuditQuery get query => _$args;

  FutureOr<Paged<AuditEntry>> build(AuditQuery query);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The entry the audit log shows in detail, by its sequence number; null
/// when none is picked.

@ProviderFor(AuditSelection)
final auditSelectionProvider = AuditSelectionProvider._();

/// The entry the audit log shows in detail, by its sequence number; null
/// when none is picked.
final class AuditSelectionProvider
    extends $NotifierProvider<AuditSelection, int?> {
  /// The entry the audit log shows in detail, by its sequence number; null
  /// when none is picked.
  AuditSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditSelectionHash();

  @$internal
  @override
  AuditSelection create() => AuditSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$auditSelectionHash() => r'2e7bf9af29bdea31a2c328cd5126f55e2638c261';

/// The entry the audit log shows in detail, by its sequence number; null
/// when none is picked.

abstract class _$AuditSelection extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
