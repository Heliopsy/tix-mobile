// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/features/templates/presentation/template_sheets.dart';

/// Offers "Save as a template" in the palette while a task is open, and
/// New template everywhere. Mounted around the signed-in screens by the
/// router.
class TemplatesCommands extends StatefulWidget {
  /// Registers the commands around [child].
  const TemplatesCommands({required this.child, super.key});

  /// The signed-in screens.
  final Widget child;

  @override
  State<TemplatesCommands> createState() => _TemplatesCommandsState();
}

class _TemplatesCommandsState extends State<TemplatesCommands> {
  GoRouter? _router;
  String? _taskRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _router = GoRouter.maybeOf(context)?..routerDelegate.addListener(_routed);
      _routed();
    });
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_routed);
    super.dispose();
  }

  void _routed() {
    final segments =
        _router?.routerDelegate.currentConfiguration.uri.pathSegments ??
        const <String>[];
    final ref = segments.length == 4 && segments[2] == 'tasks'
        ? segments[3]
        : null;
    if (ref != _taskRef && mounted) setState(() => _taskRef = ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final taskRef = _taskRef;
    return CommandScope(
      commands: [
        TixCommand(
          id: 'templates.new',
          label: l10n.templateNew,
          group: l10n.paletteGroupTemplates,
          icon: Icons.bolt,
          keywords: taskRef ?? '',
          run: () => unawaited(showNewTemplate(context, taskRef: taskRef)),
        ),
      ],
      child: widget.child,
    );
  }
}
