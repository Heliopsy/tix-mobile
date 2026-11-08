// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/licences/notices.dart';
import 'package:tix_mobile/src/core/licences/packages.g.dart';

const _bsd =
    'Redistribution and use in source and binary forms, with or '
    'without modification, are permitted provided that the following '
    'conditions are met.';
const _cc0 = 'Creative Commons Legal Code\n\nCC0 1.0 Universal\n\nwaived.';
const _unlicense =
    'This is free and unencumbered software released into\n'
    'the public domain.';
const _zeroBsd =
    'Permission to use, copy, modify, and/or distribute this '
    'software for any purpose with or without fee is hereby granted.\n\n'
    'THE SOFTWARE IS PROVIDED "AS IS".';
const _isc =
    'Permission to use, copy, modify, and/or distribute this '
    'software for any purpose with or without fee is hereby granted, '
    'provided that the above copyright notice appear in all copies.';

String _notices(List<(List<String>, String)> blocks) =>
    blocks.map((b) => '${b.$1.join('\n')}\n\n${b.$2}').join('\n${'-' * 80}\n');

void main() {
  test('the package sets come from the package graph', () {
    expect(runtimePackages, containsAll(['dio', 'flutter', 'riverpod']));
    expect(devOnlyPackages, containsAll(['build_runner', 'analyzer']));
    expect(runtimePackages.intersection(devOnlyPackages), isEmpty);
    expect(devOnlyPackages, isNot(contains('tix_mobile')));
  });

  test('parses blocks as Flutter does', () {
    final raw = _notices([
      (['dio'], 'MIT'),
      (['skia', 'angle'], 'BSD'),
    ]);
    final n = parseFlutterNotices(raw);
    expect(n.map((b) => b.packages), [
      ['dio'],
      ['skia', 'angle'],
    ]);
    expect(parseFlutterNotices('no packages').single.packages, isEmpty);
  });

  test('keeps what ships and drops dev tools and no-notice licences', () {
    final kept = keepShipped(
      parseFlutterNotices(
        _notices([
          (['dio'], _bsd),
          (['build_runner'], _bsd),
          (['analyzer', 'collection'], _bsd),
          (['skia'], _bsd),
          (['some_pd_package'], _cc0),
          (['unlicensed'], _unlicense),
          (['zero'], _zeroBsd),
          (['isc'], _isc),
        ]),
      ),
      devOnly: devOnlyPackages,
    );
    final names = kept.expand((n) => n.packages).toList();
    expect(names, ['dio', 'collection', 'skia', 'isc']);
  });

  test('no-notice licences are recognised and others are kept', () {
    expect(needsNoNotice(_cc0), isTrue);
    expect(needsNoNotice(_unlicense), isTrue);
    expect(needsNoNotice(_zeroBsd), isTrue);
    expect(
      needsNoNotice(
        'The source code for SQLite is in the public domain. No claim of '
        'copyright is made on any part of the core source code.',
      ),
      isTrue,
    );
    expect(
      needsNoNotice(
        'The Ahem font belongs to the public domain. In jurisdictions that '
        'do not recognize public domain ownership, the following applies.',
      ),
      isFalse,
    );
    expect(needsNoNotice(_isc), isFalse);
    expect(needsNoNotice(_bsd), isFalse);
    expect(needsNoNotice('something unknown'), isFalse);
  });

  test('every shipped engine target maps to a GOOS/GOARCH', () {
    expect(engineTarget(Abi.androidArm64), 'android/arm64');
    expect(engineTarget(Abi.androidArm), 'android/arm');
    expect(engineTarget(Abi.androidX64), 'android/amd64');
    expect(engineTarget(Abi.iosArm64), 'ios/arm64');
    expect(engineTarget(Abi.iosX64), 'ios/amd64');
    expect(engineTarget(Abi.macosArm64), 'darwin/arm64');
    expect(engineTarget(Abi.macosX64), 'darwin/amd64');
    expect(engineTarget(Abi.linuxX64), 'linux/amd64');
    expect(engineTarget(Abi.linuxArm64), 'linux/arm64');
    expect(engineTarget(Abi.windowsX64), 'windows/amd64');
    expect(engineTarget(Abi.fuchsiaX64), isNull);
  });

  test('the bundled engine notices list tix and its Go modules', () {
    final json = File('assets/licenses/libtix.json').readAsStringSync();
    for (final target in [
      'android/arm64',
      'ios/arm64',
      'darwin/arm64',
      'linux/amd64',
      'windows/amd64',
    ]) {
      final n = engineNotices(json, target);
      final names = n.map((e) => e.packages.single).toSet();
      expect(
        names,
        containsAll(['github.com/heliopsy/tix', 'modernc.org/sqlite', 'Go']),
        reason: target,
      );
      expect(n.where((e) => e.text.contains('GNU AFFERO')), isNotEmpty);
      expect(n.where((e) => needsNoNotice(e.text)), isEmpty, reason: target);
    }
    expect(engineNotices(json, 'plan9/386'), isEmpty);
  });
}
