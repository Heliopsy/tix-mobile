// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/integrations.dart';
import 'package:tix_mobile/src/data/repositories/audit_repository.dart';

export 'package:tix_mobile/src/data/repositories/audit_repository.dart'
    show AuditQuery;

part 'audit.g.dart';

/// What the audit log screen is narrowed to.
@riverpod
class AuditFilter extends _$AuditFilter {
  @override
  AuditQuery build() => const AuditQuery();

  /// Narrows the log to what [edit] makes of the current query.
  void change(AuditQuery Function(AuditQuery current) edit) =>
      state = edit(state);
}

/// The audit entries matching [query], newest first, a page at a time.
@riverpod
class AuditLog extends _$AuditLog {
  @override
  Future<Paged<AuditEntry>> build(AuditQuery query) async {
    final page = await ref.watch(auditRepositoryProvider).list(query);
    return Paged(items: page.items, cursor: page.nextCursor);
  }

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(auditRepositoryProvider).list(query, cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (e) => e.seq,
  );
}

/// The entry the audit log shows in detail, by its sequence number; null
/// when none is picked.
@riverpod
class AuditSelection extends _$AuditSelection {
  @override
  int? build() => null;

  /// Shows [entry] in detail.
  void show(AuditEntry entry) => state = entry.seq;

  /// Shows no entry in detail.
  void clear() => state = null;
}
