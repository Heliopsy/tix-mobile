// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/transport.dart';
import 'package:tix_mobile/src/data/events/tix_event.dart';

/// One answer of `GET /api/v1/events/poll`.
@immutable
class EventPollPage {
  /// The [events] after the cursor sent, and the cursor to send next.
  const EventPollPage({required this.events, required this.nextSeq});

  /// The events, in `seq` order.
  final List<TixEvent> events;

  /// The highest `seq` the server examined: the next `since_seq`.
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

/// [EventPoller] over a connection's [TixTransport], so the request carries
/// that connection's credential.
// TODO(live): call the generated `api.event.poll` once tix.lock pins a tix
// whose openapi.yaml has the route, and drop this hand-written request.
class TixEventPoller implements EventPoller {
  /// Polls through [transport].
  TixEventPoller(this.transport);

  /// The connection's transport.
  final TixTransport transport;

  @override
  Future<EventPollPage> poll({
    required int sinceSeq,
    List<String> types = const [],
    Duration wait = Duration.zero,
    int limit = 200,
    CancelToken? cancel,
  }) async {
    final Map<String, dynamic> body;
    try {
      body = await transport.json(
        'GET',
        '/api/v1/events/poll',
        query: {
          if (sinceSeq > 0) 'since_seq': sinceSeq,
          if (types.isNotEmpty) 'types': types.join(','),
          'limit': limit,
          if (wait > Duration.zero) 'wait': '${wait.inSeconds}s',
        },
        cancel: cancel,
      );
    } on TixException catch (e) {
      if (e.status == 404 || e.status == 405) {
        throw const EventPollUnsupported();
      }
      rethrow;
    }
    final raw = body['events'];
    final next = body['next_seq'];
    if (raw is! List || next is! num) {
      throw const TixException(TixErrorKind.notTix, status: 200);
    }
    return EventPollPage(
      events: [
        for (final e in raw)
          if (e is Map<String, dynamic>) TixEvent.fromJson(e),
      ],
      nextSeq: next.toInt(),
    );
  }
}
