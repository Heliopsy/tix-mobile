// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';

/// Says "Offline, showing saved copy from …" while what a screen draws came
/// from the copy kept for offline use, and nothing otherwise. Put it above
/// a list; the line wraps rather than clipping at large text sizes.
class SavedCopyMark extends ConsumerWidget {
  /// Creates the mark.
  const SavedCopyMark({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final since = ref.watch(savedCopySinceProvider).value;
    if (since == null) return const SizedBox.shrink();
    final t = context.tix;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final at = DateFormat.yMMMd(locale).add_Hm().format(since.toLocal());
    return Semantics(
      liveRegion: true,
      child: Padding(
        key: const Key('savedCopy'),
        padding: const EdgeInsets.fromLTRB(
          TixSpace.s5,
          0,
          TixSpace.s5,
          TixSpace.s2,
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, size: TixSpace.s4, color: t.warn),
            const SizedBox(width: TixSpace.s2),
            Expanded(
              child: Text(
                context.l10n.offlineSavedCopy(at),
                style: TextStyle(fontSize: TixText.xs, color: t.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
