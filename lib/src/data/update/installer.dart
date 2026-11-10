// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/update/release.dart';

/// Where the running app is installed.
@immutable
class InstallTarget {
  /// The app at [path], replaceable in place when [writable].
  const InstallTarget({required this.path, required this.writable});

  /// The bundle directory, the runner folder or the `.app`.
  final String path;

  /// Whether this user can replace it.
  final bool writable;
}

/// A verified update unpacked next to the installed app, waiting for a
/// restart.
@immutable
class StagedUpdate {
  /// [version], unpacked at [path].
  const StagedUpdate({required this.version, required this.path});

  /// The version it installs.
  final ReleaseVersion version;

  /// The unpacked bundle directory, runner folder or `.app`.
  final String path;
}

/// The platform half of an update: unpacking and swapping the install. Kept
/// to the system's own tools and directory moves, so everything else can be
/// tested with a fake.
abstract interface class UpdateInstaller {
  /// Where the app is installed, null when it is not an install this can
  /// replace at all.
  Future<InstallTarget?> target();

  /// Unpacks [archive] next to the installed app and checks it holds this
  /// app.
  Future<StagedUpdate> stage(File archive, ReleaseVersion version);

  /// Puts [update] in place of the installed app, now or once this process
  /// has exited, and starts it afterwards when [relaunch]. The caller quits
  /// the app right after.
  Future<void> apply(StagedUpdate update, {required bool relaunch});

  /// Removes what an earlier update left behind.
  Future<void> cleanup();
}

/// An installer for a platform that installs nothing.
class NoUpdateInstaller implements UpdateInstaller {
  /// Installs nothing.
  const NoUpdateInstaller();

  @override
  Future<InstallTarget?> target() async => null;

  @override
  Future<StagedUpdate> stage(File archive, ReleaseVersion version) =>
      throw UnsupportedError('no installer on this platform');

  @override
  Future<void> apply(StagedUpdate update, {required bool relaunch}) =>
      throw UnsupportedError('no installer on this platform');

  @override
  Future<void> cleanup() async {}
}
