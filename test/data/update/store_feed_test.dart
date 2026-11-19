// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';
import 'package:tix_mobile/src/data/update/store_feed.dart';

import '../../helpers/fake_tix.dart';

void main() {
  final page = Uri.parse('https://apps.apple.com/app/id6834556706');

  group('appStoreRelease', () {
    test('reads the version the App Store serves', () {
      final r = appStoreRelease({
        'resultCount': 1,
        'results': [
          {'version': '0.21.0', 'bundleId': 'red.tix.tixMobile'},
        ],
      }, page: page)!;
      expect(r.version, const ReleaseVersion(0, 21, 0));
      expect(r.page, page);
      expect(r.assets, isEmpty);
      expect(r.prerelease, isFalse);
    });

    test('is null when the app is not listed or the answer is odd', () {
      expect(
        appStoreRelease({'resultCount': 0, 'results': <Object>[]}, page: page),
        isNull,
      );
      expect(appStoreRelease({'results': 'x'}, page: page), isNull);
      expect(appStoreRelease([1, 2], page: page), isNull);
      expect(
        appStoreRelease({
          'results': [
            {'version': 'two'},
          ],
        }, page: page),
        isNull,
      );
      expect(
        appStoreRelease({
          'results': [
            {'trackName': 'tix'},
          ],
        }, page: page),
        isNull,
      );
    });
  });

  group('storefrontOf', () {
    test('takes the region of a locale', () {
      expect(storefrontOf('de_DE'), 'de');
      expect(storefrontOf('en-GB'), 'gb');
      expect(storefrontOf('bg_BG.UTF-8'), 'bg');
      expect(storefrontOf('sr_Latn_RS'), 'rs');
    });

    test('is empty without one', () {
      expect(storefrontOf('en'), '');
      expect(storefrontOf('C'), '');
    });
  });

  group('AppStoreReleaseFeed', () {
    AppStoreReleaseFeed feed(FakeAdapter adapter, {String country = ''}) =>
        AppStoreReleaseFeed(
          country: country,
          dio: Dio()..httpClientAdapter = adapter,
        );

    test('asks Apple about the bundle in the storefront', () async {
      final adapter = FakeAdapter(
        (_) => const FakeResponse(
          200,
          '{"resultCount":1,"results":[{"version":"0.21.0"}]}',
          'text/javascript; charset=utf-8',
        ),
      );
      final r = await feed(adapter, country: 'de').latest();
      expect(r!.version.toString(), '0.21.0');
      expect(r.page, appStorePage);
      final uri = adapter.requests.single.uri;
      expect(uri.host, 'itunes.apple.com');
      expect(uri.path, '/lookup');
      expect(uri.queryParameters, {
        'bundleId': 'red.tix.tixMobile',
        'country': 'de',
      });
    });

    test('a failed or garbled answer is a network failure', () async {
      final down = feed(FakeAdapter((_) => const FakeResponse(503, 'no')));
      await expectLater(
        down.latest(),
        throwsA(
          isA<UpdateException>().having(
            (e) => e.kind,
            'kind',
            UpdateErrorKind.network,
          ),
        ),
      );
      final garbled = feed(
        FakeAdapter((_) => const FakeResponse(200, '<html>', 'text/html')),
      );
      await expectLater(garbled.latest(), throwsA(isA<UpdateException>()));
    });

    test('has nothing to download', () async {
      final f = feed(FakeAdapter((_) => const FakeResponse(200, '{}')));
      await expectLater(
        f.download(appStorePage, File('unused')),
        throwsA(isA<UpdateException>()),
      );
      await expectLater(f.bytes(appStorePage), throwsA(isA<UpdateException>()));
    });
  });
}
