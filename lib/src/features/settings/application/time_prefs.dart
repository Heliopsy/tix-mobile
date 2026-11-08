// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/server_info.dart';
import 'package:tix_mobile/src/data/models/server_info.dart';

export 'package:tix_mobile/src/data/models/server_info.dart';

part 'time_prefs.g.dart';

/// The caller's date format and timezone, kept on the server so they follow
/// the person to every device, and the levels they inherit from.
@riverpod
class TimePrefsState extends _$TimePrefsState {
  @override
  Future<TimeSettings> build() =>
      ref.watch(serverInfoRepositoryProvider).time();

  /// Sets the date [format]; empty goes back to the tenant's.
  Future<void> setFormat(String format) => _set(format: format);

  /// Sets the [timezone], an IANA name; empty goes back to the tenant's.
  Future<void> setTimezone(String timezone) => _set(timezone: timezone.trim());

  Future<void> _set({String? format, String? timezone}) async {
    final next = await ref
        .read(serverInfoRepositoryProvider)
        .setTime(format: format, timezone: timezone);
    if (ref.mounted) state = AsyncData(next);
  }
}
