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

/// The event stream of the active context, null while there is none or it
/// cannot be reached. Rebuilt, with a fresh cursor, when the context
/// changes.

@ProviderFor(tixEventStream)
final tixEventStreamProvider = TixEventStreamProvider._();

/// The event stream of the active context, null while there is none or it
/// cannot be reached. Rebuilt, with a fresh cursor, when the context
/// changes.

final class TixEventStreamProvider
    extends
        $FunctionalProvider<TixEventStream?, TixEventStream?, TixEventStream?>
    with $Provider<TixEventStream?> {
  /// The event stream of the active context, null while there is none or it
  /// cannot be reached. Rebuilt, with a fresh cursor, when the context
  /// changes.
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
  $ProviderElement<TixEventStream?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TixEventStream? create(Ref ref) {
    return tixEventStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TixEventStream? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TixEventStream?>(value),
    );
  }
}

String _$tixEventStreamHash() => r'658f02c3ae81a2dd3c1954f804bec5a6dcadd295';

/// Every update of the active context's event stream, for anything that
/// shows whether updates are live.

@ProviderFor(tixEvents)
final tixEventsProvider = TixEventsProvider._();

/// Every update of the active context's event stream, for anything that
/// shows whether updates are live.

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
  /// Every update of the active context's event stream, for anything that
  /// shows whether updates are live.
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

/// Where the active context's event stream stands.

@ProviderFor(eventStreamState)
final eventStreamStateProvider = EventStreamStateProvider._();

/// Where the active context's event stream stands.

final class EventStreamStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventStreamState>,
          EventStreamState,
          Stream<EventStreamState>
        >
    with $FutureModifier<EventStreamState>, $StreamProvider<EventStreamState> {
  /// Where the active context's event stream stands.
  EventStreamStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventStreamStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventStreamStateHash();

  @$internal
  @override
  $StreamProviderElement<EventStreamState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<EventStreamState> create(Ref ref) {
    return eventStreamState(ref);
  }
}

String _$eventStreamStateHash() => r'ea7bd0078148260ae7fb3986bf0026be49c52b76';
