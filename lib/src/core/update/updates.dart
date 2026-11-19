// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/update/play_updates.dart';
import 'package:tix_mobile/src/core/update/update_notice.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';
import 'package:tix_mobile/src/data/update/installer.dart';
import 'package:tix_mobile/src/data/update/platform_installers.dart';
import 'package:tix_mobile/src/data/update/play_feed.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';
import 'package:tix_mobile/src/data/update/signing_key.dart';
import 'package:tix_mobile/src/data/update/store_feed.dart';
import 'package:tix_mobile/src/data/update/updater.dart';

export 'package:tix_mobile/src/data/update/release_feed.dart'
    show UpdateErrorKind;
export 'package:tix_mobile/src/data/update/updater.dart'
    show Distribution, UpdateMode, UpdateOffer;

part 'updates.g.dart';

/// Whether this build may update itself. Store and package-manager builds
/// pass `--dart-define=TIX_SELF_UPDATE=false`.
const selfUpdateBuildFlag = bool.fromEnvironment(
  'TIX_SELF_UPDATE',
  defaultValue: true,
);

/// Where this Android build is published: `github` (the default), `fdroid`
/// or `play`. `just build-aab` passes `play`, the F-Droid recipe `fdroid`.
const distributionBuildFlag = String.fromEnvironment(
  'TIX_DISTRIBUTION',
  defaultValue: 'github',
);

/// Whether this is the Google Play build. A constant, so the Play channel
/// client is compiled out of every other build.
const playBuild = distributionBuildFlag == 'play';

/// How often the app looks for a newer release, running or, as far as the
/// phone lets it, in the background.
const updateCheckInterval = Duration(hours: 3);

/// The most a running app's next check is put off past
/// [updateCheckInterval], so that apps started together do not ask at once.
const updateCheckJitter = Duration(minutes: 20);

/// The process's architecture, as the release archives name it.
CpuArch currentArch() => switch (Abi.current()) {
  Abi.linuxX64 || Abi.windowsX64 || Abi.macosX64 => CpuArch.x64,
  Abi.linuxArm64 || Abi.windowsArm64 || Abi.macosArm64 => CpuArch.arm64,
  _ => CpuArch.other,
};

/// The desktop this runs on, null on a phone.
DesktopOs? currentDesktop() => Platform.isLinux
    ? DesktopOs.linux
    : Platform.isWindows
    ? DesktopOs.windows
    : Platform.isMacOS
    ? DesktopOs.macos
    : null;

/// What decides whether and how this build updates itself.
@Riverpod(keepAlive: true)
Future<UpdateEnvironment> updateEnvironment(Ref ref) async {
  final mobile = Platform.isAndroid || Platform.isIOS;
  final installer = mobile
      ? (await PackageInfo.fromPlatform()).installerStore
      : null;
  return UpdateEnvironment(
    // Only redundant in builds that keep the default; Play, F-Droid and
    // Flatpak pass TIX_SELF_UPDATE=false.
    // ignore: avoid_redundant_argument_values
    buildAllows: selfUpdateBuildFlag,
    desktop: currentDesktop(),
    arch: currentArch(),
    android: Platform.isAndroid,
    ios: Platform.isIOS,
    flatpak: Platform.isLinux && File('/.flatpak-info').existsSync(),
    snap: Platform.environment.containsKey('SNAP'),
    releaseBuild: kReleaseMode,
    androidInstaller: Platform.isAndroid ? installer : null,
    appleInstaller: Platform.isIOS ? installer : null,
    distribution: Distribution.parse(distributionBuildFlag),
  );
}

/// Where releases come from.
@Riverpod(keepAlive: true)
ReleaseFeed releaseFeed(Ref ref) => GitHubReleaseFeed();

/// What the App Store serves, in the device's storefront.
@Riverpod(keepAlive: true)
ReleaseFeed storeFeed(Ref ref) =>
    AppStoreReleaseFeed(country: storefrontOf(Platform.localeName));

/// Google Play's in-app updates; never there outside the Play build.
@Riverpod(keepAlive: true)
PlayUpdates playUpdates(Ref ref) =>
    playBuild ? const ChannelPlayUpdates() : const NoPlayUpdates();

/// Which store sends updates in the `store` mode.
enum UpdateStore {
  /// Apple's App Store, on iOS.
  appStore,

  /// Google Play, on Android.
  play,
}

/// The store this build updates from, null outside the `store` mode.
@Riverpod(keepAlive: true)
Future<UpdateStore?> updateStore(Ref ref) async {
  final mode = await ref.watch(updateModeProvider.future);
  if (mode != UpdateMode.store) return null;
  final env = await ref.watch(updateEnvironmentProvider.future);
  return env.android ? UpdateStore.play : UpdateStore.appStore;
}

/// The platform half of installing an update.
@Riverpod(keepAlive: true)
UpdateInstaller updateInstaller(Ref ref) =>
    platformInstaller(executable: Platform.resolvedExecutable, processId: pid);

/// How far this app goes with a newer release.
@Riverpod(keepAlive: true)
Future<UpdateMode> updateMode(Ref ref) async {
  final env = await ref.watch(updateEnvironmentProvider.future);
  final desktop = env.buildAllows && env.desktop != null;
  final target = desktop && !env.flatpak && !env.snap
      ? await ref.watch(updateInstallerProvider).target()
      : null;
  return updateModeFor(env, target: target);
}

/// Finds, verifies and stages updates for this build.
@Riverpod(keepAlive: true)
Future<Updater> updater(Ref ref) async {
  final env = await ref.watch(updateEnvironmentProvider.future);
  final app = await ref.watch(appInfoProvider.future);
  final feed = switch (await ref.watch(updateStoreProvider.future)) {
    UpdateStore.play => PlayReleaseFeed(ref.watch(playUpdatesProvider)),
    UpdateStore.appStore => ref.watch(storeFeedProvider),
    null => ref.watch(releaseFeedProvider),
  };
  return Updater(
    feed: feed,
    installer: ref.watch(updateInstallerProvider),
    current:
        ReleaseVersion.tryParse(app.version) ?? const ReleaseVersion(0, 0, 0),
    publicKey: updateSigningPublicKey,
    os: env.desktop,
    arch: env.arch,
  );
}

/// Android's periodic background check, which runs while the app is closed.
abstract interface class BackgroundUpdateChecks {
  /// Schedules the background check, or cancels it.
  Future<void> set({required bool on});
}

/// [BackgroundUpdateChecks] over WorkManager, through `MainActivity`.
class AndroidBackgroundUpdateChecks implements BackgroundUpdateChecks {
  static const _channel = MethodChannel('tix/update');

  @override
  Future<void> set({required bool on}) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('background', on);
    } on PlatformException catch (e) {
      log('update: background checks not set: ${e.code}');
    } on MissingPluginException {
      return;
    }
  }
}

/// The background check; iOS needs none of its own, as its widget refresh
/// looks for updates too.
@Riverpod(keepAlive: true)
BackgroundUpdateChecks backgroundUpdateChecks(Ref ref) =>
    AndroidBackgroundUpdateChecks();

SettingsRepository _settings(Ref ref) =>
    SettingsRepository(ref.watch(keyValueStoreProvider));

/// Whether the app looks for updates on its own; on until turned off.
@Riverpod(keepAlive: true)
class UpdateCheckSetting extends _$UpdateCheckSetting {
  @override
  bool build() => _settings(ref).updateCheck();

  /// Turns the automatic check on or off and remembers it.
  Future<void> set({required bool on}) async {
    state = on;
    await _settings(ref).setUpdateCheck(on: on);
  }
}

/// Whether a downloaded update is installed when the app quits; off until
/// turned on.
@Riverpod(keepAlive: true)
class AutoInstallSetting extends _$AutoInstallSetting {
  @override
  bool build() => _settings(ref).updateAutoInstall();

  /// Turns installing on quit on or off and remembers it.
  Future<void> set({required bool on}) async {
    state = on;
    await _settings(ref).setUpdateAutoInstall(on: on);
  }
}

/// Where an update stands.
enum UpdatePhase {
  /// Not checked yet, or updates are off.
  idle,

  /// Asking GitHub.
  checking,

  /// The running version is the latest.
  current,

  /// A newer release exists; it is offered as a download.
  available,

  /// The newer release is being downloaded and verified.
  downloading,

  /// The newer release is staged and installs on restart.
  ready,

  /// The last step failed; [UpdateState.error] says which.
  failed,
}

/// The update controller's state.
@immutable
class UpdateState {
  /// In [phase], about [offer].
  const UpdateState({
    this.phase = UpdatePhase.idle,
    this.offer,
    this.progress,
    this.error,
    this.staged,
  });

  /// Where it stands.
  final UpdatePhase phase;

  /// The newer release, when one is known.
  final UpdateOffer? offer;

  /// The share downloaded, while downloading.
  final double? progress;

  /// Why it failed, or why an available update is only a download.
  final UpdateErrorKind? error;

  /// The update waiting for a restart.
  final StagedUpdate? staged;

  @override
  bool operator ==(Object other) =>
      other is UpdateState &&
      other.phase == phase &&
      other.offer?.version == offer?.version &&
      other.progress == progress &&
      other.error == error &&
      other.staged?.path == staged?.path;

  @override
  int get hashCode =>
      Object.hash(phase, offer?.version, progress, error, staged?.path);
}

/// Looks for newer releases, downloads and stages them where the app can
/// install itself, and installs on restart or on quit.
@Riverpod(keepAlive: true)
class Updates extends _$Updates {
  Timer? _timer;
  bool _busy = false;
  Future<void>? _cleaning;

  final _random = Random();

  @override
  UpdateState build() {
    final async = ref.watch(updateModeProvider);
    final mode = async.value ?? UpdateMode.off;
    ref.onDispose(() => _timer?.cancel());
    if (mode == UpdateMode.off) {
      if (async.hasValue) unawaited(_background(on: false));
      return const UpdateState();
    }
    if (mode == UpdateMode.install) _cleaning ??= _cleanup();
    ref.listen(updateCheckSettingProvider, (_, on) {
      _timer?.cancel();
      _timer = null;
      unawaited(_background(on: on));
      if (!on) return;
      _schedule();
      unawaited(Future<void>.microtask(_auto));
    }, fireImmediately: true);
    return stateOrNull ?? const UpdateState();
  }

  Future<void> _background({required bool on}) =>
      ref.read(backgroundUpdateChecksProvider).set(on: on);

  void _schedule() {
    final jitter = _random.nextInt(updateCheckJitter.inSeconds + 1);
    _timer = Timer(updateCheckInterval + Duration(seconds: jitter), () {
      _schedule();
      unawaited(_auto());
    });
  }

  Future<void> _auto() async {
    final settings = _settings(ref);
    await settings.setUpdateLastCheck(ref.read(clockProvider)());
    await _check(notify: true);
  }

  Future<void> _notify() async {
    final mode = ref.read(updateModeProvider).value ?? UpdateMode.off;
    final kind = updateNoteKind(
      mode,
      state,
      autoInstall: ref.read(autoInstallSettingProvider),
      store: ref.read(updateStoreProvider).value,
    );
    final version = state.offer?.version.toString();
    if (kind == null || version == null) return;
    final store = ref.read(keyValueStoreProvider);
    await notifyUpdateOnce(
      notes: ref.read(localNotesProvider),
      settings: SettingsRepository(store),
      version: version,
      note: updateNote(storedL10n(store), version, kind),
    );
  }

  Future<void> _cleanup() async {
    try {
      await ref.read(updateInstallerProvider).cleanup();
    } on FileSystemException catch (e) {
      log('update: leftovers stay: ${e.message}');
    }
  }

  /// Asks for the latest release now, and downloads it where the app
  /// installs itself. Does nothing while a download runs or one is staged.
  Future<void> check() => _check(notify: false);

  Future<void> _check({required bool notify}) async {
    final mode = ref.read(updateModeProvider).value ?? UpdateMode.off;
    if (_busy || mode == UpdateMode.off) return;
    if (state.phase case UpdatePhase.downloading || UpdatePhase.ready) return;
    _busy = true;
    state = UpdateState(phase: UpdatePhase.checking, offer: state.offer);
    try {
      final updater = await ref.read(updaterProvider.future);
      final offer = await updater.check();
      if (!ref.mounted) return;
      if (offer == null) {
        state = const UpdateState(phase: UpdatePhase.current);
      } else if (mode == UpdateMode.install && offer.asset != null) {
        await _download(updater, offer);
      } else {
        state = UpdateState(
          phase: UpdatePhase.available,
          offer: offer,
          error: mode == UpdateMode.install ? UpdateErrorKind.noAsset : null,
        );
      }
      if (notify && ref.mounted) await _notify();
    } on UpdateException catch (e) {
      log('update: $e');
      if (ref.mounted) {
        state = UpdateState(
          phase: UpdatePhase.failed,
          offer: state.offer,
          error: e.kind,
        );
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _download(Updater updater, UpdateOffer offer) async {
    await _cleaning;
    state = UpdateState(
      phase: UpdatePhase.downloading,
      offer: offer,
      progress: 0,
    );
    final staged = await updater.download(
      offer,
      onProgress: (p) {
        if (ref.mounted) {
          state = UpdateState(
            phase: UpdatePhase.downloading,
            offer: offer,
            progress: p,
          );
        }
      },
    );
    if (!ref.mounted) return;
    state = UpdateState(phase: UpdatePhase.ready, offer: offer, staged: staged);
  }

  /// Sends the person to the store to update, in the `store` mode: Google
  /// Play's flexible in-app update where Play allows one, else the Play
  /// listing; the App Store page on iOS. False when nothing opened.
  Future<bool> openStore() async {
    final store = await ref.read(updateStoreProvider.future);
    final links = ref.read(attachmentsProvider);
    switch (store) {
      case UpdateStore.play:
        final started = await ref.read(playUpdatesProvider).start();
        return started != PlayStart.none || await links.openLink(playListing);
      case UpdateStore.appStore:
        return await links.openLink(state.offer?.page ?? appStorePage);
      case null:
        return false;
    }
  }

  /// Installs the staged update, starts the new version and quits. False
  /// when nothing is staged or the install failed.
  Future<bool> restart() async {
    if (!await _apply(relaunch: true)) return false;
    await ref.read(desktopShellProvider).quit();
    return true;
  }

  /// Installs the staged update without restarting, when installing on
  /// quit is on. Call right before the app quits.
  Future<void> installOnQuit() async {
    if (ref.read(autoInstallSettingProvider)) await _apply(relaunch: false);
  }

  Future<bool> _apply({required bool relaunch}) async {
    final staged = state.staged;
    if (staged == null) return false;
    try {
      final updater = await ref.read(updaterProvider.future);
      await updater.apply(staged, relaunch: relaunch);
      return true;
    } on UpdateException catch (e) {
      log('update: $e');
      if (ref.mounted) {
        state = UpdateState(
          phase: UpdatePhase.failed,
          offer: state.offer,
          error: e.kind,
        );
      }
      return false;
    }
  }
}
