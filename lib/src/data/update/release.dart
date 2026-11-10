// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';

/// A release version, `MAJOR.MINOR.PATCH` with an optional prerelease,
/// ordered by semantic version precedence. Build metadata is ignored.
@immutable
class ReleaseVersion implements Comparable<ReleaseVersion> {
  /// The version [major].[minor].[patch], with [pre] after a dash.
  const ReleaseVersion(this.major, this.minor, this.patch, [this.pre = '']);

  /// The major number.
  final int major;

  /// The minor number.
  final int minor;

  /// The patch number.
  final int patch;

  /// The prerelease part, empty for a release.
  final String pre;

  static final _pattern = RegExp(
    r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$',
  );

  /// Reads `v1.2.3`, `1.2.3-rc.1` or `1.2.3+4`; null for anything else.
  static ReleaseVersion? tryParse(String text) {
    final m = _pattern.firstMatch(text.trim());
    if (m == null) return null;
    return ReleaseVersion(
      int.parse(m[1]!),
      int.parse(m[2]!),
      int.parse(m[3]!),
      m[4] ?? '',
    );
  }

  /// Whether this is newer than [other].
  bool isNewerThan(ReleaseVersion other) => compareTo(other) > 0;

  @override
  int compareTo(ReleaseVersion other) {
    for (final (a, b) in [
      (major, other.major),
      (minor, other.minor),
      (patch, other.patch),
    ]) {
      if (a != b) return a.compareTo(b);
    }
    if (pre == other.pre) return 0;
    if (pre.isEmpty) return 1;
    if (other.pre.isEmpty) return -1;
    return _comparePre(pre.split('.'), other.pre.split('.'));
  }

  static int _comparePre(List<String> a, List<String> b) {
    for (var i = 0; i < a.length && i < b.length; i++) {
      final x = int.tryParse(a[i]);
      final y = int.tryParse(b[i]);
      final c = switch ((x, y)) {
        (final int x, final int y) => x.compareTo(y),
        (int(), null) => -1,
        (null, int()) => 1,
        _ => a[i].compareTo(b[i]),
      };
      if (c != 0) return c;
    }
    return a.length.compareTo(b.length);
  }

  @override
  bool operator ==(Object other) =>
      other is ReleaseVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch &&
      other.pre == pre;

  @override
  int get hashCode => Object.hash(major, minor, patch, pre);

  @override
  String toString() =>
      pre.isEmpty ? '$major.$minor.$patch' : '$major.$minor.$patch-$pre';
}

/// One file attached to a release.
@immutable
class ReleaseAsset {
  /// The file [name], downloaded from [url], [size] bytes.
  const ReleaseAsset({required this.name, required this.url, this.size = 0});

  /// The file name.
  final String name;

  /// Where it downloads from.
  final Uri url;

  /// Its size in bytes, 0 when unknown.
  final int size;
}

/// A published release as GitHub describes it.
@immutable
class Release {
  /// The release tagged [tag].
  const Release({
    required this.tag,
    required this.version,
    required this.page,
    required this.assets,
    this.draft = false,
    this.prerelease = false,
  });

  /// Reads GitHub's release JSON; null when the tag is not a version.
  static Release? fromJson(Map<String, Object?> json) {
    final tag = json['tag_name'];
    final page = json['html_url'];
    if (tag is! String || page is! String) return null;
    final version = ReleaseVersion.tryParse(tag);
    if (version == null) return null;
    final assets = <ReleaseAsset>[];
    for (final a in (json['assets'] as List<Object?>?) ?? const []) {
      if (a is! Map<String, Object?>) continue;
      final name = a['name'];
      final url = a['browser_download_url'];
      if (name is! String || url is! String) continue;
      assets.add(
        ReleaseAsset(
          name: name,
          url: Uri.parse(url),
          size: (a['size'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    return Release(
      tag: tag,
      version: version,
      page: Uri.parse(page),
      assets: assets,
      draft: json['draft'] == true,
      prerelease: json['prerelease'] == true,
    );
  }

  /// The git tag, such as `v0.12.0`.
  final String tag;

  /// The version the tag names.
  final ReleaseVersion version;

  /// The release page with its notes and downloads.
  final Uri page;

  /// The attached files.
  final List<ReleaseAsset> assets;

  /// Whether it is a draft.
  final bool draft;

  /// Whether it is marked as a prerelease.
  final bool prerelease;

  /// The asset called [name], null when there is none.
  ReleaseAsset? asset(String name) {
    for (final a in assets) {
      if (a.name == name) return a;
    }
    return null;
  }
}

/// The desktops a release ships an archive for.
enum DesktopOs {
  /// A tarball of the bundle.
  linux,

  /// A zip of the runner output.
  windows,

  /// A zip of the app bundle.
  macos,
}

/// The processor architectures the desktop archives are built for.
enum CpuArch {
  /// x86-64.
  x64,

  /// 64-bit ARM.
  arm64,

  /// Anything else.
  other,
}

/// The release file name for [version] on [os] and [arch], null when no
/// archive is built for that combination.
String? desktopAssetName(ReleaseVersion version, DesktopOs os, CpuArch arch) =>
    switch ((os, arch)) {
      (DesktopOs.linux, CpuArch.x64 || CpuArch.arm64) =>
        'tix-mobile-$version-linux-${arch.name}.tar.gz',
      (DesktopOs.windows, CpuArch.x64) => 'tix-mobile-$version-windows-x64.zip',
      (DesktopOs.macos, _) => 'tix-mobile-$version-macos.zip',
      _ => null,
    };

/// The archive in [release] for [os] and [arch], null when it has none.
ReleaseAsset? chooseDesktopAsset(Release release, DesktopOs os, CpuArch arch) {
  final name = desktopAssetName(release.version, os, arch);
  return name == null ? null : release.asset(name);
}
