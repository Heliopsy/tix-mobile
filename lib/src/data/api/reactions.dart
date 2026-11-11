// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/transport.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/reaction.dart';

/// Comment reactions, which tix v0.53.0 (the release `tix.lock` pins) does
/// not describe. Written by hand over the generated client's transport; the
/// generated operations replace it when the pin moves to a release with them.
class ReactionOps {
  /// Sends through [_t].
  const ReactionOps(this._t);

  final TixTransport _t;

  /// AddReaction adds the caller's [reaction] to the comment [id] and returns
  /// the comment. Idempotent. Throws [ReactionsUnsupported] on a server
  /// without the route.
  ///
  /// `PUT /api/v1/comments/{id}/reactions/{reaction}`, scope `comment:write`.
  Future<ReactedComment> add(String id, Reaction reaction) =>
      _send('PUT', id, reaction);

  /// RemoveReaction removes the caller's [reaction] from the comment [id] and
  /// returns the comment. Idempotent. Throws [ReactionsUnsupported] on a
  /// server without the route.
  ///
  /// `DELETE /api/v1/comments/{id}/reactions/{reaction}`, scope
  /// `comment:write`.
  Future<ReactedComment> remove(String id, Reaction reaction) =>
      _send('DELETE', id, reaction);

  /// ListComments lists a task's comments that are not deleted, oldest first,
  /// keeping each one's reactions.
  ///
  /// `GET /api/v1/tasks/{ref}/comments` (`comment.list`), scope `task:read`.
  Future<Page<ReactedComment>> comments(String ref) async => Page.fromJson(
    await _t.json('GET', '/api/v1/tasks/${_t.segment(ref)}/comments'),
    (e) => ReactedComment.fromJson(e! as Map<String, dynamic>),
  );

  Future<ReactedComment> _send(
    String method,
    String id,
    Reaction reaction,
  ) async {
    final path =
        '/api/v1/comments/${_t.segment(id)}/reactions/${reaction.wire}';
    try {
      return ReactedComment.fromJson(await _t.json(method, path));
    } on TixException catch (e) {
      if (isMissingRoute(e)) throw ReactionsUnsupported(e);
      rethrow;
    }
  }
}

/// Whether [e] is how a server without the reaction routes answers: 405, or
/// 404 with no envelope or tix's routing message. A missing comment is a 404
/// that names the comment.
bool isMissingRoute(TixException e) =>
    e.status == 405 ||
    (e.status == 404 && (e.message.isEmpty || e.message == 'no such route'));

/// The server has no reaction routes: it predates them.
final class ReactionsUnsupported implements Exception {
  /// Reports a server that answered [cause] to a reaction.
  const ReactionsUnsupported(this.cause);

  /// The server's answer.
  final TixException cause;

  @override
  String toString() => 'the server does not support reactions ($cause)';
}
