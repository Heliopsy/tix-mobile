// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'connect_flow.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Adding an instance or a connection, one step at a time; one flow per
/// connect screen, named by [key].

@ProviderFor(ConnectFlow)
final connectFlowProvider = ConnectFlowFamily._();

/// Adding an instance or a connection, one step at a time; one flow per
/// connect screen, named by [key].
final class ConnectFlowProvider
    extends $NotifierProvider<ConnectFlow, ConnectStep> {
  /// Adding an instance or a connection, one step at a time; one flow per
  /// connect screen, named by [key].
  ConnectFlowProvider._({
    required ConnectFlowFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'connectFlowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$connectFlowHash();

  @override
  String toString() {
    return r'connectFlowProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConnectFlow create() => ConnectFlow();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectStep value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectStep>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectFlowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$connectFlowHash() => r'9e2c55d7be32bb8f8fd4f99d879e4b31b3515112';

/// Adding an instance or a connection, one step at a time; one flow per
/// connect screen, named by [key].

final class ConnectFlowFamily extends $Family
    with
        $ClassFamilyOverride<
          ConnectFlow,
          ConnectStep,
          ConnectStep,
          ConnectStep,
          String
        > {
  ConnectFlowFamily._()
    : super(
        retry: null,
        name: r'connectFlowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Adding an instance or a connection, one step at a time; one flow per
  /// connect screen, named by [key].

  ConnectFlowProvider call(String key) =>
      ConnectFlowProvider._(argument: key, from: this);

  @override
  String toString() => r'connectFlowProvider';
}

/// Adding an instance or a connection, one step at a time; one flow per
/// connect screen, named by [key].

abstract class _$ConnectFlow extends $Notifier<ConnectStep> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  ConnectStep build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConnectStep, ConnectStep>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectStep, ConnectStep>,
              ConnectStep,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
