// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'app_shortcuts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's launcher shortcuts; tests swap in a fake.

@ProviderFor(appShortcuts)
final appShortcutsProvider = AppShortcutsProvider._();

/// The platform's launcher shortcuts; tests swap in a fake.

final class AppShortcutsProvider
    extends $FunctionalProvider<AppShortcuts, AppShortcuts, AppShortcuts>
    with $Provider<AppShortcuts> {
  /// The platform's launcher shortcuts; tests swap in a fake.
  AppShortcutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appShortcutsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appShortcutsHash();

  @$internal
  @override
  $ProviderElement<AppShortcuts> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppShortcuts create(Ref ref) {
    return appShortcuts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppShortcuts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppShortcuts>(value),
    );
  }
}

String _$appShortcutsHash() => r'bef3b9d1ee68ba4148708e0dec18c0b7fa22618b';
