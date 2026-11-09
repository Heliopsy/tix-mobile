// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/pinned_shortcuts.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';

/// The `<connection>.<tenant>` key a shortcut made now names, null when
/// nobody is signed in.
String? activeContextKey(WidgetRef ref) {
  final active = ref.read(sessionControllerProvider).value?.ref;
  return active == null ? null : contextKeyOf(active);
}

/// The `<connection>.<tenant>` key of [context], as links and widgets name
/// it.
String contextKeyOf(ContextRef context) =>
    '${context.connectionId}.${context.tenantKey}';

/// Asks the launcher to pin the shortcut [build] makes for the active
/// context, and says when it could not.
Future<void> pinToHomeScreen(
  BuildContext context,
  WidgetRef ref,
  PinnedShortcut Function(String context) build,
) async {
  final key = activeContextKey(ref);
  final l10n = context.l10n;
  final ok =
      key != null && await ref.read(pinnedShortcutsProvider).pin(build(key));
  if (!ok && context.mounted) {
    showTixToast(context, l10n.pinFailed, tone: TixTone.danger);
  }
}

/// Add to home screen for the shortcut [shortcut] makes, drawn only where
/// the launcher can pin one.
class PinShortcutButton extends ConsumerWidget {
  /// A pin button for the shortcut [shortcut] makes.
  const PinShortcutButton({required this.shortcut, super.key});

  /// Makes the shortcut for a `<connection>.<tenant>` context key.
  final PinnedShortcut Function(String context) shortcut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(pinSupportedProvider).value != true) {
      return const SizedBox.shrink();
    }
    return TixIconButton(
      icon: Icons.add_to_home_screen,
      tooltip: context.l10n.pinToHome,
      onPressed: () => pinToHomeScreen(context, ref, shortcut),
    );
  }
}
