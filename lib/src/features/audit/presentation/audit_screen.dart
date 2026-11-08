// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/features/audit/application/audit.dart';

String _when(BuildContext context, DateTime at) => context.times.stamp(at);

/// The tenant's audit log: every change, newest first, narrowed by text,
/// surface, channel, actor, action, token and time, with each entry's
/// detail beside the list on a wide window.
class AuditScreen extends ConsumerWidget {
  /// Creates the screen.
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(auditFilterProvider);
    final log = auditLogProvider(query);
    final picked = ref.watch(auditSelectionProvider);
    final twoPane = context.isTwoPane;
    final list = AsyncBody(
      value: ref.watch(log),
      onRetry: () => ref.invalidate(log),
      data: (paged) => PagedListView(
        paged: paged,
        header: const _Filters(),
        empty: EmptyState(
          icon: Icons.manage_search,
          title: query.isEmpty ? l10n.auditEmpty : l10n.auditNoMatch,
          body: query.isEmpty ? l10n.auditEmptyBody : l10n.auditNoMatchBody,
        ),
        onRefresh: () => ref.refresh(log.future),
        onLoadMore: () => ref.read(log.notifier).loadMore(),
        itemBuilder: (context, entry) => AuditRow(
          entry: entry,
          selected: twoPane && entry.seq == picked,
          onTap: () {
            if (twoPane) {
              ref.read(auditSelectionProvider.notifier).show(entry);
            } else {
              unawaited(
                showTixSheet<void>(
                  context,
                  builder: (context) => TixSheetBody(
                    title: entry.action,
                    actions: [
                      TixButton.quiet(
                        label: l10n.close,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                    child: AuditEntryDetail(entry: entry),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
    return TixPage(
      title: l10n.auditTitle,
      subtitle: l10n.auditSubtitle,
      body: !twoPane
          ? list
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: list),
                VerticalDivider(width: 1, color: context.tix.line),
                Expanded(
                  flex: 2,
                  child: () {
                    final entry = ref
                        .watch(log)
                        .value
                        ?.items
                        .where((e) => e.seq == picked)
                        .firstOrNull;
                    if (entry == null) {
                      return EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.auditPick,
                        body: l10n.auditPickBody,
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(TixSpace.s4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            entry.action,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: TixSpace.s3),
                          AuditEntryDetail(entry: entry),
                        ],
                      ),
                    );
                  }(),
                ),
              ],
            ),
    );
  }
}

class _Filters extends ConsumerStatefulWidget {
  const _Filters();

  @override
  ConsumerState<_Filters> createState() => _FiltersState();
}

class _FiltersState extends ConsumerState<_Filters> {
  late final _text = TextEditingController(
    text: ref.read(auditFilterProvider).text,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _set(AuditQuery query) {
    ref.read(auditSelectionProvider.notifier).clear();
    ref.read(auditFilterProvider.notifier).change((_) => query);
  }

  Future<void> _more(AuditQuery query) async {
    final next = await showTixSheet<AuditQuery>(
      context,
      builder: (_) => AuditFilterForm(query: query),
    );
    if (next != null) _set(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = ref.watch(auditFilterProvider);
    final extra =
        [q.actorId, q.action, q.token].where((s) => s.isNotEmpty).length +
        (q.since == null ? 0 : 1) +
        (q.until == null ? 0 : 1);
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
          TixSearchField(
            fieldKey: const Key('audit.text'),
            controller: _text,
            hint: l10n.auditSearch,
            onChanged: (_) {},
            onSubmitted: (v) => _set(q.copyWith(text: v)),
          ),
          const SizedBox(height: TixSpace.s2),
          Text(l10n.auditVia, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: TixSpace.s1),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              for (final v in AuditQuery.viaKinds)
                TixFilterChip(
                  key: Key('audit.via.$v'),
                  label: v,
                  selected: q.vias.contains(v),
                  onSelected: (on) => _set(
                    q.copyWith(
                      vias: on ? {...q.vias, v} : ({...q.vias}..remove(v)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TixButton(
                key: const Key('audit.more'),
                label: extra == 0
                    ? l10n.auditMoreFilters
                    : l10n.auditMoreFiltersCount(extra),
                icon: Icons.tune,
                size: TixButtonSize.small,
                onPressed: () => _more(q),
              ),
              if (!q.isEmpty)
                TixButton.quiet(
                  key: const Key('audit.clear'),
                  label: l10n.auditClear,
                  size: TixButtonSize.small,
                  onPressed: () {
                    _text.clear();
                    _set(const AuditQuery());
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Narrows the audit log by surface, actor, action, API token and time.
class AuditFilterForm extends StatefulWidget {
  /// A form starting from [query].
  const AuditFilterForm({required this.query, super.key});

  /// The current query.
  final AuditQuery query;

  @override
  State<AuditFilterForm> createState() => _AuditFilterFormState();
}

class _AuditFilterFormState extends State<AuditFilterForm> {
  late final _actor = TextEditingController(text: widget.query.actorId);
  late final _action = TextEditingController(text: widget.query.action);
  late final _token = TextEditingController(text: widget.query.token);
  late Set<Source> _sources = {...widget.query.sources};
  late DateTime? _since = widget.query.since;
  late DateTime? _until = widget.query.until;

  @override
  void dispose() {
    _actor.dispose();
    _action.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now().add(const Duration(days: 1)),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String day(DateTime? d) =>
        d == null ? l10n.auditAnyTime : context.times.style.calendar(d);
    const gap = SizedBox(height: TixSpace.s3);
    return TixSheetBody(
      title: l10n.auditFilters,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('audit.apply'),
          label: l10n.auditApply,
          onPressed: () => Navigator.of(context).pop(
            widget.query.copyWith(
              actorId: _actor.text.trim(),
              action: _action.text.trim(),
              token: _token.text.trim(),
              sources: _sources,
              since: () => _since?.toUtc(),
              until: () => _until?.add(const Duration(days: 1)).toUtc(),
            ),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.auditSource, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: TixSpace.s1),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              for (final s in Source.values)
                TixFilterChip(
                  key: Key('audit.source.${s.value}'),
                  label: s.value,
                  selected: _sources.contains(s),
                  onSelected: (on) => setState(
                    () => _sources = on
                        ? {..._sources, s}
                        : ({..._sources}..remove(s)),
                  ),
                ),
            ],
          ),
          gap,
          TixTextField(
            fieldKey: const Key('audit.actor'),
            label: l10n.auditActor,
            help: l10n.auditActorHelp,
            controller: _actor,
          ),
          gap,
          TixTextField(
            fieldKey: const Key('audit.action'),
            label: l10n.auditAction,
            hint: 'task.create',
            controller: _action,
          ),
          gap,
          TixTextField(
            fieldKey: const Key('audit.token'),
            label: l10n.auditToken,
            help: l10n.auditTokenHelp,
            controller: _token,
          ),
          gap,
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TixButton(
                key: const Key('audit.since'),
                label: l10n.auditSince(day(_since)),
                icon: Icons.event,
                size: TixButtonSize.small,
                onPressed: () async {
                  final d = await _pick(_since);
                  if (d != null) setState(() => _since = d);
                },
              ),
              TixButton(
                key: const Key('audit.until'),
                label: l10n.auditUntil(day(_until)),
                icon: Icons.event,
                size: TixButtonSize.small,
                onPressed: () async {
                  final d = await _pick(_until);
                  if (d != null) setState(() => _until = d);
                },
              ),
              if (_since != null || _until != null)
                TixButton.quiet(
                  label: l10n.auditAnyTime,
                  size: TixButtonSize.small,
                  onPressed: () => setState(() {
                    _since = null;
                    _until = null;
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One audit entry in the list: the action, the record, who and how.
class AuditRow extends StatelessWidget {
  /// Draws [entry].
  const AuditRow({
    required this.entry,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  /// The entry.
  final AuditEntry entry;

  /// Opens its detail.
  final VoidCallback onTap;

  /// Whether its detail is shown beside the list.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final at = entry.occurredAt;
    final via = entry.via;
    return ListTile(
      key: Key('audit.${entry.seq}'),
      selected: selected,
      title: Text(
        entry.action,
        style: tixMono(context, size: TixText.sm, color: context.tix.ink),
      ),
      subtitle: Text(
        [
          '${entry.subjectType} ${entry.subjectId}',
          if (at != null) _when(context, at),
          if (via != null && via.kind.isNotEmpty) via.kind,
          if (via != null && via.tokenName.isNotEmpty) via.tokenName,
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}

/// Everything one audit entry records: when, who, through what, and the
/// record before and after.
class AuditEntryDetail extends StatelessWidget {
  /// Shows [entry].
  const AuditEntryDetail({required this.entry, super.key});

  /// The entry.
  final AuditEntry entry;

  static const _pretty = JsonEncoder.withIndent('  ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final t = context.tix;
    final via = entry.via;
    final at = entry.occurredAt;
    final facts = <(String, String)>[
      (l10n.auditSeq, '${entry.seq}'),
      if (at != null) (l10n.auditWhen, _when(context, at)),
      (
        l10n.auditActor,
        entry.actorId.isEmpty ? l10n.auditSystem : entry.actorId,
      ),
      (l10n.auditSubject, '${entry.subjectType} ${entry.subjectId}'),
      if (entry.source != null) (l10n.auditSource, entry.source!.value),
      if (via != null)
        for (final (label, value) in [
          (l10n.auditVia, via.kind),
          (l10n.auditToken, via.tokenName),
          (l10n.auditTokenId, via.tokenId),
          (l10n.auditSession, via.session),
          (l10n.auditKey, via.keyFingerprint),
          (l10n.auditClient, via.clientAddr),
          (l10n.auditOrigin, via.origin),
          (l10n.auditHost, via.host),
          (l10n.auditOsUser, via.osUser),
          (l10n.auditJob, via.job),
          (l10n.auditUserAgent, via.userAgent),
        ])
          if (value.isNotEmpty) (label, value),
    ];
    Widget json(String title, Object? value) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: TixSpace.s3),
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: TixSpace.s1),
        Container(
          padding: const EdgeInsets.all(TixSpace.s3),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(TixRadius.md),
          ),
          child: SelectableText(
            _pretty.convert(value),
            style: tixMono(context, color: t.ink),
          ),
        ),
      ],
    );
    return Column(
      key: Key('audit.detail.${entry.seq}'),
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
        if (entry.before != null) json(l10n.auditBefore, entry.before),
        if (entry.after != null) json(l10n.auditAfter, entry.after),
      ],
    );
  }
}
