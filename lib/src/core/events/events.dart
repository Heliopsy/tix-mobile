// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/events/live_events.dart';

export 'package:tix_mobile/src/data/events/live_events.dart';

part 'events.g.dart';

/// How event sockets are opened; tests swap in a fake.
@Riverpod(keepAlive: true)
EventSocketConnector eventSocketConnector(Ref ref) => ioEventSocket;

/// Fires each time the app comes back to the foreground.
@Riverpod(keepAlive: true)
Stream<void> appResumed(Ref ref) {
  final resumed = StreamController<void>.broadcast();
  final listener = AppLifecycleListener(onResume: () => resumed.add(null));
  ref.onDispose(() {
    listener.dispose();
    unawaited(resumed.close());
  });
  return resumed.stream;
}

/// Fires each time the app goes out of sight, the moment a home screen and
/// its widgets come back into view.
@Riverpod(keepAlive: true)
Stream<void> appHidden(Ref ref) {
  final hidden = StreamController<void>.broadcast();
  final listener = AppLifecycleListener(onHide: () => hidden.add(null));
  ref.onDispose(() {
    listener.dispose();
    unawaited(hidden.close());
  });
  return hidden.stream;
}

/// Fires each time the app goes to the background.
@Riverpod(keepAlive: true)
Stream<void> appPaused(Ref ref) {
  final paused = StreamController<void>.broadcast();
  final listener = AppLifecycleListener(onPause: () => paused.add(null));
  ref.onDispose(() {
    listener.dispose();
    unawaited(paused.close());
  });
  return paused.stream;
}

/// Whether polling stops while the app is in the background. Phones
/// suspend a backgrounded app anyway; desktops keep running when minimised.
@Riverpod(keepAlive: true)
bool livePausesInBackground(Ref ref) => Platform.isAndroid || Platform.isIOS;

/// The thresholds and timings of live updates; tests shorten them.
@Riverpod(keepAlive: true)
LiveConfig liveConfig(Ref ref) => const LiveConfig();

/// Live updates of the active context, null while there is none or it
/// cannot be reached: the WebSocket, or the HTTP fallback when it keeps
/// failing. Rebuilt, with a fresh cursor, when the context changes.
@Riverpod(keepAlive: true)
LiveEvents? tixEventStream(Ref ref) {
  final (baseUrl, credential, problem) = ref.watch(
    sessionControllerProvider.select(
      (s) => (s.value?.baseUrl, s.value?.credential, s.value?.problem),
    ),
  );
  if (baseUrl == null ||
      baseUrl.isEmpty ||
      credential == null ||
      problem != null) {
    return null;
  }
  final api = ref.watch(tixApiFactoryProvider)(baseUrl, credential);
  final live = LiveEvents(
    baseUrl: baseUrl,
    headers: credential.headers,
    poller: TixEventPoller(api),
    connector: ref.watch(eventSocketConnectorProvider),
    config: ref.watch(liveConfigProvider),
  );
  ref.listen(appResumedProvider, (_, _) => live.reconnectNow());
  if (ref.watch(livePausesInBackgroundProvider)) {
    ref.listen(appPausedProvider, (_, _) => live.pause());
  }
  ref.onDispose(live.close);
  return live;
}

/// Every update of the active context's live events.
@Riverpod(keepAlive: true)
Stream<EventStreamUpdate> tixEvents(Ref ref) =>
    ref.watch(tixEventStreamProvider)?.updates ?? const Stream.empty();

/// How live updates reach the active context and the last error, for the
/// live indicator and diagnostics. Null while there is no context.
@Riverpod(keepAlive: true)
Stream<LiveStatus?> liveStatus(Ref ref) async* {
  final live = ref.watch(tixEventStreamProvider);
  if (live == null) {
    yield null;
    return;
  }
  yield live.status;
  yield* live.statuses;
}
