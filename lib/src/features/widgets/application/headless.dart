// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/features/widgets/application/widget_sync.dart';
import 'package:tix_mobile/src/features/widgets/application/writer.dart';

/// What a widget can wake the app's code for.
const widgetBackgroundHosts = {'drain', 'refresh'};

/// Runs what a widget woke the app for, in a headless engine with no
/// screen and no session: the queue, then every snapshot. Reads stored
/// credentials through [container]'s providers, the same code the app
/// signs in with, and never starts a local engine: local contexts are
/// skipped and keep their snapshot.
Future<void> runWidgetBackground(Uri? uri, ProviderContainer container) async {
  if (uri == null || !widgetBackgroundHosts.contains(uri.host)) return;
  final store = container.read(keyValueStoreProvider);
  final instances = container.read(instancesRepositoryProvider);
  final writer = WidgetWriter(
    bridge: container.read(widgetBridgeProvider),
    instances: instances,
    store: store,
    l10n: widgetL10n(store),
    now: container.read(clockProvider),
    open: (t) => openStoredFeed(
      t,
      instances: instances,
      factory: container.read(tixApiFactoryProvider),
      cache: container.read(cacheStoreProvider),
    ),
  );
  bool remote(WidgetTarget t) => !t.local;
  try {
    await writer.drain(reachable: remote);
    await writer.refresh(reachable: remote);
  } on Object catch (e, s) {
    log('widgets: background run failed', error: e, stackTrace: s);
  }
}
