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
