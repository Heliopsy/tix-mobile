// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  runApp(
    ProviderScope(
      retry: noRetry,
      overrides: [
        keyValueStoreProvider.overrideWithValue(PrefsKeyValueStore(prefs)),
      ],
      child: const App(),
    ),
  );
}
