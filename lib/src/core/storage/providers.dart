// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';

part 'providers.g.dart';

/// The settings store, overridden in `main` once preferences are loaded.
@Riverpod(keepAlive: true)
KeyValueStore keyValueStore(Ref ref) =>
    throw UnimplementedError('keyValueStoreProvider must be overridden');

/// The secret store for API tokens.
@Riverpod(keepAlive: true)
SecretStore secretStore(Ref ref) => SecureSecretStore();

/// Where the last good responses are kept: the app's support directory,
/// which the platform does not back up as user documents.
@Riverpod(keepAlive: true)
CacheStore cacheStore(Ref ref) => FileCacheStore(
  () async => Directory(
    '${(await getApplicationSupportDirectory()).path}'
    '${Platform.pathSeparator}cache',
  ),
);
