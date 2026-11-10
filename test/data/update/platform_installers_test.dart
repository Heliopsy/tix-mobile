// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/update/platform_installers.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

void main() {
  test('the relaunch waits for this process, then runs the command', () {
    final args = waitThenRun(4242, ['/opt/tix/tix_mobile']);
    expect(args.first, '-c');
    expect(args[1], contains(r'kill -0 "$0"'));
    expect(args[1], contains(r'exec "$@"'));
    expect(args.sublist(2), ['4242', '/opt/tix/tix_mobile']);
  });

  test('the Windows helper gets every path and the relaunch flag', () {
    final args = windowsSwapArgs(
      script: r'C:\Temp\swap.ps1',
      processId: 7,
      target: r'C:\Apps\tix',
      staged: r'C:\Apps\.tix.update',
      old: r'C:\Apps\.tix.old',
      exe: r'C:\Apps\tix\tix_mobile.exe',
      relaunch: true,
    );
    expect(args, containsAllInOrder(['-File', r'C:\Temp\swap.ps1']));
    expect(args, containsAllInOrder(['-ProcessId', '7']));
    expect(args, containsAllInOrder(['-Target', r'C:\Apps\tix']));
    expect(args, containsAllInOrder(['-Staged', r'C:\Apps\.tix.update']));
    expect(args, containsAllInOrder(['-Old', r'C:\Apps\.tix.old']));
    expect(args.sublist(args.length - 2), ['-Relaunch', '1']);
    for (final p in ['ProcessId', 'Target', 'Staged', 'Old', 'Exe']) {
      expect(windowsSwapScript, contains('\$$p'));
    }
    expect(windowsSwapScript.trimLeft(), startsWith('param('));
  });

  group('on a real directory', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('tix-install-');
      addTearDown(() => root.delete(recursive: true));
    });

    Future<Directory> bundle(String path, String content) async {
      final dir = Directory('${root.path}/$path');
      await Directory('${dir.path}/data/flutter_assets')
          .create(recursive: true);
      await File('${dir.path}/tix_mobile').writeAsString(content);
      return dir;
    }

    test(
      'swapIn puts the old directory back when the new one is gone',
      () async {
        final installed = await bundle('tix', 'old');
        await expectLater(
          swapIn(
            installed,
            Directory('${root.path}/missing'),
            '${root.path}/.old',
          ),
          throwsA(isA<UpdateException>()),
        );
        expect(await File('${root.path}/tix/tix_mobile').readAsString(), 'old');
      },
    );

    test('the Linux bundle is staged, swapped and cleaned up', () async {
      final installed = await bundle('tix-mobile', 'old');
      final source = await bundle('src', 'new');
      final archive = File('${root.path}/new.tar.gz');
      final tar = await Process.run('tar', [
        '-czf',
        archive.path,
        '-C',
        source.path,
        '.',
      ]);
      expect(tar.exitCode, 0, reason: '${tar.stderr}');
      final installer = LinuxInstaller(
        executable: '${installed.path}/tix_mobile',
        processId: pid,
      );

      final target = await installer.target();
      expect(target!.path, installed.path);
      expect(target.writable, isTrue);

      final staged = await installer.stage(
        archive,
        const ReleaseVersion(0, 12, 0),
      );
      expect(staged.path, '${root.path}/.tix-mobile.update');
      expect(await File('${installed.path}/tix_mobile').readAsString(), 'old');

      await installer.apply(staged, relaunch: false);
      expect(await File('${installed.path}/tix_mobile').readAsString(), 'new');
      expect(
        await File('${root.path}/.tix-mobile.old/tix_mobile').readAsString(),
        'old',
      );
      expect(Directory(staged.path).existsSync(), isFalse);

      await installer.cleanup();
      expect(Directory('${root.path}/.tix-mobile.old').existsSync(), isFalse);
    }, skip: !Platform.isLinux);

    test('an archive without the binary is not staged', () async {
      final installed = await bundle('tix-mobile', 'old');
      final empty = await Directory('${root.path}/empty').create();
      final archive = File('${root.path}/empty.tar.gz');
      await Process.run('tar', ['-czf', archive.path, '-C', empty.path, '.']);
      final installer = LinuxInstaller(
        executable: '${installed.path}/tix_mobile',
        processId: pid,
      );
      await expectLater(
        installer.stage(archive, const ReleaseVersion(0, 12, 0)),
        throwsA(
          isA<UpdateException>().having(
            (e) => e.kind,
            'kind',
            UpdateErrorKind.install,
          ),
        ),
      );
    }, skip: !Platform.isLinux);

    test('a directory that is not a bundle is no install target', () async {
      final dir = await Directory('${root.path}/bin').create();
      final installer = LinuxInstaller(
        executable: '${dir.path}/tix_mobile',
        processId: pid,
      );
      expect(await installer.target(), isNull);
    });

    test('the sandboxed macOS app is not writable', () async {
      final app = await Directory('${root.path}/tix.app/Contents/MacOS')
          .create(recursive: true);
      MacInstaller mac({required bool sandboxed}) => MacInstaller(
        executable: '${app.path}/tix',
        processId: pid,
        sandboxed: sandboxed,
      );
      final free = await mac(sandboxed: false).target();
      expect(free!.path, '${root.path}/tix.app');
      expect(free.writable, isTrue);
      expect((await mac(sandboxed: true).target())!.writable, isFalse);
    });
  });
}
