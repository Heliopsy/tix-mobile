// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/update/installer.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';
import 'package:tix_mobile/src/data/update/verify.dart';

/// How far the app goes with a newer release.
enum UpdateMode {
  /// Never checks: a store, Flatpak, iOS or a build that turned it off.
  off,

  /// Checks and shows it with a link to the release page.
  notify,

  /// Checks, downloads, verifies and installs on restart.
  install,
}

/// What decides [UpdateMode], gathered once at start.
@immutable
class UpdateEnvironment {
  /// The facts about this build and where it runs.
  const UpdateEnvironment({
    this.desktop,
    this.arch = CpuArch.other,
    this.android = false,
    this.buildAllows = true,
    this.flatpak = false,
    this.snap = false,
    this.releaseBuild = true,
    this.keyPinned = true,
    this.androidInstaller,
  });

  /// The desktop this runs on, null on a phone.
  final DesktopOs? desktop;

  /// The process's architecture.
  final CpuArch arch;

  /// Whether this is Android.
  final bool android;

  /// Whether the build left self-update on (`TIX_SELF_UPDATE`).
  final bool buildAllows;

  /// Whether this runs inside Flatpak.
  final bool flatpak;

  /// Whether this runs as a Snap.
  final bool snap;

  /// Whether this is a release build rather than `flutter run`.
  final bool releaseBuild;

  /// Whether an update signing key is built in.
  final bool keyPinned;

  /// The package that installed the app on Android, null when unknown.
  final String? androidInstaller;
}

/// The installers that mean an APK came from the GitHub release: none
/// (adb) or the system package installer. Play, F-Droid and other stores
/// name themselves.
const sideloadInstallers = {
  'com.android.packageinstaller',
  'com.google.android.packageinstaller',
};

/// What the app does about updates in [env], with the install at [target].
UpdateMode updateModeFor(UpdateEnvironment env, {InstallTarget? target}) {
  if (!env.buildAllows) return UpdateMode.off;
  if (env.android) {
    final installer = env.androidInstaller;
    return installer == null || sideloadInstallers.contains(installer)
        ? UpdateMode.notify
        : UpdateMode.off;
  }
  if (env.desktop == null || env.flatpak || env.snap) return UpdateMode.off;
  final installs =
      env.releaseBuild && env.keyPinned && (target?.writable ?? false);
  return installs ? UpdateMode.install : UpdateMode.notify;
}

/// A release newer than the running app.
@immutable
class UpdateOffer {
  /// [release], installable from [asset] when there is one for this system.
  const UpdateOffer({required this.release, this.asset});

  /// The release.
  final Release release;

  /// The archive for this system, null when there is none.
  final ReleaseAsset? asset;

  /// Its version.
  ReleaseVersion get version => release.version;

  /// Its release page, with the notes and every download.
  Uri get page => release.page;
}

/// Finds, verifies and stages updates. Everything but unpacking and the
/// swap, which [installer] does.
class Updater {
  /// Updates [current] from [feed] through [installer], on [os] and [arch],
  /// trusting [publicKey].
  Updater({
    required this.feed,
    required this.installer,
    required this.current,
    required this.publicKey,
    this.os,
    this.arch = CpuArch.other,
  });

  /// Where releases come from.
  final ReleaseFeed feed;

  /// The platform half.
  final UpdateInstaller installer;

  /// The running version.
  final ReleaseVersion current;

  /// The pinned Ed25519 key, base64; empty for none.
  final String publicKey;

  /// The desktop, null on a phone.
  final DesktopOs? os;

  /// The process's architecture.
  final CpuArch arch;

  /// The latest release when it is newer than [current], else null. Drafts
  /// and prereleases never count.
  Future<UpdateOffer?> check() async {
    final release = await feed.latest();
    if (release == null || release.draft || release.prerelease) return null;
    if (!release.version.isNewerThan(current)) return null;
    final os = this.os;
    return UpdateOffer(
      release: release,
      asset: os == null ? null : chooseDesktopAsset(release, os, arch),
    );
  }

  /// Checks the signature of the release's checksums, downloads [offer]'s
  /// archive, checks its hash and stages it. Nothing large is fetched
  /// before the signature holds.
  Future<StagedUpdate> download(
    UpdateOffer offer, {
    void Function(double progress)? onProgress,
  }) async {
    final asset = offer.asset;
    if (asset == null) throw const UpdateException(UpdateErrorKind.noAsset);
    final expected = await _signedChecksum(offer.release, asset.name);
    final dir = await Directory.systemTemp.createTemp('tix-update-');
    try {
      final archive = File('${dir.path}/${asset.name}');
      await feed.download(asset.url, archive, onProgress: onProgress);
      final actual = await sha256OfFile(archive);
      if (actual != expected) {
        throw UpdateException(
          UpdateErrorKind.unverified,
          '${asset.name}: sha256 $actual, signed $expected',
        );
      }
      try {
        return await installer.stage(archive, offer.version);
      } on FileSystemException catch (e) {
        throw UpdateException(UpdateErrorKind.install, e.message);
      }
    } finally {
      await dir.delete(recursive: true);
    }
  }

  Future<String> _signedChecksum(Release release, String name) async {
    final sums = release.asset('SHA256SUMS');
    final sig = release.asset('SHA256SUMS.sig');
    if (publicKey.isEmpty) {
      throw const UpdateException(UpdateErrorKind.unverified, 'no key pinned');
    }
    if (sums == null || sig == null) {
      throw const UpdateException(
        UpdateErrorKind.unverified,
        'the release has no signed SHA256SUMS',
      );
    }
    final text = await feed.bytes(sums.url);
    final signature = await feed.bytes(sig.url);
    final ok = await verifyEd25519(
      message: text,
      signature: signature,
      publicKey: publicKey,
    );
    if (!ok) {
      throw const UpdateException(
        UpdateErrorKind.unverified,
        'SHA256SUMS.sig does not match the pinned key',
      );
    }
    final expected = parseSha256Sums(
      utf8.decode(text, allowMalformed: true),
    )[name];
    if (expected == null) {
      throw UpdateException(
        UpdateErrorKind.unverified,
        'SHA256SUMS has no line for $name',
      );
    }
    return expected;
  }

  /// Puts [update] in place; see [UpdateInstaller.apply].
  Future<void> apply(StagedUpdate update, {required bool relaunch}) async {
    try {
      await installer.apply(update, relaunch: relaunch);
    } on FileSystemException catch (e) {
      throw UpdateException(UpdateErrorKind.install, e.message);
    } on ProcessException catch (e) {
      throw UpdateException(UpdateErrorKind.install, e.message);
    }
  }
}
