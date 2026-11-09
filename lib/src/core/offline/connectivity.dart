// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

part 'connectivity.g.dart';

/// The device's network as background work cares about it.
enum NetworkState {
  /// No network at all.
  offline,

  /// Only a network that may cost money: mobile data.
  metered,

  /// Wi-Fi, Ethernet or anything else not known to cost money.
  unmetered,
}

/// The [NetworkState] that connectivity_plus's [results] stand for.
NetworkState networkStateOf(List<ConnectivityResult> results) {
  final up = results.where((r) => r != ConnectivityResult.none).toSet();
  if (up.isEmpty) return NetworkState.offline;
  if (up.contains(ConnectivityResult.mobile) &&
      !up.contains(ConnectivityResult.wifi) &&
      !up.contains(ConnectivityResult.ethernet)) {
    return NetworkState.metered;
  }
  return NetworkState.unmetered;
}

/// The device's network, from connectivity_plus; tests override it.
@Riverpod(keepAlive: true)
Stream<NetworkState> networkState(Ref ref) async* {
  final connectivity = Connectivity();
  try {
    yield networkStateOf(await connectivity.checkConnectivity());
  } on MissingPluginException {
    // A host without the plugin (a test, an unsupported embedder) cannot
    // tell, so it counts as connected and requests decide.
    yield NetworkState.unmetered;
    return;
  }
  yield* connectivity.onConnectivityChanged.map(networkStateOf);
}

/// Whether the active context's server should be reachable now: always for
/// a local instance, which runs on this device; for a remote one, unless
/// the device has no network at all.
@Riverpod(keepAlive: true)
bool online(Ref ref) {
  final kind = ref.watch(
    sessionControllerProvider.select((s) => s.value?.instance.kind),
  );
  if (kind == InstanceKind.local) return true;
  return ref.watch(networkStateProvider).value != NetworkState.offline;
}

/// What the device says about running background work now.
@immutable
class DeviceConditions {
  /// Conditions on a [phone], with [batterySaver] and [batteryLow].
  const DeviceConditions({
    this.phone = false,
    this.batterySaver = false,
    this.batteryLow = false,
  });

  /// Whether this is a phone or tablet (Android or iOS), where data and
  /// battery are worth saving.
  final bool phone;

  /// Whether the platform's battery saver is on.
  final bool batterySaver;

  /// Whether the battery is low and not charging.
  final bool batteryLow;
}

/// Below this charge, out of the charger, the battery counts as low.
const lowBatteryPercent = 20;

/// Reads [DeviceConditions] now.
typedef DeviceProbe = Future<DeviceConditions> Function();

/// The probe background sync asks before it runs; tests override it.
@Riverpod(keepAlive: true)
DeviceProbe deviceProbe(Ref ref) => () async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
    return const DeviceConditions();
  }
  final battery = Battery();
  final saver = await battery.isInBatterySaveMode;
  final level = await battery.batteryLevel;
  final state = await battery.batteryState;
  final charging = state == BatteryState.charging || state == BatteryState.full;
  return DeviceConditions(
    phone: true,
    batterySaver: saver,
    batteryLow: !charging && level < lowBatteryPercent,
  );
};
