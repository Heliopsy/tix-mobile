// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// What time it is. Screens read it for relative dates; tests fix it.
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
