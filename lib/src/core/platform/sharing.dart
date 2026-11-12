// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'sharing.g.dart';

/// Handing a line of text to another app through the share sheet, behind an
/// interface so tests reach no platform channel.
abstract interface class TextSharing {
  /// Offers [text] to other apps; [origin] anchors the sheet on tablets.
  /// Whether it went anywhere.
  Future<bool> share(String text, {String? subject, Rect? origin});
}

/// [TextSharing] with the system share sheet.
class SystemTextSharing implements TextSharing {
  /// Creates the service.
  const SystemTextSharing();

  @override
  Future<bool> share(String text, {String? subject, Rect? origin}) async {
    final result = await SharePlus.instance.share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
    return result.status == ShareResultStatus.success;
  }
}

/// The platform's share sheet.
@Riverpod(keepAlive: true)
TextSharing textSharing(Ref ref) => const SystemTextSharing();

/// Where [context]'s widget is on screen, to anchor a share sheet on
/// tablets; null when it is not a laid-out box.
Rect? originOf(BuildContext context) {
  final box = context.findRenderObject();
  return box is RenderBox && box.hasSize
      ? box.localToGlobal(Offset.zero) & box.size
      : null;
}
