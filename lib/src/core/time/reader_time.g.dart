// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'reader_time.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active context's date settings: what was remembered for it at once,
/// then the server's answer. Null without a context, and from a server
/// that keeps none, which leaves the device's formats in force.
///
/// A connection that reaches one tenant is keyed by the connection alone,
/// as the response cache is, so `whoami` naming the tenant later does not
/// read the settings twice.

@ProviderFor(ReaderTime)
final readerTimeProvider = ReaderTimeProvider._();

/// The active context's date settings: what was remembered for it at once,
/// then the server's answer. Null without a context, and from a server
/// that keeps none, which leaves the device's formats in force.
///
/// A connection that reaches one tenant is keyed by the connection alone,
/// as the response cache is, so `whoami` naming the tenant later does not
/// read the settings twice.
final class ReaderTimeProvider
    extends $NotifierProvider<ReaderTime, TimeSettings?> {
  /// The active context's date settings: what was remembered for it at once,
  /// then the server's answer. Null without a context, and from a server
  /// that keeps none, which leaves the device's formats in force.
  ///
  /// A connection that reaches one tenant is keyed by the connection alone,
  /// as the response cache is, so `whoami` naming the tenant later does not
  /// read the settings twice.
  ReaderTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerTimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerTimeHash();

  @$internal
  @override
  ReaderTime create() => ReaderTime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeSettings? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeSettings?>(value),
    );
  }
}

String _$readerTimeHash() => r'e1f0396d53444eb69d279eb31e733af05cce8c5f';

/// The active context's date settings: what was remembered for it at once,
/// then the server's answer. Null without a context, and from a server
/// that keeps none, which leaves the device's formats in force.
///
/// A connection that reaches one tenant is keyed by the connection alone,
/// as the response cache is, so `whoami` naming the tenant later does not
/// read the settings twice.

abstract class _$ReaderTime extends $Notifier<TimeSettings?> {
  TimeSettings? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TimeSettings?, TimeSettings?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimeSettings?, TimeSettings?>,
              TimeSettings?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How dates and times are written for the active context: the server's
/// effective preference (the person's, else the tenant's, else the
/// deployment's), and the device's formats and zone for whatever it leaves
/// empty.

@ProviderFor(readerTimeStyle)
final readerTimeStyleProvider = ReaderTimeStyleProvider._();

/// How dates and times are written for the active context: the server's
/// effective preference (the person's, else the tenant's, else the
/// deployment's), and the device's formats and zone for whatever it leaves
/// empty.

final class ReaderTimeStyleProvider
    extends $FunctionalProvider<TixTimeStyle, TixTimeStyle, TixTimeStyle>
    with $Provider<TixTimeStyle> {
  /// How dates and times are written for the active context: the server's
  /// effective preference (the person's, else the tenant's, else the
  /// deployment's), and the device's formats and zone for whatever it leaves
  /// empty.
  ReaderTimeStyleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerTimeStyleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerTimeStyleHash();

  @$internal
  @override
  $ProviderElement<TixTimeStyle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TixTimeStyle create(Ref ref) {
    return readerTimeStyle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TixTimeStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TixTimeStyle>(value),
    );
  }
}

String _$readerTimeStyleHash() => r'ce8ce0a9d16b09ae0d6f8319a41701d614ab0670';
