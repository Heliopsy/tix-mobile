// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:tix_mobile/src/core/time/times.dart';

/// [when] as a day in the reader's date format and zone.
String formatDay(BuildContext context, DateTime when) =>
    context.times.style.date(when);

/// [when] as a day and time in the reader's date format and zone.
String formatMoment(BuildContext context, DateTime when) =>
    context.times.stamp(when);
