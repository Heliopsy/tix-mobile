// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';

/// An action an empty or error state offers: a label, an icon and what it
/// does.
@immutable
class TixAction {
  /// An action labelled [label].
  const TixAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.key,
  });

  /// The button's label.
  final String label;

  /// What it does.
  final VoidCallback onPressed;

  /// An icon before the label; [Icons.add] for a create action.
  final IconData? icon;

  /// The button's key, for tests.
  final Key? key;
}

/// Nothing here yet, said plainly, with the screen's create action.
///
/// Every list that can be empty uses it. When the screen has a create
/// action, pass it as [action]: an empty list carries the same primary
/// button as the header.
class EmptyState extends StatelessWidget {
  /// Says [title], explained by [body].
  const EmptyState({
    required this.title,
    this.body,
    this.icon,
    this.action,
    super.key,
  });

  /// The one line that says what is empty.
  final String title;

  /// What to do about it, or why.
  final String? body;

  /// A quiet illustration.
  final IconData? icon;

  /// The primary action, usually the screen's create action.
  final TixAction? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final theme = Theme.of(context);
    final action = this.action;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: TixSpace.s4,
          vertical: TixSpace.s7,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: TixMeasure.text),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 40, color: t.lineStrong),
                const SizedBox(height: TixSpace.s3),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (body != null) ...[
                const SizedBox(height: TixSpace.s1),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: TixSpace.s4),
                TixButton.primary(
                  key: action.key,
                  label: action.label,
                  icon: action.icon,
                  onPressed: action.onPressed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A failure, explained, with a retry and a way back.
///
/// The message box is tix's `.failure-message`. A sign-in whose session
/// ended also gets "Sign in again". [onBack] defaults to popping the route
/// when there is one to pop; a tab root has the navigation as its way back.
class ErrorState extends ConsumerWidget {
  /// Explains [error], retrying with [onRetry].
  const ErrorState({
    required this.error,
    required this.onRetry,
    this.onBack,
    this.compact = false,
    super.key,
  });

  /// What went wrong.
  final Object error;

  /// Tries again.
  final VoidCallback onRetry;

  /// Leaves the screen; null pops when possible.
  final VoidCallback? onBack;

  /// Drawn inline, as a list footer, rather than filling the screen.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final connection = ref.watch(sessionControllerProvider).value?.connection;
    final reconnect =
        error is TixException &&
        (error as TixException).kind == TixErrorKind.unauthenticated &&
        connection?.kind == ConnectionKind.signIn;
    final back =
        onBack ??
        (!compact && Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null);
    final message = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s4,
        vertical: TixSpace.s3,
      ),
      decoration: BoxDecoration(
        color: t.dangerSoft,
        border: Border.all(color: t.danger),
        borderRadius: BorderRadius.circular(TixRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: t.danger),
          const SizedBox(width: TixSpace.s2),
          Expanded(
            child: Text(
              errorMessage(l10n, error),
              style: TextStyle(color: t.danger, fontSize: TixText.md),
            ),
          ),
        ],
      ),
    );
    final actions = Wrap(
      spacing: TixSpace.s2,
      runSpacing: TixSpace.s2,
      children: [
        TixButton(
          key: const Key('error.retry'),
          label: l10n.retry,
          icon: Icons.refresh,
          onPressed: onRetry,
        ),
        if (reconnect)
          TixButton.primary(
            key: const Key('error.signInAgain'),
            label: l10n.signInAgain,
            onPressed: () => context.go(Routes.reconnect(connection!.id)),
          ),
        if (back != null)
          TixButton.quiet(
            key: const Key('error.back'),
            label: l10n.back,
            icon: Icons.arrow_back,
            onPressed: back,
          ),
      ],
    );
    final body = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: TixMeasure.text),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          message,
          const SizedBox(height: TixSpace.s3),
          actions,
        ],
      ),
    );
    if (compact) {
      return Padding(padding: const EdgeInsets.all(TixSpace.s4), child: body);
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TixSpace.s5),
        child: body,
      ),
    );
  }
}

/// A grey block standing in for content that is loading.
class SkeletonBox extends StatelessWidget {
  /// A block [width] by [height]; null width fills.
  const SkeletonBox({
    this.width,
    this.height = 12,
    this.radius = TixRadius.sm,
    super.key,
  });

  /// The width, or null to fill.
  final double? width;

  /// The height.
  final double height;

  /// The corner radius.
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: context.tix.line,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// The shape of a list while its first page loads: rows of grey blocks
/// that breathe, never a spinner. Still when motion is reduced.
class SkeletonList extends StatefulWidget {
  /// [rows] placeholder rows; [leading] draws a square before each.
  const SkeletonList({this.rows = 8, this.leading = true, super.key});

  /// How many rows.
  final int rows;

  /// Whether each row starts with a mark, as project rows do.
  final bool leading;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    lowerBound: 0.45,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still || !TickerMode.valuesOf(context).enabled) {
      _pulse
        ..stop()
        ..value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      label: l10n.loading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _pulse,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.rows,
            itemBuilder: (context, i) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TixSpace.s4,
                vertical: TixSpace.s3,
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.tix.line)),
              ),
              child: Row(
                children: [
                  if (widget.leading) ...[
                    const SkeletonBox(width: 22, height: 22, radius: 11),
                    const SizedBox(width: TixSpace.s3),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: const [0.7, 0.5, 0.85, 0.6][i % 4],
                          child: const SkeletonBox(height: 14),
                        ),
                        const SizedBox(height: TixSpace.s2),
                        const Row(
                          children: [
                            SkeletonBox(width: 40, height: 10),
                            SizedBox(width: TixSpace.s2),
                            SkeletonBox(width: 32, height: 10),
                            SizedBox(width: TixSpace.s2),
                            SkeletonBox(width: 48, height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
