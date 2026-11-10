// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'desktop.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The desktop's tray, window and hotkey; tests swap in a fake.

@ProviderFor(desktopShell)
final desktopShellProvider = DesktopShellProvider._();

/// The desktop's tray, window and hotkey; tests swap in a fake.

final class DesktopShellProvider
    extends $FunctionalProvider<DesktopShell, DesktopShell, DesktopShell>
    with $Provider<DesktopShell> {
  /// The desktop's tray, window and hotkey; tests swap in a fake.
  DesktopShellProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'desktopShellProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$desktopShellHash();

  @$internal
  @override
  $ProviderElement<DesktopShell> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DesktopShell create(Ref ref) {
    return desktopShell(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DesktopShell value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DesktopShell>(value),
    );
  }
}

String _$desktopShellHash() => r'48d47af03fb594ca713e3f0c2c64a571f63d0104';
