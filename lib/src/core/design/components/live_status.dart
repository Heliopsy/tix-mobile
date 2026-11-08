// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// How live updates are reaching the app, as [LiveIndicator] draws it.
enum LiveState {
  /// Over the WebSocket, as they happen.
  live,

  /// Opening the connection.
  connecting,

  /// Over plain HTTP, because the WebSocket keeps failing.
  polling,

  /// Not at all: the screen reloads on a timer.
  refreshing,

  /// The server cannot be reached.
  offline,

  /// This connection may not follow live updates.
  unavailable,
}

/// A dot and a word saying whether changes made elsewhere show up on their
/// own, explained in a tooltip on hover or long press, so a tap still
/// reaches the control it sits in.
///
/// Live is the dot alone; every other state adds its word, so a degraded
/// mode is never only a colour. [compact] draws the dot alone in every
/// state, for a corner badge, and leaves the explanation to semantics.
class LiveIndicator extends StatelessWidget {
  /// Draws [state]; [refreshSeconds] goes into the refreshing explanation.
  const LiveIndicator({
    required this.state,
    this.refreshSeconds = 45,
    this.compact = false,
    super.key,
  });

  /// The state.
  final LiveState state;

  /// How often the screen reloads while [LiveState.refreshing].
  final int refreshSeconds;

  /// Whether to draw the dot alone, with no tooltip or target.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final (label, info) = switch (state) {
      LiveState.live => (l10n.liveStatusLive, l10n.liveStatusLiveInfo),
      LiveState.connecting => (
        l10n.liveStatusConnecting,
        l10n.liveStatusConnectingInfo,
      ),
      LiveState.polling => (l10n.liveStatusPolling, l10n.liveStatusPollingInfo),
      LiveState.refreshing => (
        l10n.liveStatusRefreshing,
        l10n.liveStatusRefreshingInfo(refreshSeconds),
      ),
      LiveState.offline => (l10n.liveStatusOffline, l10n.liveStatusOfflineInfo),
      LiveState.unavailable => (
        l10n.liveStatusUnavailable,
        l10n.liveStatusUnavailableInfo,
      ),
    };
    final (colour, filled) = switch (state) {
      LiveState.live => (t.ok, true),
      LiveState.connecting => (t.muted, false),
      LiveState.polling || LiveState.refreshing => (t.warn, true),
      LiveState.offline => (t.danger, false),
      LiveState.unavailable => (t.muted, true),
    };
    final dot = Container(
      width: TixSpace.s2,
      height: TixSpace.s2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? colour : null,
        border: filled ? null : Border.all(color: colour, width: 1.5),
      ),
    );
    final semantics = '${l10n.liveStatusLabel(label)}. $info';
    if (compact) {
      return Semantics(
        key: const Key('live.indicator'),
        label: semantics,
        child: ExcludeSemantics(child: dot),
      );
    }
    return Tooltip(
      key: const Key('live.indicator'),
      message: info,
      excludeFromSemantics: true,
      child: Semantics(
        label: semantics,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: TixSize.target,
              minHeight: TixSize.target,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                dot,
                if (state != LiveState.live) ...[
                  const SizedBox(width: TixSpace.s1),
                  Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: TixText.xs,
                      fontWeight: FontWeight.w600,
                      color:
                          state == LiveState.connecting ||
                              state == LiveState.unavailable
                          ? t.muted
                          : colour,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
