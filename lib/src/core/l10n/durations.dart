// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/l10n/generated/app_localizations.dart';

final _part = RegExp(r'(\d+(?:\.\d+)?)(ns|us|µs|ms|s|m|h)');

/// Reads a Go duration as tix writes one ("2h0m0s", "90m", "1.5h"), or null
/// when [text] is not one.
Duration? parseGoDuration(String text) {
  final value = text.trim();
  if (value.isEmpty) return null;
  final negative = value.startsWith('-');
  final body = negative || value.startsWith('+') ? value.substring(1) : value;
  if (body == '0') return Duration.zero;
  var micros = 0.0;
  var at = 0;
  for (final m in _part.allMatches(body)) {
    if (m.start != at) return null;
    at = m.end;
    final n = double.parse(m[1]!);
    micros +=
        n *
        switch (m[2]!) {
          'h' => Duration.microsecondsPerHour,
          'm' => Duration.microsecondsPerMinute,
          's' => Duration.microsecondsPerSecond,
          'ms' => Duration.microsecondsPerMillisecond,
          'ns' => 0.001,
          _ => 1,
        };
  }
  if (at != body.length || at == 0) return null;
  final d = Duration(microseconds: micros.round());
  return negative ? -d : d;
}

/// [d] the way a person reads it: "2 h", "1 h 30 min", "1 d 12 h".
/// Whole days, hours and minutes; seconds only for a span under a minute.
String formatDuration(AppLocalizations l10n, Duration d) {
  if (d.inSeconds < 60) return l10n.durationSeconds(d.inSeconds);
  final days = d.inDays;
  final hours = d.inHours % 24;
  final minutes = d.inMinutes % 60;
  return [
    if (days > 0) l10n.durationDays(days),
    if (hours > 0) l10n.durationHours(hours),
    if (minutes > 0) l10n.durationMinutes(minutes),
  ].join(' ');
}

/// tix's duration [text] made readable, or [text] itself when it is not a
/// duration; empty stays empty.
String humanDuration(AppLocalizations l10n, String text) {
  final d = parseGoDuration(text);
  return d == null ? text : formatDuration(l10n, d);
}
