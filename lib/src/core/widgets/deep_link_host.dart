// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/context_match.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/widgets/live_details.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

/// Mounted around the signed-in screens by the router: follows `tix://`
/// links, including the one that launched the app. A link naming a context
/// switches to it first, asking which one when the name fits several. A
/// link the app does not know says so and goes home. Links only navigate;
/// `tix://quick-add` opens the quick-add sheet, which adds nothing until the
/// person does.
class DeepLinkHost extends ConsumerStatefulWidget {
  /// Follows links around [child].
  const DeepLinkHost({required this.child, super.key});

  /// The signed-in screens.
  final Widget child;

  @override
  ConsumerState<DeepLinkHost> createState() => _DeepLinkHostState();
}

class _DeepLinkHostState extends ConsumerState<DeepLinkHost> {
  StreamSubscription<Uri>? _links;

  @override
  void initState() {
    super.initState();
    final intake = ref.read(deepLinkIntakeProvider);
    _links = intake.links.listen((u) => unawaited(_open(u)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final waiting = intake.take();
      if (waiting != null) unawaited(_open(waiting));
      unawaited(intake.start());
    });
  }

  @override
  void dispose() {
    unawaited(_links?.cancel());
    super.dispose();
  }

  String get _home => StartScreen.named(
    SettingsRepository(ref.read(keyValueStoreProvider)).startScreen(),
  ).route;

  Future<void> _open(Uri uri) async {
    if (!mounted) return;
    final router = GoRouter.of(context);
    final link = parseTixLink(uri);
    if (link == null) {
      _unknown(router);
      return;
    }
    final named = link.context;
    if (named != null && !await _switchFor(named, router)) return;
    final route = link.route;
    if (link.quickAdd) {
      ref.read(quickAddDraftsProvider.notifier).open(project: link.project);
    } else if (route != null) {
      router.go(route);
    } else if (mounted) {
      await showLiveDetails(context);
    }
  }

  void _unknown(GoRouter router) {
    if (mounted) showTixToast(context, context.l10n.linkNotRecognised);
    router.go(_home);
  }

  Future<bool> _switchFor(String named, GoRouter router) async {
    final match = matchContext(
      named,
      savedContexts(ref.read(instancesRepositoryProvider)),
      ref.read(sessionControllerProvider).value?.ref,
    );
    final ContextEntry? target;
    switch (match.kind) {
      case ContextMatchKind.unknown:
        _unknown(router);
        return false;
      case ContextMatchKind.stay:
        return true;
      case ContextMatchKind.switchTo:
        target = match.choices.single;
      case ContextMatchKind.ambiguous:
        target = await _pick(match.choices);
    }
    if (target == null || !mounted) return false;
    try {
      await ref.read(sessionControllerProvider.notifier).activate(target.ref);
      return true;
    } on Exception catch (e) {
      if (mounted) {
        showTixToast(
          context,
          errorMessage(context.l10n, e),
          tone: TixTone.danger,
        );
      }
      return false;
    }
  }

  Future<ContextEntry?> _pick(List<ContextEntry> choices) {
    final l10n = context.l10n;
    return showTixSheet<ContextEntry>(
      context,
      builder: (sheet) => TixSheetBody(
        title: l10n.linkPickContextTitle,
        actions: [
          TixButton.quiet(
            key: const Key('link.context.cancel'),
            label: l10n.cancel,
            onPressed: () => Navigator.of(sheet).pop(),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.linkPickContextBody),
            for (final e in choices)
              ListTile(
                key: Key('link.context.${contextKey(e)}'),
                leading: const Icon(Icons.swap_horiz),
                title: Text(contextLabel(e)),
                subtitle: e.instance.host.isEmpty
                    ? null
                    : Text(e.instance.host),
                onTap: () => Navigator.of(sheet).pop(e),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
