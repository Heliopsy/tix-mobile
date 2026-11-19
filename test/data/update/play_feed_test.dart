// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/update/play_feed.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

import '../../helpers/fake_play.dart';

void main() {
  group('versionOfPlayCode', () {
    test('reads back what build-version.sh stamps', () {
      expect(versionOfPlayCode(21000), const ReleaseVersion(0, 21, 0));
      expect(versionOfPlayCode(1002003), const ReleaseVersion(1, 2, 3));
      expect(versionOfPlayCode(12000999), const ReleaseVersion(12, 0, 999));
    });

    test('is null for no code', () {
      expect(versionOfPlayCode(0), isNull);
      expect(versionOfPlayCode(-1), isNull);
    });
  });

  group('PlayUpdateInfo', () {
    test('reads the channel answer', () {
      final i = PlayUpdateInfo.fromMap({
        'available': true,
        'versionCode': 21000,
        'flexible': true,
      })!;
      expect(i.available, isTrue);
      expect(i.versionCode, 21000);
      expect(i.flexible, isTrue);
    });

    test('is null for the oss stand-in and odd answers', () {
      expect(PlayUpdateInfo.fromMap(null), isNull);
      expect(PlayUpdateInfo.fromMap({'available': true}), isNull);
      expect(
        PlayUpdateInfo.fromMap({'available': 'yes', 'versionCode': 1}),
        isNull,
      );
    });

    test("reads the update worker's link", () {
      final i = PlayUpdateInfo.fromUri(
        Uri.parse('tixwidget://update?play=1&code=21000'),
      )!;
      expect(i.available, isTrue);
      expect(i.versionCode, 21000);
      expect(
        PlayUpdateInfo.fromUri(Uri.parse('tixwidget://update?play=0&code=0'))!
            .available,
        isFalse,
      );
    });

    test('is null for a link without Play', () {
      expect(PlayUpdateInfo.fromUri(null), isNull);
      expect(PlayUpdateInfo.fromUri(Uri.parse('tixwidget://update')), isNull);
      expect(
        PlayUpdateInfo.fromUri(Uri.parse('tixwidget://update?code=21000')),
        isNull,
      );
      expect(
        PlayUpdateInfo.fromUri(Uri.parse('tixwidget://update?play=1&code=x')),
        isNull,
      );
    });
  });

  group('PlayReleaseFeed', () {
    test('offers the version Play serves, on the Play listing', () async {
      final play = FakePlayUpdates(
        answer: const PlayUpdateInfo(available: true, versionCode: 21003),
      );
      final r = (await PlayReleaseFeed(play).latest())!;
      expect(r.version, const ReleaseVersion(0, 21, 3));
      expect(r.tag, '21003');
      expect(
        r.page,
        Uri.parse(
          'https://play.google.com/store/apps/details?id=red.tix.tix_mobile',
        ),
      );
      expect(r.assets, isEmpty);
      expect(play.asks, 1);
    });

    test('offers nothing when Play has no update or is not there', () async {
      final play = FakePlayUpdates(
        answer: const PlayUpdateInfo(available: false, versionCode: 21003),
      );
      expect(await PlayReleaseFeed(play).latest(), isNull);
      play.answer = null;
      expect(await PlayReleaseFeed(play).latest(), isNull);
    });

    test('passes a failure on', () async {
      final play = FakePlayUpdates()
        ..failure = const UpdateException(UpdateErrorKind.network);
      await expectLater(
        PlayReleaseFeed(play).latest(),
        throwsA(isA<UpdateException>()),
      );
    });

    test('has no files to download', () async {
      final f = PlayReleaseFeed(FakePlayUpdates());
      await expectLater(f.bytes(playListing), throwsA(isA<UpdateException>()));
      await expectLater(
        f.download(playListing, File('unused')),
        throwsA(isA<UpdateException>()),
      );
    });
  });
}
