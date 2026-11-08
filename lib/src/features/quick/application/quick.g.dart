// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'quick.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active context as a stable key, or null when none is. Like the
/// response cache, only a switchable sign-in names its tenant, so a
/// background `whoami` filling in the tenant does not look like a switch.

@ProviderFor(quickContext)
final quickContextProvider = QuickContextProvider._();

/// The active context as a stable key, or null when none is. Like the
/// response cache, only a switchable sign-in names its tenant, so a
/// background `whoami` filling in the tenant does not look like a switch.

final class QuickContextProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The active context as a stable key, or null when none is. Like the
  /// response cache, only a switchable sign-in names its tenant, so a
  /// background `whoami` filling in the tenant does not look like a switch.
  QuickContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickContextProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickContextHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return quickContext(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$quickContextHash() => r'b9b3673b22cc38e225b8b4d0cc518ecd35827d52';

/// Every project, for the picker and `+` completions.

@ProviderFor(quickProjects)
final quickProjectsProvider = QuickProjectsProvider._();

/// Every project, for the picker and `+` completions.

final class QuickProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          FutureOr<List<Project>>
        >
    with $FutureModifier<List<Project>>, $FutureProvider<List<Project>> {
  /// Every project, for the picker and `+` completions.
  QuickProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickProjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Project>> create(Ref ref) {
    return quickProjects(ref);
  }
}

String _$quickProjectsHash() => r'12ee3a6676c47d62ce4f57c84b5cfdac05ffa9af';

/// Every tag, for `#` completions.

@ProviderFor(quickTags)
final quickTagsProvider = QuickTagsProvider._();

/// Every tag, for `#` completions.

final class QuickTagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Every tag, for `#` completions.
  QuickTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickTagsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return quickTags(ref);
  }
}

String _$quickTagsHash() => r'8b57c9641314826d7145d50d4e17d18f2c0c3b57';

/// Every actor, for `@` completions.

@ProviderFor(quickActors)
final quickActorsProvider = QuickActorsProvider._();

/// Every actor, for `@` completions.

final class QuickActorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Actor>>,
          List<Actor>,
          FutureOr<List<Actor>>
        >
    with $FutureModifier<List<Actor>>, $FutureProvider<List<Actor>> {
  /// Every actor, for `@` completions.
  QuickActorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickActorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickActorsHash();

  @$internal
  @override
  $FutureProviderElement<List<Actor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Actor>> create(Ref ref) {
    return quickActors(ref);
  }
}

String _$quickActorsHash() => r'd55e325d799a52efb98fe489dca3f2d440e68230';

/// The most used templates, for one-tap use from quick add.

@ProviderFor(quickTemplates)
final quickTemplatesProvider = QuickTemplatesProvider._();

/// The most used templates, for one-tap use from quick add.

final class QuickTemplatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskTemplate>>,
          List<TaskTemplate>,
          FutureOr<List<TaskTemplate>>
        >
    with
        $FutureModifier<List<TaskTemplate>>,
        $FutureProvider<List<TaskTemplate>> {
  /// The most used templates, for one-tap use from quick add.
  QuickTemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickTemplatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickTemplatesHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskTemplate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskTemplate>> create(Ref ref) {
    return quickTemplates(ref);
  }
}

String _$quickTemplatesHash() => r'aabac0b1cfadfae88c2fd2607812ac7ab8b1f89d';

/// The recent values of the active context, kept in preferences. Only
/// identifiers are kept: keys, tag names and handles.

@ProviderFor(RecentQuickValues)
final recentQuickValuesProvider = RecentQuickValuesProvider._();

/// The recent values of the active context, kept in preferences. Only
/// identifiers are kept: keys, tag names and handles.
final class RecentQuickValuesProvider
    extends $NotifierProvider<RecentQuickValues, RecentValues> {
  /// The recent values of the active context, kept in preferences. Only
  /// identifiers are kept: keys, tag names and handles.
  RecentQuickValuesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentQuickValuesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentQuickValuesHash();

  @$internal
  @override
  RecentQuickValues create() => RecentQuickValues();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecentValues value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecentValues>(value),
    );
  }
}

String _$recentQuickValuesHash() => r'bfa7d102dd79fa6fe9a361514a231eba98cc8a66';

/// The recent values of the active context, kept in preferences. Only
/// identifiers are kept: keys, tag names and handles.

abstract class _$RecentQuickValues extends $Notifier<RecentValues> {
  RecentValues build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RecentValues, RecentValues>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecentValues, RecentValues>,
              RecentValues,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether quick add stays open after adding, for the next line.

@ProviderFor(AddAnother)
final addAnotherProvider = AddAnotherProvider._();

/// Whether quick add stays open after adding, for the next line.
final class AddAnotherProvider extends $NotifierProvider<AddAnother, bool> {
  /// Whether quick add stays open after adding, for the next line.
  AddAnotherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addAnotherProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addAnotherHash();

  @$internal
  @override
  AddAnother create() => AddAnother();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$addAnotherHash() => r'3a14c194584692da32cf34d4f67f08f9562b2d74';

/// Whether quick add stays open after adding, for the next line.

abstract class _$AddAnother extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How long the preview waits after the last keystroke.

@ProviderFor(previewDebounce)
final previewDebounceProvider = PreviewDebounceProvider._();

/// How long the preview waits after the last keystroke.

final class PreviewDebounceProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long the preview waits after the last keystroke.
  PreviewDebounceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewDebounceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewDebounceHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return previewDebounce(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$previewDebounceHash() => r'99332a7c580b8dd8e391a966ff603af517e9d2f7';

/// Whether the server refused the preview in this context, which it does
/// for a credential without the `import` scope.

@ProviderFor(PreviewBlocked)
final previewBlockedProvider = PreviewBlockedProvider._();

/// Whether the server refused the preview in this context, which it does
/// for a credential without the `import` scope.
final class PreviewBlockedProvider
    extends $NotifierProvider<PreviewBlocked, bool> {
  /// Whether the server refused the preview in this context, which it does
  /// for a credential without the `import` scope.
  PreviewBlockedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewBlockedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewBlockedHash();

  @$internal
  @override
  PreviewBlocked create() => PreviewBlocked();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$previewBlockedHash() => r'4613e4827e5b17f5fc824236e3038b19f3fb0032';

/// Whether the server refused the preview in this context, which it does
/// for a credential without the `import` scope.

abstract class _$PreviewBlocked extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// What the server makes of the line typed so far: a dry run of tix's
/// import, sent once typing pauses. Only the newest answer is kept.

@ProviderFor(QuickPreviewer)
final quickPreviewerProvider = QuickPreviewerProvider._();

/// What the server makes of the line typed so far: a dry run of tix's
/// import, sent once typing pauses. Only the newest answer is kept.
final class QuickPreviewerProvider
    extends $NotifierProvider<QuickPreviewer, AsyncValue<QuickPreview?>> {
  /// What the server makes of the line typed so far: a dry run of tix's
  /// import, sent once typing pauses. Only the newest answer is kept.
  QuickPreviewerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickPreviewerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickPreviewerHash();

  @$internal
  @override
  QuickPreviewer create() => QuickPreviewer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<QuickPreview?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<QuickPreview?>>(value),
    );
  }
}

String _$quickPreviewerHash() => r'7067584f52e368c4356bd3a7cc9fe2ec79dc5c71';

/// What the server makes of the line typed so far: a dry run of tix's
/// import, sent once typing pauses. Only the newest answer is kept.

abstract class _$QuickPreviewer extends $Notifier<AsyncValue<QuickPreview?>> {
  AsyncValue<QuickPreview?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<QuickPreview?>, AsyncValue<QuickPreview?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuickPreview?>, AsyncValue<QuickPreview?>>,
              AsyncValue<QuickPreview?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Adds tasks from quick add and from templates. The sheet and the host
/// watch it, which keeps it alive across a request.

@ProviderFor(QuickAdder)
final quickAdderProvider = QuickAdderProvider._();

/// Adds tasks from quick add and from templates. The sheet and the host
/// watch it, which keeps it alive across a request.
final class QuickAdderProvider extends $NotifierProvider<QuickAdder, void> {
  /// Adds tasks from quick add and from templates. The sheet and the host
  /// watch it, which keeps it alive across a request.
  QuickAdderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickAdderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickAdderHash();

  @$internal
  @override
  QuickAdder create() => QuickAdder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$quickAdderHash() => r'de53993c317fa78148ec3c052980da65a97edae4';

/// Adds tasks from quick add and from templates. The sheet and the host
/// watch it, which keeps it alive across a request.

abstract class _$QuickAdder extends $Notifier<void> {
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

/// Tasks opened in this session, newest first, kept in memory while the
/// quick-action host, which watches it, is mounted.

@ProviderFor(RecentTasks)
final recentTasksProvider = RecentTasksProvider._();

/// Tasks opened in this session, newest first, kept in memory while the
/// quick-action host, which watches it, is mounted.
final class RecentTasksProvider
    extends $NotifierProvider<RecentTasks, List<RecentTask>> {
  /// Tasks opened in this session, newest first, kept in memory while the
  /// quick-action host, which watches it, is mounted.
  RecentTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentTasksHash();

  @$internal
  @override
  RecentTasks create() => RecentTasks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RecentTask> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RecentTask>>(value),
    );
  }
}

String _$recentTasksHash() => r'1da6bb6ba06084958068dd202d4f35e4e1245ad0';

/// Tasks opened in this session, newest first, kept in memory while the
/// quick-action host, which watches it, is mounted.

abstract class _$RecentTasks extends $Notifier<List<RecentTask>> {
  List<RecentTask> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<RecentTask>, List<RecentTask>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<RecentTask>, List<RecentTask>>,
              List<RecentTask>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
