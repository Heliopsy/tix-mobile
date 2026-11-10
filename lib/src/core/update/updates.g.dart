// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'updates.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What decides whether and how this build updates itself.

@ProviderFor(updateEnvironment)
final updateEnvironmentProvider = UpdateEnvironmentProvider._();

/// What decides whether and how this build updates itself.

final class UpdateEnvironmentProvider
    extends
        $FunctionalProvider<
          AsyncValue<UpdateEnvironment>,
          UpdateEnvironment,
          FutureOr<UpdateEnvironment>
        >
    with
        $FutureModifier<UpdateEnvironment>,
        $FutureProvider<UpdateEnvironment> {
  /// What decides whether and how this build updates itself.
  UpdateEnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateEnvironmentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateEnvironmentHash();

  @$internal
  @override
  $FutureProviderElement<UpdateEnvironment> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateEnvironment> create(Ref ref) {
    return updateEnvironment(ref);
  }
}

String _$updateEnvironmentHash() => r'6a3afafee4ae0ec7d699272f99e030cb9091781a';

/// Where releases come from.

@ProviderFor(releaseFeed)
final releaseFeedProvider = ReleaseFeedProvider._();

/// Where releases come from.

final class ReleaseFeedProvider
    extends $FunctionalProvider<ReleaseFeed, ReleaseFeed, ReleaseFeed>
    with $Provider<ReleaseFeed> {
  /// Where releases come from.
  ReleaseFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'releaseFeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$releaseFeedHash();

  @$internal
  @override
  $ProviderElement<ReleaseFeed> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReleaseFeed create(Ref ref) {
    return releaseFeed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReleaseFeed value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReleaseFeed>(value),
    );
  }
}

String _$releaseFeedHash() => r'a65318c7c5fd1c4967473bc61fe45a086095a5a9';

/// The platform half of installing an update.

@ProviderFor(updateInstaller)
final updateInstallerProvider = UpdateInstallerProvider._();

/// The platform half of installing an update.

final class UpdateInstallerProvider
    extends
        $FunctionalProvider<UpdateInstaller, UpdateInstaller, UpdateInstaller>
    with $Provider<UpdateInstaller> {
  /// The platform half of installing an update.
  UpdateInstallerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateInstallerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateInstallerHash();

  @$internal
  @override
  $ProviderElement<UpdateInstaller> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateInstaller create(Ref ref) {
    return updateInstaller(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateInstaller value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateInstaller>(value),
    );
  }
}

String _$updateInstallerHash() => r'096bc16bbba9be66390041c68d913a222f2210d1';

/// How far this app goes with a newer release.

@ProviderFor(updateMode)
final updateModeProvider = UpdateModeProvider._();

/// How far this app goes with a newer release.

final class UpdateModeProvider
    extends
        $FunctionalProvider<
          AsyncValue<UpdateMode>,
          UpdateMode,
          FutureOr<UpdateMode>
        >
    with $FutureModifier<UpdateMode>, $FutureProvider<UpdateMode> {
  /// How far this app goes with a newer release.
  UpdateModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateModeHash();

  @$internal
  @override
  $FutureProviderElement<UpdateMode> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateMode> create(Ref ref) {
    return updateMode(ref);
  }
}

String _$updateModeHash() => r'9f75f7ca7d40a4e963efc2b93c2f6886528abbd9';

/// Finds, verifies and stages updates for this build.

@ProviderFor(updater)
final updaterProvider = UpdaterProvider._();

/// Finds, verifies and stages updates for this build.

final class UpdaterProvider
    extends $FunctionalProvider<AsyncValue<Updater>, Updater, FutureOr<Updater>>
    with $FutureModifier<Updater>, $FutureProvider<Updater> {
  /// Finds, verifies and stages updates for this build.
  UpdaterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updaterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updaterHash();

  @$internal
  @override
  $FutureProviderElement<Updater> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Updater> create(Ref ref) {
    return updater(ref);
  }
}

String _$updaterHash() => r'c58f9e698c4a6f7ed733052291d91fbac5a628e2';

/// Whether the app looks for updates on its own; on until turned off.

@ProviderFor(UpdateCheckSetting)
final updateCheckSettingProvider = UpdateCheckSettingProvider._();

/// Whether the app looks for updates on its own; on until turned off.
final class UpdateCheckSettingProvider
    extends $NotifierProvider<UpdateCheckSetting, bool> {
  /// Whether the app looks for updates on its own; on until turned off.
  UpdateCheckSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCheckSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCheckSettingHash();

  @$internal
  @override
  UpdateCheckSetting create() => UpdateCheckSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$updateCheckSettingHash() =>
    r'f7155bb436dca8567d74028f39bfad6a87b2f537';

/// Whether the app looks for updates on its own; on until turned off.

abstract class _$UpdateCheckSetting extends $Notifier<bool> {
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

/// Whether a downloaded update is installed when the app quits; off until
/// turned on.

@ProviderFor(AutoInstallSetting)
final autoInstallSettingProvider = AutoInstallSettingProvider._();

/// Whether a downloaded update is installed when the app quits; off until
/// turned on.
final class AutoInstallSettingProvider
    extends $NotifierProvider<AutoInstallSetting, bool> {
  /// Whether a downloaded update is installed when the app quits; off until
  /// turned on.
  AutoInstallSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoInstallSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoInstallSettingHash();

  @$internal
  @override
  AutoInstallSetting create() => AutoInstallSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$autoInstallSettingHash() =>
    r'67673f89c980e74860862e892ffa04acbe52658f';

/// Whether a downloaded update is installed when the app quits; off until
/// turned on.

abstract class _$AutoInstallSetting extends $Notifier<bool> {
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

/// Looks for newer releases, downloads and stages them where the app can
/// install itself, and installs on restart or on quit.

@ProviderFor(Updates)
final updatesProvider = UpdatesProvider._();

/// Looks for newer releases, downloads and stages them where the app can
/// install itself, and installs on restart or on quit.
final class UpdatesProvider extends $NotifierProvider<Updates, UpdateState> {
  /// Looks for newer releases, downloads and stages them where the app can
  /// install itself, and installs on restart or on quit.
  UpdatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatesHash();

  @$internal
  @override
  Updates create() => Updates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateState>(value),
    );
  }
}

String _$updatesHash() => r'3ff29154eb088c0e313c9ecd1cfbb100016cca05';

/// Looks for newer releases, downloads and stages them where the app can
/// install itself, and installs on restart or on quit.

abstract class _$Updates extends $Notifier<UpdateState> {
  UpdateState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UpdateState, UpdateState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdateState, UpdateState>,
              UpdateState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
