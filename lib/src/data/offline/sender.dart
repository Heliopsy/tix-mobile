// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        ArtifactInput,
        CheckItemInput,
        CommentRequest,
        DependencyRequest,
        RouteInput,
        SnoozeInput,
        TagRequest;
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/task_patch.dart';
import 'package:tix_mobile/src/data/offline/outbox_entry.dart';

/// Sends queued writes to the server. Only the replay talks to it.
abstract interface class OutboxSender {
  /// The task [ref] as the server has it now.
  Future<Task> fetch(String ref);

  /// Sends [op] to [target] with [values], as the person's write against
  /// [version] when given, under the idempotency [key]. The task as the
  /// server now has it, when the operation answers with one.
  Future<Task?> send(
    OutboxOp op,
    String target,
    Map<String, Object?> values, {
    required String key,
    int? version,
  });

  /// The tasks a create made before its answer was lost may have become:
  /// tasks in its project, by the caller, made since [since].
  Future<CreateLookup> findCreated(Map<String, Object?> values, DateTime since);

  /// Whether the caller added a comment reading [body] to [target] since
  /// [since], so a comment whose answer was lost is not added twice.
  Future<bool> findComment(String target, String body, DateTime since);

  /// Whether the server honours `Idempotency-Key`, asked once.
  Future<bool> detectIdempotency();
}

/// What a lookup for a create whose answer was lost found: tasks whose
/// title is the queued title, and how many others only resemble it (one
/// title starts with the other). Only a single exact match and nothing
/// similar is safe to adopt.
@immutable
class CreateLookup {
  /// A lookup that found [exact] and [similar] others.
  const CreateLookup({this.exact = const [], this.similar = 0});

  /// Tasks whose normalized title equals the queued one.
  final List<Task> exact;

  /// Tasks whose title only shares a prefix with the queued one.
  final int similar;

  /// Whether nothing was found at all, so sending is safe.
  bool get none => exact.isEmpty && similar == 0;

  /// The one task the create became, when that is certain.
  Task? get certain => exact.length == 1 && similar == 0 ? exact.single : null;
}

/// [s] with its ends trimmed and every run of white space made one space.
String normalizeText(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Whether a write that failed with [e] may still have reached the server:
/// it went out and its answer was lost. A refused connection never left the
/// device.
bool mayHaveArrived(TixException e) => switch (e.kind) {
  TixErrorKind.timeout || TixErrorKind.upstream || TixErrorKind.notTix => true,
  _ => false,
};

/// The header that makes a retried write safe.
const idempotencyHeader = 'Idempotency-Key';

/// What a server that honours `Idempotency-Key` meant by refusing a write
/// sent again with the same key.
enum KeyedAnswer {
  /// Not about the key.
  none,

  /// The first request with this key is still running: try again later.
  inFlight,

  /// The first request was applied but its answer was not kept: it is
  /// done, so read the result rather than send it again.
  appliedLost,

  /// The key was used for a different request.
  mismatch,
}

/// What [e], the answer to a write sent with an `Idempotency-Key`, says
/// about the key. tix answers all three with `conflict` or `invalid` and
/// names the key in the message, which is how they differ from a stale
/// version or a bad value.
KeyedAnswer keyedAnswer(TixException e) {
  final m = e.message.toLowerCase();
  if (!m.contains('idempotency key')) return KeyedAnswer.none;
  if (e.kind == TixErrorKind.conflict) {
    return m.contains('still running')
        ? KeyedAnswer.inFlight
        : KeyedAnswer.appliedLost;
  }
  if (e.kind == TixErrorKind.invalid) return KeyedAnswer.mismatch;
  return KeyedAnswer.none;
}

/// An [OutboxSender] over the generated client.
class ApiOutboxSender implements OutboxSender {
  /// Sends through [_api].
  ApiOutboxSender(this._api);

  final TixApi _api;
  String? _me;

  /// A reference no task has; the probe deletes it.
  static const probeRef = 'idempotency-probe-0';

  /// A key longer than the 200 characters tix accepts.
  static final String probeKey = 'k' * 201;

  /// A server that reads the header refuses [probeKey] with 400 before it
  /// looks for the task; one that ignores it answers 404.
  @override
  Future<bool> detectIdempotency() async {
    try {
      await _api.transport.empty(
        'DELETE',
        '/api/v1/tasks/${_api.transport.segment(probeRef)}',
        headers: {idempotencyHeader: probeKey},
      );
    } on TixException catch (e) {
      return e.kind == TixErrorKind.invalid;
    }
    return false;
  }

  @override
  Future<Task> fetch(String ref) => _api.task.show(ref);

  @override
  Future<Task?> send(
    OutboxOp op,
    String target,
    Map<String, Object?> values, {
    required String key,
    int? version,
  }) async {
    final api = _api;
    String s(String k) => values[k]?.toString() ?? '';
    switch (op) {
      case OutboxOp.update:
        return await api.task.update(
          target,
          TaskPatch.fromJson(values).toInput(version: version),
          idempotencyKey: key,
        );
      case OutboxOp.check:
        return await api.task.check(
          target,
          CheckItemInput(
            item: values['item']! as int,
            done: values['done']! as bool,
            version: version,
          ),
          idempotencyKey: key,
        );
      case OutboxOp.move:
        final to = s('to');
        final comment = s('comment');
        final route = values['route'];
        final result = await api.task.route(
          target,
          route is List
              ? RouteInput(
                  route: [for (final k in route) '$k'],
                  comment: comment.isEmpty ? null : comment,
                )
              : RouteInput(to: to, comment: comment.isEmpty ? null : comment),
          idempotencyKey: key,
        );
        if (result.stopped.isNotEmpty && result.stopped != to) {
          throw TixException(
            TixErrorKind.preconditionFailed,
            message: result.reason,
          );
        }
        return result.task;
      case OutboxOp.star:
        await api.task.star(target, idempotencyKey: key);
        return null;
      case OutboxOp.unstar:
        await api.task.unstar(target, idempotencyKey: key);
        return null;
      case OutboxOp.snooze:
        final until = s('until');
        return until.isEmpty
            ? await api.task.unsnooze(target, idempotencyKey: key)
            : await api.task.snooze(
                target,
                SnoozeInput(until: DateTime.parse(until)),
                idempotencyKey: key,
              );
      case OutboxOp.create:
        return await api.task.create(
          CreateTaskRequest.fromJson(values),
          idempotencyKey: key,
        );
      case OutboxOp.comment:
        await api.comment.add(
          target,
          CommentRequest(body: s('body')),
          idempotencyKey: key,
        );
        return null;
      case OutboxOp.tagAdd:
        await api.tag.add(
          target,
          TagRequest(name: s('name')),
          idempotencyKey: key,
        );
        return null;
      case OutboxOp.tagRemove:
        await api.tag.remove(target, s('name'), idempotencyKey: key);
        return null;
      case OutboxOp.dependencyAdd:
        await api.dependency.add(
          target,
          DependencyRequest(dependsOn: s('depends_on')),
          idempotencyKey: key,
        );
        return null;
      case OutboxOp.artifactAdd:
        await api.artifact.put(
          target,
          ArtifactInput.fromJson(values),
          idempotencyKey: key,
        );
        return null;
      case OutboxOp.restore:
        return await api.task.restore(target, idempotencyKey: key);
      case OutboxOp.projectStar:
        await api.project.star(target, idempotencyKey: key);
        return null;
      case OutboxOp.projectUnstar:
        await api.project.unstar(target, idempotencyKey: key);
        return null;
    }
  }

  /// How many tasks one page of a lookup asks for.
  static const lookupPage = 100;

  /// How many pages a lookup reads at most.
  static const lookupPages = 20;

  Future<String> _whoami() async => _me ??= (await _api.identity.whoami()).id;

  @override
  Future<CreateLookup> findCreated(
    Map<String, Object?> values,
    DateTime since,
  ) async {
    final me = await _whoami();
    final line = normalizeText(values['title']?.toString() ?? '');
    final project = values['project_ref']?.toString();
    final from = since.subtract(const Duration(minutes: 5));
    final exact = <Task>[];
    var similar = 0;
    String? cursor;
    for (var n = 0; n < lookupPages; n++) {
      final page = await _api.task.list(
        project: project == null ? null : [project],
        creator: [me],
        sort: 'created_at',
        direction: 'desc',
        limit: lookupPage,
        cursor: cursor,
      );
      var older = false;
      for (final t in page.items) {
        final at = t.createdAt;
        if (at != null && at.isBefore(from)) {
          older = true;
          continue;
        }
        final title = normalizeText(t.title);
        if (title.isEmpty) continue;
        if (title == line) {
          exact.add(t);
        } else if (line.startsWith(title) || title.startsWith(line)) {
          similar++;
        }
      }
      cursor = page.nextCursor;
      if (older || cursor == null) break;
    }
    return CreateLookup(exact: exact, similar: similar);
  }

  @override
  Future<bool> findComment(String target, String body, DateTime since) async {
    final me = await _whoami();
    final want = normalizeText(body);
    final from = since.subtract(const Duration(minutes: 5));
    await for (final c in _api.comment.listStream(target)) {
      final at = c.createdAt;
      if (c.authorActorId == me &&
          normalizeText(c.body) == want &&
          (at == null || !at.isBefore(from))) {
        return true;
      }
    }
    return false;
  }
}
