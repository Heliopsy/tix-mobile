// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/events/events.dart';

/// The design system's state for [mode], null when there is nothing to say.
LiveState? liveStateOf(LiveMode? mode) => switch (mode) {
  LiveMode.websocket => LiveState.live,
  LiveMode.connecting => LiveState.connecting,
  LiveMode.polling => LiveState.polling,
  LiveMode.refreshing => LiveState.refreshing,
  LiveMode.offline => LiveState.offline,
  LiveMode.unavailable => LiveState.unavailable,
  LiveMode.closed || null => null,
};

/// How live updates reach the active context, beside the context switcher.
class LiveStatusIndicator extends ConsumerWidget {
  /// Draws the indicator; [compact] draws the dot alone.
  const LiveStatusIndicator({this.compact = false, super.key});

  /// Whether to draw the dot alone.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = liveStateOf(ref.watch(liveStatusProvider).value?.mode);
    if (state == null) return const SizedBox.shrink();
    return LiveIndicator(
      state: state,
      compact: compact,
      refreshSeconds: ref.watch(liveConfigProvider).refreshEvery.inSeconds,
    );
  }
}
