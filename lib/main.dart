// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/licences/binding.dart';
import 'package:tix_mobile/src/core/platform/adb_bridge.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/local/ffi_local_engine.dart';
import 'package:tix_mobile/src/features/inbox/application/note_actions.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';
import 'package:tix_mobile/src/features/widgets/application/headless.dart';

Future<void> main() async {
  TixBinding.ensureInitialized(
    engineBundled: () => FfiLocalTixEngine.load() != null,
  );
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  final container = ProviderContainer(
    retry: noRetry,
    overrides: [
      keyValueStoreProvider.overrideWithValue(PrefsKeyValueStore(prefs)),
      widgetBridgeProvider.overrideWithValue(
        platformWidgetBridge(background: widgetBackgroundCallback),
      ),
      adbAppearanceProvider.overrideWith(LiveAppearance.new),
    ],
  );
  if (Platform.isAndroid) {
    unawaited(container.read(adbBridgeProvider).listen());
    unawaited(container.read(noteActionBridgeProvider).listen());
  }
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

/// Android starts a headless engine here to answer `dumpsys` and
/// `am broadcast` while the app is not open (docs/adb.md). It reads what is
/// stored and never builds the session, live updates or a local engine.
@pragma('vm:entry-point')
Future<void> adbHeadlessMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  final container = ProviderContainer(
    retry: noRetry,
    overrides: [
      keyValueStoreProvider.overrideWithValue(PrefsKeyValueStore(prefs)),
      adbHeadlessProvider.overrideWithValue(true),
    ],
  );
  await container.read(adbBridgeProvider).listen();
}

/// Android starts a headless engine here to run a notification button
/// pressed while the app is not open. It writes through the stored
/// context's outbox and never builds the session or a local engine.
@pragma('vm:entry-point')
Future<void> noteActionHeadlessMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  final container = ProviderContainer(
    retry: noRetry,
    overrides: [
      keyValueStoreProvider.overrideWithValue(PrefsKeyValueStore(prefs)),
    ],
  );
  await container.read(noteActionBridgeProvider).listen();
}

/// What an Android widget's tick or the refresh worker runs, in the
/// headless engine `home_widget` starts.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) => _headless(uri);

/// The iOS runner's headless engine starts here for a widget tick or a
/// background refresh, and is told `done` when the work is over.
@pragma('vm:entry-point')
Future<void> widgetHeadlessMain(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _headless(args.isEmpty ? null : Uri.tryParse(args.first));
  } finally {
    await const MethodChannel('tix/widgets/headless')
        .invokeMethod<void>('done');
  }
}

Future<void> _headless(Uri? uri) async {
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  final container = ProviderContainer(
    retry: noRetry,
    overrides: [
      keyValueStoreProvider.overrideWithValue(PrefsKeyValueStore(prefs)),
      widgetBridgeProvider.overrideWithValue(platformWidgetBridge()),
    ],
  );
  try {
    await runWidgetBackground(uri, container);
  } finally {
    container.dispose();
  }
}
