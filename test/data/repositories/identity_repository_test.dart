// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/identity_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  test('me reads whoami and keeps it for the next start', () async {
    final server = FakeTix()..identity = {'role': 'member'};
    final store = MemoryCacheStore();
    final repo = IdentityRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(store, const CacheScope('c1', '')),
    );
    final me = await repo.me();
    expect(me.role?.value, 'member');
    final later = IdentityRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(store, const CacheScope('c1', '')),
    );
    expect((await later.cachedMe())!.role?.value, 'member');
  });
}
