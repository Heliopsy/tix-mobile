// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'project_stars.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The projects the reader starred on the active server: the copy last read
/// at once, then the server's, and again whenever a project or a lane star
/// changes. Null when the server keeps no project stars, which hides every
/// star control.
///
/// A project star is the star on the project's lane, so starring a lane on
/// the task screen stars the project, and the other way round.

@ProviderFor(ProjectStars)
final projectStarsProvider = ProjectStarsProvider._();

/// The projects the reader starred on the active server: the copy last read
/// at once, then the server's, and again whenever a project or a lane star
/// changes. Null when the server keeps no project stars, which hides every
/// star control.
///
/// A project star is the star on the project's lane, so starring a lane on
/// the task screen stars the project, and the other way round.
final class ProjectStarsProvider
    extends $AsyncNotifierProvider<ProjectStars, StarredProjects?> {
  /// The projects the reader starred on the active server: the copy last read
  /// at once, then the server's, and again whenever a project or a lane star
  /// changes. Null when the server keeps no project stars, which hides every
  /// star control.
  ///
  /// A project star is the star on the project's lane, so starring a lane on
  /// the task screen stars the project, and the other way round.
  ProjectStarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectStarsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectStarsHash();

  @$internal
  @override
  ProjectStars create() => ProjectStars();
}

String _$projectStarsHash() => r'53d5951dc373927f75cf8cfbaa770a97af9d7771';

/// The projects the reader starred on the active server: the copy last read
/// at once, then the server's, and again whenever a project or a lane star
/// changes. Null when the server keeps no project stars, which hides every
/// star control.
///
/// A project star is the star on the project's lane, so starring a lane on
/// the task screen stars the project, and the other way round.

abstract class _$ProjectStars extends $AsyncNotifier<StarredProjects?> {
  FutureOr<StarredProjects?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<StarredProjects?>, StarredProjects?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StarredProjects?>, StarredProjects?>,
              AsyncValue<StarredProjects?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
