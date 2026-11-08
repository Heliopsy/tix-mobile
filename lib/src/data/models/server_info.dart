// SPDX-License-Identifier: AGPL-3.0-or-later

/// What the server reports about itself and the caller's date display, as
/// the generated client reads it.
library;

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        Installation,
        ServerStatus,
        StatusReport,
        TOTPReport,
        TimePrefs,
        TimePrefsInput,
        TimeSettings,
        Work;

/// The date styles tix can show, in the order its settings list them.
const timeFormats = [
  'iso',
  'rfc3339',
  'short',
  'long',
  'dotted',
  'dayfirst',
  'us',
  'relative',
];
