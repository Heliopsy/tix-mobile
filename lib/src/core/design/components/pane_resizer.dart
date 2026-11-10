// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// Reports a pane width the handle asks for; [done] is false while a drag
/// is still under way.
typedef PaneResize = void Function(double width, {required bool done});

/// The line between two panes, which resizes the one on its [growsLeft]
/// side: dragged, or from the keyboard as tix web's sidebar handle is.
/// Left and Right move it by 16, 64 with Shift; Home and End go to [min]
/// and [max]; Enter and a double click reset. With [onCollapse], a drag
/// that ends under [collapseAt], or Left at [min], collapses the pane, and
/// Right on a [collapsed] pane calls [onExpand].
class TixPaneResizer extends StatefulWidget {
  /// A handle for a pane [width] wide, announced as [label].
  const TixPaneResizer({
    required this.label,
    required this.width,
    required this.min,
    required this.max,
    required this.onResize,
    required this.onReset,
    this.growsLeft = false,
    this.collapsed = false,
    this.collapseAt,
    this.onCollapse,
    this.onExpand,
    super.key,
  });

  /// The step of an arrow key.
  static const step = 16.0;

  /// The step of an arrow key with Shift.
  static const bigStep = 64.0;

  /// The width the handle takes between the panes.
  static const double extent = TixSpace.s2;

  /// What the handle resizes, for screen readers.
  final String label;

  /// The pane's width as drawn now.
  final double width;

  /// The narrowest the pane may be.
  final double min;

  /// The widest the pane may be.
  final double max;

  /// Called with each width asked for.
  final PaneResize onResize;

  /// Restores the default width.
  final VoidCallback onReset;

  /// Whether the pane sits right of the handle, so dragging left widens it.
  final bool growsLeft;

  /// Whether the pane is collapsed now.
  final bool collapsed;

  /// A drag that lets go under this width collapses the pane.
  final double? collapseAt;

  /// Collapses the pane; null when it does not collapse.
  final VoidCallback? onCollapse;

  /// Expands a collapsed pane at its last width.
  final VoidCallback? onExpand;

  @override
  State<TixPaneResizer> createState() => _TixPaneResizerState();
}

class _TixPaneResizerState extends State<TixPaneResizer> {
  var _hover = false;
  var _focus = false;
  double? _start;
  var _dx = 0.0;
  var _collapsing = false;
  double? _last;

  double get _sign => widget.growsLeft ? -1 : 1;

  double _clamp(double w) => w.clamp(widget.min, widget.max);

  void _grow(double by) {
    if (widget.collapsed) {
      if (by > 0) widget.onExpand?.call();
      return;
    }
    if (by < 0 && widget.width <= widget.min && widget.onCollapse != null) {
      widget.onCollapse!();
      return;
    }
    widget.onResize(_clamp(widget.width + by), done: true);
  }

  KeyEventResult _key(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final step = HardwareKeyboard.instance.isShiftPressed
        ? TixPaneResizer.bigStep
        : TixPaneResizer.step;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight) {
      _grow(step * _sign);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _grow(-step * _sign);
    } else if (key == LogicalKeyboardKey.home) {
      widget.onResize(widget.min, done: true);
    } else if (key == LogicalKeyboardKey.end) {
      widget.onResize(widget.max, done: true);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      widget.onReset();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _dragStart(DragStartDetails _) => setState(() {
    _start = widget.width;
    _dx = 0;
    _collapsing = false;
    _last = null;
  });

  void _dragUpdate(DragUpdateDetails details) {
    final start = _start;
    if (start == null) return;
    _dx += details.delta.dx * _sign;
    final next = start + _dx;
    final collapseAt = widget.collapseAt;
    if (widget.onCollapse != null && collapseAt != null && next < collapseAt) {
      if (!_collapsing) widget.onCollapse!();
      _collapsing = true;
      _last = null;
      return;
    }
    _collapsing = false;
    _last = _clamp(next);
    widget.onResize(_last!, done: false);
  }

  void _dragEnd([Object? _]) {
    final last = _last;
    setState(() {
      _start = null;
      _last = null;
    });
    if (last != null) widget.onResize(last, done: true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final active = _hover || _focus || _start != null;
    final w = widget.width.round();
    const step = TixPaneResizer.step;
    return Semantics(
      label: widget.label,
      hint: l10n.paneResizeHint,
      slider: true,
      value: widget.collapsed ? l10n.paneCollapsed : '$w',
      increasedValue: '${_clamp(widget.width + step).round()}',
      decreasedValue: '${_clamp(widget.width - step).round()}',
      onIncrease: () => _grow(step),
      onDecrease: () => _grow(-step),
      child: Focus(
        onKeyEvent: _key,
        onFocusChange: (f) => setState(() => _focus = f),
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            dragStartBehavior: DragStartBehavior.down,
            onHorizontalDragStart: _dragStart,
            onHorizontalDragUpdate: _dragUpdate,
            onHorizontalDragEnd: _dragEnd,
            onHorizontalDragCancel: _dragEnd,
            onDoubleTap: widget.onReset,
            child: SizedBox(
              width: TixPaneResizer.extent,
              child: Center(
                child: AnimatedContainer(
                  duration: TixMotion.fast,
                  width: active ? 2 : 1,
                  color: active ? t.accent : t.line,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
