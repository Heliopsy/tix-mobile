// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/data/update/release.dart';

/// Why an update could not be checked, verified or installed.
enum UpdateErrorKind {
  /// GitHub could not be reached or answered with an error.
  network,

  /// The release has no archive for this system.
  noAsset,

  /// No key is pinned, the release has no signature, or the signature or a
  /// checksum does not match.
  unverified,

  /// The archive could not be unpacked or the install could not be swapped.
  install,
}

/// A failed update step.
class UpdateException implements Exception {
  /// A failure of [kind], with [detail] for the log.
  const UpdateException(this.kind, [this.detail = '']);

  /// What went wrong.
  final UpdateErrorKind kind;

  /// What the step saw, for the log only.
  final String detail;

  @override
  String toString() => 'UpdateException(${kind.name}): $detail';
}

/// Where releases are published.
abstract interface class ReleaseFeed {
  /// The latest published release, null when there is none.
  Future<Release?> latest();

  /// The whole of a small file such as `SHA256SUMS`.
  Future<List<int>> bytes(Uri url);

  /// Downloads [url] into [to], reporting the share received so far.
  Future<void> download(
    Uri url,
    File to, {
    void Function(double progress)? onProgress,
  });
}

/// [ReleaseFeed] over GitHub's REST API for one repository. It marshals and
/// nothing else: which release counts and whether it can be trusted is
/// decided by the caller.
class GitHubReleaseFeed implements ReleaseFeed {
  /// Reads releases of [repo] (`owner/name`).
  GitHubReleaseFeed({this.repo = 'heliopsy/tix-mobile', Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(minutes: 5),
              headers: {'User-Agent': 'tix-mobile'},
            ),
          );

  /// The repository, `owner/name`.
  final String repo;

  final Dio _dio;

  @override
  Future<Release?> latest() async {
    try {
      final r = await _dio.get<Map<String, Object?>>(
        'https://api.github.com/repos/$repo/releases/latest',
        options: Options(
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
          validateStatus: (s) => s == 200 || s == 404,
        ),
      );
      final data = r.data;
      if (r.statusCode == 404 || data == null) return null;
      return Release.fromJson(data);
    } on DioException catch (e) {
      throw UpdateException(UpdateErrorKind.network, e.message ?? '$e');
    }
  }

  @override
  Future<List<int>> bytes(Uri url) async {
    try {
      final r = await _dio.getUri<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return r.data ?? const [];
    } on DioException catch (e) {
      throw UpdateException(UpdateErrorKind.network, e.message ?? '$e');
    }
  }

  @override
  Future<void> download(
    Uri url,
    File to, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      await _dio.downloadUri(
        url,
        to.path,
        onReceiveProgress: (got, total) {
          if (total > 0) onProgress?.call(got / total);
        },
      );
    } on DioException catch (e) {
      throw UpdateException(UpdateErrorKind.network, e.message ?? '$e');
    }
  }
}
