// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

/// What a [TixNotice] is about.
enum TixNoticeTone {
  /// Something worth knowing.
  info,

  /// Something to check before going on.
  warn,

  /// Something refused or broken.
  danger,
}

/// A short message inside a screen or form, on a tint of its tone: a
/// refusal from the server above the form that caused it, a warning about
/// what a change will do, or why a screen is read only.
///
/// For something that just happened use `showTixToast`; for a screen that
/// failed to load use `ErrorState`.
class TixNotice extends StatelessWidget {
  /// A notice saying [message].
  const TixNotice(
    this.message, {
    this.tone = TixNoticeTone.info,
    this.title,
    super.key,
  });

  /// What it says.
  final String message;

  /// A bold line before [message].
  final String? title;

  /// What it is about.
  final TixNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final (fg, bg, icon) = switch (tone) {
      TixNoticeTone.info => (t.muted, t.surface, Icons.info_outline),
      TixNoticeTone.warn => (t.warn, t.warnSoft, Icons.warning_amber_rounded),
      TixNoticeTone.danger => (t.danger, t.dangerSoft, Icons.error_outline),
    };
    return Semantics(
      liveRegion: tone == TixNoticeTone.danger,
      child: Container(
        padding: const EdgeInsets.all(TixSpace.s3),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: tone == TixNoticeTone.info ? t.line : fg),
          borderRadius: BorderRadius.circular(TixRadius.base),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: TixSpace.s2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: TixText.sm,
                        fontWeight: FontWeight.w600,
                        color: tone == TixNoticeTone.info ? t.ink : fg,
                      ),
                    ),
                  Text(
                    message,
                    style: TextStyle(fontSize: TixText.sm, color: t.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
