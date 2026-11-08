// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info.g.dart';

/// What this build is and what it runs on.
@immutable
class AppInfo {
  /// A build [version] number [build] on [platform] [osVersion].
  const AppInfo({
    required this.version,
    required this.build,
    required this.platform,
    required this.osVersion,
  });

  /// The version name, such as `0.4.0`.
  final String version;

  /// The build number, empty when the platform has none.
  final String build;

  /// The operating system as the bug form lists it: Android, iOS, Linux,
  /// macOS or Windows.
  final String platform;

  /// The operating system's own version string.
  final String osVersion;
}

/// The platform's name as the bug report form lists it.
String platformName(String os) => switch (os) {
  'android' => 'Android',
  'ios' => 'iOS',
  'linux' => 'Linux',
  'macos' => 'macOS',
  'windows' => 'Windows',
  _ => os,
};

/// This build's version and the system it runs on.
@Riverpod(keepAlive: true)
Future<AppInfo> appInfo(Ref ref) async {
  final p = await PackageInfo.fromPlatform();
  return AppInfo(
    version: p.version,
    build: p.buildNumber,
    platform: platformName(Platform.operatingSystem),
    osVersion: Platform.operatingSystemVersion,
  );
}
