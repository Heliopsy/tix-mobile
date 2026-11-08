// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Scope;
import 'package:tix_mobile/src/data/models/actor.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Scope;

/// What the active credential may do, read from `whoami`.
///
/// It mirrors tix's `Actor.HasScope`: scopes granted directly, then the
/// role's bundle, with `*` covering everything except `global:admin` and
/// `account:read`, which count only when named. Screens use it to leave out
/// what the server would refuse; the server still decides.
@immutable
class Access {
  /// The access [actor] has.
  const Access(this.actor);

  /// Nothing at all: before `whoami` answers, or for a credential it
  /// refuses.
  static const none = Access(Actor());

  /// The actor `whoami` answered with.
  final Actor actor;

  static const _named = {'global:admin', 'account:read'};

  /// The scopes each role grants, as tix's `Role.Scopes` lists them.
  static const roleScopes = <Role, List<String>>{
    Role.viewer: [
      'task:read',
      'project:read',
      'workflow:read',
      'event:subscribe',
      'audit:read',
    ],
    Role.member: [
      'task:read',
      'task:write',
      'task:transition',
      'task:claim',
      'project:read',
      'workflow:read',
      'comment:write',
      'artifact:write',
      'event:subscribe',
      'audit:read',
      'export',
    ],
    Role.admin: ['*'],
  };

  /// Whether the actor holds [scope], directly or by role.
  bool has(Scope scope) => hasValue(scope.value);

  /// Whether the actor holds the scope named [scope], for scopes the
  /// generated enum does not list yet.
  bool hasValue(String scope) {
    final direct = actor.scopes;
    if (_named.contains(scope)) return direct.contains(scope);
    if (direct.contains('*') || direct.contains(scope)) return true;
    final role = roleScopes[actor.role] ?? const <String>[];
    return role.contains('*') || role.contains(scope);
  }

  /// Whether the actor may act as a global admin right now.
  bool get globalAdmin => actor.globalAdmin;

  /// The project a project-scoped token is confined to, or empty.
  String get projectId => actor.projectId;

  @override
  bool operator ==(Object other) => other is Access && other.actor == actor;

  @override
  int get hashCode => actor.hashCode;
}
