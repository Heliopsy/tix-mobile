// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/l10n/durations.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final de = lookupAppLocalizations(const Locale('de'));

  test('reads Go durations as tix writes them', () {
    expect(parseGoDuration('2h0m0s'), const Duration(hours: 2));
    expect(parseGoDuration('1h30m'), const Duration(minutes: 90));
    expect(parseGoDuration('45m0s'), const Duration(minutes: 45));
    expect(parseGoDuration('1.5h'), const Duration(minutes: 90));
    expect(parseGoDuration('300ms'), const Duration(milliseconds: 300));
    expect(parseGoDuration('0'), Duration.zero);
    expect(parseGoDuration('-5m'), const Duration(minutes: -5));
  });

  test('refuses what is not a duration', () {
    for (final bad in ['', 'soon', '2 hours', '2h junk', 'h', '5x']) {
      expect(parseGoDuration(bad), isNull, reason: bad);
    }
  });

  test('formats whole days, hours and minutes', () {
    expect(humanDuration(en, '2h0m0s'), '2 h');
    expect(humanDuration(en, '1h30m0s'), '1 h 30 min');
    expect(humanDuration(en, '36h0m0s'), '1 d 12 h');
    expect(humanDuration(en, '24h'), '1 d');
    expect(humanDuration(en, '45s'), '45 s');
    expect(humanDuration(de, '2h0m0s'), '2 Std.');
  });

  test('passes anything else through untouched', () {
    expect(humanDuration(en, ''), '');
    expect(humanDuration(en, 'forever'), 'forever');
  });
}
