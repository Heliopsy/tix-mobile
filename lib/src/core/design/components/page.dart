// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/components/help.dart';
import 'package:tix_mobile/src/core/design/components/list_keys.dart';
import 'package:tix_mobile/src/core/design/components/states.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';

/// Every screen's frame: a title, an optional line under it, the screen's
/// create action, and the body.
///
/// On a wide window the header is tix's page head: a 24px title with its
/// lede and the tools on the right, the primary action last. On a phone it
/// is an app bar, and the primary action becomes an extended floating
/// button (icon and label) in thumb reach. Either way there is exactly one
/// primary action, and it is the same [TixAction].
class TixPage extends StatelessWidget {
  /// A page titled [title] showing [body].
  const TixPage({
    required this.title,
    required this.body,
    this.subtitle,
    this.subtitleNote,
    this.primaryAction,
    this.actions = const [],
    this.titleWidget,
    super.key,
  });

  /// The page's name.
  final String title;

  /// A widget drawn in place of the title text, such as a reference beside
  /// it; [title] still names the page for screen readers.
  final Widget? titleWidget;

  /// What the page shows, in a line: a count, a scope.
  final String? subtitle;

  /// A highlight after [subtitle], in the accent, such as how many tasks an
  /// agent holds; drawn only with a [subtitle].
  final String? subtitleNote;

  /// The create action: a primary button with [Icons.add] and a label.
  final TixAction? primaryAction;

  /// Secondary tools, usually [TixIconButton]s.
  final List<Widget> actions;

  /// The content.
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final action = primaryAction;
    final open = TixPageHelp._openFor(context);
    final help = open == null
        ? null
        : ScreenHelpButton(
            key: const Key('page.help'),
            title: title,
            onPressed: open,
          );
    final content = _InTixPage(child: TixListKeys(child: body));
    if (context.isCompact) {
      final theme = Theme.of(context);
      return Scaffold(
        appBar: AppBar(
          title: Semantics(
            header: true,
            label: title,
            child: ExcludeSemantics(
              child:
                  titleWidget ?? Text(title, overflow: TextOverflow.ellipsis),
            ),
          ),
          actions: [
            ...actions,
            ?help,
            const SizedBox(width: TixSpace.s1),
          ],
          bottom: subtitle == null
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(24),
                  child: Container(
                    alignment: AlignmentDirectional.centerStart,
                    padding: const EdgeInsets.fromLTRB(
                      TixSpace.s4,
                      0,
                      TixSpace.s4,
                      TixSpace.s2,
                    ),
                    child: Text.rich(
                      _lede(context, subtitle!, subtitleNote),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
        ),
        floatingActionButton: action == null
            ? null
            : FloatingActionButton.extended(
                key: action.key,
                heroTag: null,
                onPressed: action.onPressed,
                icon: Icon(action.icon ?? Icons.add),
                label: Text(action.label),
              ),
        body: content,
      );
    }
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TixPageHeader(
              title: title,
              titleWidget: titleWidget,
              subtitle: subtitle,
              subtitleNote: subtitleNote,
              actions: [
                ...actions,
                ?help,
                if (action != null)
                  TixButton.primary(
                    key: action.key,
                    label: action.label,
                    icon: action.icon ?? Icons.add,
                    onPressed: action.onPressed,
                  ),
              ],
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

/// What pressing the (?) in a [TixPage] header below it does: [open] gives
/// the action for the page built in a context, or null for a page whose
/// screen has no documentation. Set once around the routes; without it,
/// pages draw no (?).
class TixPageHelp extends InheritedWidget {
  /// Help for the pages in [child], as [open] finds it.
  const TixPageHelp({required this.open, required super.child, super.key});

  /// The action for the page in a context, or null for none.
  final VoidCallback? Function(BuildContext context) open;

  /// The (?) action for a page in [context]; null inside another page, so a
  /// pane drawn as a page does not repeat its host's.
  static VoidCallback? _openFor(BuildContext context) {
    if (context.getInheritedWidgetOfExactType<_InTixPage>() != null) {
      return null;
    }
    return context.dependOnInheritedWidgetOfExactType<TixPageHelp>()?.open(
      context,
    );
  }

  @override
  bool updateShouldNotify(TixPageHelp oldWidget) => open != oldWidget.open;
}

/// Marks the body of a [TixPage].
class _InTixPage extends InheritedWidget {
  const _InTixPage({required super.child});

  @override
  bool updateShouldNotify(_InTixPage oldWidget) => false;
}

/// tix's page head on its own: a back button when the route can go back,
/// the title and its lede, and tools on the right. [TixPage] uses it on
/// wide windows; use it directly for a pane that needs a header.
class TixPageHeader extends StatelessWidget {
  /// A header titled [title].
  const TixPageHeader({
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleNote,
    this.actions = const [],
    super.key,
  });

  /// The title.
  final String title;

  /// Drawn in place of the title text.
  final Widget? titleWidget;

  /// The line under it.
  final String? subtitle;

  /// A highlight after [subtitle], in the accent.
  final String? subtitleNote;

  /// Tools, primary action last.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s5,
        TixSpace.s5,
        TixSpace.s5,
        TixSpace.headGap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canPop) ...[
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: BackButton(),
            ),
            const SizedBox(width: TixSpace.s1),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: TixSpace.s1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    label: title,
                    child: ExcludeSemantics(
                      child: DefaultTextStyle(
                        style: theme.textTheme.headlineSmall!,
                        child: titleWidget ?? Text(title),
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: TixSpace.headSub),
                    Text.rich(
                      _lede(context, subtitle!, subtitleNote),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.tix.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: TixSpace.s3),
            Wrap(
              spacing: TixSpace.s2,
              runSpacing: TixSpace.s2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

/// [subtitle], then [note] after a middle dot in the accent, as tix's lede
/// marks the tasks an agent holds.
TextSpan _lede(BuildContext context, String subtitle, String? note) => TextSpan(
  text: subtitle,
  children: [
    if (note != null) ...[
      const TextSpan(text: ' · '),
      TextSpan(
        text: note,
        style: TextStyle(color: context.tix.accent),
      ),
    ],
  ],
);
