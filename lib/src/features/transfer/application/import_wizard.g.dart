// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'import_wizard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The states of [project]'s workflow, for the values step.

@ProviderFor(importStates)
final importStatesProvider = ImportStatesFamily._();

/// The states of [project]'s workflow, for the values step.

final class ImportStatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<({String key, String label})>>,
          List<({String key, String label})>,
          FutureOr<List<({String key, String label})>>
        >
    with
        $FutureModifier<List<({String key, String label})>>,
        $FutureProvider<List<({String key, String label})>> {
  /// The states of [project]'s workflow, for the values step.
  ImportStatesProvider._({
    required ImportStatesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'importStatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$importStatesHash();

  @override
  String toString() {
    return r'importStatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<({String key, String label})>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<({String key, String label})>> create(Ref ref) {
    final argument = this.argument as String;
    return importStates(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ImportStatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$importStatesHash() => r'edf221b6f49e147a22065d06ff367a181291036b';

/// The states of [project]'s workflow, for the values step.

final class ImportStatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<({String key, String label})>>,
          String
        > {
  ImportStatesFamily._()
    : super(
        retry: null,
        name: r'importStatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The states of [project]'s workflow, for the values step.

  ImportStatesProvider call(String project) =>
      ImportStatesProvider._(argument: project, from: this);

  @override
  String toString() => r'importStatesProvider';
}

/// The import wizard's state, opened on [project].

@ProviderFor(ImportWizard)
final importWizardProvider = ImportWizardFamily._();

/// The import wizard's state, opened on [project].
final class ImportWizardProvider
    extends $NotifierProvider<ImportWizard, ImportDraft> {
  /// The import wizard's state, opened on [project].
  ImportWizardProvider._({
    required ImportWizardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'importWizardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$importWizardHash();

  @override
  String toString() {
    return r'importWizardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ImportWizard create() => ImportWizard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportDraft>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ImportWizardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$importWizardHash() => r'94dca107345b89ad8667f579316653e67745d6d4';

/// The import wizard's state, opened on [project].

final class ImportWizardFamily extends $Family
    with
        $ClassFamilyOverride<
          ImportWizard,
          ImportDraft,
          ImportDraft,
          ImportDraft,
          String
        > {
  ImportWizardFamily._()
    : super(
        retry: null,
        name: r'importWizardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The import wizard's state, opened on [project].

  ImportWizardProvider call(String project) =>
      ImportWizardProvider._(argument: project, from: this);

  @override
  String toString() => r'importWizardProvider';
}

/// The import wizard's state, opened on [project].

abstract class _$ImportWizard extends $Notifier<ImportDraft> {
  late final _$args = ref.$arg as String;
  String get project => _$args;

  ImportDraft build(String project);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ImportDraft, ImportDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ImportDraft, ImportDraft>,
              ImportDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
