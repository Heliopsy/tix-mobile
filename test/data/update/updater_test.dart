// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/update/installer.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';
import 'package:tix_mobile/src/data/update/updater.dart';

import '../../helpers/fake_update.dart';

const linuxX64 = 'tix-mobile-0.12.0-linux-x64.tar.gz';

void main() {
  group('updateModeFor', () {
    const writable = InstallTarget(path: '/home/ana/tix', writable: true);
    const readOnly = InstallTarget(path: '/opt/tix', writable: false);
    const linux = UpdateEnvironment(desktop: DesktopOs.linux);

    test('a writable release install on a desktop installs', () {
      expect(updateModeFor(linux, target: writable), UpdateMode.install);
    });

    test('a read-only or unknown install only notifies', () {
      expect(updateModeFor(linux, target: readOnly), UpdateMode.notify);
      expect(updateModeFor(linux), UpdateMode.notify);
    });

    test('a debug build only notifies', () {
      const debug = UpdateEnvironment(
        desktop: DesktopOs.linux,
        releaseBuild: false,
      );
      expect(updateModeFor(debug, target: writable), UpdateMode.notify);
    });

    test('Flatpak, Snap and a build flag turn it off', () {
      for (final env in const [
        UpdateEnvironment(desktop: DesktopOs.linux, flatpak: true),
        UpdateEnvironment(desktop: DesktopOs.linux, snap: true),
        UpdateEnvironment(desktop: DesktopOs.macos, buildAllows: false),
        UpdateEnvironment(android: true, buildAllows: false),
      ]) {
        expect(updateModeFor(env, target: writable), UpdateMode.off);
      }
    });

    test('iOS is off', () {
      expect(updateModeFor(const UpdateEnvironment()), UpdateMode.off);
    });

    test('Android notifies only for the GitHub APK', () {
      UpdateMode android(String? installer) => updateModeFor(
        UpdateEnvironment(android: true, androidInstaller: installer),
      );
      expect(android(null), UpdateMode.notify);
      expect(android('com.google.android.packageinstaller'), UpdateMode.notify);
      expect(android('com.android.packageinstaller'), UpdateMode.notify);
      expect(android('com.android.vending'), UpdateMode.off);
      expect(android('org.fdroid.fdroid'), UpdateMode.off);
      expect(android('com.looker.droidify'), UpdateMode.off);
    });
  });

  group('Updater', () {
    late FakeReleaseFeed feed;
    late FakeInstaller installer;
    late TestKey key;

    setUp(() async {
      feed = FakeReleaseFeed();
      installer = FakeInstaller();
      key = await testKey();
    });

    Updater updater({String? publicKey, String current = '0.11.0'}) => Updater(
      feed: feed,
      installer: installer,
      current: ReleaseVersion.tryParse(current)!,
      publicKey: publicKey ?? key.public,
      os: DesktopOs.linux,
      arch: CpuArch.x64,
    );

    final archive = utf8.encode('the new bundle');

    group('check', () {
      test("offers a newer release with this system's archive", () async {
        await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
          signer: key,
        );
        final offer = await updater().check();
        expect(offer!.version.toString(), '0.12.0');
        expect(offer.asset!.name, linuxX64);
        expect(offer.page.path, endsWith('/v0.12.0'));
      });

      test('nothing when the latest is not newer', () async {
        await publish(feed, version: '0.11.0', archives: {linuxX64: archive});
        expect(await updater().check(), isNull);
        expect(await updater(current: '0.12.0').check(), isNull);
      });

      test('nothing when there is no release', () async {
        expect(await updater().check(), isNull);
      });

      test('prereleases and drafts never count', () async {
        await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
          prerelease: true,
        );
        expect(await updater().check(), isNull);
        final r = feed.release!;
        feed.release = Release(
          tag: r.tag,
          version: r.version,
          page: r.page,
          assets: r.assets,
          draft: true,
        );
        expect(await updater().check(), isNull);
      });

      test('an offer without an archive for this system', () async {
        await publish(
          feed,
          version: '0.12.0',
          archives: {'tix-mobile-0.12.0-macos.zip': archive},
        );
        final offer = await updater().check();
        expect(offer, isNotNull);
        expect(offer!.asset, isNull);
      });

      test('a network failure is an update error', () async {
        feed.failure = const UpdateException(UpdateErrorKind.network);
        await expectLater(
          updater().check(),
          throwsA(
            isA<UpdateException>().having(
              (e) => e.kind,
              'kind',
              UpdateErrorKind.network,
            ),
          ),
        );
      });
    });

    group('download', () {
      Matcher fails(UpdateErrorKind kind) =>
          throwsA(isA<UpdateException>().having((e) => e.kind, 'kind', kind));

      test('a signed, matching archive is staged', () async {
        await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
          signer: key,
        );
        final u = updater();
        final progress = <double>[];
        final staged = await u.download(
          (await u.check())!,
          onProgress: progress.add,
        );
        expect(staged.version.toString(), '0.12.0');
        expect(installer.staged, [archive]);
        expect(progress, [0.5, 1]);
      });

      test('pinned key and no signature: nothing is downloaded', () async {
        await publish(feed, version: '0.12.0', archives: {linuxX64: archive});
        final u = updater();
        await expectLater(
          u.download((await u.check())!),
          fails(UpdateErrorKind.unverified),
        );
        expect(feed.downloads, isEmpty);
        expect(installer.staged, isEmpty);
      });

      test(
        'no pinned key: a matching archive is staged on its checksum',
        () async {
          await publish(feed, version: '0.12.0', archives: {linuxX64: archive});
          final u = updater(publicKey: '');
          await u.download((await u.check())!);
          expect(installer.staged, [archive]);
          expect(feed.reads.map((r) => r.pathSegments.last), ['SHA256SUMS']);
        },
      );

      test('no pinned key: a checksum mismatch is refused', () async {
        final release = await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
        );
        feed.files[release.asset(linuxX64)!.url] = utf8.encode('tampered');
        final u = updater(publicKey: '');
        await expectLater(
          u.download((await u.check())!),
          fails(UpdateErrorKind.unverified),
        );
        expect(installer.staged, isEmpty);
      });

      test('no pinned key: a release without SHA256SUMS is refused', () async {
        final release = await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
        );
        feed.release = Release(
          tag: release.tag,
          version: release.version,
          page: release.page,
          assets: [release.asset(linuxX64)!],
        );
        final u = updater(publicKey: '');
        await expectLater(
          u.download((await u.check())!),
          fails(UpdateErrorKind.unverified),
        );
        expect(feed.downloads, isEmpty);
      });

      test('a download from outside GitHub over HTTPS is refused', () async {
        final release = await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
        );
        final plain = Uri.parse('http://github.com/a/$linuxX64');
        feed
          ..release = Release(
            tag: release.tag,
            version: release.version,
            page: release.page,
            assets: [
              ReleaseAsset(name: linuxX64, url: plain),
              release.asset('SHA256SUMS')!,
            ],
          )
          ..files[plain] = archive;
        final u = updater(publicKey: '');
        await expectLater(
          u.download((await u.check())!),
          fails(UpdateErrorKind.unverified),
        );
        expect(feed.reads, isEmpty);
        expect(feed.downloads, isEmpty);
      });

      test('trusted hosts are GitHub and its asset CDN over HTTPS', () {
        for (final ok in [
          'https://github.com/heliopsy/tix-mobile/releases/download/v1/x',
          'https://objects.githubusercontent.com/github-production-release/x',
          'https://release-assets.githubusercontent.com/x',
        ]) {
          expect(trustedReleaseUrl(Uri.parse(ok)), isTrue, reason: ok);
        }
        for (final bad in [
          'http://github.com/x',
          'https://github.com.evil.test/x',
          'https://evilgithubusercontent.com/x',
          'https://example.com/x',
        ]) {
          expect(trustedReleaseUrl(Uri.parse(bad)), isFalse, reason: bad);
        }
      });

      test('a signature by another key: nothing is downloaded', () async {
        await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
          signer: await testKey(),
        );
        final u = updater();
        await expectLater(
          u.download((await u.check())!),
          fails(UpdateErrorKind.unverified),
        );
        expect(feed.downloads, isEmpty);
      });

      test('an archive that differs from the signed sum is refused', () async {
        final release = await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
          signer: key,
        );
        feed.files[release.asset(linuxX64)!.url] = utf8.encode('tampered');
        final u = updater();
        await expectLater(
          u.download((await u.check())!),
          fails(UpdateErrorKind.unverified),
        );
        expect(feed.downloads, hasLength(1));
        expect(installer.staged, isEmpty);
      });

      test('signed sums without a line for the archive are refused', () async {
        await publish(
          feed,
          version: '0.12.0',
          archives: {linuxX64: archive},
          signer: key,
          sums: sumsOf({'something-else.zip': archive}),
        );
        final u = updater();
        await expectLater(
          u.download((await u.check())!),
          fails(UpdateErrorKind.unverified),
        );
        expect(feed.downloads, isEmpty);
      });

      test('an offer without an archive cannot be downloaded', () async {
        await publish(
          feed,
          version: '0.12.0',
          archives: {'tix-mobile-0.12.0-macos.zip': archive},
          signer: key,
        );
        final u = updater();
        await expectLater(
          u.download((await u.check())!),
          fails(UpdateErrorKind.noAsset),
        );
      });
    });

    test('apply hands the staged update to the installer', () async {
      final staged = StagedUpdate(
        version: ReleaseVersion.tryParse('0.12.0')!,
        path: '/opt/.tix.update',
      );
      await updater().apply(staged, relaunch: true);
      await updater().apply(staged, relaunch: false);
      expect(installer.applied, [true, false]);
    });
  });
}
