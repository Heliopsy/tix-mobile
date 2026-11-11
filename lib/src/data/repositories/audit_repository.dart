// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/data/api/answer.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/wire.dart';

export 'package:tix_mobile/src/data/models/integrations.dart';

/// What the audit log is narrowed to. Empty fields do not narrow.
@immutable
class AuditQuery {
  /// A query; every field empty lists everything.
  const AuditQuery({
    this.text = '',
    this.actorId = '',
    this.action = '',
    this.token = '',
    this.vias = const {},
    this.sources = const {},
    this.since,
    this.until,
  });

  /// A substring searched for in the action, subject, source and values.
  final String text;

  /// The actor who made the change, by id.
  final String actorId;

  /// The action, such as `task.create`.
  final String action;

  /// The API token's name.
  final String token;

  /// The access channels, such as `web` or `ssh`.
  final Set<String> vias;

  /// The surfaces, such as `cli`.
  final Set<Source> sources;

  /// The earliest entry.
  final DateTime? since;

  /// The latest entry.
  final DateTime? until;

  /// Whether nothing narrows the log.
  bool get isEmpty =>
      text.isEmpty &&
      actorId.isEmpty &&
      action.isEmpty &&
      token.isEmpty &&
      vias.isEmpty &&
      sources.isEmpty &&
      since == null &&
      until == null;

  /// The access channels tix records.
  static const viaKinds = [
    'web',
    'api',
    'cli-local',
    'cli-remote',
    'ssh',
    'mcp',
    'sync',
    'import',
    'system',
    'unknown',
  ];

  /// A copy with the given fields replaced; a [since] or [until] function
  /// returning null clears it.
  AuditQuery copyWith({
    String? text,
    String? actorId,
    String? action,
    String? token,
    Set<String>? vias,
    Set<Source>? sources,
    DateTime? Function()? since,
    DateTime? Function()? until,
  }) => AuditQuery(
    text: text ?? this.text,
    actorId: actorId ?? this.actorId,
    action: action ?? this.action,
    token: token ?? this.token,
    vias: vias ?? this.vias,
    sources: sources ?? this.sources,
    since: since == null ? this.since : since(),
    until: until == null ? this.until : until(),
  );

  static bool _same<T>(Set<T> a, Set<T> b) =>
      a.length == b.length && a.containsAll(b);

  @override
  bool operator ==(Object other) =>
      other is AuditQuery &&
      other.text == text &&
      other.actorId == actorId &&
      other.action == action &&
      other.token == token &&
      _same(other.vias, vias) &&
      _same(other.sources, sources) &&
      other.since == since &&
      other.until == until;

  @override
  int get hashCode => Object.hash(
    text,
    actorId,
    action,
    token,
    Object.hashAllUnordered(vias),
    Object.hashAllUnordered(sources),
    since,
    until,
  );
}

/// The tenant's audit log.
///
/// Nothing here is cached: entries record changes to credential-bearing
/// records, and almost every read is filtered.
class AuditRepository {
  /// Reads through [_api].
  AuditRepository(this._api);

  final TixApi _api;

  static List<String>? _one(String v) => v.trim().isEmpty ? null : [v.trim()];

  /// One page of entries matching [query], newest first (`audit.list`),
  /// each keeping the JSON object tix sent for it ([wireJson]).
  Future<Page<AuditEntry>> list(AuditQuery query, {String? cursor}) async {
    final (page, answer) = await withAnswer(
      _api.transport,
      (t) => AuditOps(t).list(
        cursor: cursor,
        limit: pageSize,
        sort: 'seq',
        direction: 'desc',
        text: query.text.trim().isEmpty ? null : query.text.trim(),
        actorId: _one(query.actorId),
        action: _one(query.action),
        token: _one(query.token),
        via: query.vias.isEmpty ? null : query.vias.toList(),
        source: query.sources.isEmpty
            ? null
            : [for (final s in query.sources) s.value],
        since: query.since,
        until: query.until,
      ),
    );
    keepWireAll(page.items, answer?['items']);
    return page;
  }
}
