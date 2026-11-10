// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/update/release.dart';

ReleaseVersion v(String s) => ReleaseVersion.tryParse(s)!;

void main() {
  group('ReleaseVersion', () {
    test('reads tags, plain versions and build metadata', () {
      expect(v('v0.12.0'), const ReleaseVersion(0, 12, 0));
      expect(v('1.2.3'), const ReleaseVersion(1, 2, 3));
      expect(v('1.2.3+45'), const ReleaseVersion(1, 2, 3));
      expect(v('1.2.3-rc.1'), const ReleaseVersion(1, 2, 3, 'rc.1'));
      expect(v('1.2.3-rc.1').toString(), '1.2.3-rc.1');
      expect(v('v0.12.0').toString(), '0.12.0');
    });

    test('refuses what is not a version', () {
      for (final s in ['', 'latest', 'v1.2', '1.2.3.4', 'nightly-1.2.3']) {
        expect(ReleaseVersion.tryParse(s), isNull, reason: s);
      }
    });

    test('compares numerically, field by field', () {
      expect(v('0.12.0').isNewerThan(v('0.11.0')), isTrue);
      expect(v('0.11.0').isNewerThan(v('0.12.0')), isFalse);
      expect(v('0.10.0').isNewerThan(v('0.9.9')), isTrue);
      expect(v('1.0.0').isNewerThan(v('0.99.99')), isTrue);
      expect(v('0.11.1').isNewerThan(v('0.11.0')), isTrue);
      expect(v('0.11.0').isNewerThan(v('0.11.0')), isFalse);
    });

    test('a prerelease comes before its release', () {
      expect(v('1.0.0').isNewerThan(v('1.0.0-rc.1')), isTrue);
      expect(v('1.0.0-rc.1').isNewerThan(v('1.0.0')), isFalse);
      expect(v('1.0.0-rc.1').isNewerThan(v('0.9.0')), isTrue);
    });

    test('prerelease identifiers compare as semver says', () {
      final ordered = [
        '1.0.0-alpha',
        '1.0.0-alpha.1',
        '1.0.0-alpha.beta',
        '1.0.0-beta',
        '1.0.0-beta.2',
        '1.0.0-beta.11',
        '1.0.0-rc.1',
        '1.0.0',
      ].map(v).toList();
      for (var i = 1; i < ordered.length; i++) {
        expect(
          ordered[i].isNewerThan(ordered[i - 1]),
          isTrue,
          reason: '${ordered[i]} > ${ordered[i - 1]}',
        );
      }
      expect([...ordered.reversed]..sort(), ordered);
    });

    test('build metadata does not count', () {
      expect(v('1.2.3+1'), v('1.2.3+2'));
      expect(v('1.2.3+1').hashCode, v('1.2.3+2').hashCode);
    });
  });

  group('Release.fromJson', () {
    Map<String, Object?> json({
      String tag = 'v0.12.0',
      bool draft = false,
      bool prerelease = false,
    }) => {
      'tag_name': tag,
      'html_url': 'https://github.com/heliopsy/tix-mobile/releases/tag/$tag',
      'draft': draft,
      'prerelease': prerelease,
      'assets': [
        {
          'name': 'tix-mobile-0.12.0-linux-x64.tar.gz',
          'browser_download_url': 'https://example.test/linux-x64.tar.gz',
          'size': 1234,
        },
        {'name': 'broken'},
        'not an asset',
      ],
    };

    test('reads the tag, the page, the flags and the assets', () {
      final r = Release.fromJson(json(prerelease: true))!;
      expect(r.version, v('0.12.0'));
      expect(r.tag, 'v0.12.0');
      expect(r.page.path, '/heliopsy/tix-mobile/releases/tag/v0.12.0');
      expect(r.prerelease, isTrue);
      expect(r.draft, isFalse);
      expect(r.assets, hasLength(1));
      final a = r.asset('tix-mobile-0.12.0-linux-x64.tar.gz')!;
      expect(a.size, 1234);
      expect(a.url, Uri.parse('https://example.test/linux-x64.tar.gz'));
      expect(r.asset('missing'), isNull);
    });

    test('a tag that is not a version is no release', () {
      expect(Release.fromJson(json(tag: 'nightly')), isNull);
      expect(Release.fromJson(const {'html_url': 'x'}), isNull);
    });
  });

  group('desktop assets', () {
    final release = Release(
      tag: 'v0.12.0',
      version: v('0.12.0'),
      page: Uri.parse('https://example.test/r'),
      assets: [
        for (final name in [
          'tix-mobile-0.12.0-linux-x64.tar.gz',
          'tix-mobile-0.12.0-linux-arm64.tar.gz',
          'tix-mobile-0.12.0-windows-x64.zip',
          'tix-mobile-0.12.0-macos.zip',
          'tix-mobile-0.12.0-android-arm64-v8a.apk',
          'SHA256SUMS',
        ])
          ReleaseAsset(
            name: name,
            url: Uri.parse('https://example.test/$name'),
          ),
      ],
    );

    String? pick(DesktopOs os, CpuArch arch) =>
        chooseDesktopAsset(release, os, arch)?.name;

    test('each desktop and architecture gets its own archive', () {
      expect(
        pick(DesktopOs.linux, CpuArch.x64),
        'tix-mobile-0.12.0-linux-x64.tar.gz',
      );
      expect(
        pick(DesktopOs.linux, CpuArch.arm64),
        'tix-mobile-0.12.0-linux-arm64.tar.gz',
      );
      expect(
        pick(DesktopOs.windows, CpuArch.x64),
        'tix-mobile-0.12.0-windows-x64.zip',
      );
      expect(
        pick(DesktopOs.macos, CpuArch.arm64),
        'tix-mobile-0.12.0-macos.zip',
      );
      expect(pick(DesktopOs.macos, CpuArch.x64), 'tix-mobile-0.12.0-macos.zip');
    });

    test('no archive where none is built', () {
      expect(pick(DesktopOs.windows, CpuArch.arm64), isNull);
      expect(pick(DesktopOs.linux, CpuArch.other), isNull);
    });

    test('an archive the release lacks is no archive', () {
      final bare = Release(
        tag: release.tag,
        version: release.version,
        page: release.page,
        assets: const [],
      );
      expect(chooseDesktopAsset(bare, DesktopOs.linux, CpuArch.x64), isNull);
    });
  });
}
