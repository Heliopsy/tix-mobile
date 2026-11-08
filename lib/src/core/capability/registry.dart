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
  'event.subscribe': Binding(
    feature: 'core/events',
    action: 'live-updates',
    wave: 0,
  ),
};
