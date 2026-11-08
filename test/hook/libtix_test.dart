// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../hook/src/libtix.dart';

void main() {
  test('tix.lock pins a full commit and a version', () {
    final lock = TixLock.parse(File('tix.lock').readAsStringSync());
    expect(lock.commit, matches(RegExp(r'^[0-9a-f]{40}$')));
    expect(lock.version, isNotEmpty);
    expect(lock.shortCommit, lock.commit.substring(0, 8));
  });

  test('a lock without a full SHA is refused', () {
    expect(() => TixLock.parse('commit = abc'), throwsFormatException);
    expect(() => TixLock.parse('nonsense'), throwsFormatException);
    final bare = TixLock.parse('# c\n\ncommit = ${'a' * 40}\n');
    expect(bare.version, 'a' * 12);
  });

  test('targets name their library and cache key', () {
    const android = GoTarget(
      goos: 'android',
      goarch: 'arm',
      goarm: '7',
      variant: 'api23',
    );
    expect(android.fileName, 'libtix.so');
    expect(android.key, 'android-arm-7-api23');
    expect(android.noticesTarget, 'android/arm');
    expect(
      const GoTarget(goos: 'ios', goarch: 'arm64').fileName,
      'libtix.dylib',
    );
    expect(
      const GoTarget(goos: 'darwin', goarch: 'arm64').fileName,
      'libtix.dylib',
    );
    expect(
      const GoTarget(goos: 'windows', goarch: 'amd64').fileName,
      'libtix.dll',
    );
    expect(const GoTarget(goos: 'linux', goarch: 'amd64').key, 'linux-amd64');
  });

  test('the cache lives under the user cache directory', () {
    final dir = LibtixBuilder.defaultCacheRoot({
      'HOME': '/home/a',
      'LOCALAPPDATA': r'C:\Users\a\AppData\Local',
    });
    expect(dir.path, contains('tix-mobile'));
    expect(dir.path, endsWith('libtix'));
  });
}
