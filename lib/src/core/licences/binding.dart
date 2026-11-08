// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io' show gzip;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tix_mobile/src/core/licences/notices.dart';
import 'package:tix_mobile/src/core/licences/packages.g.dart';

/// Where the merged notices of every libtix target are bundled.
const engineNoticesAsset = 'assets/licenses/libtix.json';

/// The app's binding: Flutter's, with a Licenses page that lists what ships.
class TixBinding extends WidgetsFlutterBinding {
  /// Whether this build bundles the embedded engine, asked when the Licenses
  /// page first opens.
  static bool Function() engineBundled = () => false;

  /// Creates the binding once and returns it.
  static WidgetsBinding ensureInitialized({
    required bool Function() engineBundled,
  }) {
    TixBinding.engineBundled = engineBundled;
    if (!_created) {
      _created = true;
      TixBinding();
    }
    return WidgetsBinding.instance;
  }

  static var _created = false;

  @override
  // Flutter's own collector lists every package in the build graph, dev
  // tools included; this one replaces it rather than adding to it, so it
  // must not call super.
  // ignore: must_call_super
  void initLicenses() {
    LicenseRegistry.addLicense(
      () => shippedLicences(rootBundle, engineBundled: engineBundled()),
    );
  }
}

/// The licences of what ships: Flutter's notices without dev-only packages
/// or licences that ask for none, then the engine's Go modules when
/// [engineBundled].
Stream<LicenseEntry> shippedLicences(
  AssetBundle bundle, {
  required bool engineBundled,
}) async* {
  final zipped = await bundle.load('NOTICES.Z');
  final raw = await compute(_unzip, zipped.buffer.asUint8List());
  final flutter = await compute(_flutterNotices, raw);
  for (final n in flutter) {
    yield LicenseEntryWithLineBreaks(n.packages, n.text);
  }
  final target = engineTarget(Abi.current());
  if (!engineBundled || target == null) return;
  final json = await bundle.loadString(engineNoticesAsset, cache: false);
  for (final n in engineNotices(json, target)) {
    yield LicenseEntryWithLineBreaks(n.packages, n.text);
  }
}

String _unzip(Uint8List bytes) => utf8.decode(gzip.decode(bytes));

List<Notice> _flutterNotices(String raw) =>
    keepShipped(parseFlutterNotices(raw), devOnly: devOnlyPackages);
