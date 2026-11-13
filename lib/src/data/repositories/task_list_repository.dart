// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show RouteInput, SnoozeInput;
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/data/offline/outbox.dart';
import 'package:tix_mobile/src/data/query/filter_expression.dart';
import 'package:tix_mobile/src/data/query/task_index.dart';
import 'package:tix_mobile/src/data/query/task_query.dart';

/// One listing request: the filter's parameters and the order.
typedef ListingRequest = ({
  TaskParams params,
  String? sort,
  String? direction,
  int limit,
});

/// Listings, quick actions and bulk actions over tasks, and the workflows
/// that say where a task may go. First pages and workflows are kept in the
/// cache, each with a `cached…` twin for a screen to draw at once.
class TaskListRepository {
  /// Reads through [_api], keeping copies in [_cache].
  TaskListRepository(this._api, this._cache, {this._outbox});

  final TixApi _api;
  final ResponseCache _cache;
  final Outbox? _outbox;

  Future<void> _write(
    OutboxOp op,
    String ref,
    Future<void> Function() send, {
    Task? base,
    Map<String, Object?> values = const {},
  }) {
    final outbox = _outbox;
    if (outbox == null) return send();
    return outbox.write(
      op: op,
      target: ref,
      base: base,
      values: values,
      online: (_) => send(),
      local: (_) {},
    );
  }

  /// The request the task screen sends for [query], read at [now] against
  /// [context]: one place, so a prefetch keeps exactly what a screen reads.
  /// With [held], the second request My work sends when it takes in the
  /// tasks the reader holds.
  static ListingRequest requestFor(
    TaskQuery query,
    TaskIndex context,
    DateTime now, {
    bool held = false,
  }) => (
    params: paramsFor(query, context, now, held: held),
    sort: query.scope is MineScope && query.sort.isEmpty
        ? 'due_at'
        : query.sort.isEmpty
        ? null
        : query.sort,
    direction: query.descending ? 'desc' : null,
    limit: query.limit,
  );

  static String _key(ListingRequest l) {
    final keys = l.params.keys.toList()..sort();
    final shape = {
      for (final k in keys) k: l.params[k],
      's': l.sort,
      'd': l.direction,
      'n': l.limit,
    };
    return 'tasks?${jsonEncode(shape)}';
  }

  static Page<Task> _tasks(Object? json) => Page.fromJson(
    json! as Map<String, dynamic>,
    (e) => Task.fromJson(e! as Map<String, dynamic>),
  );

  /// One page of the tasks [listing] selects.
  Future<Page<Task>> list(ListingRequest listing, {String? cursor}) {
    final fresh = _send(listing, cursor);
    if (cursor != null) return fresh;
    return _cache.remember(
      _key(listing),
      fresh,
      (p) => p.toJson((e) => e.toJson()),
      decode: _tasks,
    );
  }

  /// Every page of [listing], at most [max] tasks, kept under the first
  /// page's key as one page with no cursor, so a screen opened offline
  /// draws all of it.
  Future<Page<Task>> listAll(ListingRequest listing, {int max = 5000}) async {
    final all = <Task>[];
    String? cursor;
    do {
      final page = await _send(listing, cursor);
      all.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null && all.length < max);
    final merged = Page(items: all);
    await _cache.keep(
      _key(listing),
      merged,
      (p) => p.toJson((e) => e.toJson()),
    );
    return merged;
  }

  /// [assigned] with the tasks of [held] it does not already list added
  /// after it, as tix's web merges My work with the tasks the reader holds.
  static Page<Task> withHeld(Page<Task> assigned, Page<Task> held) {
    final seen = {for (final t in assigned.items) t.id};
    return Page(
      items: [
        ...assigned.items,
        for (final t in held.items)
          if (!seen.contains(t.id)) t,
      ],
      nextCursor: assigned.nextCursor,
    );
  }

  /// The first page of [listing] as last read, null when never read.
  Future<Page<Task>?> cachedList(ListingRequest listing) =>
      _cache.peek(_key(listing), _tasks);

  /// tix's counts over everything [listing] selects, every page of it, or
  /// null from a server that does not answer them.
  Future<TaskTally?> tally(ListingRequest listing) async {
    final page = await _send(listing, null, limit: 1, tally: true);
    final raw = page.tally;
    return raw == null ? null : TaskTally.fromJson(raw);
  }

  Future<Page<Task>> _send(
    ListingRequest l,
    String? cursor, {
    int? limit,
    bool? tally,
  }) {
    final p = l.params;
    List<String>? all(String k) => p[k];
    String? one(String k) => p[k]?.last;
    List<int>? ints(String k) => p[k]?.map(int.parse).toList();
    bool? flag(String k) => p[k] == null ? null : p[k]!.last == 'true';
    DateTime? time(String k) =>
        p[k] == null ? null : DateTime.parse(p[k]!.last);
    final fields = {
      for (final e in p.entries)
        if (e.key.startsWith('field.')) e.key.substring(6): e.value.last,
    };
    return _api.task.list(
      limit: limit ?? int.tryParse(one('limit') ?? '') ?? l.limit,
      cursor: cursor,
      tally: tally,
      sort: one('sort') ?? l.sort,
      direction: l.direction,
      project: all('project'),
      status: all('status'),
      tag: all('tag'),
      assignee: all('assignee'),
      creator: all('creator'),
      claimedBy: all('claimed_by'),
      parentId: one('parent_id'),
      q: one('q'),
      rootOnly: flag('root_only'),
      includeDeleted: flag('include_deleted'),
      claimed: one('claimed'),
      starred: one('starred'),
      blocked: one('blocked'),
      recurring: one('recurring'),
      checklist: one('checklist'),
      checklistOpen: one('checklist_open'),
      trashed: one('trashed'),
      snoozed: one('snoozed'),
      priority: ints('priority'),
      notProject: all('not_project'),
      notStatus: all('not_status'),
      notTag: all('not_tag'),
      notAssignee: all('not_assignee'),
      notCreator: all('not_creator'),
      notClaimedBy: all('not_claimed_by'),
      notPriority: ints('not_priority'),
      text: all('text'),
      dueBefore: time('due_before'),
      dueAfter: time('due_after'),
      fieldFilters: fields.isEmpty ? null : fields,
    );
  }

  /// [page] with the writes waiting in the outbox drawn on its tasks, and
  /// the drafts of [project], when given, in front.
  Page<Task> withQueued(Page<Task> page, {String? project}) {
    final outbox = _outbox;
    if (outbox == null) return page;
    return Page(
      items: [
        if (project != null) ...outbox.drafts(key: project),
        for (final t in page.items) outbox.overlay(t),
      ],
      nextCursor: page.nextCursor,
    );
  }

  /// Applies one action to many tasks.
  Future<BulkResult> bulk(BulkTaskInput request) => _api.task.bulk(request);

  /// Moves [ref] to [status] by its workflow's shortest route. [base] is
  /// the task as the person saw it, for a move the outbox keeps.
  Future<void> move(String ref, String status, {Task? base}) => _write(
    OutboxOp.move,
    ref,
    () => _one(BulkTaskInput(action: BulkAction.move, refs: [ref], to: status)),
    base: base,
    values: {'to': status},
  );

  /// Moves [ref] through the states [route] names, in order, in one request
  /// (`task.route`), so the reader's choice of journey is the one written. A
  /// hop the server refuses fails with its reason.
  Future<void> route(String ref, List<String> route, {Task? base}) => _write(
    OutboxOp.move,
    ref,
    () async {
      final result = await _api.task.route(ref, RouteInput(route: route));
      if (result.stopped.isNotEmpty) {
        throw TixException(
          TixErrorKind.preconditionFailed,
          message: result.reason,
        );
      }
    },
    base: base,
    values: {'to': route.last, 'route': route},
  );

  /// Assigns [ref] to [actorId], or clears it when empty.
  Future<void> assign(String ref, String actorId, {Task? base}) => _write(
    OutboxOp.update,
    ref,
    () => _one(
      BulkTaskInput(
        action: BulkAction.assign,
        refs: [ref],
        assigneeActorId: actorId,
      ),
    ),
    base: base,
    values: {'assignee_actor_id': actorId},
  );

  Future<void> _one(BulkTaskInput request) async {
    final refused = (await _api.task.bulk(request)).refusals;
    if (refused.isNotEmpty) throw refusalError(refused.first);
  }

  /// Stars [ref] for the caller.
  Future<void> star(String ref) =>
      _write(OutboxOp.star, ref, () => _api.task.star(ref));

  /// Takes the caller's star off [ref].
  Future<void> unstar(String ref) =>
      _write(OutboxOp.unstar, ref, () => _api.task.unstar(ref));

  /// Hides [ref] until [until]. Offline, the answer carries only the
  /// reference and the snooze.
  Future<Task> snooze(String ref, DateTime until) => _writeTask(
    OutboxOp.snooze,
    ref,
    () => _api.task.snooze(ref, SnoozeInput(until: until.toUtc())),
    Task(id: ref, ref: ref, snoozedUntil: until.toUtc()),
    values: {'until': until.toUtc().toIso8601String()},
  );

  /// Wakes [ref]. Offline, the answer carries only the reference.
  Future<Task> unsnooze(String ref) => _writeTask(
    OutboxOp.snooze,
    ref,
    () => _api.task.unsnooze(ref),
    Task(id: ref, ref: ref),
  );

  Future<Task> _writeTask(
    OutboxOp op,
    String ref,
    Future<Task> Function() send,
    Task local, {
    Map<String, Object?> values = const {},
  }) {
    final outbox = _outbox;
    if (outbox == null) return send();
    return outbox.write(
      op: op,
      target: ref,
      values: values,
      online: (_) => send(),
      local: (_) => local,
    );
  }

  /// Every workflow in the tenant.
  Future<List<Workflow>> workflows() async => (await _cache.remember(
    'workflows',
    _api.workflow.list(),
    (p) => p.toJson((e) => e.toJson()),
    decode: _workflows,
  )).items;

  /// The workflows as last read, null when never read.
  Future<List<Workflow>?> cachedWorkflows() async =>
      (await _cache.peek('workflows', _workflows))?.items;

  static Page<Workflow> _workflows(Object? json) => Page.fromJson(
    json! as Map<String, dynamic>,
    (e) => Workflow.fromJson(e! as Map<String, dynamic>),
  );

  /// Who the caller is.
  Future<Actor> me() => _api.identity.whoami();
}

/// The error a refused bulk outcome stands for.
TixException refusalError(BulkOutcome outcome) =>
    TixException.fromEngine({'code': outcome.code, 'message': outcome.error});
