// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';

/// One page of a keyset-paginated tix listing.
@immutable
class Page<T> {
  /// Creates a page holding [items], followed by [nextCursor] if any.
  const Page({required this.items, this.nextCursor});

  /// Reads `{"items": [...], "next_cursor": "..."}` with [item] per element.
  factory Page.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) item,
  ) {
    final raw = json['items'] as List<dynamic>? ?? const <dynamic>[];
    final cursor = json['next_cursor'] as String?;
    return Page(
      items: [for (final e in raw) item(e as Map<String, dynamic>)],
      nextCursor: cursor == null || cursor.isEmpty ? null : cursor,
    );
  }

  /// The rows of this page.
  final List<T> items;

  /// The cursor of the following page, null on the last one.
  final String? nextCursor;

  /// Whether another page follows.
  bool get hasMore => nextCursor != null;
}
