// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/widgets/live_details.dart';

/// The design system's state for [mode], null when there is nothing to say.
LiveState? liveStateOf(LiveMode? mode) => switch (mode) {
  LiveMode.websocket => LiveState.live,
  LiveMode.connecting => LiveState.connecting,
  LiveMode.polling => LiveState.polling,
  LiveMode.refreshing => LiveState.refreshing,
  LiveMode.offline => LiveState.offline,
  LiveMode.unavailable => LiveState.unavailable,
  LiveMode.closed || LiveMode.paused || null => null,
};

/// How live updates reach the active context, beside the context switcher.
/// Tapping it opens the connection details; the corner dot is too small to
/// tap, so the switcher opens them on a long press instead.
class LiveStatusIndicator extends ConsumerWidget {
  /// Draws the indicator; [compact] draws the dot alone, [leading] starts
  /// it at its target's leading edge, [pulse] makes a live dot breathe.
  const LiveStatusIndicator({
    this.compact = false,
    this.leading = false,
    this.pulse = false,
    super.key,
  });

  /// Whether the dot breathes while live or connecting.
  final bool pulse;

  /// Whether to draw the dot alone.
  final bool compact;

  /// Whether the dot starts at the leading edge, after a line of text.
  final bool leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = liveStateOf(ref.watch(liveStatusProvider).value?.mode);
    if (state == null) return const SizedBox.shrink();
    return LiveIndicator(
      state: state,
      compact: compact,
      leading: leading,
      pulse: pulse,
      onTap: () => showLiveDetails(context),
      refreshSeconds: ref.watch(liveConfigProvider).refreshEvery.inSeconds,
    );
  }
}
