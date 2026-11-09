// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'connectivity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device's network, from connectivity_plus; tests override it.

@ProviderFor(networkState)
final networkStateProvider = NetworkStateProvider._();

/// The device's network, from connectivity_plus; tests override it.

final class NetworkStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetworkState>,
          NetworkState,
          Stream<NetworkState>
        >
    with $FutureModifier<NetworkState>, $StreamProvider<NetworkState> {
  /// The device's network, from connectivity_plus; tests override it.
  NetworkStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStateHash();

  @$internal
  @override
  $StreamProviderElement<NetworkState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NetworkState> create(Ref ref) {
    return networkState(ref);
  }
}

String _$networkStateHash() => r'ae81903f6970e913ebfef9a111e7b80f61a2ba27';

/// Whether the active context's server should be reachable now: always for
/// a local instance, which runs on this device; for a remote one, unless
/// the device has no network at all.

@ProviderFor(online)
final onlineProvider = OnlineProvider._();

/// Whether the active context's server should be reachable now: always for
/// a local instance, which runs on this device; for a remote one, unless
/// the device has no network at all.

final class OnlineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the active context's server should be reachable now: always for
  /// a local instance, which runs on this device; for a remote one, unless
  /// the device has no network at all.
  OnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return online(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onlineHash() => r'c16a392bef08ff97037081e188c50c9921e4555f';

/// The probe background sync asks before it runs; tests override it.

@ProviderFor(deviceProbe)
final deviceProbeProvider = DeviceProbeProvider._();

/// The probe background sync asks before it runs; tests override it.

final class DeviceProbeProvider
    extends $FunctionalProvider<DeviceProbe, DeviceProbe, DeviceProbe>
    with $Provider<DeviceProbe> {
  /// The probe background sync asks before it runs; tests override it.
  DeviceProbeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceProbeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceProbeHash();

  @$internal
  @override
  $ProviderElement<DeviceProbe> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceProbe create(Ref ref) {
    return deviceProbe(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceProbe value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceProbe>(value),
    );
  }
}

String _$deviceProbeHash() => r'c641fafc4f43f7b68a30968cda1ef76d8100819e';
