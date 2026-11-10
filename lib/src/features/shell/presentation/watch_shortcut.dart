// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/access.dart';

/// Opens Watch from the shell's bar, beside quick add. Drawn only while the
/// credential holds `event:subscribe`, the scope Manage lists Watch under.
class WatchShortcutButton extends ConsumerWidget {
  /// Creates the button.
  const WatchShortcutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(currentAccessProvider).value;
    if (!(access?.has(Scope.eventSubscribe) ?? false)) {
      return const SizedBox.shrink();
    }
    return TixIconButton(
      key: const Key('shell.watch'),
      icon: Icons.stream,
      tooltip: context.l10n.watchShortcut,
      onPressed: () => context.go(Routes.watch),
    );
  }
}
