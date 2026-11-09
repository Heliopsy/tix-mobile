// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/l10n/generated/app_localizations.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/platform/note_actions_bridge.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/data/repositories/inbox_repository.dart';
import 'package:tix_mobile/src/data/repositories/instances_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';
import 'package:tix_mobile/src/features/inbox/application/alerts.dart';

part 'note_actions.g.dart';

/// When Snooze wakes the task: nine tomorrow morning on the device's clock,
/// the task screen's "Tomorrow morning".
DateTime snoozeUntil(DateTime now) {
  final local = now.toLocal();
  return DateTime(local.year, local.month, local.day + 1, 9);
}

/// One pressed notification button, as the platform hands it over.
@immutable
class NoteActionRequest {
  /// [kind] pressed on notification [noteId] about [target], with the typed
  /// [text] for a reply.
  const NoteActionRequest({
    required this.kind,
    required this.noteId,
    required this.target,
    this.text = '',
  });

  /// Reads the channel's arguments, null when they are not an action.
  static NoteActionRequest? parse(Object? args) {
    if (args is! Map) return null;
    final kind = NoteActionKind.values.asNameMap()[args['action']];
    final id = args['id'];
    final payload = args['payload'];
    if (kind == null || id is! int || payload is! String) return null;
    final target = NoteTarget.parse(payload);
    if (target == null) return null;
    final text = args['text'];
    return NoteActionRequest(
      kind: kind,
      noteId: id,
      target: target,
      text: text is String ? text : '',
    );
  }

  /// What was pressed.
  final NoteActionKind kind;

  /// The notification it was pressed on.
  final int noteId;

  /// The item and context the notification is about.
  final NoteTarget target;

  /// What was typed into Reply.
  final String text;
}

/// What became of a notification action.
enum NoteActionOutcome {
  /// The server took it.
  sent,

  /// It waits in the context's outbox.
  queued,

  /// It cannot be done: refused, or its context or task is unknown.
  failed,
}

/// One context's repositories, as a notification action reaches them.
class NoteActionContext {
  /// The repositories of a context whose server [reachable] says whether to
  /// try.
  const NoteActionContext({
    required this.outbox,
    required this.detail,
    required this.tasks,
    required this.lists,
    required this.inbox,
    required this.reachable,
  });

  /// The context's outbox, which every write goes through.
  final Outbox outbox;

  /// Moves, snoozes and comments.
  final TaskDetailRepository detail;

  /// The task and the projects, for the done state.
  final TasksRepository tasks;

  /// The workflows.
  final TaskListRepository lists;

  /// Marks the item read.
  final InboxRepository inbox;

  /// Whether the server may be tried from here: false for a local instance
  /// (a background action never starts its engine), a sign-in sitting in
  /// another tenant, or a credential that cannot be read.
  final bool reachable;
}

/// Opens the context a notification names by its key, null when it is no
/// longer saved.
typedef NoteContextOpener = Future<NoteActionContext?> Function(String key);

/// The saved context [key] (`<connection>.<tenant>`) names among [entries]. A
/// key whose tenant was not known yet, or a context whose tenant is not,
/// matches the same connection when that has only one context.
ContextEntry? noteContextEntry(String key, List<ContextEntry> entries) {
  for (final e in entries) {
    if ('${e.connection.id}.${e.tenantKey}' == key) return e;
  }
  final dot = key.indexOf('.');
  if (dot < 0) return null;
  final connection = key.substring(0, dot);
  final tenant = key.substring(dot + 1);
  final same = [
    for (final e in entries)
      if (e.connection.id == connection &&
          (tenant.isEmpty || e.tenantKey.isEmpty))
        e,
  ];
  return same.length == 1 ? same.single : null;
}

/// Opens the context [key] from what is saved, the way widgets do: the
/// credential from secure storage, the outbox from [stores], never a local
/// engine.
Future<NoteActionContext?> openSavedNoteContext(
  String key, {
  required InstancesRepository instances,
  required TixApiFactory factory,
  required CacheStore cache,
  required SyncStores stores,
  required DateTime Function() clock,
}) async {
  final entry = noteContextEntry(key, [
    for (final i in instances.instances())
      for (final c in instances.connectionsOf(i.id))
        for (final e in entriesOf(i, c))
          if (e.elsewhere.isEmpty) e,
  ]);
  if (entry == null) return null;
  final c = entry.connection;
  final instance = entry.instance;
  var reachable =
      instance.kind != InstanceKind.local &&
      !(c.switchable && entry.tenantKey != c.tenantKey);
  Credential? credential;
  if (reachable) {
    try {
      final secret = await instances.secret(c);
      if (secret != null && secret.isNotEmpty) {
        credential = switch (c.kind) {
          ConnectionKind.token => BearerCredential(secret),
          ConnectionKind.signIn => SessionCredential(secret),
        };
      }
    } on Exception catch (e) {
      log('note actions: credential unreadable: ${e.runtimeType}');
    }
    reachable = credential != null;
  }
  final api = factory(instance.baseUrl, credential);
  final scope = CacheScope(c.id, c.switchable ? entry.tenantKey : '');
  final responses = ResponseCache(cache, scope, now: clock);
  final online = reachable;
  final outbox = Outbox(stores.of(scope), offline: () => !online, clock: clock);
  return NoteActionContext(
    outbox: outbox,
    detail: TaskDetailRepository(api, responses, outbox: outbox),
    tasks: TasksRepository(api, responses, outbox: outbox),
    lists: TaskListRepository(api, responses, outbox: outbox),
    inbox: InboxRepository(api, responses),
    reachable: online,
  );
}

/// Runs notification actions without a screen: writes through the
/// context's outbox, so each carries an idempotency key and waits when the
/// server cannot be reached, then dismisses the notification, and posts a
/// short follow-up naming no task when the action failed.
class NoteActionRunner {
  /// Opens contexts with [open] and shows notifications through [notes].
  NoteActionRunner({
    required this.open,
    required this.notes,
    required this.l10n,
    required this.now,
  });

  /// Opens a context by its key.
  final NoteContextOpener open;

  /// The platform's notifications.
  final LocalNotifier notes;

  /// The text of a follow-up, in the app's language.
  final AppLocalizations Function() l10n;

  /// The clock.
  final DateTime Function() now;

  /// Runs [request] and answers what became of it.
  Future<NoteActionOutcome> run(NoteActionRequest request) async {
    final outcome = await _apply(request);
    await notes.cancel(request.noteId);
    if (outcome == NoteActionOutcome.failed) await _followUp(request);
    return outcome;
  }

  Future<NoteActionOutcome> _apply(NoteActionRequest r) async {
    final ref = r.target.taskRef;
    if (ref.isEmpty) return NoteActionOutcome.failed;
    final ctx = await open(r.target.context);
    if (ctx == null) return NoteActionOutcome.failed;
    final before = (await ctx.outbox.store.load()).nextSeq;
    try {
      switch (r.kind) {
        case NoteActionKind.done:
          final to = await _doneState(ctx, r.target);
          if (to == null) return NoteActionOutcome.failed;
          if (to.isNotEmpty) await ctx.detail.move(ref, to);
        case NoteActionKind.snooze:
          await ctx.detail.snooze(ref, snoozeUntil(now()).toUtc());
        case NoteActionKind.reply:
          final body = r.text.trim();
          if (body.isEmpty) return NoteActionOutcome.failed;
          await ctx.detail.addComment(ref, body);
      }
    } on TixException catch (e) {
      log('note actions: ${r.kind.name} refused: ${e.kind.name}');
      return NoteActionOutcome.failed;
    }
    if (ctx.outbox.store.now.nextSeq > before) return NoteActionOutcome.queued;
    await _markRead(ctx, r.target.item);
    return NoteActionOutcome.sent;
  }

  /// The state Done moves the task to: empty when it is finished already,
  /// null when neither the server nor the saved copies say.
  Future<String?> _doneState(NoteActionContext ctx, NoteTarget target) async {
    final task = ctx.reachable
        ? await ctx.tasks.task(target.taskRef)
        : await ctx.tasks.cachedTask(target.taskRef);
    if (task == null) return null;
    if (task.completedAt != null) return '';
    final projects = ctx.reachable
        ? await _allProjects(ctx.tasks)
        : (await ctx.tasks.cachedProjects())?.items ?? const <Project>[];
    final workflows = ctx.reachable
        ? await ctx.lists.workflows()
        : await ctx.lists.cachedWorkflows() ?? const <Workflow>[];
    Project? project;
    for (final p in projects) {
      if (p.id == task.projectId ||
          (project == null && p.key == target.projectKey)) {
        project = p;
      }
    }
    Workflow? workflow;
    for (final w in workflows) {
      if (w.id == project?.workflowId) workflow = w;
    }
    if (workflow == null) return null;
    if (WorkflowRules(workflow).state(task.status)?.terminal ?? false) {
      return '';
    }
    final done = workflow.doneState?.key ?? '';
    return done.isEmpty ? null : done;
  }

  static Future<List<Project>> _allProjects(TasksRepository tasks) async {
    final all = <Project>[];
    String? cursor;
    do {
      final page = await tasks.projects(cursor: cursor);
      all.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null);
    return all;
  }

  Future<void> _markRead(NoteActionContext ctx, String item) async {
    if (item.isEmpty || !ctx.reachable) return;
    try {
      await ctx.inbox.markRead(item);
    } on TixException catch (e) {
      log('note actions: mark read failed: ${e.kind.name}');
    }
  }

  Future<void> _followUp(NoteActionRequest r) async {
    final text = l10n();
    final title = switch (r.kind) {
      NoteActionKind.done => text.notifActionFailedDone,
      NoteActionKind.snooze => text.notifActionFailedSnooze,
      NoteActionKind.reply => text.notifActionFailedReply,
    };
    await notes.show(
      LocalNote(
        id: stableNoteId('action.failed.${r.noteId}'),
        title: title,
        body: text.notifActionFailedBody,
        publicTitle: title,
        publicBody: text.notifActionFailedBody,
        payload: r.target.encode(),
      ),
    );
  }
}

/// Runs notification actions with this engine's providers. In the app's
/// engine the outbox stores are the ones its sync uses, so a queued action
/// is sent with the rest.
@Riverpod(keepAlive: true)
NoteActionRunner noteActionRunner(Ref ref) => NoteActionRunner(
  open: (key) => openSavedNoteContext(
    key,
    instances: ref.read(instancesRepositoryProvider),
    factory: ref.read(tixApiFactoryProvider),
    cache: ref.read(cacheStoreProvider),
    stores: ref.read(syncStoresProvider),
    clock: ref.read(clockProvider),
  ),
  notes: ref.read(localNotesProvider),
  l10n: () => notificationL10n(ref.read(keyValueStoreProvider)),
  now: ref.read(clockProvider),
);

/// Where Android hands this engine notification actions (`tix/note-actions`).
@Riverpod(keepAlive: true)
NoteActionBridge noteActionBridge(Ref ref) => NoteActionBridge((args) async {
  final request = NoteActionRequest.parse(args);
  if (request == null) return NoteActionOutcome.failed.name;
  return (await ref.read(noteActionRunnerProvider).run(request)).name;
});
