// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';

part 'providers.g.dart';

/// The settings store, overridden in `main` once preferences are loaded.
@Riverpod(keepAlive: true)
KeyValueStore keyValueStore(Ref ref) =>
    throw UnimplementedError('keyValueStoreProvider must be overridden');

/// The secret store for API tokens.
@Riverpod(keepAlive: true)
SecretStore secretStore(Ref ref) => SecureSecretStore();
