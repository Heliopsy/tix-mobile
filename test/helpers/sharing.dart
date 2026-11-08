// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ui' show Rect;

import 'package:flutter_riverpod/misc.dart';
import 'package:tix_mobile/src/core/platform/sharing.dart';

/// A share sheet that records what it was handed.
class FakeTextSharing implements TextSharing {
  /// Everything shared, in order.
  final shared = <String>[];

  @override
  Future<bool> share(String text, {String? subject, Rect? origin}) async {
    shared.add(text);
    return true;
  }

  /// The override that puts this fake in place.
  Override get asOverride => textSharingProvider.overrideWithValue(this);
}
