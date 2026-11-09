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
/// [leading] puts the dot at the start of its target instead of its
/// middle, for an indicator that follows a line of text. With [onTap] the
/// target is a button of its own, and says it opens the connection details.
class LiveIndicator extends StatelessWidget {
  /// Draws [state]; [refreshSeconds] goes into the refreshing explanation.
  const LiveIndicator({
    required this.state,
    this.refreshSeconds = 45,
    this.compact = false,
    this.leading = false,
    this.onTap,
    super.key,
  });

  /// The state.
  final LiveState state;

  /// How often the screen reloads while [LiveState.refreshing].
  final int refreshSeconds;

  /// Whether to draw the dot alone, with no tooltip or target.
  final bool compact;

  /// Whether the dot and word start at the target's leading edge.
  final bool leading;

  /// Opens the connection details. A [compact] dot is too small a target:
  /// it only says that a long press on what it sits in opens them.
  final VoidCallback? onTap;

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
    final tap = compact ? null : onTap;
    if (compact) {
      return Semantics(
        key: const Key('live.indicator'),
        label: semantics,
        hint: onTap == null ? null : l10n.liveDetailsLongPressHint,
        child: ExcludeSemantics(child: dot),
      );
    }
    return Tooltip(
      key: const Key('live.indicator'),
      message: info,
      excludeFromSemantics: true,
      child: Semantics(
        container: tap != null,
        button: tap == null ? null : true,
        label: semantics,
        hint: tap == null ? null : l10n.liveDetailsHint,
        onTap: tap,
        child: ExcludeSemantics(
          child: _Target(
            onTap: tap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: TixSize.target,
                minHeight: TixSize.target,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: leading
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  dot,
                  if (state != LiveState.live) ...[
                    const SizedBox(width: TixSpace.s1),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Target extends StatelessWidget {
  const _Target({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => onTap == null
      ? child
      : InkWell(
          borderRadius: BorderRadius.circular(TixRadius.md),
          onTap: onTap,
          child: child,
        );
}
