// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// A quiet "Updated" pill that fades in when a list refreshed itself from
/// a live event, and out again when [visible] goes false.
///
/// Put it in the page header's tools or above the list. It never moves the
/// content: it only appears.
class UpdatedMark extends StatelessWidget {
  /// Shows the mark while [visible].
  const UpdatedMark({required this.visible, this.label, super.key});

  /// Whether it shows.
  final bool visible;

  /// The text; "Updated" when null.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: TixMotion.of(context, TixMotion.base),
      child: Semantics(
        liveRegion: visible,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TixSpace.s2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: t.accentSoft,
            borderRadius: BorderRadius.circular(TixRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: t.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: TixSpace.s1),
              Text(
                label ?? context.l10n.liveUpdated,
                style: TextStyle(
                  fontSize: TixText.xs,
                  fontWeight: FontWeight.w600,
                  color: t.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Says that what the person is editing changed elsewhere, and offers to
/// load the new version. Their input stays until they choose [onReload].
///
/// Show it at the top of an edit form when a live event names the item
/// being edited, instead of reloading under the person's fingers.
class ChangedElsewhereBanner extends StatelessWidget {
  /// A banner offering [onReload], and [onDismiss] to keep editing.
  const ChangedElsewhereBanner({
    required this.onReload,
    this.onDismiss,
    this.by = '',
    super.key,
  });

  /// Discards the input and loads the current version.
  final VoidCallback onReload;

  /// Hides the banner and keeps editing.
  final VoidCallback? onDismiss;

  /// Who changed it, as a handle, when known.
  final String by;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          TixSpace.s3,
          TixSpace.s2,
          TixSpace.s2,
          TixSpace.s2,
        ),
        decoration: BoxDecoration(
          color: t.warnSoft,
          border: Border.all(color: t.warn.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(TixRadius.base),
        ),
        child: Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s1,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sync_problem, size: 18, color: t.warn),
                const SizedBox(width: TixSpace.s2),
                Flexible(
                  child: Text(
                    by.isEmpty
                        ? l10n.liveChangedElsewhere
                        : l10n.liveChangedElsewhereBy(by),
                    style: TextStyle(fontSize: TixText.sm, color: t.ink),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onDismiss != null)
                  TixButton.quiet(
                    key: const Key('live.keep'),
                    label: l10n.liveKeepEditing,
                    size: TixButtonSize.small,
                    onPressed: onDismiss,
                  ),
                TixButton(
                  key: const Key('live.reload'),
                  label: l10n.liveReload,
                  icon: Icons.refresh,
                  size: TixButtonSize.small,
                  onPressed: onReload,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Washes [child] in the accent's tint when [fresh], fading to nothing:
/// how a row that arrived live says it is new.
class FreshHighlight extends StatefulWidget {
  /// Wraps [child].
  const FreshHighlight({required this.fresh, required this.child, super.key});

  /// Whether the row just arrived.
  final bool fresh;

  /// The row.
  final Widget child;

  @override
  State<FreshHighlight> createState() => _FreshHighlightState();
}

class _FreshHighlightState extends State<FreshHighlight> {
  late bool _lit = widget.fresh;

  @override
  void initState() {
    super.initState();
    if (_lit) _fadeSoon();
  }

  @override
  void didUpdateWidget(FreshHighlight old) {
    super.didUpdateWidget(old);
    if (widget.fresh && !old.fresh) {
      _lit = true;
      _fadeSoon();
    }
  }

  void _fadeSoon() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) setState(() => _lit = false);
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: TixMotion.of(context, const Duration(seconds: 2)),
    curve: Curves.easeOut,
    color: _lit ? context.tix.accentSoft : context.tix.accentSoft.withAlpha(0),
    child: widget.child,
  );
}
