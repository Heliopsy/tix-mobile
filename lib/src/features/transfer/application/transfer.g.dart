// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'transfer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every project, for the export and import pickers.

@ProviderFor(transferProjects)
final transferProjectsProvider = TransferProjectsProvider._();

/// Every project, for the export and import pickers.

final class TransferProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          FutureOr<List<Project>>
        >
    with $FutureModifier<List<Project>>, $FutureProvider<List<Project>> {
  /// Every project, for the export and import pickers.
  TransferProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferProjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Project>> create(Ref ref) {
    return transferProjects(ref);
  }
}

String _$transferProjectsHash() => r'6577404b0b45408f10d6855f5398c9c53667be18';

/// The custom fields of [project], offered as export columns.

@ProviderFor(transferFields)
final transferFieldsProvider = TransferFieldsFamily._();

/// The custom fields of [project], offered as export columns.

final class TransferFieldsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FieldDef>>,
          List<FieldDef>,
          FutureOr<List<FieldDef>>
        >
    with $FutureModifier<List<FieldDef>>, $FutureProvider<List<FieldDef>> {
  /// The custom fields of [project], offered as export columns.
  TransferFieldsProvider._({
    required TransferFieldsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transferFieldsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transferFieldsHash();

  @override
  String toString() {
    return r'transferFieldsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FieldDef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FieldDef>> create(Ref ref) {
    final argument = this.argument as String;
    return transferFields(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransferFieldsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transferFieldsHash() => r'10078110527e9509a1f2d468d5d462e0a2eb9958';

/// The custom fields of [project], offered as export columns.

final class TransferFieldsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FieldDef>>, String> {
  TransferFieldsFamily._()
    : super(
        retry: null,
        name: r'transferFieldsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The custom fields of [project], offered as export columns.

  TransferFieldsProvider call(String project) =>
      TransferFieldsProvider._(argument: project, from: this);

  @override
  String toString() => r'transferFieldsProvider';
}

/// Writes exports and runs imports for the screens.

@ProviderFor(Transfer)
final transferProvider = TransferProvider._();

/// Writes exports and runs imports for the screens.
final class TransferProvider extends $NotifierProvider<Transfer, void> {
  /// Writes exports and runs imports for the screens.
  TransferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferHash();

  @$internal
  @override
  Transfer create() => Transfer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$transferHash() => r'cdb7bb24ce4d0b8b2efa6cddf87c71722172c9d9';

/// Writes exports and runs imports for the screens.

abstract class _$Transfer extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
