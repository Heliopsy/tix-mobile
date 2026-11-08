// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'templates.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The templates the person can read, by name, a page at a time, and what
/// can be done to them.

@ProviderFor(Templates)
final templatesProvider = TemplatesProvider._();

/// The templates the person can read, by name, a page at a time, and what
/// can be done to them.
final class TemplatesProvider
    extends $AsyncNotifierProvider<Templates, Paged<TaskTemplate>> {
  /// The templates the person can read, by name, a page at a time, and what
  /// can be done to them.
  TemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templatesHash();

  @$internal
  @override
  Templates create() => Templates();
}

String _$templatesHash() => r'74f714969c6d4c1c223252d7691988148bc6ce10';

/// The templates the person can read, by name, a page at a time, and what
/// can be done to them.

abstract class _$Templates extends $AsyncNotifier<Paged<TaskTemplate>> {
  FutureOr<Paged<TaskTemplate>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Paged<TaskTemplate>>, Paged<TaskTemplate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<TaskTemplate>>, Paged<TaskTemplate>>,
              AsyncValue<Paged<TaskTemplate>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Every project, for the template forms' pickers.

@ProviderFor(templateProjects)
final templateProjectsProvider = TemplateProjectsProvider._();

/// Every project, for the template forms' pickers.

final class TemplateProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          FutureOr<List<Project>>
        >
    with $FutureModifier<List<Project>>, $FutureProvider<List<Project>> {
  /// Every project, for the template forms' pickers.
  TemplateProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templateProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templateProjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Project>> create(Ref ref) {
    return templateProjects(ref);
  }
}

String _$templateProjectsHash() => r'fc45b8e13cf6d465ebd58351a93baca38906292a';
