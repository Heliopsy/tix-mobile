// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';
import 'package:tix_mobile/src/data/update/updater.dart';

import '../../helpers/container.dart';
import '../../helpers/eventually.dart';
import '../../helpers/fake_desktop.dart';
import '../../helpers/fake_update.dart';
import '../../helpers/stores.dart';

const linuxX64 = 'tix-mobile-0.12.0-linux-x64.tar.gz';

void main() {
  late MemoryKeyValueStore store;
  late FakeReleaseFeed feed;
  late FakeInstaller installer;
  late FakeDesktop desktop;
  late TestKey key;

  setUp(() async {
    store = MemoryKeyValueStore();
    feed = FakeReleaseFeed();
    installer = FakeInstaller();
    desktop = FakeDesktop();
    key = await testKey();
  });

  ProviderContainer container({UpdateMode mode = UpdateMode.install}) {
    final c = makeContainer([
      keyValueStoreProvider.overrideWithValue(store),
      desktopShellProvider.overrideWithValue(desktop),
      updateModeProvider.overrideWithValue(AsyncData(mode)),
      updateInstallerProvider.overrideWithValue(installer),
      updaterProvider.overrideWith(
        (ref) async => Updater(
          feed: feed,
          installer: installer,
          current: const ReleaseVersion(0, 11, 0),
          publicKey: key.public,
          os: DesktopOs.linux,
          arch: CpuArch.x64,
        ),
      ),
    ])..listen(updatesProvider, (_, _) {});
    return c;
  }

  Future<void> release({String version = '0.12.0', bool signed = true}) =>
      publish(
        feed,
        version: version,
        archives: {
          'tix-mobile-$version-linux-x64.tar.gz': utf8.encode('bundle'),
        },
        signer: signed ? key : null,
      );

  UpdatePhase phase(ProviderContainer c) => c.read(updatesProvider).phase;

  group('settings', () {
    test('checking is on and installing on quit off by default', () {
      final c = container();
      expect(c.read(updateCheckSettingProvider), isTrue);
      expect(c.read(autoInstallSettingProvider), isFalse);
    });

    test('both choices are kept on the device', () async {
      final c = container();
      await c.read(updateCheckSettingProvider.notifier).set(on: false);
      await c.read(autoInstallSettingProvider.notifier).set(on: true);
      expect(store.values['settings.updateCheck'], 'off');
      expect(store.values['settings.updateAutoInstall'], 'true');
      final again = container();
      expect(again.read(updateCheckSettingProvider), isFalse);
      expect(again.read(autoInstallSettingProvider), isTrue);
      await again.read(updateCheckSettingProvider.notifier).set(on: true);
      await again.read(autoInstallSettingProvider.notifier).set(on: false);
      expect(store.values, isNot(contains('settings.updateCheck')));
      expect(store.values, isNot(contains('settings.updateAutoInstall')));
    });
  });

  group('controller', () {
    test('a newer release is found at start, downloaded and staged', () async {
      await release();
      final c = container();
      await eventually(() => phase(c) == UpdatePhase.ready);
      final s = c.read(updatesProvider);
      expect(s.offer!.version.toString(), '0.12.0');
      expect(s.staged!.version.toString(), '0.12.0');
      expect(installer.staged, hasLength(1));
      expect(installer.cleanups, 1);
    });

    test('the same version is reported as current', () async {
      await release(version: '0.11.0');
      final c = container();
      await eventually(() => phase(c) == UpdatePhase.current);
      expect(feed.downloads, isEmpty);
    });

    test('nothing is fetched at start while checking is off', () async {
      store.values['settings.updateCheck'] = 'off';
      await release();
      final c = container();
      await pumpEventQueue();
      expect(phase(c), UpdatePhase.idle);
      expect(feed.reads, isEmpty);
      await c.read(updatesProvider.notifier).check();
      expect(phase(c), UpdatePhase.ready);
    });

    test('in notify mode an update is only offered', () async {
      store.values['settings.updateCheck'] = 'off';
      await release();
      final c = container(mode: UpdateMode.notify);
      await c.read(updatesProvider.notifier).check();
      final s = c.read(updatesProvider);
      expect(s.phase, UpdatePhase.available);
      expect(s.error, isNull);
      expect(feed.downloads, isEmpty);
      expect(installer.cleanups, 0);
    });

    test("a release without this system's archive is offered", () async {
      store.values['settings.updateCheck'] = 'off';
      await publish(
        feed,
        version: '0.12.0',
        archives: {'tix-mobile-0.12.0-macos.zip': utf8.encode('app')},
        signer: key,
      );
      final c = container();
      await c.read(updatesProvider.notifier).check();
      final s = c.read(updatesProvider);
      expect(s.phase, UpdatePhase.available);
      expect(s.error, UpdateErrorKind.noAsset);
    });

    test(
      'an unsigned release fails verification and keeps the offer',
      () async {
        store.values['settings.updateCheck'] = 'off';
        await release(signed: false);
        final c = container();
        await c.read(updatesProvider.notifier).check();
        final s = c.read(updatesProvider);
        expect(s.phase, UpdatePhase.failed);
        expect(s.error, UpdateErrorKind.unverified);
        expect(s.offer!.version.toString(), '0.12.0');
        expect(installer.staged, isEmpty);
      },
    );

    test('a network failure is reported', () async {
      store.values['settings.updateCheck'] = 'off';
      feed.failure = const UpdateException(UpdateErrorKind.network);
      final c = container();
      await c.read(updatesProvider.notifier).check();
      expect(c.read(updatesProvider).error, UpdateErrorKind.network);
    });

    test('updates off: never checks, Check now does nothing', () async {
      await release();
      final c = container(mode: UpdateMode.off);
      await c.read(updatesProvider.notifier).check();
      expect(phase(c), UpdatePhase.idle);
      expect(feed.reads, isEmpty);
    });

    test('Restart to update installs, relaunches and quits', () async {
      await release();
      final c = container();
      await eventually(() => phase(c) == UpdatePhase.ready);
      expect(await c.read(updatesProvider.notifier).restart(), isTrue);
      expect(installer.applied, [true]);
      expect(desktop.quits, 1);
    });

    test('a failed install does not quit', () async {
      await release();
      installer.applyFailure = const UpdateException(UpdateErrorKind.install);
      final c = container();
      await eventually(() => phase(c) == UpdatePhase.ready);
      expect(await c.read(updatesProvider.notifier).restart(), isFalse);
      expect(desktop.quits, 0);
      expect(c.read(updatesProvider).error, UpdateErrorKind.install);
    });

    test('nothing staged: restart does nothing', () async {
      final c = container();
      expect(await c.read(updatesProvider.notifier).restart(), isFalse);
      expect(installer.applied, isEmpty);
    });

    test('on quit it installs only when that is chosen', () async {
      await release();
      final c = container();
      await eventually(() => phase(c) == UpdatePhase.ready);
      await c.read(updatesProvider.notifier).installOnQuit();
      expect(installer.applied, isEmpty);
      await c.read(autoInstallSettingProvider.notifier).set(on: true);
      await c.read(updatesProvider.notifier).installOnQuit();
      expect(installer.applied, [false]);
      expect(desktop.quits, 0);
    });

    test('a staged update is not checked again', () async {
      await release();
      final c = container();
      await eventually(() => phase(c) == UpdatePhase.ready);
      final reads = feed.reads.length;
      await c.read(updatesProvider.notifier).check();
      expect(feed.reads, hasLength(reads));
      expect(phase(c), UpdatePhase.ready);
    });
  });

  test('UpdateState compares by content', () {
    const a = UpdateState(phase: UpdatePhase.checking);
    expect(a, const UpdateState(phase: UpdatePhase.checking));
    expect(a.hashCode, const UpdateState(phase: UpdatePhase.checking).hashCode);
    expect(a, isNot(const UpdateState()));
  });
}
