// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/repositories/instances_repository.dart';

/// Every context saved in [repo] that this device reaches, one per
/// connection and tenant.
List<ContextEntry> savedContexts(InstancesRepository repo) => [
  for (final i in repo.instances())
    for (final c in repo.connectionsOf(i.id))
      for (final e in entriesOf(i, c))
        if (e.elsewhere.isEmpty) e,
];

/// How the dump and commands name [entry]: `<connection>.<tenant>`, the key
/// widgets and notifications use.
String contextKey(ContextEntry entry) =>
    '${entry.connection.id}.${entry.tenantKey}';

/// [entry] as a person reads it: the instance, then the tenant.
String contextLabel(ContextEntry entry) => [
  entry.instance.name,
  entry.tenantName,
].where((s) => s.isNotEmpty).join(' · ');

/// Whether [entry] is the context [active].
bool isActiveContext(ContextEntry entry, ContextRef? active) =>
    active != null &&
    entry.connection.id == active.connectionId &&
    (!entry.connection.switchable || entry.tenantKey == active.tenantKey);

/// The entries [name] names: by key (`<connection>.<tenant>`) or connection
/// id first, else by instance name, tenant key or name, connection label,
/// or `<instance>/<tenant>`, ignoring case.
List<ContextEntry> contextsNamed(String name, List<ContextEntry> entries) {
  final q = name.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final byId = [
    for (final e in entries)
      if (contextKey(e).toLowerCase() == q ||
          e.connection.id.toLowerCase() == q)
        e,
  ];
  if (byId.isNotEmpty) return byId;
  bool named(ContextEntry e) => [
    e.instance.name,
    e.tenantKey,
    e.tenantName,
    e.connection.label,
    '${e.instance.name}/${e.tenantKey}',
    '${e.instance.name}/${e.tenantName}',
  ].any((s) => s.isNotEmpty && s.toLowerCase() == q);
  return [
    for (final e in entries)
      if (named(e)) e,
  ];
}

/// What naming a context means.
enum ContextMatchKind {
  /// Nothing saved is called that.
  unknown,

  /// It is the active context.
  stay,

  /// It names one other context.
  switchTo,

  /// It names several; someone has to pick.
  ambiguous,
}

/// The outcome of naming a context.
@immutable
class ContextMatch {
  /// A match of [kind] among [choices].
  const ContextMatch(this.kind, [this.choices = const []]);

  /// What it means.
  final ContextMatchKind kind;

  /// The context to switch to, or those to pick from.
  final List<ContextEntry> choices;
}

/// What [name] means given the saved [entries] and the [active] context.
/// Naming the active context, alone or among others, stays in it.
ContextMatch matchContext(
  String name,
  List<ContextEntry> entries,
  ContextRef? active,
) {
  final found = contextsNamed(name, entries);
  if (found.isEmpty) return const ContextMatch(ContextMatchKind.unknown);
  if (found.any((e) => isActiveContext(e, active))) {
    return const ContextMatch(ContextMatchKind.stay);
  }
  if (found.length == 1) {
    return ContextMatch(ContextMatchKind.switchTo, found);
  }
  return ContextMatch(ContextMatchKind.ambiguous, found);
}
