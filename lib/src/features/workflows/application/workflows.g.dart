// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'workflows.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tenant's workflows, builtin first then by name: the cached list at
/// once, then the server's, and again whenever a workflow changes.

@ProviderFor(Workflows)
final workflowsProvider = WorkflowsProvider._();

/// The tenant's workflows, builtin first then by name: the cached list at
/// once, then the server's, and again whenever a workflow changes.
final class WorkflowsProvider
    extends $AsyncNotifierProvider<Workflows, List<Workflow>> {
  /// The tenant's workflows, builtin first then by name: the cached list at
  /// once, then the server's, and again whenever a workflow changes.
  WorkflowsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workflowsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workflowsHash();

  @$internal
  @override
  Workflows create() => Workflows();
}

String _$workflowsHash() => r'7759e02255d2da52957e1f46110979edf1ced8c3';

/// The tenant's workflows, builtin first then by name: the cached list at
/// once, then the server's, and again whenever a workflow changes.

abstract class _$Workflows extends $AsyncNotifier<List<Workflow>> {
  FutureOr<List<Workflow>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Workflow>>, List<Workflow>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Workflow>>, List<Workflow>>,
              AsyncValue<List<Workflow>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One workflow, for its editor.

@ProviderFor(WorkflowDetail)
final workflowDetailProvider = WorkflowDetailFamily._();

/// One workflow, for its editor.
final class WorkflowDetailProvider
    extends $AsyncNotifierProvider<WorkflowDetail, Workflow> {
  /// One workflow, for its editor.
  WorkflowDetailProvider._({
    required WorkflowDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workflowDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workflowDetailHash();

  @override
  String toString() {
    return r'workflowDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WorkflowDetail create() => WorkflowDetail();

  @override
  bool operator ==(Object other) {
    return other is WorkflowDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workflowDetailHash() => r'4ba1b53a4be35df0ff74271e9963b266ec20f3f3';

/// One workflow, for its editor.

final class WorkflowDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          WorkflowDetail,
          AsyncValue<Workflow>,
          Workflow,
          FutureOr<Workflow>,
          String
        > {
  WorkflowDetailFamily._()
    : super(
        retry: null,
        name: r'workflowDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One workflow, for its editor.

  WorkflowDetailProvider call(String key) =>
      WorkflowDetailProvider._(argument: key, from: this);

  @override
  String toString() => r'workflowDetailProvider';
}

/// One workflow, for its editor.

abstract class _$WorkflowDetail extends $AsyncNotifier<Workflow> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  FutureOr<Workflow> build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Workflow>, Workflow>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Workflow>, Workflow>,
              AsyncValue<Workflow>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
