// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/inbox/application/alerts.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';

/// Keeps inbox notifications running while the signed-in screens show,
/// and opens the task of a tapped notification, including the one that
/// launched the app.
class InboxAlertsScope extends ConsumerStatefulWidget {
  /// Wraps [child].
  const InboxAlertsScope({required this.child, super.key});

  /// The signed-in frame.
  final Widget child;

  @override
  ConsumerState<InboxAlertsScope> createState() => _InboxAlertsScopeState();
}

class _InboxAlertsScopeState extends ConsumerState<InboxAlertsScope> {
  StreamSubscription<String>? _taps;

  @override
  void initState() {
    super.initState();
    final notes = ref.read(localNotesProvider);
    _taps = notes.taps.listen((p) => unawaited(_open(p)));
    unawaited(_launched(notes));
  }

  Future<void> _launched(LocalNotifier notes) async {
    final payload = await notes.launchPayload();
    if (payload == null) return;
    await ref.read(sessionControllerProvider.future);
    if (mounted) await _open(payload);
  }

  Future<void> _open(String payload) async {
    final route = await ref.read(inboxAlertsProvider.notifier).open(payload);
    if (route != null && mounted) GoRouter.of(context).go(route);
  }

  @override
  void dispose() {
    unawaited(_taps?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(inboxAlertsProvider);
    return widget.child;
  }
}

/// The Inbox destination's icon, with the unread count as a badge.
class InboxNavIcon extends ConsumerWidget {
  /// Draws [icon] with the count.
  const InboxNavIcon({required this.icon, super.key});

  /// The destination's icon.
  final Widget icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(inboxUnreadProvider).value ?? 0;
    final t = context.tix;
    return Badge(
      key: const Key('inbox.badge'),
      backgroundColor: t.accent,
      textColor: t.onAccent,
      isLabelVisible: unread > 0,
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: icon,
    );
  }
}
