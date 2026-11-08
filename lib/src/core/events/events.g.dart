// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'events.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How event sockets are opened; tests swap in a fake.

@ProviderFor(eventSocketConnector)
final eventSocketConnectorProvider = EventSocketConnectorProvider._();

/// How event sockets are opened; tests swap in a fake.

final class EventSocketConnectorProvider
    extends
        $FunctionalProvider<
          EventSocketConnector,
          EventSocketConnector,
          EventSocketConnector
        >
    with $Provider<EventSocketConnector> {
  /// How event sockets are opened; tests swap in a fake.
  EventSocketConnectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventSocketConnectorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventSocketConnectorHash();

  @$internal
  @override
  $ProviderElement<EventSocketConnector> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventSocketConnector create(Ref ref) {
    return eventSocketConnector(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventSocketConnector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventSocketConnector>(value),
    );
  }
}

String _$eventSocketConnectorHash() =>
    r'3d585d101a28b35f873541f0d91a9e21737f3d46';

/// Fires each time the app comes back to the foreground.

@ProviderFor(appResumed)
final appResumedProvider = AppResumedProvider._();

/// Fires each time the app comes back to the foreground.

final class AppResumedProvider
    extends $FunctionalProvider<AsyncValue<void>, void, Stream<void>>
    with $FutureModifier<void>, $StreamProvider<void> {
  /// Fires each time the app comes back to the foreground.
  AppResumedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appResumedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appResumedHash();

  @$internal
  @override
  $StreamProviderElement<void> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<void> create(Ref ref) {
    return appResumed(ref);
  }
}

String _$appResumedHash() => r'a48e02764c6328223e6f2e16cbf9f6bc79a70526';

/// Fires each time the app goes to the background.

@ProviderFor(appPaused)
final appPausedProvider = AppPausedProvider._();

/// Fires each time the app goes to the background.

final class AppPausedProvider
    extends $FunctionalProvider<AsyncValue<void>, void, Stream<void>>
    with $FutureModifier<void>, $StreamProvider<void> {
  /// Fires each time the app goes to the background.
  AppPausedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPausedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPausedHash();

  @$internal
  @override
  $StreamProviderElement<void> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<void> create(Ref ref) {
    return appPaused(ref);
  }
}

String _$appPausedHash() => r'436e416d5171d1e0d65d7d1522b52f18ffef592c';

/// Whether polling stops while the app is in the background. Phones
/// suspend a backgrounded app anyway; desktops keep running when minimised.

@ProviderFor(livePausesInBackground)
final livePausesInBackgroundProvider = LivePausesInBackgroundProvider._();

/// Whether polling stops while the app is in the background. Phones
/// suspend a backgrounded app anyway; desktops keep running when minimised.

final class LivePausesInBackgroundProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether polling stops while the app is in the background. Phones
  /// suspend a backgrounded app anyway; desktops keep running when minimised.
  LivePausesInBackgroundProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'livePausesInBackgroundProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$livePausesInBackgroundHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return livePausesInBackground(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$livePausesInBackgroundHash() =>
    r'1520200188d9bc1ad68d6b4a0d3d38b0a35fe9ea';

/// The thresholds and timings of live updates; tests shorten them.

@ProviderFor(liveConfig)
final liveConfigProvider = LiveConfigProvider._();

/// The thresholds and timings of live updates; tests shorten them.

final class LiveConfigProvider
    extends $FunctionalProvider<LiveConfig, LiveConfig, LiveConfig>
    with $Provider<LiveConfig> {
  /// The thresholds and timings of live updates; tests shorten them.
  LiveConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveConfigHash();

  @$internal
  @override
  $ProviderElement<LiveConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LiveConfig create(Ref ref) {
    return liveConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveConfig>(value),
    );
  }
}

String _$liveConfigHash() => r'855e2b51cb6141525a09de035f38b2af55e0f09b';

/// Live updates of the active context, null while there is none or it
/// cannot be reached: the WebSocket, or the HTTP fallback when it keeps
/// failing. Rebuilt, with a fresh cursor, when the context changes.

@ProviderFor(tixEventStream)
final tixEventStreamProvider = TixEventStreamProvider._();

/// Live updates of the active context, null while there is none or it
/// cannot be reached: the WebSocket, or the HTTP fallback when it keeps
/// failing. Rebuilt, with a fresh cursor, when the context changes.

final class TixEventStreamProvider
    extends $FunctionalProvider<LiveEvents?, LiveEvents?, LiveEvents?>
    with $Provider<LiveEvents?> {
  /// Live updates of the active context, null while there is none or it
  /// cannot be reached: the WebSocket, or the HTTP fallback when it keeps
  /// failing. Rebuilt, with a fresh cursor, when the context changes.
  TixEventStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tixEventStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tixEventStreamHash();

  @$internal
  @override
  $ProviderElement<LiveEvents?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LiveEvents? create(Ref ref) {
    return tixEventStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveEvents? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveEvents?>(value),
    );
  }
}

String _$tixEventStreamHash() => r'34bd5729a9e2252a42f6f3bbe461326a17a29fbe';

/// Every update of the active context's live events.

@ProviderFor(tixEvents)
final tixEventsProvider = TixEventsProvider._();

/// Every update of the active context's live events.

final class TixEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventStreamUpdate>,
          EventStreamUpdate,
          Stream<EventStreamUpdate>
        >
    with
        $FutureModifier<EventStreamUpdate>,
        $StreamProvider<EventStreamUpdate> {
  /// Every update of the active context's live events.
  TixEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tixEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tixEventsHash();

  @$internal
  @override
  $StreamProviderElement<EventStreamUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<EventStreamUpdate> create(Ref ref) {
    return tixEvents(ref);
  }
}

String _$tixEventsHash() => r'e21ae7a0d600c9cc935a332a0e8496d67779de3a';

/// How live updates reach the active context and the last error, for the
/// live indicator and diagnostics. Null while there is no context.

@ProviderFor(liveStatus)
final liveStatusProvider = LiveStatusProvider._();

/// How live updates reach the active context and the last error, for the
/// live indicator and diagnostics. Null while there is no context.

final class LiveStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<LiveStatus?>,
          LiveStatus?,
          Stream<LiveStatus?>
        >
    with $FutureModifier<LiveStatus?>, $StreamProvider<LiveStatus?> {
  /// How live updates reach the active context and the last error, for the
  /// live indicator and diagnostics. Null while there is no context.
  LiveStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveStatusHash();

  @$internal
  @override
  $StreamProviderElement<LiveStatus?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LiveStatus?> create(Ref ref) {
    return liveStatus(ref);
  }
}

String _$liveStatusHash() => r'96c27d4b12cf6a847927a40dc04952d0480f25e4';
