// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';
import 'package:tix_mobile/src/data/update/installer.dart';
import 'package:tix_mobile/src/data/update/platform_installers.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';
import 'package:tix_mobile/src/data/update/signing_key.dart';
import 'package:tix_mobile/src/data/update/updater.dart';

export 'package:tix_mobile/src/data/update/release_feed.dart'
    show UpdateErrorKind;
export 'package:tix_mobile/src/data/update/updater.dart'
    show UpdateMode, UpdateOffer;

part 'updates.g.dart';

/// Whether this build may update itself. Store and package-manager builds
/// pass `--dart-define=TIX_SELF_UPDATE=false`.
const selfUpdateBuildFlag = bool.fromEnvironment(
  'TIX_SELF_UPDATE',
  defaultValue: true,
);

/// How often a running app looks for a newer release.
const updateCheckInterval = Duration(hours: 6);

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
  if (!selfUpdateBuildFlag) return const UpdateEnvironment(buildAllows: false);
  return UpdateEnvironment(
    desktop: currentDesktop(),
    arch: currentArch(),
    android: Platform.isAndroid,
    flatpak: Platform.isLinux && File('/.flatpak-info').existsSync(),
    snap: Platform.environment.containsKey('SNAP'),
    releaseBuild: kReleaseMode,
    keyPinned: updateSigningPublicKey.isNotEmpty,
    androidInstaller: Platform.isAndroid
        ? (await PackageInfo.fromPlatform()).installerStore
        : null,
  );
}

/// Where releases come from.
@Riverpod(keepAlive: true)
ReleaseFeed releaseFeed(Ref ref) => GitHubReleaseFeed();

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
  return Updater(
    feed: ref.watch(releaseFeedProvider),
    installer: ref.watch(updateInstallerProvider),
    current:
        ReleaseVersion.tryParse(app.version) ?? const ReleaseVersion(0, 0, 0),
    publicKey: updateSigningPublicKey,
    os: env.desktop,
    arch: env.arch,
  );
}

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

  @override
  UpdateState build() {
    final mode = ref.watch(updateModeProvider).value ?? UpdateMode.off;
    ref.onDispose(() => _timer?.cancel());
    if (mode == UpdateMode.off) return const UpdateState();
    if (mode == UpdateMode.install) _cleaning ??= _cleanup();
    ref.listen(updateCheckSettingProvider, (_, on) {
      _timer?.cancel();
      _timer = null;
      if (!on) return;
      _timer = Timer.periodic(updateCheckInterval, (_) => unawaited(check()));
      unawaited(Future<void>.microtask(check));
    }, fireImmediately: true);
    return stateOrNull ?? const UpdateState();
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
  Future<void> check() async {
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
