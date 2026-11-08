// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';

/// Where the app offers one tix operation.
///
/// The idea is tix's own `internal/capability`: every operation is declared
/// once with what exposes it, and a test holds the app to the whole API.
/// Here the API is `api/tix-openapi.yaml`, and an operation is either bound
/// below, or exempt or pending in `exemptions.yaml` beside this file.
@immutable
class Binding {
  /// Binds an operation to [action] in [feature], shipped in [wave].
  const Binding({
    required this.feature,
    required this.action,
    required this.wave,
  });

  /// The directory under `lib/src/features/`, or `core/<dir>` for an
  /// operation the app uses without a screen of its own.
  final String feature;

  /// What the person does, or what the app does for them: a short id.
  final String action;

  /// The wave it shipped in: 0 for what predates the parity work, then 1
  /// daily work, 2 team, 3 admin.
  final int wave;
}

/// Every operationId the app performs, and where.
const bindings = <String, Binding>{
  'server.health': Binding(feature: 'connect', action: 'check-server', wave: 0),
  'identity.whoami': Binding(feature: 'connect', action: 'identify', wave: 0),
  'tenant.show': Binding(feature: 'connect', action: 'name-tenant', wave: 0),
  'session.login': Binding(feature: 'connect', action: 'sign-in', wave: 0),
  'session.switch': Binding(feature: 'shell', action: 'switch-tenant', wave: 0),
  'session.logout': Binding(feature: 'instances', action: 'sign-out', wave: 0),
  'project.list': Binding(feature: 'projects', action: 'list', wave: 0),
  'task.list': Binding(feature: 'tasks', action: 'list', wave: 0),
  'task.show': Binding(feature: 'tasks', action: 'detail', wave: 0),
  'task.create': Binding(feature: 'tasks', action: 'quick-add', wave: 0),
  'actor.show': Binding(feature: 'tasks', action: 'assignee', wave: 0),
  // Wave 1: quick add, templates and the palette.
  'task.import': Binding(feature: 'quick', action: 'preview-line', wave: 1),
  'template.list': Binding(feature: 'templates', action: 'list', wave: 1),
  'template.show': Binding(feature: 'templates', action: 'show', wave: 1),
  'template.save': Binding(feature: 'templates', action: 'save', wave: 1),
  'template.update': Binding(feature: 'templates', action: 'edit', wave: 1),
  'template.delete': Binding(feature: 'templates', action: 'delete', wave: 1),
  'template.use': Binding(feature: 'templates', action: 'use', wave: 1),
  'event.subscribe': Binding(
    feature: 'core/events',
    action: 'live-updates',
    wave: 0,
  ),
  'event.poll': Binding(
    feature: 'core/events',
    action: 'live-updates-fallback',
    wave: 1,
  ),
  'task.update': Binding(feature: 'tasks', action: 'edit', wave: 1),
  'task.check': Binding(feature: 'tasks', action: 'tick-checklist', wave: 1),
  'task.route': Binding(feature: 'tasks', action: 'move', wave: 1),
  // Wave 1: board, lists, filters and bulk actions.
  'task.bulk': Binding(feature: 'tasks', action: 'bulk', wave: 1),
  'task.star': Binding(feature: 'tasks', action: 'star', wave: 1),
  'task.unstar': Binding(feature: 'tasks', action: 'unstar', wave: 1),
  'task.snooze': Binding(feature: 'tasks', action: 'snooze', wave: 1),
  'task.unsnooze': Binding(feature: 'tasks', action: 'wake', wave: 1),
  'task.copy': Binding(feature: 'tasks', action: 'copy', wave: 1),
  'task.delete': Binding(feature: 'tasks', action: 'delete', wave: 1),
  'task.restore': Binding(feature: 'tasks', action: 'undo-delete', wave: 1),
  'task.tree': Binding(feature: 'tasks', action: 'subtasks', wave: 1),
  'task.audit': Binding(feature: 'tasks', action: 'history', wave: 1),
  'tag.add': Binding(feature: 'tasks', action: 'add-tag', wave: 1),
  'tag.remove': Binding(feature: 'tasks', action: 'remove-tag', wave: 1),
  'tag.list': Binding(feature: 'tasks', action: 'tag-picker', wave: 1),
  'comment.list': Binding(feature: 'tasks', action: 'comments', wave: 1),
  'comment.add': Binding(feature: 'tasks', action: 'comment', wave: 1),
  'comment.edit': Binding(feature: 'tasks', action: 'edit-comment', wave: 1),
  'comment.delete': Binding(
    feature: 'tasks',
    action: 'delete-comment',
    wave: 1,
  ),
  'dependency.list': Binding(feature: 'tasks', action: 'dependencies', wave: 1),
  'dependency.add': Binding(
    feature: 'tasks',
    action: 'add-dependency',
    wave: 1,
  ),
  'dependency.remove': Binding(
    feature: 'tasks',
    action: 'remove-dependency',
    wave: 1,
  ),
  'artifact.list': Binding(feature: 'tasks', action: 'artifacts', wave: 1),
  'artifact.put': Binding(feature: 'tasks', action: 'attach', wave: 1),
  'field.list': Binding(feature: 'tasks', action: 'custom-fields', wave: 1),
  'project.show': Binding(feature: 'tasks', action: 'project-of-task', wave: 1),
  'workflow.get': Binding(feature: 'tasks', action: 'workflow-moves', wave: 1),
  'actor.list': Binding(feature: 'tasks', action: 'actor-picker', wave: 1),
  'trash.status': Binding(feature: 'tasks', action: 'delete-undo', wave: 1),
  'workflow.list': Binding(feature: 'tasks', action: 'board-columns', wave: 1),
  'view.groups': Binding(feature: 'tasks', action: 'arrangement', wave: 1),
  'view.group.set': Binding(feature: 'tasks', action: 'arrange-group', wave: 1),
  'view.order': Binding(feature: 'tasks', action: 'move-group', wave: 1),
  'view.reset': Binding(feature: 'tasks', action: 'reset-arrangement', wave: 1),
  'filter.list': Binding(feature: 'tasks', action: 'saved-filters', wave: 1),
  'filter.save': Binding(feature: 'tasks', action: 'save-filter', wave: 1),
  'filter.update': Binding(feature: 'tasks', action: 'edit-filter', wave: 1),
  'filter.delete': Binding(feature: 'tasks', action: 'delete-filter', wave: 1),
  'filter.order': Binding(feature: 'tasks', action: 'order-filters', wave: 1),
  'stats.read': Binding(feature: 'projects', action: 'open-count', wave: 1),
  // Inbox, notifications and the summary (wave 1, area C).
  'inbox.list': Binding(feature: 'inbox', action: 'list', wave: 1),
  'inbox.count': Binding(feature: 'inbox', action: 'badge', wave: 1),
  'inbox.read': Binding(feature: 'inbox', action: 'mark-read', wave: 1),
  'inbox.unread': Binding(feature: 'inbox', action: 'mark-unread', wave: 1),
  'inbox.read_all': Binding(feature: 'inbox', action: 'mark-all-read', wave: 1),
  'inbox.prefs': Binding(feature: 'inbox', action: 'kinds', wave: 1),
  'inbox.prefs.set': Binding(feature: 'inbox', action: 'mute-kind', wave: 1),
  'time.settings': Binding(
    feature: 'core/time',
    action: 'date-settings',
    wave: 1,
  ),
  'time.prefs.set': Binding(
    feature: 'settings',
    action: 'set-date-settings',
    wave: 1,
  ),
  'inbox.channel.list': Binding(feature: 'inbox', action: 'channels', wave: 1),
  'inbox.channel.add': Binding(
    feature: 'inbox',
    action: 'add-channel',
    wave: 1,
  ),
  'inbox.channel.edit': Binding(
    feature: 'inbox',
    action: 'edit-channel',
    wave: 1,
  ),
  'inbox.channel.rm': Binding(
    feature: 'inbox',
    action: 'delete-channel',
    wave: 1,
  ),
  'inbox.channel.test': Binding(
    feature: 'inbox',
    action: 'test-channel',
    wave: 1,
  ),
  'inbox.channel.deliveries': Binding(
    feature: 'inbox',
    action: 'deliveries',
    wave: 1,
  ),
  'inbox.channel.redeliver': Binding(
    feature: 'inbox',
    action: 'redeliver',
    wave: 1,
  ),
  // Wave 2: projects, workflows and custom fields.
  'project.create': Binding(feature: 'projects', action: 'create', wave: 2),
  'project.update': Binding(feature: 'projects', action: 'settings', wave: 2),
  'project.delete': Binding(
    feature: 'projects',
    action: 'archive-or-delete',
    wave: 2,
  ),
  'project.delete-plan': Binding(
    feature: 'projects',
    action: 'delete-plan',
    wave: 2,
  ),
  'project.icon': Binding(feature: 'projects', action: 'icon-image', wave: 2),
  'field.put': Binding(feature: 'projects', action: 'define-field', wave: 2),
  'field.delete': Binding(feature: 'projects', action: 'delete-field', wave: 2),
  'workflow.put': Binding(feature: 'workflows', action: 'create', wave: 2),
  'workflow.put_by_key': Binding(feature: 'workflows', action: 'edit', wave: 2),
  'workflow.delete': Binding(feature: 'workflows', action: 'delete', wave: 2),
  // Wave 2, people and access (w2-people-access).
  'user.list': Binding(feature: 'people', action: 'list', wave: 2),
  'user.create': Binding(feature: 'people', action: 'create-user', wave: 2),
  'user.update': Binding(feature: 'people', action: 'edit-user', wave: 2),
  'user.delete': Binding(feature: 'people', action: 'delete-user', wave: 2),
  'member.list': Binding(feature: 'people', action: 'roles', wave: 2),
  'member.add': Binding(feature: 'people', action: 'add-member', wave: 2),
  'member.remove': Binding(feature: 'people', action: 'remove-member', wave: 2),
  'invite.create': Binding(feature: 'people', action: 'invite', wave: 2),
  'invite.list': Binding(feature: 'people', action: 'invites', wave: 2),
  'invite.reissue': Binding(
    feature: 'people',
    action: 'reissue-invite',
    wave: 2,
  ),
  'invite.revoke': Binding(feature: 'people', action: 'revoke-invite', wave: 2),
  'token.create': Binding(feature: 'tokens', action: 'issue', wave: 2),
  'token.list': Binding(feature: 'tokens', action: 'list', wave: 2),
  'token.revoke': Binding(feature: 'tokens', action: 'revoke', wave: 2),
  'account.log': Binding(feature: 'account', action: 'history', wave: 2),
  'calendar.show': Binding(
    feature: 'account',
    action: 'calendar-feed',
    wave: 2,
  ),
  'calendar.create': Binding(
    feature: 'account',
    action: 'create-feed',
    wave: 2,
  ),
  'calendar.rotate': Binding(
    feature: 'account',
    action: 'rotate-feed',
    wave: 2,
  ),
  'calendar.revoke': Binding(
    feature: 'account',
    action: 'revoke-feed',
    wave: 2,
  ),
  'calendar.filter': Binding(
    feature: 'account',
    action: 'filter-feed',
    wave: 2,
  ),
  'task.export': Binding(feature: 'transfer', action: 'export-tasks', wave: 2),
  'snapshot.export': Binding(
    feature: 'transfer',
    action: 'export-snapshot',
    wave: 2,
  ),
  'tenant.update': Binding(
    feature: 'admin',
    action: 'tenant-settings',
    wave: 3,
  ),
  'tenant.delete': Binding(feature: 'admin', action: 'delete-tenant', wave: 3),
  'tenant.list': Binding(feature: 'admin', action: 'tenants', wave: 3),
  'tenant.create': Binding(feature: 'admin', action: 'create-tenant', wave: 3),
  'tenant.user.list': Binding(
    feature: 'admin',
    action: 'tenant-users',
    wave: 3,
  ),
  'tenant.user.create': Binding(
    feature: 'admin',
    action: 'create-tenant-user',
    wave: 3,
  ),
  'tenant.user.update': Binding(
    feature: 'admin',
    action: 'edit-tenant-user',
    wave: 3,
  ),
  'tenant.user.delete': Binding(
    feature: 'admin',
    action: 'delete-tenant-user',
    wave: 3,
  ),
  'tenant.member.add': Binding(
    feature: 'admin',
    action: 'add-tenant-member',
    wave: 3,
  ),
  'tenant.domain.list': Binding(
    feature: 'admin',
    action: 'tenant-domains',
    wave: 3,
  ),
  'domain.update': Binding(feature: 'admin', action: 'share-domain', wave: 3),
  'domain.list': Binding(feature: 'admin', action: 'domains', wave: 3),
  'domain.add': Binding(feature: 'admin', action: 'add-domain', wave: 3),
  'domain.remove': Binding(feature: 'admin', action: 'remove-domain', wave: 3),
  'global_admin.list': Binding(
    feature: 'admin',
    action: 'global-admins',
    wave: 3,
  ),
  'global_admin.grant': Binding(
    feature: 'admin',
    action: 'grant-global-admin',
    wave: 3,
  ),
  'global_admin.revoke': Binding(
    feature: 'admin',
    action: 'revoke-global-admin',
    wave: 3,
  ),
  'account.log.any': Binding(feature: 'admin', action: 'account-log', wave: 3),
  'connection.list': Binding(feature: 'admin', action: 'connections', wave: 3),
  'connection.end': Binding(
    feature: 'admin',
    action: 'end-connection',
    wave: 3,
  ),
  'totp.clear': Binding(
    feature: 'admin',
    action: 'clear-second-factor',
    wave: 3,
  ),
  'totp.status': Binding(feature: 'security', action: 'second-factor', wave: 3),
  'totp.enrol': Binding(
    feature: 'security',
    action: 'set-up-second-factor',
    wave: 3,
  ),
  'totp.confirm': Binding(
    feature: 'security',
    action: 'confirm-second-factor',
    wave: 3,
  ),
  'totp.codes': Binding(
    feature: 'security',
    action: 'new-recovery-codes',
    wave: 3,
  ),
  'totp.remove': Binding(
    feature: 'security',
    action: 'remove-second-factor',
    wave: 3,
  ),
  'sshkey.list': Binding(feature: 'security', action: 'ssh-keys', wave: 3),
  'sshkey.enrol': Binding(feature: 'security', action: 'add-ssh-key', wave: 3),
  'sshkey.revoke': Binding(
    feature: 'security',
    action: 'revoke-ssh-key',
    wave: 3,
  ),
  'claim.reclaim': Binding(
    feature: 'tasks',
    action: 'force-release-claim',
    wave: 3,
  ),
  'audit.list': Binding(feature: 'audit', action: 'browse', wave: 3),
  'webhook.list': Binding(feature: 'integrations', action: 'webhooks', wave: 3),
  'webhook.put': Binding(
    feature: 'integrations',
    action: 'save-webhook',
    wave: 3,
  ),
  'webhook.delete': Binding(
    feature: 'integrations',
    action: 'delete-webhook',
    wave: 3,
  ),
  'webhook.deliveries': Binding(
    feature: 'integrations',
    action: 'delivery-log',
    wave: 3,
  ),
  'webhook.redeliver': Binding(
    feature: 'integrations',
    action: 'redeliver',
    wave: 3,
  ),
  'sync.source.list': Binding(
    feature: 'integrations',
    action: 'sync-sources',
    wave: 3,
  ),
  'sync.source.put': Binding(
    feature: 'integrations',
    action: 'save-sync-source',
    wave: 3,
  ),
  'sync.source.delete': Binding(
    feature: 'integrations',
    action: 'delete-sync-source',
    wave: 3,
  ),
  'sync.run': Binding(feature: 'integrations', action: 'run-sync', wave: 3),
  'retention.get': Binding(
    feature: 'maintenance',
    action: 'retention',
    wave: 3,
  ),
  'retention.put': Binding(
    feature: 'maintenance',
    action: 'save-retention',
    wave: 3,
  ),
  'retention.prune': Binding(feature: 'maintenance', action: 'prune', wave: 3),
  'housekeeping.get': Binding(
    feature: 'maintenance',
    action: 'housekeeping',
    wave: 3,
  ),
  'housekeeping.put': Binding(
    feature: 'maintenance',
    action: 'save-housekeeping',
    wave: 3,
  ),
  'housekeeping.run': Binding(
    feature: 'maintenance',
    action: 'run-housekeeping',
    wave: 3,
  ),
  // The rest of waves 1 and 2: claims shown, single transitions, fresh
  // tags, saved filters by name, invites, status and bundles.
  'task.lease': Binding(feature: 'tasks', action: 'lease-shown', wave: 1),
  'task.tags': Binding(feature: 'tasks', action: 'fresh-tags', wave: 1),
  'task.transition': Binding(feature: 'tasks', action: 'transition', wave: 1),
  'filter.show': Binding(feature: 'tasks', action: 'open-filter', wave: 1),
  'invite.preview': Binding(
    feature: 'connect',
    action: 'preview-invite',
    wave: 2,
  ),
  'invite.accept': Binding(
    feature: 'connect',
    action: 'accept-invite',
    wave: 2,
  ),
  'status.read': Binding(feature: 'status', action: 'status', wave: 2),
  'bundle.export': Binding(
    feature: 'bundles',
    action: 'export-bundle',
    wave: 2,
  ),
  'bundle.import': Binding(
    feature: 'bundles',
    action: 'import-bundle',
    wave: 2,
  ),
  'snapshot.import': Binding(
    feature: 'bundles',
    action: 'import-snapshot',
    wave: 2,
  ),
  'token.rotate': Binding(
    feature: 'instances',
    action: 'rotate-own-token',
    wave: 2,
  ),
};
