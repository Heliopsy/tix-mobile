// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';

/// The actor id tix gives to changes nobody made, which has no screen.
const systemActorId = 'system';

/// Makes [child] open the actor screen of [actor], an id or a handle, as
/// tix's web links every name it draws to `/actors/ID`. An empty actor or
/// the system actor draws [child] alone. Inside a sheet or a dialog it
/// closes that first.
class ActorLink extends StatelessWidget {
  /// Links [child] to [actor].
  const ActorLink({required this.actor, required this.child, super.key});

  /// The actor's id or handle.
  final String actor;

  /// What names it: a name, an avatar, a row.
  final Widget child;

  /// Whether [actor] has a screen to open.
  static bool links(String actor) => actor.isNotEmpty && actor != systemActorId;

  @override
  Widget build(BuildContext context) {
    if (!links(actor)) return child;
    return Semantics(
      link: true,
      hint: context.l10n.actorOpenHint,
      child: InkWell(onTap: () => _open(context), child: child),
    );
  }

  /// Opens the actor's screen, closing the sheet or dialog [context] is in
  /// first so the screen is not drawn beneath it.
  void _open(BuildContext context) {
    final router = GoRouter.of(context);
    if (ModalRoute.of(context) is PopupRoute) Navigator.of(context).pop();
    unawaited(router.push(Routes.actor(actor)));
  }
}
