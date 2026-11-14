// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/view_prefs_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late ViewPrefsRepository repo;

  setUp(() {
    server = FakeTix();
    repo = ViewPrefsRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(MemoryCacheStore(), const CacheScope('c1', '')),
    );
  });

  Map<String, Object?> filter(String id, {bool mine = true}) => {
    'id': id,
    'name': 'name $id',
    'query': 'tag:$id',
    'view': 'lanes',
    'mine': mine,
    'editable': mine,
    'position': 1,
  };

  test('saveFilter sends the view and sort with the query', () async {
    final saved = await repo.saveFilter(
      name: 'Ops',
      query: 'tag:ops',
      sort: 'due_at',
      view: 'board',
      shared: true,
    );
    final body = server.requestsTo('/api/v1/filters').single.data as Map;
    expect(body['view'], 'board');
    expect(body['sort'], 'due_at');
    expect(body['shared'], true);
    expect(saved.view, 'board');
  });

  test('filters read the server order, position and view', () async {
    server.filters.addAll([filter('b'), filter('a'), filter('s', mine: false)]);
    final filters = await repo.filters();
    expect(filters.map((f) => f.id), ['b', 'a', 's']);
    expect(filters.first.view, 'lanes');
    expect(filters.first.position, 1);
  });

  test('orderFilters sends the ids and returns the server order', () async {
    server.filters.addAll([filter('a'), filter('b'), filter('c')]);
    final ordered = await repo.orderFilters(['c', 'a', 'b']);
    final put = server.requestsTo('/api/v1/filters/order').single;
    expect(put.method, 'PUT');
    expect((put.data as Map)['filters'], ['c', 'a', 'b']);
    expect(ordered.map((f) => f.id), ['c', 'a', 'b']);
  });
}
