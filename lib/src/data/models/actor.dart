// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show AccountMembership, Actor, ActorKind, Role;

/// What the app shows for an actor.
extension ActorLabel on Actor {
  /// The name to show for this actor: display name, else handle, else id.
  String get label => displayName.isNotEmpty
      ? displayName
      : handle.isNotEmpty
      ? handle
      : id;
}
