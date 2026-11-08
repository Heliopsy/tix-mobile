// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'local_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's local notifications; tests swap in a fake.

@ProviderFor(localNotes)
final localNotesProvider = LocalNotesProvider._();

/// The app's local notifications; tests swap in a fake.

final class LocalNotesProvider
    extends $FunctionalProvider<LocalNotifier, LocalNotifier, LocalNotifier>
    with $Provider<LocalNotifier> {
  /// The app's local notifications; tests swap in a fake.
  LocalNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNotesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNotesHash();

  @$internal
  @override
  $ProviderElement<LocalNotifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalNotifier create(Ref ref) {
    return localNotes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNotifier>(value),
    );
  }
}

String _$localNotesHash() => r'c142751973890d4af7834ea009f03737b10ce031';
