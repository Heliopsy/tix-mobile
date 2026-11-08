// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:developer' as developer;

import 'package:meta/meta.dart';

/// Writes a line to the platform log under the `tix` name.
void log(String message, {Object? error, StackTrace? stackTrace}) =>
    logSink(message, error, stackTrace);

/// Where [log] writes. Tests swap it to read every line the app logs, so a
/// guard can prove a secret never reaches the log.
@visibleForTesting
void Function(String message, Object? error, StackTrace? stackTrace) logSink =
    _platform;

void _platform(String message, Object? error, StackTrace? stackTrace) =>
    developer.log(message, name: 'tix', error: error, stackTrace: stackTrace);
