// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

/// The Android application id, the same in every distribution.
const playPackage = 'red.tix.tix_mobile';

/// The app's Google Play listing on the web.
final Uri playListing = Uri.https('play.google.com', '/store/apps/details', {
  'id': playPackage,
});

/// What Google Play says about an update to this install.
@immutable
class PlayUpdateInfo {
  /// Play's answer: whether an update is [available], its [versionCode],
  /// and whether a [flexible] in-app update is allowed.
  const PlayUpdateInfo({
    required this.available,
    required this.versionCode,
    this.flexible = false,
  });

  /// Reads the `tix/play-update` channel's `info` answer; null for anything
  /// else, which is what the oss build's stand-in answers.
  static PlayUpdateInfo? fromMap(Object? map) {
    if (map is! Map) return null;
    final available = map['available'];
    final code = map['versionCode'];
    if (available is! bool || code is! int) return null;
    return PlayUpdateInfo(
      available: available,
      versionCode: code,
      flexible: map['flexible'] == true,
    );
  }

  /// Reads the answer the Android update worker adds to its
  /// `tixwidget://update` link (`play` and `code`); null when the link
  /// carries none, as when Play did not answer.
  static PlayUpdateInfo? fromUri(Uri? uri) {
    final q = uri?.queryParameters ?? const <String, String>{};
    final code = int.tryParse(q['code'] ?? '');
    final play = q['play'];
    if (code == null || (play != '1' && play != '0')) return null;
    return PlayUpdateInfo(available: play == '1', versionCode: code);
  }

  /// Whether Play serves a newer version to this install.
  final bool available;

  /// The version code Play serves.
  final int versionCode;

  /// Whether Play allows a flexible in-app update now.
  final bool flexible;
}

/// The version an Android build number stands for, the inverse of
/// `scripts/build-version.sh`: MAJOR * 1000000 + MINOR * 1000 + PATCH.
ReleaseVersion? versionOfPlayCode(int code) {
  if (code <= 0) return null;
  return ReleaseVersion(code ~/ 1000000, code ~/ 1000 % 1000, code % 1000);
}

/// The release Play offers in [info], opening [page]; null when Play has
/// no update or the version code is not one of ours.
Release? playRelease(PlayUpdateInfo info, {required Uri page}) {
  if (!info.available) return null;
  final version = versionOfPlayCode(info.versionCode);
  if (version == null) return null;
  return Release(
    tag: '${info.versionCode}',
    version: version,
    page: page,
    assets: const [],
  );
}

/// Asks Google Play about an update, null when Play is not there to ask.
abstract interface class PlayUpdateSource {
  /// Play's answer for this install.
  Future<PlayUpdateInfo?> info();
}

/// [ReleaseFeed] over Google Play's in-app update API: the version Play
/// serves to this install, linking to the Play listing. It has no files;
/// Play installs the update.
class PlayReleaseFeed implements ReleaseFeed {
  /// Asks [source], linking to [page].
  PlayReleaseFeed(this.source, {Uri? page}) : page = page ?? playListing;

  /// Where Play's answer comes from.
  final PlayUpdateSource source;

  /// Where an update is installed from.
  final Uri page;

  @override
  Future<Release?> latest() async {
    final info = await source.info();
    return info == null ? null : playRelease(info, page: page);
  }

  @override
  Future<List<int>> bytes(Uri url) async =>
      throw const UpdateException(UpdateErrorKind.noAsset, 'Google Play');

  @override
  Future<void> download(
    Uri url,
    File to, {
    void Function(double progress)? onProgress,
  }) async =>
      throw const UpdateException(UpdateErrorKind.noAsset, 'Google Play');
}
