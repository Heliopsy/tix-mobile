// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import '../core/design/flutter_test_config.dart' as design;

/// The same real fonts as the design goldens.
Future<void> testExecutable(FutureOr<void> Function() testMain) =>
    design.testExecutable(testMain);
