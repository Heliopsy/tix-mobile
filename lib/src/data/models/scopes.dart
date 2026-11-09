// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/models/access.dart';
import 'package:tix_mobile/src/data/models/actor.dart';

export 'package:tix_mobile/src/data/models/access.dart';

/// tix's scopes, as `docs/agents.md` lists them.
abstract final class Scopes {
  /// Everything but [globalAdmin] and [accountRead]; what the admin role
  /// carries.
  static const all = '*';

  /// Read tasks.
  static const taskRead = 'task:read';

  /// Create and edit tasks.
  static const taskWrite = 'task:write';

  /// Move a task between states.
  static const taskTransition = 'task:transition';

  /// Claim, renew, release.
  static const taskClaim = 'task:claim';

  /// Delete and restore tasks.
  static const taskDelete = 'task:delete';

  /// End the lease another worker holds.
  static const taskReclaim = 'task:reclaim';

  /// Cross a workflow edge that asks for approval.
  static const taskApprove = 'task:approve';

  /// Read projects.
  static const projectRead = 'project:read';

  /// Change projects.
  static const projectWrite = 'project:write';

  /// Read workflows.
  static const workflowRead = 'workflow:read';

  /// Change workflows.
  static const workflowWrite = 'workflow:write';

  /// Comment on tasks.
  static const commentWrite = 'comment:write';

  /// Attach artifacts.
  static const artifactWrite = 'artifact:write';

  /// Follow the event stream.
  static const eventSubscribe = 'event:subscribe';

  /// Manage users and invites.
  static const userAdmin = 'user:admin';

  /// Clear another person's second factor.
  static const totpAdmin = 'totp:admin';

  /// Issue and revoke API tokens.
  static const tokenAdmin = 'token:admin';

  /// Manage webhooks.
  static const webhookAdmin = 'webhook:admin';

  /// Manage the tenant, its members and domains.
  static const tenantAdmin = 'tenant:admin';

  /// Manage and run imports from other trackers.
  static const syncAdmin = 'sync:admin';

  /// Read the audit log.
  static const auditRead = 'audit:read';

  /// Export tasks and snapshots.
  static const export = 'export';

  /// Import tasks and snapshots.
  static const import = 'import';

  /// Administer every tenant; never carried by [all].
  static const globalAdmin = 'global:admin';

  /// Read the owner's own account history; never carried by [all].
  static const accountRead = 'account:read';

  /// The scopes a token form offers, grouped the way a person looks for them,
  /// as tix's `onboard.ScopeGroups`.
  static const groups = <String, List<String>>{
    'tasks': [
      taskRead,
      taskWrite,
      taskTransition,
      taskClaim,
      taskDelete,
      taskReclaim,
      taskApprove,
    ],
    'projects': [projectRead, projectWrite],
    'workflows': [workflowRead, workflowWrite],
    'comments': [commentWrite, artifactWrite],
    'events': [eventSubscribe],
    'admin': [
      userAdmin,
      totpAdmin,
      tokenAdmin,
      webhookAdmin,
      tenantAdmin,
      syncAdmin,
      auditRead,
      export,
      import,
      globalAdmin,
    ],
    'account': [accountRead],
  };

  /// Named bundles a token form offers, as tix's `onboard.Presets`.
  static const presets = <String, List<String>>{
    'agent': [taskRead, taskWrite, taskTransition, taskClaim, commentWrite],
    'read': [taskRead, projectRead, workflowRead, eventSubscribe],
  };
}

/// What the people and access screens ask of an [Access].
extension AccessScopes on Access {
  /// Who the credential is.
  Actor get me => actor;

  /// Whether this is an API token rather than a person's session.
  bool get isToken => actor.tokenId.isNotEmpty;

  /// Whether the credential holds [scope]. A person's own session reads
  /// its own account, as tix lets it, though `account:read` is otherwise
  /// only ever named on a token.
  bool can(String scope) =>
      hasValue(scope) ||
      (scope == Scopes.accountRead && !isToken && actor.kind == ActorKind.user);

  /// Whether the credential holds every scope, so a token form may offer
  /// `*` itself.
  bool get canAll => hasValue(Scopes.all);
}

/// One expiry a form offers: [days] from now, or never when zero.
@immutable
class ExpiryChoice {
  /// [key] lasting [days].
  const ExpiryChoice(this.key, this.days);

  /// The choice's id, as tix's form names it.
  final String key;

  /// How long it lasts; zero never expires.
  final int days;

  /// When it ends, counted from [now]; null for never.
  DateTime? from(DateTime now) =>
      days == 0 ? null : now.toUtc().add(Duration(days: days));
}

/// The expiries a token form offers, as tix's `onboard.TokenExpiries`.
const tokenExpiries = [
  ExpiryChoice('7d', 7),
  ExpiryChoice('30d', 30),
  ExpiryChoice('90d', 90),
  ExpiryChoice('365d', 365),
  ExpiryChoice('never', 0),
];

/// What a token form proposes: an expiry, not never.
const defaultTokenExpiry = '90d';

/// The lifetimes an invite link may have, as tix's web form offers them.
const inviteExpiries = [
  ExpiryChoice('1d', 1),
  ExpiryChoice('3d', 3),
  ExpiryChoice('7d', 7),
  ExpiryChoice('14d', 14),
  ExpiryChoice('30d', 30),
];

/// What an invite form proposes, tix's own default.
const defaultInviteExpiry = '7d';
