// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'outbox.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Everything waiting to sync in the active context, kept current.

@ProviderFor(syncState)
final syncStateProvider = SyncStateProvider._();

/// Everything waiting to sync in the active context, kept current.

final class SyncStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncSnapshot>,
          SyncSnapshot,
          Stream<SyncSnapshot>
        >
    with $FutureModifier<SyncSnapshot>, $StreamProvider<SyncSnapshot> {
  /// Everything waiting to sync in the active context, kept current.
  SyncStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStateHash();

  @$internal
  @override
  $StreamProviderElement<SyncSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SyncSnapshot> create(Ref ref) {
    return syncState(ref);
  }
}

String _$syncStateHash() => r'48318ef968728216e918fa24e8224a0a0e6bf03a';

/// The writes waiting for the task [ref], for its unsynced mark and banner.

@ProviderFor(pendingWrites)
final pendingWritesProvider = PendingWritesFamily._();

/// The writes waiting for the task [ref], for its unsynced mark and banner.

final class PendingWritesProvider
    extends
        $FunctionalProvider<
          List<OutboxEntry>,
          List<OutboxEntry>,
          List<OutboxEntry>
        >
    with $Provider<List<OutboxEntry>> {
  /// The writes waiting for the task [ref], for its unsynced mark and banner.
  PendingWritesProvider._({
    required PendingWritesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pendingWritesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pendingWritesHash();

  @override
  String toString() {
    return r'pendingWritesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<OutboxEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<OutboxEntry> create(Ref ref) {
    final argument = this.argument as String;
    return pendingWrites(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OutboxEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OutboxEntry>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PendingWritesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pendingWritesHash() => r'da3851255c15608a18f03805a90d69213e43675b';

/// The writes waiting for the task [ref], for its unsynced mark and banner.

final class PendingWritesFamily extends $Family
    with $FunctionalFamilyOverride<List<OutboxEntry>, String> {
  PendingWritesFamily._()
    : super(
        retry: null,
        name: r'pendingWritesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The writes waiting for the task [ref], for its unsynced mark and banner.

  PendingWritesProvider call(String taskRef) =>
      PendingWritesProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'pendingWritesProvider';
}

/// The references of every task with a write waiting, for rows.

@ProviderFor(unsyncedRefs)
final unsyncedRefsProvider = UnsyncedRefsProvider._();

/// The references of every task with a write waiting, for rows.

final class UnsyncedRefsProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  /// The references of every task with a write waiting, for rows.
  UnsyncedRefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unsyncedRefsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unsyncedRefsHash();

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    return unsyncedRefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$unsyncedRefsHash() => r'7368fdc7f21d3f868d81b1cb906d7936804d311f';

/// The conflicts nobody has settled yet, newest first.

@ProviderFor(openConflicts)
final openConflictsProvider = OpenConflictsProvider._();

/// The conflicts nobody has settled yet, newest first.

final class OpenConflictsProvider
    extends
        $FunctionalProvider<
          List<ConflictRecord>,
          List<ConflictRecord>,
          List<ConflictRecord>
        >
    with $Provider<List<ConflictRecord>> {
  /// The conflicts nobody has settled yet, newest first.
  OpenConflictsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openConflictsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openConflictsHash();

  @$internal
  @override
  $ProviderElement<List<ConflictRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ConflictRecord> create(Ref ref) {
    return openConflicts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ConflictRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ConflictRecord>>(value),
    );
  }
}

String _$openConflictsHash() => r'24750dbe1d4855dd0f55e4bf1f57d32f363f5e83';

/// How conflicts found during replay are settled in the active context:
/// asking by default.

@ProviderFor(ConflictPolicySetting)
final conflictPolicySettingProvider = ConflictPolicySettingProvider._();

/// How conflicts found during replay are settled in the active context:
/// asking by default.
final class ConflictPolicySettingProvider
    extends $NotifierProvider<ConflictPolicySetting, ConflictPolicy> {
  /// How conflicts found during replay are settled in the active context:
  /// asking by default.
  ConflictPolicySettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conflictPolicySettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conflictPolicySettingHash();

  @$internal
  @override
  ConflictPolicySetting create() => ConflictPolicySetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConflictPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConflictPolicy>(value),
    );
  }
}

String _$conflictPolicySettingHash() =>
    r'769a295b2c5dbd67c5c22374af03003308fcd62d';

/// How conflicts found during replay are settled in the active context:
/// asking by default.

abstract class _$ConflictPolicySetting extends $Notifier<ConflictPolicy> {
  ConflictPolicy build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConflictPolicy, ConflictPolicy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConflictPolicy, ConflictPolicy>,
              ConflictPolicy,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sends the active context's outbox: when the network comes back, when
/// the event stream goes live again, when a write is queued while the
/// server is reachable, every [replayRetry] while writes wait, and first
/// in every sync. After writes go out it reports a gap on the event
/// stream, so every screen reloads from the server.

@ProviderFor(OutboxSync)
final outboxSyncProvider = OutboxSyncProvider._();

/// Sends the active context's outbox: when the network comes back, when
/// the event stream goes live again, when a write is queued while the
/// server is reachable, every [replayRetry] while writes wait, and first
/// in every sync. After writes go out it reports a gap on the event
/// stream, so every screen reloads from the server.
final class OutboxSyncProvider
    extends $NotifierProvider<OutboxSync, ReplayStatus> {
  /// Sends the active context's outbox: when the network comes back, when
  /// the event stream goes live again, when a write is queued while the
  /// server is reachable, every [replayRetry] while writes wait, and first
  /// in every sync. After writes go out it reports a gap on the event
  /// stream, so every screen reloads from the server.
  OutboxSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxSyncHash();

  @$internal
  @override
  OutboxSync create() => OutboxSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReplayStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReplayStatus>(value),
    );
  }
}

String _$outboxSyncHash() => r'01424b2fda3e76337e1804357983fe25afcf3d9b';

/// Sends the active context's outbox: when the network comes back, when
/// the event stream goes live again, when a write is queued while the
/// server is reachable, every [replayRetry] while writes wait, and first
/// in every sync. After writes go out it reports a gap on the event
/// stream, so every screen reloads from the server.

abstract class _$OutboxSync extends $Notifier<ReplayStatus> {
  ReplayStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReplayStatus, ReplayStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReplayStatus, ReplayStatus>,
              ReplayStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
