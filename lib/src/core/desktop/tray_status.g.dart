// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'tray_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the tray's hover text says about the saved instances, the active
/// context's connection, sync and outbox, and its unread count; null while
/// the session loads.

@ProviderFor(trayStatus)
final trayStatusProvider = TrayStatusProvider._();

/// What the tray's hover text says about the saved instances, the active
/// context's connection, sync and outbox, and its unread count; null while
/// the session loads.

final class TrayStatusProvider
    extends $FunctionalProvider<TrayStatus?, TrayStatus?, TrayStatus?>
    with $Provider<TrayStatus?> {
  /// What the tray's hover text says about the saved instances, the active
  /// context's connection, sync and outbox, and its unread count; null while
  /// the session loads.
  TrayStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trayStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trayStatusHash();

  @$internal
  @override
  $ProviderElement<TrayStatus?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrayStatus? create(Ref ref) {
    return trayStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrayStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrayStatus?>(value),
    );
  }
}

String _$trayStatusHash() => r'bd563856807b6d2c37a1cf8d5360b0c71e7c896c';
