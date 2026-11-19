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

String _$updateEnvironmentHash() => r'06aa362b30815b11bd5d647674c6755b02c4f314';

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

/// What the App Store serves, in the device's storefront.

@ProviderFor(storeFeed)
final storeFeedProvider = StoreFeedProvider._();

/// What the App Store serves, in the device's storefront.

final class StoreFeedProvider
    extends $FunctionalProvider<ReleaseFeed, ReleaseFeed, ReleaseFeed>
    with $Provider<ReleaseFeed> {
  /// What the App Store serves, in the device's storefront.
  StoreFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeFeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeFeedHash();

  @$internal
  @override
  $ProviderElement<ReleaseFeed> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReleaseFeed create(Ref ref) {
    return storeFeed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReleaseFeed value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReleaseFeed>(value),
    );
  }
}

String _$storeFeedHash() => r'2d06c7204dadfecf0cb450bf45ecfbb971cb46fa';

/// Google Play's in-app updates; never there outside the Play build.

@ProviderFor(playUpdates)
final playUpdatesProvider = PlayUpdatesProvider._();

/// Google Play's in-app updates; never there outside the Play build.

final class PlayUpdatesProvider
    extends $FunctionalProvider<PlayUpdates, PlayUpdates, PlayUpdates>
    with $Provider<PlayUpdates> {
  /// Google Play's in-app updates; never there outside the Play build.
  PlayUpdatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playUpdatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playUpdatesHash();

  @$internal
  @override
  $ProviderElement<PlayUpdates> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlayUpdates create(Ref ref) {
    return playUpdates(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayUpdates value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayUpdates>(value),
    );
  }
}

String _$playUpdatesHash() => r'ae44598d675112fbecf7e9e750d95fa7a289d441';

/// The store this build updates from, null outside the `store` mode.

@ProviderFor(updateStore)
final updateStoreProvider = UpdateStoreProvider._();

/// The store this build updates from, null outside the `store` mode.

final class UpdateStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<UpdateStore?>,
          UpdateStore?,
          FutureOr<UpdateStore?>
        >
    with $FutureModifier<UpdateStore?>, $FutureProvider<UpdateStore?> {
  /// The store this build updates from, null outside the `store` mode.
  UpdateStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateStoreHash();

  @$internal
  @override
  $FutureProviderElement<UpdateStore?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateStore?> create(Ref ref) {
    return updateStore(ref);
  }
}

String _$updateStoreHash() => r'f06417cd84bed521023b730628bb608fa1c24bc4';

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

String _$updaterHash() => r'b06e203b3f4e07862dabb0f77e38243ca51d0fef';

/// The background check; iOS needs none of its own, as its widget refresh
/// looks for updates too.

@ProviderFor(backgroundUpdateChecks)
final backgroundUpdateChecksProvider = BackgroundUpdateChecksProvider._();

/// The background check; iOS needs none of its own, as its widget refresh
/// looks for updates too.

final class BackgroundUpdateChecksProvider
    extends
        $FunctionalProvider<
          BackgroundUpdateChecks,
          BackgroundUpdateChecks,
          BackgroundUpdateChecks
        >
    with $Provider<BackgroundUpdateChecks> {
  /// The background check; iOS needs none of its own, as its widget refresh
  /// looks for updates too.
  BackgroundUpdateChecksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundUpdateChecksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundUpdateChecksHash();

  @$internal
  @override
  $ProviderElement<BackgroundUpdateChecks> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackgroundUpdateChecks create(Ref ref) {
    return backgroundUpdateChecks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundUpdateChecks value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundUpdateChecks>(value),
    );
  }
}

String _$backgroundUpdateChecksHash() =>
    r'7066cdbdccc747cefcd8124899597df92ae4d418';

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

String _$updatesHash() => r'38ec23973498680c3a9dc8ade7e97f0f79e2f249';

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
