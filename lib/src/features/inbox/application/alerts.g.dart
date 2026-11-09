// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'alerts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notification choices on this device.

@ProviderFor(notificationSettingsRepository)
final notificationSettingsRepositoryProvider =
    NotificationSettingsRepositoryProvider._();

/// Notification choices on this device.

final class NotificationSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationSettingsRepository,
          NotificationSettingsRepository,
          NotificationSettingsRepository
        >
    with $Provider<NotificationSettingsRepository> {
  /// Notification choices on this device.
  NotificationSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationSettingsRepository create(Ref ref) {
    return notificationSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSettingsRepository>(
        value,
      ),
    );
  }
}

String _$notificationSettingsRepositoryHash() =>
    r'c658f566c10d992d81522a0b9b5c268a33676e33';

/// The active context's notification choices.

@ProviderFor(NotificationPrefsState)
final notificationPrefsStateProvider = NotificationPrefsStateProvider._();

/// The active context's notification choices.
final class NotificationPrefsStateProvider
    extends $NotifierProvider<NotificationPrefsState, NotificationPrefs> {
  /// The active context's notification choices.
  NotificationPrefsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPrefsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPrefsStateHash();

  @$internal
  @override
  NotificationPrefsState create() => NotificationPrefsState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPrefs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPrefs>(value),
    );
  }
}

String _$notificationPrefsStateHash() =>
    r'0dd4c52b2fc0b2f69f6e441afa8aea664c636bbd';

/// The active context's notification choices.

abstract class _$NotificationPrefsState extends $Notifier<NotificationPrefs> {
  NotificationPrefs build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationPrefs, NotificationPrefs>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationPrefs, NotificationPrefs>,
              NotificationPrefs,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Notifies new inbox items of the active context while the app runs:
/// each item once, none that was there when the app started.

@ProviderFor(InboxAlerts)
final inboxAlertsProvider = InboxAlertsProvider._();

/// Notifies new inbox items of the active context while the app runs:
/// each item once, none that was there when the app started.
final class InboxAlertsProvider
    extends $AsyncNotifierProvider<InboxAlerts, void> {
  /// Notifies new inbox items of the active context while the app runs:
  /// each item once, none that was there when the app started.
  InboxAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxAlertsHash();

  @$internal
  @override
  InboxAlerts create() => InboxAlerts();
}

String _$inboxAlertsHash() => r'f102bfe2b369f17c895d24101e701b14b859a644';

/// Notifies new inbox items of the active context while the app runs:
/// each item once, none that was there when the app started.

abstract class _$InboxAlerts extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
