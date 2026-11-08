// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'time_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The caller's date format and timezone, kept on the server so they follow
/// the person to every device, and the levels they inherit from.

@ProviderFor(TimePrefsState)
final timePrefsStateProvider = TimePrefsStateProvider._();

/// The caller's date format and timezone, kept on the server so they follow
/// the person to every device, and the levels they inherit from.
final class TimePrefsStateProvider
    extends $AsyncNotifierProvider<TimePrefsState, TimeSettings> {
  /// The caller's date format and timezone, kept on the server so they follow
  /// the person to every device, and the levels they inherit from.
  TimePrefsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timePrefsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timePrefsStateHash();

  @$internal
  @override
  TimePrefsState create() => TimePrefsState();
}

String _$timePrefsStateHash() => r'bd0ccef593030db9d9b4f0f4ab1ef0bb2026e93c';

/// The caller's date format and timezone, kept on the server so they follow
/// the person to every device, and the levels they inherit from.

abstract class _$TimePrefsState extends $AsyncNotifier<TimeSettings> {
  FutureOr<TimeSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TimeSettings>, TimeSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TimeSettings>, TimeSettings>,
              AsyncValue<TimeSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
