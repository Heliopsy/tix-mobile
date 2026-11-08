// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'projects.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The projects on the active server, a page at a time: the cached first
/// page at once, then the server's, and again whenever a project changes.

@ProviderFor(Projects)
final projectsProvider = ProjectsProvider._();

/// The projects on the active server, a page at a time: the cached first
/// page at once, then the server's, and again whenever a project changes.
final class ProjectsProvider
    extends $AsyncNotifierProvider<Projects, Paged<Project>> {
  /// The projects on the active server, a page at a time: the cached first
  /// page at once, then the server's, and again whenever a project changes.
  ProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsHash();

  @$internal
  @override
  Projects create() => Projects();
}

String _$projectsHash() => r'636b32dedf6e75e784cb00c245db251901bd422e';

/// The projects on the active server, a page at a time: the cached first
/// page at once, then the server's, and again whenever a project changes.

abstract class _$Projects extends $AsyncNotifier<Paged<Project>> {
  FutureOr<Paged<Project>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Paged<Project>>, Paged<Project>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<Project>>, Paged<Project>>,
              AsyncValue<Paged<Project>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How many of project [key]'s tasks are still open.

@ProviderFor(projectOpenCount)
final projectOpenCountProvider = ProjectOpenCountFamily._();

/// How many of project [key]'s tasks are still open.

final class ProjectOpenCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many of project [key]'s tasks are still open.
  ProjectOpenCountProvider._({
    required ProjectOpenCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectOpenCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectOpenCountHash();

  @override
  String toString() {
    return r'projectOpenCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return projectOpenCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectOpenCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectOpenCountHash() => r'84539ab512d47dee3a41455cefc69e0c0b8f80e2';

/// How many of project [key]'s tasks are still open.

final class ProjectOpenCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  ProjectOpenCountFamily._()
    : super(
        retry: null,
        name: r'projectOpenCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many of project [key]'s tasks are still open.

  ProjectOpenCountProvider call(String key) =>
      ProjectOpenCountProvider._(argument: key, from: this);

  @override
  String toString() => r'projectOpenCountProvider';
}
