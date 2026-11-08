// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/features/inbox/application/alerts.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';
import 'package:tix_mobile/src/features/inbox/presentation/summary_card.dart';

/// From this width the summary sits beside the list instead of above it.
const inboxSideMinWidth = 1100.0;

/// The label of an inbox [kind], plural, as filters and settings say it.
String inboxKindLabel(AppLocalizations l10n, InboxKind kind) => switch (kind) {
  InboxKind.mention => l10n.inboxKindMention,
  InboxKind.assigned => l10n.inboxKindAssigned,
  InboxKind.comment => l10n.inboxKindComment,
  InboxKind.status => l10n.inboxKindStatus,
};

/// The caller's inbox: what concerns them, newest first, grouped by day.
class InboxScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  bool _updated = false;
  Timer? _updatedTimer;

  @override
  void dispose() {
    _updatedTimer?.cancel();
    super.dispose();
  }

  void _flashUpdated() {
    _updatedTimer?.cancel();
    setState(() => _updated = true);
    _updatedTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _updated = false);
    });
  }

  Future<void> _markAll() async {
    final l10n = context.l10n;
    final marks = ref.read(inboxMarksProvider.notifier);
    late List<InboxItem> before;
    var marked = 0;
    await runOptimistic(
      context,
      apply: () => before = marks.applyAll(),
      rollback: () => marks.rollbackAll(before),
      commit: () async => marked = await marks.sendAll(),
      describe: (e) => errorMessage(l10n, e),
    );
    if (mounted && marked > 0) {
      showTixToast(context, l10n.inboxMarkedAll(marked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(inboxMarksProvider);
    final filter = ref.watch(inboxFilterStateProvider);
    final unread = ref.watch(inboxUnreadProvider).value ?? 0;
    final list = ref.watch(inboxListProvider(filter.unread));
    ref.listen(freshInboxIdsProvider, (_, next) {
      if (next.isNotEmpty) _flashUpdated();
    });
    final wide = MediaQuery.sizeOf(context).width >= inboxSideMinWidth;
    final compact = context.isCompact;
    final markAll = unread == 0 ? null : _markAll;
    return CommandScope(
      commands: [
        TixCommand(
          id: 'inbox.readAll',
          label: l10n.inboxMarkAllRead,
          group: l10n.inboxTitle,
          icon: Icons.done_all,
          run: () => unawaited(_markAll()),
        ),
        TixCommand(
          id: 'inbox.unread',
          label: l10n.inboxShowUnread,
          group: l10n.inboxTitle,
          icon: Icons.mark_email_unread_outlined,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyU),
          run: () => ref
              .read(inboxFilterStateProvider.notifier)
              .setUnread(unread: !filter.unread),
        ),
        TixCommand(
          id: 'inbox.settings',
          label: l10n.notifSettingsTitle,
          group: l10n.inboxTitle,
          icon: Icons.tune,
          run: () => context.go(Routes.notificationSettings),
        ),
      ],
      child: TixPage(
        title: l10n.inboxTitle,
        subtitle: unread == 0
            ? l10n.inboxAllCaughtUp
            : l10n.inboxUnreadCount(unread),
        actions: [
          UpdatedMark(visible: _updated),
          if (compact)
            TixIconButton(
              key: const Key('inbox.readAll'),
              icon: Icons.done_all,
              tooltip: l10n.inboxMarkAllRead,
              onPressed: markAll,
            )
          else
            TixButton(
              key: const Key('inbox.readAll'),
              label: l10n.inboxMarkAllRead,
              icon: Icons.done_all,
              onPressed: markAll,
            ),
          TixIconButton(
            key: const Key('inbox.settings'),
            icon: Icons.tune,
            tooltip: l10n.notifSettingsTitle,
            onPressed: () => context.go(Routes.notificationSettings),
          ),
        ],
        body: AsyncBody(
          value: list,
          onRetry: () => ref.invalidate(inboxListProvider(filter.unread)),
          data: (paged) => _InboxList(paged: paged, filter: filter, side: wide),
        ),
      ),
    );
  }
}

sealed class _Entry {
  const _Entry();
}

final class _Heading extends _Entry {
  const _Heading(this.label);
  final String label;
}

final class _Row extends _Entry {
  const _Row(this.item);
  final InboxItem item;
}

class _InboxList extends ConsumerWidget {
  const _InboxList({
    required this.paged,
    required this.filter,
    required this.side,
  });

  final Paged<InboxItem> paged;
  final InboxFilter filter;
  final bool side;

  List<_Entry> _group(
    AppLocalizations l10n,
    TixTimeStyle style,
    List<InboxItem> items,
    DateTime now,
  ) {
    final today = style.day(now);
    final out = <_Entry>[];
    String? last;
    for (final item in items) {
      final at = item.createdAt;
      final days = at == null ? 2 : today.difference(style.day(at)).inDays;
      final label = days <= 0
          ? l10n.inboxToday
          : days == 1
          ? l10n.inboxYesterday
          : l10n.inboxEarlier;
      if (label != last) out.add(_Heading(label));
      last = label;
      out.add(_Row(item));
    }
    return out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final fresh = ref.watch(freshInboxIdsProvider);
    final notifier = ref.read(inboxListProvider(filter.unread).notifier);
    final visible = paged.items.where(filter.keeps).toList();
    if (visible.isEmpty && paged.hasMore && !paged.loadingMore) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(notifier.fill(filter.keeps)),
      );
    }
    final entries = _group(l10n, context.times.style, visible, now);
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!side) const InboxSummaryCard(),
        const _NotificationNudge(),
        _Filters(filter: filter),
      ],
    );
    final empty = paged.hasMore
        ? const SizedBox(height: 200, child: SkeletonList(rows: 3))
        : EmptyState(
            icon: filter.unread || filter.kinds.isNotEmpty
                ? Icons.done_all
                : Icons.inbox_outlined,
            title: filter.unread
                ? l10n.inboxEmptyUnread
                : filter.kinds.isNotEmpty
                ? l10n.inboxEmptyFiltered
                : l10n.inboxEmpty,
            body: filter.unread || filter.kinds.isNotEmpty
                ? null
                : l10n.inboxEmptyBody,
          );
    final listView = PagedListView<_Entry>(
      paged: Paged(
        items: entries,
        cursor: paged.cursor,
        loadingMore: paged.loadingMore,
        moreError: paged.moreError,
      ),
      header: header,
      empty: empty,
      padding: const EdgeInsets.only(bottom: TixSpace.s6),
      onRefresh: () {
        ref
          ..invalidate(inboxUnreadProvider)
          ..invalidate(inboxSummaryProvider);
        return ref.refresh(inboxListProvider(filter.unread).future);
      },
      onLoadMore: () => unawaited(notifier.loadMore()),
      itemBuilder: (context, entry) => switch (entry) {
        _Heading(:final label) => _DayHeading(label),
        _Row(:final item) => _ItemRow(
          item: item,
          now: now,
          fresh: fresh.contains(item.id),
        ),
      },
    );
    if (!side) return listView;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: listView),
        const SizedBox(width: TixSpace.s2),
        const SizedBox(
          width: 320,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(right: TixSpace.s5),
            child: InboxSummaryCard(),
          ),
        ),
      ],
    );
  }
}

class _DayHeading extends StatelessWidget {
  const _DayHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Container(
      color: t.surface,
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        TixSpace.s2,
        TixSpace.s4,
        TixSpace.s2,
      ),
      child: Semantics(
        header: true,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: TixText.xs2,
            fontWeight: FontWeight.w600,
            letterSpacing: TixText.xs2 * 0.06,
            color: t.muted,
          ),
        ),
      ),
    );
  }
}

enum _ItemAction { open, read, unread, mute }

class _ItemRow extends ConsumerWidget {
  const _ItemRow({required this.item, required this.now, required this.fresh});

  final InboxItem item;
  final DateTime now;
  final bool fresh;

  Future<void> _mark(
    BuildContext context,
    WidgetRef ref, {
    required bool read,
  }) {
    final l10n = context.l10n;
    final marks = ref.read(inboxMarksProvider.notifier);
    return runOptimistic(
      context,
      apply: () => marks.apply(item, read: read),
      rollback: () => marks.rollback(item),
      commit: () => marks.send(item, read: read),
      describe: (e) => errorMessage(l10n, e),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    unawaited(ref.read(inboxMarksProvider.notifier).openRead(item));
    if (item.opensTask) {
      context.go(Routes.task(item.projectKey, item.taskRef));
    }
  }

  static Future<void> _setReceive(
    WidgetRef ref,
    InboxKind kind, {
    required bool receive,
  }) async {
    final keep = ref.listenManual(inboxMutedProvider, (_, _) {});
    try {
      await ref.read(inboxMutedProvider.future);
      await ref
          .read(inboxMutedProvider.notifier)
          .setReceive(kind, receive: receive);
    } finally {
      keep.close();
    }
  }

  Future<void> _mute(
    BuildContext context,
    WidgetRef ref,
    InboxKind kind,
  ) async {
    final l10n = context.l10n;
    try {
      await _setReceive(ref, kind, receive: false);
      if (context.mounted) {
        showTixToast(
          context,
          l10n.inboxMuted(inboxKindLabel(l10n, kind)),
          onUndo: () => unawaited(_setReceive(ref, kind, receive: true)),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _menu(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final kind = item.kind;
    final choice = await showActionSheet<_ItemAction>(
      context,
      title: item.opensTask ? item.taskRef : l10n.inboxTitle,
      actions: [
        if (item.opensTask)
          TixSheetAction(
            key: const Key('inbox.action.open'),
            value: _ItemAction.open,
            label: l10n.inboxOpenTask,
            icon: Icons.open_in_new,
          ),
        if (item.read)
          TixSheetAction(
            key: const Key('inbox.action.unread'),
            value: _ItemAction.unread,
            label: l10n.inboxMarkUnread,
            icon: Icons.mark_email_unread_outlined,
          )
        else
          TixSheetAction(
            key: const Key('inbox.action.read'),
            value: _ItemAction.read,
            label: l10n.inboxMarkRead,
            icon: Icons.drafts_outlined,
          ),
        if (kind != null)
          TixSheetAction(
            key: const Key('inbox.action.mute'),
            value: _ItemAction.mute,
            label: l10n.inboxMuteKind(inboxKindLabel(l10n, kind)),
            icon: Icons.notifications_off_outlined,
          ),
      ],
    );
    if (!context.mounted || choice == null) return;
    switch (choice) {
      case _ItemAction.open:
        _open(context, ref);
      case _ItemAction.read:
        await _mark(context, ref, read: true);
      case _ItemAction.unread:
        await _mark(context, ref, read: false);
      case _ItemAction.mute:
        await _mute(context, ref, kind!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final read = item.read;
    final toggle = TixSwipeAction(
      label: read ? l10n.inboxMarkUnread : l10n.inboxMarkRead,
      icon: read ? Icons.mark_email_unread_outlined : Icons.drafts_outlined,
      onTrigger: () => unawaited(_mark(context, ref, read: !read)),
    );
    return TixSwipeActions(
      id: item.id,
      start: toggle,
      end: toggle,
      child: InboxRow(
        key: Key('inbox.item.${item.id}'),
        item: item,
        now: now,
        fresh: fresh,
        onTap: () => _open(context, ref),
        onMenu: () => unawaited(_menu(context, ref)),
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.filter});

  final InboxFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.read(inboxFilterStateProvider.notifier);
    final unread = ref.watch(inboxUnreadProvider).value;
    return Padding(
      padding: const EdgeInsets.only(top: TixSpace.s2),
      child: TixFilterBar(
        chips: [
          SegmentedButton<bool>(
            key: const Key('inbox.show'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l10n.inboxAll)),
              ButtonSegment(
                value: true,
                label: Text(
                  unread == null || unread == 0
                      ? l10n.inboxUnreadFilter
                      : '${l10n.inboxUnreadFilter}  $unread',
                ),
              ),
            ],
            selected: {filter.unread},
            onSelectionChanged: (s) => state.setUnread(unread: s.first),
          ),
          for (final kind in inboxKinds)
            TixFilterChip(
              key: Key('inbox.kind.${kind.value}'),
              label: inboxKindLabel(l10n, kind),
              icon: inboxKindIcon(kind),
              selected: filter.kinds.contains(kind),
              onSelected: (_) => state.toggleKind(kind),
            ),
        ],
      ),
    );
  }
}

class _NotificationNudge extends ConsumerWidget {
  const _NotificationNudge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsStateProvider);
    if (!prefs.nudge || prefs.enabled) return const SizedBox.shrink();
    final l10n = context.l10n;
    final t = context.tix;
    final notifier = ref.read(notificationPrefsStateProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        TixSpace.s2,
        TixSpace.s4,
        0,
      ),
      child: Container(
        key: const Key('inbox.nudge'),
        padding: const EdgeInsets.all(TixSpace.s3),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(TixRadius.base),
        ),
        child: Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s2,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  prefs.blocked
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_active_outlined,
                  color: prefs.blocked ? t.warn : t.accent,
                  size: 20,
                ),
                const SizedBox(width: TixSpace.s2),
                Flexible(
                  child: Text(
                    prefs.blocked ? l10n.notifBlocked : l10n.notifNudge,
                    style: const TextStyle(fontSize: TixText.sm),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TixButton.quiet(
                  key: const Key('inbox.nudge.later'),
                  label: l10n.notifNotNow,
                  size: TixButtonSize.small,
                  onPressed: () => unawaited(notifier.dismissNudge()),
                ),
                TixButton(
                  key: const Key('inbox.nudge.on'),
                  label: l10n.notifTurnOn,
                  icon: Icons.notifications_outlined,
                  size: TixButtonSize.small,
                  onPressed: () => unawaited(notifier.setEnabled(on: true)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
