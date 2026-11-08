// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/events/event_stream.dart';

export 'package:tix_mobile/src/data/events/event_stream.dart';

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

/// The event stream of the active context, null while there is none or it
/// cannot be reached. Rebuilt, with a fresh cursor, when the context
/// changes.
@Riverpod(keepAlive: true)
TixEventStream? tixEventStream(Ref ref) {
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
  final stream = TixEventStream(
    baseUrl: baseUrl,
    headers: credential.headers,
    connector: ref.watch(eventSocketConnectorProvider),
  );
  ref
    ..listen(appResumedProvider, (_, _) => stream.reconnectNow())
    ..onDispose(stream.close);
  return stream;
}

/// Every update of the active context's event stream, for anything that
/// shows whether updates are live.
@Riverpod(keepAlive: true)
Stream<EventStreamUpdate> tixEvents(Ref ref) =>
    ref.watch(tixEventStreamProvider)?.updates ?? const Stream.empty();

/// Where the active context's event stream stands.
@Riverpod(keepAlive: true)
Stream<EventStreamState> eventStreamState(Ref ref) =>
    (ref.watch(tixEventStreamProvider)?.updates ?? const Stream.empty())
        .where((u) => u is EventStreamStatus)
        .map((u) => (u as EventStreamStatus).state);
