// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:tix_mobile/src/data/models/page.dart';

/// The rows of a keyset-paginated listing loaded so far.
@immutable
class Paged<T> {
  /// Holds [items], with [cursor] naming the next page if there is one.
  const Paged({
    required this.items,
    this.cursor,
    this.loadingMore = false,
    this.moreError,
  });

  /// Every row loaded so far.
  final List<T> items;

  /// The cursor of the next page, null after the last.
  final String? cursor;

  /// Whether the next page is being fetched.
  final bool loadingMore;

  /// Why the last attempt at the next page failed, if it did.
  final Object? moreError;

  /// Whether another page follows.
  bool get hasMore => cursor != null;

  /// A copy with the given fields replaced; [moreError] is cleared unless
  /// given.
  Paged<T> copyWith({
    List<T>? items,
    String? Function()? cursor,
    bool? loadingMore,
    Object? moreError,
  }) => Paged(
    items: items ?? this.items,
    cursor: cursor == null ? this.cursor : cursor(),
    loadingMore: loadingMore ?? this.loadingMore,
    moreError: moreError,
  );
}

/// Appends the page after [current] through [emit], fetched with [fetch].
///
/// Does nothing when there is no next page or one is already in flight. A
/// failure is kept on the state as [Paged.moreError] rather than replacing
/// the rows already shown.
Future<void> loadNextPage<T>({
  required Paged<T>? current,
  required Future<Page<T>> Function(String cursor) fetch,
  required void Function(Paged<T>) emit,
}) async {
  if (current == null || current.loadingMore) return;
  final cursor = current.cursor;
  if (cursor == null) return;
  emit(current.copyWith(loadingMore: true));
  try {
    final page = await fetch(cursor);
    emit(
      current.copyWith(
        items: [...current.items, ...page.items],
        cursor: () => page.nextCursor,
        loadingMore: false,
      ),
    );
  } on Object catch (e) {
    emit(current.copyWith(loadingMore: false, moreError: e));
  }
}
