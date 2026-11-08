// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:developer' as developer;

/// Writes a line to the platform log under the `tix` name.
void log(String message, {Object? error, StackTrace? stackTrace}) =>
    developer.log(message, name: 'tix', error: error, stackTrace: stackTrace);
