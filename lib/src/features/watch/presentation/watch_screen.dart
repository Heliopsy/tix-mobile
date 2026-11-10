// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/live_status.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/features/watch/application/watch.dart';
import 'package:tix_mobile/src/features/watch/presentation/watch_summary.dart';

/// The type prefixes offered as one-tap filters.
const _quickTypes = ['task.*', 'comment.*', 'project.*'];

/// The tenant's domain events as they happen, newest first, as `tix watch`
/// and the terminal interface's Watch view show them.
class WatchScreen extends ConsumerWidget {
  /// Creates the screen.
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final feed = ref.watch(watchFeedProvider);
    final mode = ref.watch(liveStatusProvider).value?.mode;
    final notifier = ref.read(watchFeedProvider.notifier);
    void toggle() => feed.paused ? notifier.resume() : notifier.pause();
    final refused =
        mode == LiveMode.unavailable ||
        (feed.phase == WatchPhase.refused &&
            (feed.refusal?.credential ?? false));
    return CommandScope(
      commands: [
        TixCommand(
          id: 'watch.pause',
          label: feed.paused ? l10n.watchResume : l10n.watchPause,
          group: l10n.watchTitle,
          icon: feed.paused ? Icons.play_arrow : Icons.pause,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyP),
          run: toggle,
        ),
      ],
      child: TixPage(
        title: l10n.watchTitle,
        subtitle: l10n.watchSubtitle,
        actions: [
          const LiveStatusIndicator(),
          TixIconButton(
            key: const Key('watch.pause'),
            icon: feed.paused ? Icons.play_arrow : Icons.pause,
            tooltip: feed.paused ? l10n.watchResume : l10n.watchPause,
            onPressed: feed.phase == WatchPhase.idle || refused ? null : toggle,
          ),
          TixIconButton(
            key: const Key('watch.clearList'),
            icon: Icons.clear_all,
            tooltip: l10n.watchClear,
            onPressed: feed.events.isEmpty ? null : notifier.clear,
          ),
        ],
        body: switch (feed.phase) {
          WatchPhase.idle => EmptyState(
            icon: Icons.cloud_off,
            title: l10n.watchNoContext,
          ),
          _ when refused => _Refused(message: feed.refusal?.message ?? ''),
          _ => const _Feed(),
        },
      ),
    );
  }
}

class _Refused extends StatelessWidget {
  const _Refused({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      key: const Key('watch.refused'),
      icon: Icons.lock_outline,
      title: l10n.watchRefused,
      body: [
        l10n.watchRefusedBody,
        if (message.isNotEmpty) message,
      ].join('\n\n'),
      action: TixAction(
        label: l10n.back,
        icon: Icons.arrow_back,
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(Routes.manage),
      ),
    );
  }
}

class _Feed extends ConsumerWidget {
  const _Feed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final feed = ref.watch(watchFeedProvider);
    final query = ref.watch(watchFilterProvider);
    final shown = ref.watch(watchVisibleProvider);
    final held = ref.watch(watchHeldCountProvider);
    final mode = ref.watch(liveStatusProvider).value?.mode;
    final notifier = ref.read(watchFeedProvider.notifier);
    final projects = {
      for (final p in ref.watch(watchProjectsProvider).value ?? <Project>[])
        p.id: p,
    };
    void clearFilters() => ref
        .read(watchFilterProvider.notifier)
        .change((_) => const WatchQuery());
    final notices = <Widget>[
      if (feed.paused)
        _NoticeWithAction(
          key: const Key('watch.paused'),
          notice: TixNotice(
            held == 0 ? l10n.watchPaused : l10n.watchPausedNew(held),
          ),
          action: TixButton(
            key: const Key('watch.resume'),
            label: l10n.watchResume,
            icon: Icons.play_arrow,
            size: TixButtonSize.small,
            onPressed: notifier.resume,
          ),
        ),
      if (feed.phase == WatchPhase.refused && feed.refusal != null)
        _NoticeWithAction(
          key: const Key('watch.filterRefused'),
          notice: TixNotice(
            feed.refusal!.message.isEmpty
                ? feed.refusal!.code
                : feed.refusal!.message,
            title: l10n.watchFilterRefused,
            tone: TixNoticeTone.danger,
          ),
          action: TixButton(
            label: l10n.auditClear,
            size: TixButtonSize.small,
            onPressed: clearFilters,
          ),
        ),
      if (feed.phase == WatchPhase.unsupported)
        TixNotice(
          l10n.watchUnsupported,
          key: const Key('watch.unsupported'),
          tone: TixNoticeTone.warn,
        ),
      if (feed.expiredSince case final since?)
        _NoticeWithAction(
          key: const Key('watch.expired'),
          notice: TixNotice(l10n.watchExpired(since), tone: TixNoticeTone.warn),
          action: TixButton.quiet(
            label: l10n.watchDismiss,
            size: TixButtonSize.small,
            onPressed: notifier.dismissExpired,
          ),
        ),
      if (feed.missed)
        _NoticeWithAction(
          key: const Key('watch.missed'),
          notice: TixNotice(l10n.watchMissed),
          action: TixButton.quiet(
            label: l10n.watchDismiss,
            size: TixButtonSize.small,
            onPressed: notifier.dismissMissed,
          ),
        ),
    ];
    final Widget list;
    if (shown.isEmpty) {
      list = switch (mode) {
        LiveMode.offline => EmptyState(
          key: const Key('watch.offline'),
          icon: Icons.cloud_off,
          title: l10n.watchOffline,
          body: l10n.watchOfflineBody,
        ),
        _
            when feed.phase == WatchPhase.connecting ||
                mode == null ||
                mode == LiveMode.connecting =>
          EmptyState(
            key: const Key('watch.connecting'),
            icon: Icons.sync,
            title: l10n.watchConnecting,
          ),
        _ when feed.phase == WatchPhase.unsupported => const SizedBox.shrink(),
        _ when !query.isEmpty => EmptyState(
          key: const Key('watch.noMatch'),
          icon: Icons.filter_alt_off_outlined,
          title: l10n.watchNoMatch,
          body: l10n.watchNoMatchBody,
          action: TixAction(
            key: const Key('watch.noMatch.clear'),
            label: l10n.auditClear,
            onPressed: clearFilters,
          ),
        ),
        _ => EmptyState(
          key: const Key('watch.empty'),
          icon: Icons.stream,
          title: l10n.watchEmpty,
          body: l10n.watchEmptyBody,
        ),
      };
    } else {
      list = ListView.separated(
        key: const Key('watch.list'),
        itemCount: shown.length + (feed.full ? 1 : 0),
        separatorBuilder: (_, _) => Divider(height: 1, color: context.tix.line),
        itemBuilder: (context, i) {
          if (i == shown.length) {
            return Padding(
              padding: const EdgeInsets.all(TixSpace.s4),
              child: Text(
                l10n.watchKeeping(watchCap),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          final event = shown[i];
          return WatchRow(
            event: event,
            onTap: () {
              final route = watchRoute(event);
              if (route == null) {
                unawaited(showWatchDetails(context, event, projects));
              } else {
                context.go(route);
              }
            },
            onDetails: () =>
                unawaited(showWatchDetails(context, event, projects)),
          );
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Filters(projects: projects),
        for (final n in notices)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TixSpace.s4,
              0,
              TixSpace.s4,
              TixSpace.s2,
            ),
            child: n,
          ),
        Expanded(child: list),
      ],
    );
  }
}

class _NoticeWithAction extends StatelessWidget {
  const _NoticeWithAction({
    required this.notice,
    required this.action,
    super.key,
  });

  final Widget notice;
  final Widget action;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      notice,
      const SizedBox(height: TixSpace.s1),
      Align(alignment: AlignmentDirectional.centerEnd, child: action),
    ],
  );
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.projects});

  final Map<String, Project> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final q = ref.watch(watchFilterProvider);
    void set(WatchQuery next) =>
        ref.read(watchFilterProvider.notifier).change((_) => next);
    final described = [
      if (q.projectIds.isNotEmpty)
        l10n.watchFilterProject(
          q.projectIds.map((id) => projects[id]?.key ?? id).join(', '),
        ),
      if (q.types.isNotEmpty) l10n.watchFilterType(q.types.join(', ')),
      if (q.actors.isNotEmpty) l10n.watchFilterActor(q.actors.join(', ')),
      if (q.since case final since?) l10n.watchFilterSince(since),
    ];
    final count =
        (q.projectIds.isEmpty ? 0 : 1) +
        (q.types.isEmpty ? 0 : 1) +
        (q.actors.isEmpty ? 0 : 1) +
        (q.since == null ? 0 : 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        TixSpace.s3,
        TixSpace.s4,
        TixSpace.s2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TixFilterChip(
                key: const Key('watch.type.all'),
                label: l10n.watchAllTypes,
                selected: q.types.isEmpty,
                onSelected: (_) => set(q.copyWith(types: const [])),
              ),
              for (final t in _quickTypes)
                TixFilterChip(
                  key: Key('watch.type.$t'),
                  label: t,
                  selected: q.types.contains(t),
                  onSelected: (on) => set(
                    q.copyWith(
                      types: on
                          ? [...q.types, t]
                          : [...q.types.where((x) => x != t)],
                    ),
                  ),
                ),
              TixButton(
                key: const Key('watch.filters'),
                label: count == 0
                    ? l10n.watchFilters
                    : l10n.watchFiltersCount(count),
                icon: Icons.tune,
                size: TixButtonSize.small,
                onPressed: () async {
                  final next = await showTixSheet<WatchQuery>(
                    context,
                    builder: (_) => WatchFilterForm(query: q),
                  );
                  if (next != null) set(next);
                },
              ),
              if (!q.isEmpty)
                TixButton.quiet(
                  key: const Key('watch.clear'),
                  label: l10n.auditClear,
                  size: TixButtonSize.small,
                  onPressed: () => set(const WatchQuery()),
                ),
            ],
          ),
          if (described.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s2),
            Text(
              l10n.watchFiltering(described.join(' · ')),
              key: const Key('watch.filtering'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Narrows Watch by project, event type and actor, and replays from a
/// sequence number.
class WatchFilterForm extends ConsumerStatefulWidget {
  /// A form starting from [query].
  const WatchFilterForm({required this.query, super.key});

  /// The current query.
  final WatchQuery query;

  @override
  ConsumerState<WatchFilterForm> createState() => _WatchFilterFormState();
}

class _WatchFilterFormState extends ConsumerState<WatchFilterForm> {
  late final _types = TextEditingController(
    text: widget.query.types.join(', '),
  );
  late final _actors = TextEditingController(
    text: widget.query.actors.join(', '),
  );
  late final _since = TextEditingController(
    text: widget.query.since?.toString() ?? '',
  );
  late Set<String> _projects = {...widget.query.projectIds};

  @override
  void dispose() {
    _types.dispose();
    _actors.dispose();
    _since.dispose();
    super.dispose();
  }

  static List<String> _split(String text) => [
    for (final part in text.split(RegExp(r'[,\s]+')))
      if (part.trim().isNotEmpty) part.trim(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const gap = SizedBox(height: TixSpace.s3);
    final projects = ref.watch(watchProjectsProvider);
    return TixSheetBody(
      title: l10n.watchFilters,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('watch.apply'),
          label: l10n.auditApply,
          onPressed: () {
            final since = int.tryParse(_since.text.trim());
            Navigator.of(context).pop(
              WatchQuery(
                projectIds: [..._projects],
                types: _split(_types.text),
                actors: _split(_actors.text),
                since: since == null || since <= 0 ? null : since,
              ),
            );
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixFieldLabel(l10n.watchProjects),
          const SizedBox(height: TixSpace.s1),
          Text(
            l10n.watchProjectsHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: TixSpace.s2),
          switch (projects) {
            AsyncData(:final value) => Wrap(
              spacing: TixSpace.s2,
              runSpacing: TixSpace.s2,
              children: [
                for (final p in value)
                  TixFilterChip(
                    key: Key('watch.project.${p.key}'),
                    label: p.name.isEmpty ? p.key : '${p.name} (${p.key})',
                    selected: _projects.contains(p.id),
                    onSelected: (on) => setState(
                      () => _projects = on
                          ? {..._projects, p.id}
                          : ({..._projects}..remove(p.id)),
                    ),
                  ),
              ],
            ),
            AsyncError(:final error) => TixNotice(
              errorMessage(l10n, error),
              tone: TixNoticeTone.danger,
            ),
            _ => const SkeletonBox(height: TixSize.controlSmall),
          },
          gap,
          TixTextField(
            fieldKey: const Key('watch.types'),
            label: l10n.watchTypes,
            help: l10n.watchTypesHelp,
            hint: 'task.*',
            controller: _types,
          ),
          gap,
          TixTextField(
            fieldKey: const Key('watch.actors'),
            label: l10n.watchActors,
            help: l10n.watchActorsHelp,
            hint: '@pax',
            controller: _actors,
          ),
          gap,
          TixTextField(
            fieldKey: const Key('watch.since'),
            label: l10n.watchReplay,
            help: l10n.watchReplayHelp,
            controller: _since,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }
}

/// One event in the tail: its sequence number, time, actor and type, and a
/// line on what it did to what, as `tix watch` writes it.
class WatchRow extends StatelessWidget {
  /// Draws [event].
  const WatchRow({
    required this.event,
    required this.onTap,
    required this.onDetails,
    super.key,
  });

  /// The event.
  final TixEvent event;

  /// Opens what it is about, or its details.
  final VoidCallback onTap;

  /// Opens its details.
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final at = event.occurredAt;
    final detail = watchDetail(l10n, event);
    final muted = tixMono(context, size: TixText.xs, color: t.muted);
    return ListTile(
      key: Key('watch.${event.seq}'),
      onTap: onTap,
      title: Wrap(
        spacing: TixSpace.s2,
        runSpacing: TixSpace.s1,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('#${event.seq.toString().padLeft(6, '0')}', style: muted),
          if (at != null) Text(context.times.style.clock(at), style: muted),
          Text(
            watchActor(event) ?? l10n.auditSystem,
            style: TextStyle(
              fontSize: TixText.sm,
              fontWeight: FontWeight.w600,
              color: t.ink,
            ),
          ),
          TixBadge(event.type),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: TixSpace.s1),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: watchSubject(event),
                style: tixMono(context, size: TixText.sm, color: t.ink),
              ),
              if (detail.isNotEmpty) TextSpan(text: '  $detail'),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: TixIconButton(
        key: Key('watch.details.${event.seq}'),
        icon: Icons.data_object,
        tooltip: l10n.watchDetails,
        onPressed: onDetails,
      ),
    );
  }
}

/// Opens everything [event] carries, with a way to what it is about.
Future<void> showWatchDetails(
  BuildContext context,
  TixEvent event,
  Map<String, Project> projects,
) {
  final route = watchRoute(event);
  return showTixSheet<void>(
    context,
    builder: (sheet) => TixSheetBody(
      title: event.type,
      actions: [
        TixButton.quiet(
          label: context.l10n.close,
          onPressed: () => Navigator.of(sheet).pop(),
        ),
        if (route != null)
          TixButton.primary(
            key: const Key('watch.detail.open'),
            label: context.l10n.watchOpen,
            onPressed: () {
              Navigator.of(sheet).pop();
              context.go(route);
            },
          ),
      ],
      child: WatchEventDetail(event: event, project: projects[event.projectId]),
    ),
  );
}

/// Every field of one event and its full payload.
class WatchEventDetail extends StatelessWidget {
  /// Shows [event], naming [project] when it is known.
  const WatchEventDetail({required this.event, this.project, super.key});

  /// The event.
  final TixEvent event;

  /// The event's project, when known.
  final Project? project;

  static const _pretty = JsonEncoder.withIndent('  ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final t = context.tix;
    final at = event.occurredAt;
    final via = event.via;
    final facts = <(String, String)>[
      (l10n.watchSeq, '${event.seq}'),
      if (at != null) (l10n.auditWhen, context.times.stamp(at)),
      (
        l10n.auditActor,
        [
          ?watchActor(event),
          if (event.actorId.isNotEmpty && watchActor(event) != event.actorId)
            event.actorId,
        ].join(' ').trim().ifEmpty(l10n.auditSystem),
      ),
      (l10n.watchType, event.type),
      (
        l10n.auditSubject,
        '${watchSubject(event)}  ${event.subjectType} ${event.subjectId}',
      ),
      if (event.projectId.isNotEmpty)
        (
          l10n.watchProject,
          project == null
              ? event.projectId
              : '${project!.name} (${project!.key})  ${event.projectId}',
        ),
      if (via != null && via.kind.isNotEmpty) (l10n.auditVia, via.kind),
      if (via != null && via.tokenName.isNotEmpty)
        (l10n.auditToken, via.tokenName),
      if (event.id.isNotEmpty) (l10n.watchEventId, event.id),
    ];
    return Column(
      key: Key('watch.detail.${event.seq}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, value) in facts)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
            child: Wrap(
              spacing: TixSpace.s2,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                SelectableText(value),
              ],
            ),
          ),
        const SizedBox(height: TixSpace.s3),
        Text(l10n.watchPayload, style: theme.textTheme.titleSmall),
        const SizedBox(height: TixSpace.s1),
        Container(
          padding: const EdgeInsets.all(TixSpace.s3),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(TixRadius.md),
          ),
          child: SelectableText(
            _pretty.convert(event.payload),
            key: const Key('watch.payload'),
            style: tixMono(context, color: t.ink),
          ),
        ),
      ],
    );
  }
}

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}
