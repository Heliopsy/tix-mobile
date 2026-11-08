// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show TimePrefsInput;
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/time_settings.dart';

/// The reader's date format and time zone, kept by tix with their account,
/// and remembered per context so the next start shows dates their way at
/// once.
class TimePrefsRepository {
  /// Reads through [_api] and remembers in [_store].
  TimePrefsRepository(this._api, this._store);

  final TixApi _api;
  final KeyValueStore _store;

  static String _key(String context) => 'time.$context';

  /// The settings last seen for [context], null when none were.
  TimeSettings? remembered(String context) {
    final raw = _store.read(_key(context));
    if (raw == null) return null;
    try {
      return TimeSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  /// The caller's settings at every level, or null from a server too old
  /// to keep them.
  Future<TimeSettings?> settings() async {
    try {
      return await _api.time.settings();
    } on TixException catch (e) {
      if (e.kind == TixErrorKind.notFound) return null;
      rethrow;
    }
  }

  /// Changes the caller's own [format] and [timezone]. A null leaves that
  /// field alone; an empty string inherits the tenant's again.
  Future<TimeSettings> set({String? format, String? timezone}) => _api.time
      .prefsSet(TimePrefsInput(timeFormat: format, timezone: timezone));

  /// Remembers [settings] for [context].
  Future<void> remember(String context, TimeSettings settings) =>
      _store.write(_key(context), jsonEncode(settings.toJson()));
}
