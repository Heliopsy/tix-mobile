// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/data/models/page.dart';

void main() {
  test('Page.fromJson treats an empty or absent cursor as the last page', () {
    final last = Page.fromJson({
      'items': [1, 2].map((i) => {'n': i}).toList(),
      'next_cursor': '',
    }, (j) => (j! as Map)['n']! as int);
    expect(last.items, [1, 2]);
    expect(last.hasMore, isFalse);
    expect(Page.fromJson(const {'items': null}, (j) => j).items, isEmpty);
    expect(Page.fromJson(const {'next_cursor': 'c'}, (j) => j).nextCursor, 'c');
  });

  test('loadNextPage appends and moves the cursor', () async {
    final states = <Paged<int>>[];
    String? asked;
    await loadNextPage<int>(
      current: const Paged(items: [1], cursor: 'c1'),
      fetch: (c) async {
        asked = c;
        return const Page(items: [2], nextCursor: 'c2');
      },
      emit: states.add,
      idOf: (i) => i,
    );
    expect(asked, 'c1');
    expect(states.first.loadingMore, isTrue);
    expect(states.last.items, [1, 2]);
    expect(states.last.cursor, 'c2');
    expect(states.last.loadingMore, isFalse);
  });

  test('loadNextPage drops a row that moved into the next page', () async {
    final states = <Paged<int>>[];
    await loadNextPage<int>(
      current: const Paged(items: [1, 2], cursor: 'c1'),
      fetch: (_) async => const Page(items: [2, 3, 3]),
      emit: states.add,
      idOf: (i) => i,
    );
    expect(states.last.items, [1, 2, 3]);
  });

  test('loadNextPage keeps the rows and records a failure', () async {
    final states = <Paged<int>>[];
    final error = Exception('down');
    await loadNextPage<int>(
      current: const Paged(items: [1], cursor: 'c1'),
      fetch: (_) async => throw error,
      emit: states.add,
      idOf: (i) => i,
    );
    expect(states.last.items, [1]);
    expect(states.last.cursor, 'c1');
    expect(states.last.moreError, error);
    expect(states.last.loadingMore, isFalse);
  });

  test('loadNextPage does nothing at the end or while loading', () async {
    var calls = 0;
    Future<Page<int>> fetch(String _) async {
      calls++;
      return const Page(items: []);
    }

    await loadNextPage<int>(
      current: const Paged(items: [1]),
      fetch: fetch,
      emit: (_) {},
      idOf: (i) => i,
    );
    await loadNextPage<int>(
      current: const Paged(items: [1], cursor: 'c', loadingMore: true),
      fetch: fetch,
      emit: (_) {},
      idOf: (i) => i,
    );
    await loadNextPage<int>(
      current: null,
      fetch: fetch,
      emit: (_) {},
      idOf: (i) => i,
    );
    expect(calls, 0);
  });
}
