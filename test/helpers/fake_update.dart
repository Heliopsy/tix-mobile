// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart';
import 'package:tix_mobile/src/data/update/installer.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

/// A release feed answered from memory.
class FakeReleaseFeed implements ReleaseFeed {
  /// Answers [release] and serves [files] by URL.
  FakeReleaseFeed({this.release, Map<Uri, List<int>>? files})
    : files = files ?? {};

  /// What [latest] answers.
  Release? release;

  /// The bytes behind each URL.
  final Map<Uri, List<int>> files;

  /// Thrown by every call when set.
  UpdateException? failure;

  /// The URLs downloaded with [download].
  final downloads = <Uri>[];

  /// The URLs read with [bytes].
  final reads = <Uri>[];

  @override
  Future<Release?> latest() async {
    if (failure case final f?) throw f;
    return release;
  }

  @override
  Future<List<int>> bytes(Uri url) async {
    if (failure case final f?) throw f;
    reads.add(url);
    return files[url] ?? (throw const UpdateException(UpdateErrorKind.network));
  }

  @override
  Future<void> download(
    Uri url,
    File to, {
    void Function(double progress)? onProgress,
  }) async {
    if (failure case final f?) throw f;
    downloads.add(url);
    onProgress?.call(0.5);
    await to.writeAsBytes(files[url]!);
    onProgress?.call(1);
  }
}

/// An installer that records instead of touching the install.
class FakeInstaller implements UpdateInstaller {
  /// The install at [target].
  FakeInstaller({
    this.installTarget = const InstallTarget(path: '/opt/tix', writable: true),
  });

  /// What [target] answers.
  InstallTarget? installTarget;

  /// The archives staged, by content.
  final staged = <List<int>>[];

  /// Each apply's relaunch flag.
  final applied = <bool>[];

  /// Thrown by [apply] when set.
  UpdateException? applyFailure;

  /// How often [cleanup] ran.
  int cleanups = 0;

  @override
  Future<InstallTarget?> target() async => installTarget;

  @override
  Future<StagedUpdate> stage(File archive, ReleaseVersion version) async {
    staged.add(await archive.readAsBytes());
    return StagedUpdate(version: version, path: '/opt/.tix.update');
  }

  @override
  Future<void> apply(StagedUpdate update, {required bool relaunch}) async {
    if (applyFailure case final f?) throw f;
    applied.add(relaunch);
  }

  @override
  Future<void> cleanup() async => cleanups++;
}

/// A signing key made for one test, and the public half as the app pins it.
typedef TestKey = ({SimpleKeyPair pair, String public});

/// A fresh Ed25519 key.
Future<TestKey> testKey() async {
  final pair = await Ed25519().newKeyPair();
  final public = await pair.extractPublicKey();
  return (pair: pair, public: base64.encode(public.bytes));
}

/// The raw Ed25519 signature of [message] by [key].
Future<List<int>> sign(List<int> message, TestKey key) async =>
    (await Ed25519().sign(message, keyPair: key.pair)).bytes;

/// `sha256sum` output over [files].
String sumsOf(Map<String, List<int>> files) => [
  for (final MapEntry(:key, :value) in files.entries)
    '${sha256.convert(value)}  $key',
].map((l) => '$l\n').join();

const _base = 'https://github.com/heliopsy/tix-mobile/releases/download';

/// A release of [version] carrying [archives] by name, `SHA256SUMS` over
/// them, and `SHA256SUMS.sig` signed by [signer] unless it is null. The URLs
/// and bytes go into [feed].
Future<Release> publish(
  FakeReleaseFeed feed, {
  required String version,
  required Map<String, List<int>> archives,
  TestKey? signer,
  String? sums,
  bool prerelease = false,
}) async {
  final tag = 'v$version';
  Uri url(String name) => Uri.parse('$_base/$tag/$name');
  final text = utf8.encode(sums ?? sumsOf(archives));
  final assets = <ReleaseAsset>[
    for (final MapEntry(:key, :value) in archives.entries)
      ReleaseAsset(name: key, url: url(key), size: value.length),
    ReleaseAsset(name: 'SHA256SUMS', url: url('SHA256SUMS')),
    if (signer != null)
      ReleaseAsset(name: 'SHA256SUMS.sig', url: url('SHA256SUMS.sig')),
  ];
  for (final MapEntry(:key, :value) in archives.entries) {
    feed.files[url(key)] = value;
  }
  feed.files[url('SHA256SUMS')] = text;
  if (signer != null) {
    feed.files[url('SHA256SUMS.sig')] = await sign(text, signer);
  }
  final release = Release(
    tag: tag,
    version: ReleaseVersion.tryParse(version)!,
    page: Uri.parse('https://github.com/heliopsy/tix-mobile/releases/tag/$tag'),
    assets: assets,
    prerelease: prerelease,
  );
  feed.release = release;
  return release;
}
