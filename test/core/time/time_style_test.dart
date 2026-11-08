// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tix_mobile/src/core/time/time_style.dart';

void main() {
  setUpAll(initializeDateFormatting);

  // tix's own example instant, 14:05:09 UTC on 21 September 2026.
  final t = DateTime.utc(2026, 9, 21, 14, 5, 9);

  TixTimeStyle style(String format, [String zone = 'UTC']) =>
      TixTimeStyle.named(format, zone);

  test("every named format writes what tix's TimeStyle writes", () {
    // The strings in output/timestyle.go's comments, in UTC.
    expect(style('iso').stamp(t), '2026-09-21 14:05');
    expect(style('rfc3339').stamp(t), '2026-09-21T14:05:09Z');
    expect(style('short').stamp(t), '21 Sep 14:05');
    expect(style('us').stamp(t), '09/21/2026 2:05 PM');
    expect(style('dotted').stamp(t), '21.09.2026 14:05');
    expect(style('dayfirst').stamp(t), '21/09/2026 14:05');
    expect(style('long').stamp(t), '21 Sep 2026 14:05');
    expect(style('relative').stamp(t), isNull);
  });

  test('a zone moves the clock and the offset', () {
    expect(style('dotted', 'Europe/Sofia').stamp(t), '21.09.2026 17:05');
    expect(
      style('rfc3339', 'Europe/Sofia').stamp(t),
      '2026-09-21T17:05:09+03:00',
    );
    expect(
      style('rfc3339', 'America/New_York').stamp(t),
      '2026-09-21T10:05:09-04:00',
    );
    expect(style('iso', 'Europe/Sofia').zoneAbbreviation(t), 'EEST');
  });

  test('dates and day-months follow the format, as Date and DayMonth do', () {
    expect(style('iso').date(t), '2026-09-21');
    expect(style('dotted').date(t), '21.09.2026');
    expect(style('dayfirst').date(t), '21/09/2026');
    expect(style('us').date(t), '09/21/2026');
    expect(style('long').date(t), '21 Sep 2026');
    expect(style('iso').dayMonth(t), '09-21');
    expect(style('dotted').dayMonth(t), '21.09');
    expect(style('us').dayMonth(t), '09/21');
    expect(style('short').dayMonth(t), '21 Sep');
    expect(style('us').clock(t), '2:05 PM');
    expect(style('iso').clock(t), '14:05');
  });

  test('an empty or unknown preference is the device', () {
    expect(style('').named, isFalse);
    expect(style('nonsense').named, isFalse);
    expect(TixTimeStyle.named('iso', 'Mars/Olympus').zone, isNull);
    expect(TixTimeStyle.named('iso', '').zone, isNull);
    expect(TixTimeStyle.named('iso', 'utc').stamp(t), '2026-09-21 14:05');
    expect(
      TixTimeStyle.device.stamp(t),
      isNot(contains('2026-09-21')),
      reason: 'the device writes its locale format, not ISO',
    );
  });

  test('day boundaries count in the zone', () {
    final sofia = style('iso', 'Europe/Sofia');
    final evening = DateTime.utc(2026, 11, 1, 22, 30);
    expect(sofia.day(evening), DateTime(2026, 11, 2));
    expect(style('iso').day(evening), DateTime(2026, 11));
  });

  test('a picked wall clock is read in the zone', () {
    final sofia = style('iso', 'Europe/Sofia');
    final picked = sofia.fromWall(DateTime(2026, 11, 2, 9));
    expect(picked, DateTime.utc(2026, 11, 2, 7));
    expect(sofia.pickable(picked), DateTime(2026, 11, 2, 9));
  });

  test('a calendar date does not move with the zone', () {
    final ny = style('dotted', 'America/New_York');
    expect(ny.calendar(DateTime.parse('2026-11-01')), '01.11.2026');
    expect(ny.date(DateTime.utc(2026, 11)), '31.10.2026');
  });

  test('month names follow the locale', () {
    expect(
      TixTimeStyle.named('long', 'UTC', locale: 'de').stamp(t),
      '21 Sept. 2026 14:05',
    );
  });

  test('the zone list carries aliases and UTC', () {
    final names = timeZoneNames();
    expect(names, containsAll(['Europe/Sofia', 'Europe/Kiev', 'UTC']));
  });
}
