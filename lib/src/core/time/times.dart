// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/time/time_style.dart';

export 'package:tix_mobile/src/core/time/time_style.dart';

/// Hands the reader's [TixTimeStyle] to every screen below it.
class TixTimeScope extends InheritedWidget {
  /// Provides [style] to [child].
  const TixTimeScope({required this.style, required super.child, super.key});

  /// The style in force.
  final TixTimeStyle style;

  /// The nearest style, or the device's when none is provided.
  static TixTimeStyle of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TixTimeScope>()?.style ??
      TixTimeStyle.device;

  @override
  bool updateShouldNotify(TixTimeScope oldWidget) => oldWidget.style != style;
}

/// Short access to the reader's dates and times.
extension TixTimesContext on BuildContext {
  /// How this reader writes dates and times, in this context's language.
  TixTimes get times => TixTimes(
    TixTimeScope.of(this)
        .inLocale(Localizations.localeOf(this).toLanguageTag()),
    l10n,
  );
}

/// [TixTimeStyle] with the words the relative format needs.
class TixTimes {
  /// Writes with [style], in the words of [l10n].
  const TixTimes(this.style, this.l10n);

  /// The style in force.
  final TixTimeStyle style;

  /// The app's strings.
  final AppLocalizations l10n;

  /// [t] with its date and time of day.
  String stamp(DateTime t, {DateTime? now}) =>
      style.stamp(t) ?? ago(t, now: now);

  /// [t] in a list.
  String shortStamp(DateTime t, {DateTime? now}) =>
      style.shortStamp(t) ?? ago(t, now: now);

  /// [t] with its weekday, for a moment just picked.
  String weekdayStamp(DateTime t, {DateTime? now}) =>
      style.weekdayStamp(t) ?? ago(t, now: now);

  /// [t] as a distance from [now], as tix's `Relative` counts it.
  String ago(DateTime t, {DateTime? now}) {
    final d = (now ?? DateTime.now()).difference(t);
    final future = d.isNegative;
    final abs = d.abs();
    int atLeastOne(double v) => v < 1 ? 1 : v.floor();
    if (abs < const Duration(seconds: 45)) {
      return future ? l10n.timeInAMoment : l10n.timeJustNow;
    }
    final hours = abs.inMinutes / 60;
    final l = l10n;
    return switch (abs) {
      < const Duration(hours: 1) =>
        (future ? l.timeInMinutes : l.timeAgoMinutes)(
          atLeastOne(abs.inSeconds / 60),
        ),
      < const Duration(hours: 24) => (future ? l.timeInHours : l.timeAgoHours)(
        atLeastOne(hours),
      ),
      < const Duration(days: 30) => (future ? l.timeInDays : l.timeAgoDays)(
        atLeastOne(hours / 24),
      ),
      < const Duration(days: 365) =>
        (future ? l.timeInMonths : l.timeAgoMonths)(
          atLeastOne(hours / (24 * 30)),
        ),
      _ => (future ? l.timeInYears : l.timeAgoYears)(
        atLeastOne(hours / (24 * 365)),
      ),
    };
  }
}
