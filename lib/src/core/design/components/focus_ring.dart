// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

/// Draws an accent outline round the control with keyboard focus, over
/// everything in [child], dialogs included, while focus is driven by keys.
/// Text fields draw their own focused border and get none; neither do pages
/// and routes.
class TixFocusRing extends StatefulWidget {
  /// Rings keyboard focus in [child].
  const TixFocusRing({required this.child, super.key});

  /// The app.
  final Widget child;

  /// How far the ring sits outside the control.
  static const gap = 2.0;

  /// How thick it is.
  static const width = 2.0;

  @override
  State<TixFocusRing> createState() => _TixFocusRingState();
}

class _TixFocusRingState extends State<TixFocusRing> {
  static final _live = <_TixFocusRingState>{};
  static bool _hooked = false;

  final _rect = ValueNotifier<Rect?>(null);

  @override
  void initState() {
    super.initState();
    _live.add(this);
    // A persistent callback runs on frames something else asked for and
    // never asks for one, so an idle app stays idle. It catches a focused
    // row moving under a scroll or a relayout.
    if (!_hooked) {
      _hooked = true;
      SchedulerBinding.instance.addPersistentFrameCallback((_) {
        for (final s in _live.toList()) {
          s._check();
        }
      });
    }
    FocusManager.instance
      ..addListener(_kick)
      ..addHighlightModeListener(_mode);
  }

  @override
  void dispose() {
    _live.remove(this);
    FocusManager.instance
      ..removeListener(_kick)
      ..removeHighlightModeListener(_mode);
    _rect.dispose();
    super.dispose();
  }

  void _kick() => SchedulerBinding.instance.scheduleFrame();

  void _mode(FocusHighlightMode _) => _kick();

  void _check() {
    if (!mounted) return;
    final next = _target();
    if (next != _rect.value) _rect.value = next;
  }

  Rect? _target() {
    final manager = FocusManager.instance;
    if (manager.highlightMode != FocusHighlightMode.traditional) return null;
    final node = manager.primaryFocus;
    final c = node?.context;
    if (node == null ||
        c == null ||
        !c.mounted ||
        node is FocusScopeNode ||
        node.skipTraversal ||
        c.widget is EditableText ||
        c.findAncestorWidgetOfExactType<EditableText>() != null) {
      return null;
    }
    final box = context.findRenderObject();
    final target = c.findRenderObject();
    if (box is! RenderBox ||
        !box.hasSize ||
        target is! RenderBox ||
        !target.attached ||
        !target.hasSize) {
      return null;
    }
    final rect = node.rect;
    if (rect.isEmpty) return null;
    final local = rect.shift(-box.localToGlobal(Offset.zero));
    if (local.width >= box.size.width * 0.9 &&
        local.height >= box.size.height * 0.9) {
      return null;
    }
    return local;
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _RingPainter(_rect, context.tix.accent),
    child: widget.child,
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.rect, this.colour) : super(repaint: rect);

  final ValueNotifier<Rect?> rect;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final r = rect.value;
    if (r == null) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        r.inflate(TixFocusRing.gap),
        const Radius.circular(TixRadius.md),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TixFocusRing.width
        ..color = colour,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.colour != colour || old.rect != rect;
}
