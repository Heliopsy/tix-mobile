// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';

part 'panes.g.dart';

/// The sizes the reader gave the wide layout's panes. A null width is the
/// default; a null [sidebarCollapsed] follows the window.
@immutable
class PaneSizes {
  /// Sizes as given.
  const PaneSizes({this.sidebarWidth, this.sidebarCollapsed, this.detailWidth});

  /// The expanded sidebar's width.
  final double? sidebarWidth;

  /// Whether the reader collapsed the sidebar, null until they choose.
  final bool? sidebarCollapsed;

  /// The task panel's width beside a board or lanes.
  final double? detailWidth;

  /// Whether the sidebar is collapsed in a [window] this wide.
  bool collapsedIn(double window) =>
      sidebarCollapsed ?? window < extendedRailMinWidth;

  /// The expanded sidebar's width in a [window] this wide.
  double sidebarIn(double window) => (sidebarWidth ?? sidebarDefaultWidth)
      .clamp(sidebarMinWidth, sidebarMaxFor(window));

  /// The task panel's width in [space] beside the sidebar.
  double detailIn(double space) => (detailWidth ?? detailDefaultWidth).clamp(
    detailMinWidth,
    detailMaxFor(space),
  );

  @override
  bool operator ==(Object other) =>
      other is PaneSizes &&
      other.sidebarWidth == sidebarWidth &&
      other.sidebarCollapsed == sidebarCollapsed &&
      other.detailWidth == detailWidth;

  @override
  int get hashCode => Object.hash(sidebarWidth, sidebarCollapsed, detailWidth);
}

/// The pane sizes, kept per device in the settings store.
@Riverpod(keepAlive: true)
class Panes extends _$Panes {
  static const _sidebarWidth = 'layout.sidebar.width';
  static const _sidebarCollapsed = 'layout.sidebar.collapsed';
  static const _detailWidth = 'layout.detail.width';

  KeyValueStore get _store => ref.read(keyValueStoreProvider);

  @override
  PaneSizes build() {
    final store = ref.watch(keyValueStoreProvider);
    return PaneSizes(
      sidebarWidth: _width(
        store.read(_sidebarWidth),
        sidebarMinWidth,
        sidebarMaxWidth,
      ),
      sidebarCollapsed: switch (store.read(_sidebarCollapsed)) {
        '1' => true,
        '0' => false,
        _ => null,
      },
      detailWidth: _width(
        store.read(_detailWidth),
        detailMinWidth,
        detailMaxWidth,
      ),
    );
  }

  static double? _width(String? raw, double min, double max) {
    final n = double.tryParse(raw ?? '');
    if (n == null || !n.isFinite || n <= 0) return null;
    return n.clamp(min, max).roundToDouble();
  }

  /// Expands the sidebar at [width], or at the default for null; written
  /// to the store only when [save].
  Future<void> resizeSidebar(double? width, {bool save = true}) async {
    final w = width?.clamp(sidebarMinWidth, sidebarMaxWidth).roundToDouble();
    state = PaneSizes(
      sidebarWidth: w,
      sidebarCollapsed: false,
      detailWidth: state.detailWidth,
    );
    if (!save) return;
    await _put(_sidebarWidth, w?.toStringAsFixed(0));
    await _store.write(_sidebarCollapsed, '0');
  }

  /// Collapses or expands the sidebar, keeping its width.
  Future<void> collapseSidebar({required bool collapsed}) async {
    state = PaneSizes(
      sidebarWidth: state.sidebarWidth,
      sidebarCollapsed: collapsed,
      detailWidth: state.detailWidth,
    );
    await _store.write(_sidebarCollapsed, collapsed ? '1' : '0');
  }

  /// Sets the task panel's width, or the default for null; written to the
  /// store only when [save].
  Future<void> resizeDetail(double? width, {bool save = true}) async {
    final w = width?.clamp(detailMinWidth, detailMaxWidth).roundToDouble();
    state = PaneSizes(
      sidebarWidth: state.sidebarWidth,
      sidebarCollapsed: state.sidebarCollapsed,
      detailWidth: w,
    );
    if (save) await _put(_detailWidth, w?.toStringAsFixed(0));
  }

  Future<void> _put(String key, String? value) =>
      value == null ? _store.delete(key) : _store.write(key, value);
}
