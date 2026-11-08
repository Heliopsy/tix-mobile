// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/widgets/application/widget_sync.dart';

/// Keeps the home screen widgets current while the signed-in screens show,
/// and follows links tapped in a widget, including the one that launched
/// the app.
class HomeWidgetsScope extends ConsumerStatefulWidget {
  /// Wraps [child].
  const HomeWidgetsScope({required this.child, super.key});

  /// The signed-in frame.
  final Widget child;

  @override
  ConsumerState<HomeWidgetsScope> createState() => _HomeWidgetsScopeState();
}

class _HomeWidgetsScopeState extends ConsumerState<HomeWidgetsScope> {
  StreamSubscription<Uri>? _taps;

  @override
  void initState() {
    super.initState();
    final bridge = ref.read(widgetBridgeProvider);
    _taps = bridge.opened.listen((u) => unawaited(_open(u)));
    unawaited(_launched(bridge));
  }

  Future<void> _launched(WidgetBridge bridge) async {
    final uri = await bridge.launched();
    if (uri == null) return;
    await ref.read(sessionControllerProvider.future);
    if (mounted) await _open(uri);
  }

  Future<void> _open(Uri uri) async {
    final route = await ref.read(widgetSyncProvider.notifier).open(uri);
    if (route != null && mounted) GoRouter.of(context).go(route);
  }

  @override
  void dispose() {
    unawaited(_taps?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(widgetSyncProvider);
    return widget.child;
  }
}
