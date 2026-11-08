// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The named date formats tix offers, in the order its chooser lists them
/// (`core.TimeFormatNames`).
const tixTimeFormats = [
  'iso',
  'rfc3339',
  'short',
  'long',
  'dotted',
  'dayfirst',
  'us',
  'relative',
];

var _zonesLoaded = false;

void _loadZones() {
  if (_zonesLoaded) return;
  tzdata.initializeTimeZones();
  _zonesLoaded = true;
}

/// Every IANA zone name the app can render in, sorted.
List<String> timeZoneNames() {
  _loadZones();
  return tz.timeZoneDatabase.locations.keys.toList()..sort();
}

/// The zone named [name], or null for an empty or unknown name, which
/// renders in the device's own zone.
tz.Location? timeZoneNamed(String name) {
  final n = name.trim();
  if (n.isEmpty || n.toLowerCase() == 'local') return null;
  _loadZones();
  if (n.toLowerCase() == 'utc') return tz.UTC;
  try {
    return tz.getLocation(n);
  } on tz.LocationNotFoundException {
    return null;
  }
}

/// How instants are written for a reader: tix's `output.TimeStyle`, ported.
///
/// [format] is one of [tixTimeFormats], or empty for the device's own
/// locale formats, which is what the app shows until a server says
/// otherwise. [zone] is where instants are read, or null for the device's
/// zone.
@immutable
class TixTimeStyle {
  /// A style in [format] and [zone], with month and weekday names in
  /// [locale].
  const TixTimeStyle({this.format = '', this.zone, this.locale = 'en'});

  /// The style the effective server preference names, in [locale]. An
  /// unknown format or zone falls back to the device's.
  factory TixTimeStyle.named(
    String format,
    String zone, {
    String locale = 'en',
  }) {
    final f = format.trim().toLowerCase();
    return TixTimeStyle(
      format: tixTimeFormats.contains(f) ? f : '',
      zone: timeZoneNamed(zone),
      locale: locale,
    );
  }

  /// The device's own formats, in its zone.
  static const device = TixTimeStyle();

  /// One of [tixTimeFormats], or empty for the device's locale formats.
  final String format;

  /// The zone instants are read in; null is the device's.
  final tz.Location? zone;

  /// The locale month and weekday names are written in.
  final String locale;

  /// Whether this style follows a server preference rather than the device.
  bool get named => format.isNotEmpty;

  /// Whether instants are written as a distance from now.
  bool get relative => format == 'relative';

  /// This style with names in [locale].
  TixTimeStyle inLocale(String locale) =>
      TixTimeStyle(format: format, zone: zone, locale: locale);

  /// This style read in UTC, for values that are calendar dates rather
  /// than instants: a date field, or a due date tix parsed from a line.
  TixTimeStyle get plain {
    _loadZones();
    return TixTimeStyle(format: format, zone: tz.UTC, locale: locale);
  }

  /// The calendar date [d] names, written without moving it to any zone.
  String calendar(DateTime d) =>
      plain.date(DateTime.utc(d.year, d.month, d.day));

  /// [t] as a wall clock in [zone].
  DateTime wall(DateTime t) {
    final z = zone;
    return z == null ? t.toLocal() : tz.TZDateTime.from(t, z);
  }

  /// [t]'s wall clock in [zone] as a plain local [DateTime], for a picker
  /// that knows only the device's zone.
  DateTime pickable(DateTime t) {
    final w = wall(t);
    return DateTime(
      w.year,
      w.month,
      w.day,
      w.hour,
      w.minute,
      w.second,
      w.millisecond,
    );
  }

  /// The instant the wall clock [local] names in [zone], for a time a
  /// person picked.
  DateTime fromWall(DateTime local) {
    final z = zone;
    if (z == null) return local;
    return tz.TZDateTime(
      z,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
    ).toUtc();
  }

  /// Midnight of the calendar day [t] falls on in [zone], as a plain date.
  DateTime day(DateTime t) {
    final w = wall(t);
    return DateTime(w.year, w.month, w.day);
  }

  String _f(String pattern, DateTime t) =>
      DateFormat(pattern, locale).format(wall(t));

  String _device(DateFormat format, DateTime t) => format.format(wall(t));

  /// An instant with its date and time of day, as tix's `Format` writes it.
  /// Null for the relative format, which needs words.
  String? stamp(DateTime t) => switch (format) {
    '' => _device(DateFormat.yMMMd(locale).add_Hm(), t),
    'rfc3339' => _rfc3339(t),
    'short' => _f('d MMM HH:mm', t),
    'us' => _f('MM/dd/yyyy h:mm a', t),
    'dotted' => _f('dd.MM.yyyy HH:mm', t),
    'dayfirst' => _f('dd/MM/yyyy HH:mm', t),
    'long' => _f('d MMM yyyy HH:mm', t),
    'relative' => null,
    _ => _f('yyyy-MM-dd HH:mm', t),
  };

  /// An instant in a list, where the year is usually this one.
  String? shortStamp(DateTime t) =>
      named ? stamp(t) : _device(DateFormat.MMMd(locale).add_Hm(), t);

  /// An instant with the weekday, for a moment a person just picked.
  String? weekdayStamp(DateTime t) =>
      named ? stamp(t) : _device(DateFormat.MMMEd(locale).add_Hm(), t);

  /// [t]'s calendar date, as tix's `Date` writes it.
  String date(DateTime t) => switch (format) {
    '' => _device(DateFormat.yMMMd(locale), t),
    'dotted' => _f('dd.MM.yyyy', t),
    'dayfirst' => _f('dd/MM/yyyy', t),
    'us' => _f('MM/dd/yyyy', t),
    'long' || 'short' => _f('d MMM yyyy', t),
    _ => _f('yyyy-MM-dd', t),
  };

  /// [t]'s calendar date with its weekday, for a due date on its own.
  String longDate(DateTime t) => named
      ? '${_f('EEE', t)} ${date(t)}'
      : _device(DateFormat.yMMMEd(locale), t);

  /// [t]'s day and month, as tix's `DayMonth` writes it.
  String dayMonth(DateTime t) => switch (format) {
    '' => _device(DateFormat.MMMd(locale), t),
    'dotted' => _f('dd.MM', t),
    'dayfirst' => _f('dd/MM', t),
    'us' => _f('MM/dd', t),
    'long' || 'short' => _f('d MMM', t),
    _ => _f('MM-dd', t),
  };

  /// [t]'s day and month with the weekday, for a date a person picked.
  String weekdayDate(DateTime t) => named
      ? '${_f('EEE', t)} ${dayMonth(t)}'
      : _device(DateFormat.MMMEd(locale), t);

  /// [t]'s weekday, abbreviated.
  String weekday(DateTime t) => _f('EEE', t);

  /// [t]'s time of day.
  String clock(DateTime t) => switch (format) {
    '' => _device(DateFormat.Hm(locale), t),
    'us' => _f('h:mm a', t),
    _ => _f('HH:mm', t),
  };

  /// The zone's name for [t], such as `EET`, or the device's.
  String zoneAbbreviation(DateTime t) {
    return wall(t).timeZoneName;
  }

  String _rfc3339(DateTime t) {
    final w = wall(t);
    final offset = w.timeZoneOffset;
    if (offset == Duration.zero) {
      return '${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(w)}Z';
    }
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return '${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(w)}$sign$hh:$mm';
  }

  @override
  bool operator ==(Object other) =>
      other is TixTimeStyle &&
      other.format == format &&
      other.zone?.name == zone?.name &&
      other.locale == locale;

  @override
  int get hashCode => Object.hash(format, zone?.name, locale);
}
