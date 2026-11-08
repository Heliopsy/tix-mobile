// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/gen/client.gen.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Event;
import 'package:tix_mobile/src/data/events/tix_event.dart';

/// One answer of `GET /api/v1/events/poll`.
@immutable
class EventPollPage {
  /// The [events] after the cursor sent, and the cursor to send next.
  const EventPollPage({required this.events, required this.nextSeq});

  /// The events, in `seq` order.
  final List<TixEvent> events;

  /// The last `seq` the server read, past the last event when later ones
  /// were filtered out: the next `since_seq`.
  final int nextSeq;
}

/// The server has no poll endpoint: it predates it.
final class EventPollUnsupported implements Exception {
  /// Reports a server without the endpoint.
  const EventPollUnsupported();

  @override
  String toString() => 'the server cannot be polled for events';
}

/// Reads tix's event log over plain HTTP.
abstract interface class EventPoller {
  /// The events after [sinceSeq], waiting up to [wait] for one when none is
  /// there yet. Throws [EventPollUnsupported] when the server lacks the
  /// endpoint and a [TixException] for anything else; [cancel] abandons it.
  Future<EventPollPage> poll({
    required int sinceSeq,
    List<String> types = const [],
    Duration wait = Duration.zero,
    int limit = 200,
    CancelToken? cancel,
  });
}

/// [EventPoller] over the generated `event.poll`, on a client of its own so
/// the request carries that connection's credential and can be cancelled.
class TixEventPoller implements EventPoller {
  /// Polls through [api], which no one else may share: its Dio gets the
  /// interceptor that hands each poll its [CancelToken].
  TixEventPoller(this.api) {
    api.transport.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.cancelToken ??= _cancel;
          handler.next(options);
        },
      ),
    );
  }

  /// The connection's client.
  final TixClient api;
  CancelToken? _cancel;

  @override
  Future<EventPollPage> poll({
    required int sinceSeq,
    List<String> types = const [],
    Duration wait = Duration.zero,
    int limit = 200,
    CancelToken? cancel,
  }) async {
    _cancel = cancel;
    try {
      final page = await api.event.poll(
        sinceSeq: sinceSeq > 0 ? sinceSeq : null,
        types: types.isEmpty ? null : types,
        limit: limit,
        wait: wait > Duration.zero ? '${wait.inSeconds}s' : null,
      );
      return EventPollPage(
        events: [
          for (final e in page.events)
            if (e.type != null) _event(e),
        ],
        nextSeq: page.nextSeq,
      );
    } on TixException catch (e) {
      if (e.status == 404 || e.status == 405) {
        throw const EventPollUnsupported();
      }
      rethrow;
    } finally {
      _cancel = null;
    }
  }

  static TixEvent _event(Event e) => TixEvent(
    seq: e.seq,
    type: e.type!.value,
    id: e.id,
    tenantId: e.tenantId,
    projectId: e.projectId,
    subjectType: e.subjectType,
    subjectId: e.subjectId,
    actorId: e.actorId,
    payload: e.payload,
    via: e.via,
    occurredAt: e.occurredAt,
  );
}
