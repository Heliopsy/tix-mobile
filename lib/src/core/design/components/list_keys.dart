// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/commands.dart';
import 'package:tix_mobile/src/core/keyboard/keymap.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// Whether the keyboard focus is on a control, such as a button or a row,
/// rather than on a page, a route or nothing.
bool controlFocused() {
  final node = FocusManager.instance.primaryFocus;
  return node != null &&
      node is! FocusScopeNode &&
      !node.skipTraversal &&
      node.context != null;
}

/// Activates the focused control as Enter or Space would; false when no
/// control has focus.
bool activateFocused() {
  if (!controlFocused()) return false;
  final context = FocusManager.instance.primaryFocus!.context!;
  Actions.maybeInvoke(context, const ActivateIntent());
  return true;
}

/// Scrolls [context] into view by the least distance.
void showContextOnScreen(BuildContext context) =>
    context.findRenderObject()?.showOnScreen();

/// Marks a subtree that handles its own list keys, such as the task list
/// with its cursor, so the pages inside it add none.
class OwnListKeys extends InheritedWidget {
  /// Marks [child].
  const OwnListKeys({required super.child, super.key});

  /// Whether [context] is inside an [OwnListKeys].
  static bool within(BuildContext context) =>
      context.getInheritedWidgetOfExactType<OwnListKeys>() != null;

  @override
  bool updateShouldNotify(OwnListKeys oldWidget) => false;
}

/// The list actions for any page: next, previous, first, last, a page down
/// or up, and open, moving the real keyboard focus between the focusable
/// rows of [child] and scrolling the one it lands on into view. Text fields
/// are skipped, so a key never lands in one. `TixPage` mounts it, unless
/// the page is inside [OwnListKeys].
class TixListKeys extends StatefulWidget {
  /// Adds list keys to [child].
  const TixListKeys({required this.child, super.key});

  /// The page body.
  final Widget child;

  @override
  State<TixListKeys> createState() => _TixListKeysState();
}

class _TixListKeysState extends State<TixListKeys> {
  final _root = FocusNode(
    debugLabel: 'list keys',
    skipTraversal: true,
    canRequestFocus: false,
  );

  @override
  void dispose() {
    _root.dispose();
    super.dispose();
  }

  bool _inside(FocusNode? node) =>
      node != null && node.ancestors.contains(_root);

  bool get _applies =>
      _inside(FocusManager.instance.primaryFocus) || !controlFocused();

  List<FocusNode> _targets() {
    final nodes = [
      for (final n in _root.traversalDescendants)
        if (n is! FocusScopeNode &&
            _laidOut(n) &&
            !_isField(n) &&
            n.rect.height > 0)
          n,
    ];
    return nodes..sort((a, b) {
      final by = a.rect.top.compareTo(b.rect.top);
      return by != 0 ? by : a.rect.left.compareTo(b.rect.left);
    });
  }

  static bool _laidOut(FocusNode n) {
    final box = n.context?.findRenderObject();
    return box is RenderBox && box.attached && box.hasSize;
  }

  static bool _isField(FocusNode n) {
    final c = n.context!;
    return c.widget is EditableText ||
        c.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  void _focus(FocusNode node) {
    node.requestFocus();
    final c = node.context;
    if (c != null) showContextOnScreen(c);
  }

  void _step(int by) {
    final nodes = _targets();
    if (nodes.isEmpty) return;
    final current = FocusManager.instance.primaryFocus;
    if (!nodes.contains(current)) {
      _focus(by > 0 ? nodes.first : nodes.last);
      return;
    }
    final from = current!.rect;
    final ahead = [
      for (final n in nodes)
        if (by > 0
            ? n.rect.center.dy > from.bottom - 1
            : n.rect.center.dy < from.top + 1)
          n,
    ];
    if (ahead.isEmpty) return;
    final edge = by > 0
        ? ahead.map((n) => n.rect.top).reduce((a, b) => a < b ? a : b)
        : ahead.map((n) => n.rect.bottom).reduce((a, b) => a > b ? a : b);
    final row =
        [
          for (final n in ahead)
            if (n.rect.top <= edge + 1 && n.rect.bottom >= edge - 1) n,
        ]..sort(
          (a, b) => (a.rect.left - from.left).abs().compareTo(
            (b.rect.left - from.left).abs(),
          ),
        );
    _focus(row.first);
  }

  ScrollPosition? _position() {
    final nodes = _targets();
    final current = FocusManager.instance.primaryFocus;
    final at = nodes.contains(current)
        ? current!
        : (nodes.isEmpty ? null : nodes.first);
    final c = at?.context;
    return c == null ? null : Scrollable.maybeOf(c)?.position;
  }

  void _afterLayout(VoidCallback run) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) run();
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void _jump({required bool top}) {
    final position = _position();
    position?.jumpTo(top ? position.minScrollExtent : position.maxScrollExtent);
    _afterLayout(() {
      final nodes = _targets();
      if (nodes.isNotEmpty) _focus(top ? nodes.first : nodes.last);
    });
  }

  void _page(int by) {
    final position = _position();
    if (position == null) {
      _step(by);
      return;
    }
    final to = position.pixels + by * position.viewportDimension * 0.9;
    position.jumpTo(
      to.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
    _afterLayout(() {
      final nodes = _targets();
      final view = _viewRect(position);
      final visible = [
        for (final n in nodes)
          if (view == null || view.contains(n.rect.center)) n,
      ];
      if (visible.isNotEmpty) _focus(by > 0 ? visible.first : visible.last);
    });
  }

  static Rect? _viewRect(ScrollPosition position) {
    final box = position.context.notificationContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final scoped =
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() !=
        null;
    if (!scoped || OwnListKeys.within(context)) return widget.child;
    final l10n = context.l10n;
    TixCommand cmd(String action, String label, VoidCallback run) => TixCommand(
      id: 'list.keys.$action',
      action: action,
      label: label,
      group: l10n.commandsNavigate,
      inPalette: false,
      when: () => _applies,
      run: run,
    );
    return OwnListKeys(
      child: CommandScope(
        commands: [
          cmd(KeyActions.listNext, l10n.keysNextRow, () => _step(1)),
          cmd(KeyActions.listPrev, l10n.keysPreviousRow, () => _step(-1)),
          cmd(KeyActions.listTop, l10n.keysFirstRow, () => _jump(top: true)),
          cmd(KeyActions.listBottom, l10n.keysLastRow, () => _jump(top: false)),
          cmd(KeyActions.listPageDown, l10n.keysPageDown, () => _page(1)),
          cmd(KeyActions.listPageUp, l10n.keysPageUp, () => _page(-1)),
          TixCommand(
            id: 'list.keys.${KeyActions.listOpen}',
            action: KeyActions.listOpen,
            label: l10n.keysOpenRow,
            group: l10n.commandsNavigate,
            inPalette: false,
            when: () => _inside(FocusManager.instance.primaryFocus),
            run: activateFocused,
          ),
        ],
        child: Focus(focusNode: _root, child: widget.child),
      ),
    );
  }
}

/// Scrolls [child] into view whenever [active] turns true, such as a list's
/// keyboard cursor landing on a row.
class KeepInView extends StatefulWidget {
  /// Keeps [child] on screen while [active].
  const KeepInView({required this.active, required this.child, super.key});

  /// Whether it should be on screen.
  final bool active;

  /// The row.
  final Widget child;

  @override
  State<KeepInView> createState() => _KeepInViewState();
}

class _KeepInViewState extends State<KeepInView> {
  @override
  void didUpdateWidget(KeepInView old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) showContextOnScreen(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
