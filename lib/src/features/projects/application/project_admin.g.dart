// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'project_admin.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One project's settings: the cached copy at once, then the server's, and
/// again whenever a project changes.

@ProviderFor(ProjectSettings)
final projectSettingsProvider = ProjectSettingsFamily._();

/// One project's settings: the cached copy at once, then the server's, and
/// again whenever a project changes.
final class ProjectSettingsProvider
    extends $AsyncNotifierProvider<ProjectSettings, Project> {
  /// One project's settings: the cached copy at once, then the server's, and
  /// again whenever a project changes.
  ProjectSettingsProvider._({
    required ProjectSettingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectSettingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectSettingsHash();

  @override
  String toString() {
    return r'projectSettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProjectSettings create() => ProjectSettings();

  @override
  bool operator ==(Object other) {
    return other is ProjectSettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectSettingsHash() => r'0941563f0ecb588550372ab3c91e4f3edd45707e';

/// One project's settings: the cached copy at once, then the server's, and
/// again whenever a project changes.

final class ProjectSettingsFamily extends $Family
    with
        $ClassFamilyOverride<
          ProjectSettings,
          AsyncValue<Project>,
          Project,
          FutureOr<Project>,
          String
        > {
  ProjectSettingsFamily._()
    : super(
        retry: null,
        name: r'projectSettingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One project's settings: the cached copy at once, then the server's, and
  /// again whenever a project changes.

  ProjectSettingsProvider call(String key) =>
      ProjectSettingsProvider._(argument: key, from: this);

  @override
  String toString() => r'projectSettingsProvider';
}

/// One project's settings: the cached copy at once, then the server's, and
/// again whenever a project changes.

abstract class _$ProjectSettings extends $AsyncNotifier<Project> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  FutureOr<Project> build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Project>, Project>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Project>, Project>,
              AsyncValue<Project>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// What deleting project [key] would do: with [moveTo] the tasks move
/// there, otherwise the plan only counts them.

@ProviderFor(deletionPlan)
final deletionPlanProvider = DeletionPlanFamily._();

/// What deleting project [key] would do: with [moveTo] the tasks move
/// there, otherwise the plan only counts them.

final class DeletionPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProjectDeletion>,
          ProjectDeletion,
          FutureOr<ProjectDeletion>
        >
    with $FutureModifier<ProjectDeletion>, $FutureProvider<ProjectDeletion> {
  /// What deleting project [key] would do: with [moveTo] the tasks move
  /// there, otherwise the plan only counts them.
  DeletionPlanProvider._({
    required DeletionPlanFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'deletionPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deletionPlanHash();

  @override
  String toString() {
    return r'deletionPlanProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProjectDeletion> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProjectDeletion> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return deletionPlan(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DeletionPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deletionPlanHash() => r'b6ca4137c07e18ec62a3bf28ac213c81c722af3a';

/// What deleting project [key] would do: with [moveTo] the tasks move
/// there, otherwise the plan only counts them.

final class DeletionPlanFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProjectDeletion>,
          (String, String?)
        > {
  DeletionPlanFamily._()
    : super(
        retry: null,
        name: r'deletionPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What deleting project [key] would do: with [moveTo] the tasks move
  /// there, otherwise the plan only counts them.

  DeletionPlanProvider call(String key, String? moveTo) =>
      DeletionPlanProvider._(argument: (key, moveTo), from: this);

  @override
  String toString() => r'deletionPlanProvider';
}

/// The uploaded icon of project [key], whose digest is [digest]; a new
/// digest reads the new image.

@ProviderFor(projectIcon)
final projectIconProvider = ProjectIconFamily._();

/// The uploaded icon of project [key], whose digest is [digest]; a new
/// digest reads the new image.

final class ProjectIconProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// The uploaded icon of project [key], whose digest is [digest]; a new
  /// digest reads the new image.
  ProjectIconProvider._({
    required ProjectIconFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'projectIconProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectIconHash();

  @override
  String toString() {
    return r'projectIconProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as (String, String);
    return projectIcon(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectIconProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectIconHash() => r'7630993c65fa9bd2322f092665868ebcb59690bf';

/// The uploaded icon of project [key], whose digest is [digest]; a new
/// digest reads the new image.

final class ProjectIconFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List>, (String, String)> {
  ProjectIconFamily._()
    : super(
        retry: null,
        name: r'projectIconProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The uploaded icon of project [key], whose digest is [digest]; a new
  /// digest reads the new image.

  ProjectIconProvider call(String key, String digest) =>
      ProjectIconProvider._(argument: (key, digest), from: this);

  @override
  String toString() => r'projectIconProvider';
}

/// The workflows a project can follow.

@ProviderFor(WorkflowChoices)
final workflowChoicesProvider = WorkflowChoicesProvider._();

/// The workflows a project can follow.
final class WorkflowChoicesProvider
    extends $AsyncNotifierProvider<WorkflowChoices, List<Workflow>> {
  /// The workflows a project can follow.
  WorkflowChoicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workflowChoicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workflowChoicesHash();

  @$internal
  @override
  WorkflowChoices create() => WorkflowChoices();
}

String _$workflowChoicesHash() => r'f6e609daf07f7aa2e369649fb4eae19dc7775e97';

/// The workflows a project can follow.

abstract class _$WorkflowChoices extends $AsyncNotifier<List<Workflow>> {
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

/// The custom fields of project [key], in display order.

@ProviderFor(ProjectFields)
final projectFieldsProvider = ProjectFieldsFamily._();

/// The custom fields of project [key], in display order.
final class ProjectFieldsProvider
    extends $AsyncNotifierProvider<ProjectFields, List<FieldDef>> {
  /// The custom fields of project [key], in display order.
  ProjectFieldsProvider._({
    required ProjectFieldsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectFieldsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectFieldsHash();

  @override
  String toString() {
    return r'projectFieldsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProjectFields create() => ProjectFields();

  @override
  bool operator ==(Object other) {
    return other is ProjectFieldsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectFieldsHash() => r'cb053ccf480a34d8b5c60dd4d02e8a45360afd99';

/// The custom fields of project [key], in display order.

final class ProjectFieldsFamily extends $Family
    with
        $ClassFamilyOverride<
          ProjectFields,
          AsyncValue<List<FieldDef>>,
          List<FieldDef>,
          FutureOr<List<FieldDef>>,
          String
        > {
  ProjectFieldsFamily._()
    : super(
        retry: null,
        name: r'projectFieldsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The custom fields of project [key], in display order.

  ProjectFieldsProvider call(String key) =>
      ProjectFieldsProvider._(argument: key, from: this);

  @override
  String toString() => r'projectFieldsProvider';
}

/// The custom fields of project [key], in display order.

abstract class _$ProjectFields extends $AsyncNotifier<List<FieldDef>> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  FutureOr<List<FieldDef>> build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FieldDef>>, List<FieldDef>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FieldDef>>, List<FieldDef>>,
              AsyncValue<List<FieldDef>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
