// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

/// The iOS app's bundle identifier, which Apple's lookup is asked about.
const appStoreBundleId = 'red.tix.tixMobile';

/// The app's App Store page.
final Uri appStorePage = Uri.parse('https://apps.apple.com/app/id6834556706');

/// The App Store's release in Apple's lookup answer, opening [page]; null
/// when the app is not listed there or the version is not one.
Release? appStoreRelease(Object? json, {required Uri page}) {
  if (json is! Map<String, Object?>) return null;
  final results = json['results'];
  if (results is! List<Object?> || results.isEmpty) return null;
  final first = results.first;
  if (first is! Map<String, Object?>) return null;
  final text = first['version'];
  if (text is! String) return null;
  final version = ReleaseVersion.tryParse(text);
  if (version == null) return null;
  return Release(tag: text, version: version, page: page, assets: const []);
}

/// [ReleaseFeed] over Apple's public lookup: the version the App Store
/// serves in [country], linking to the App Store page. It has no files.
class AppStoreReleaseFeed implements ReleaseFeed {
  /// Asks about [bundleId] in the storefront of [country] (ISO 3166, empty
  /// for Apple's default).
  AppStoreReleaseFeed({
    this.bundleId = appStoreBundleId,
    this.country = '',
    Uri? page,
    Dio? dio,
  }) : page = page ?? appStorePage,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 20),
               receiveTimeout: const Duration(seconds: 30),
               headers: {'User-Agent': 'tix-mobile'},
             ),
           );

  /// The bundle identifier.
  final String bundleId;

  /// The storefront.
  final String country;

  /// Where an update is installed from.
  final Uri page;

  final Dio _dio;

  /// The lookup address.
  Uri get lookup => Uri.https('itunes.apple.com', '/lookup', {
    'bundleId': bundleId,
    if (country.isNotEmpty) 'country': country,
  });

  @override
  Future<Release?> latest() async {
    try {
      // Apple answers as text/javascript, which Dio would not decode.
      final r = await _dio.getUri<String>(
        lookup,
        options: Options(responseType: ResponseType.plain),
      );
      return appStoreRelease(jsonDecode(r.data ?? ''), page: page);
    } on DioException catch (e) {
      throw UpdateException(UpdateErrorKind.network, e.message ?? '$e');
    } on FormatException catch (e) {
      throw UpdateException(UpdateErrorKind.network, e.message);
    }
  }

  @override
  Future<List<int>> bytes(Uri url) async =>
      throw const UpdateException(UpdateErrorKind.noAsset, 'the App Store');

  @override
  Future<void> download(
    Uri url,
    File to, {
    void Function(double progress)? onProgress,
  }) async =>
      throw const UpdateException(UpdateErrorKind.noAsset, 'the App Store');
}

/// The storefront of a locale such as `de_DE` or `en-US`; empty when it
/// names no region.
String storefrontOf(String localeName) {
  final parts = localeName.split(RegExp('[-_.@]'));
  for (final p in parts.skip(1)) {
    if (RegExp(r'^[A-Za-z]{2}$').hasMatch(p)) return p.toLowerCase();
  }
  return '';
}
