// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// [when] as a day in the reader's language and zone: "8 Nov 2026".
String formatDay(BuildContext context, DateTime when) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
        .format(when.toLocal());

/// [when] as a day and time in the reader's language and zone.
String formatMoment(BuildContext context, DateTime when) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_Hm().format(when.toLocal());
}
