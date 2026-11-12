// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/dates.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/platform/sharing.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/repositories/account_repository.dart';
import 'package:tix_mobile/src/features/account/application/account.dart';

/// The private address a calendar app subscribes to for my due dates:
/// create, filter, rotate and revoke it, as the web's Settings does.
class CalendarScreen extends ConsumerWidget {
  /// Creates the screen.
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value;
    if (access != null && !access.can(Scopes.taskRead)) {
      return TixPage(
        title: l10n.calendarTitle,
        body: EmptyState(
          key: const Key('calendar.unavailable'),
          icon: Icons.event_busy_outlined,
          title: l10n.calendarUnavailable,
          body: l10n.calendarUnavailableBody,
        ),
      );
    }
    final feed = ref.watch(calendarProvider);
    final none = feed.hasValue && feed.value == null;
    return TixPage(
      title: l10n.calendarTitle,
      subtitle: l10n.calendarLead,
      primaryAction: none
          ? TixAction(
              key: const Key('calendar.create'),
              label: l10n.calendarCreate,
              icon: Icons.add,
              onPressed: () => _create(context, ref),
            )
          : null,
      body: AsyncBody(
        value: feed,
        onRetry: () => ref.invalidate(calendarProvider),
        data: (f) => f == null
            ? EmptyState(
                key: const Key('calendar.none'),
                icon: Icons.event_outlined,
                title: l10n.calendarNone,
                body: l10n.calendarNoneBody,
                action: TixAction(
                  label: l10n.calendarCreate,
                  icon: Icons.add,
                  onPressed: () => _create(context, ref),
                ),
              )
            : _Active(feed: f),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final filter = await showTixSheet<String>(
      context,
      builder: (_) => const _FilterSheet(initial: '', create: true),
    );
    if (filter == null || !context.mounted) return;
    await runIssue(
      context,
      () => ref.read(calendarProvider.notifier).create(filter),
      rotated: false,
    );
  }
}

/// Runs [issue] and shows the address it returns once, or the refusal.
Future<void> runIssue(
  BuildContext context,
  Future<IssuedCalendarFeed> Function() issue, {
  required bool rotated,
}) async {
  final l10n = context.l10n;
  try {
    final issued = await issue();
    if (!context.mounted) return;
    await showTixSheet<void>(
      context,
      dismissible: false,
      builder: (_) => FeedAddressSheet(issued: issued, rotated: rotated),
    );
  } on TixException catch (e) {
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    }
  }
}

class _Active extends ConsumerWidget {
  const _Active({required this.feed});

  final CalendarFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final created = feed.createdAt;
    return ListView(
      padding: const EdgeInsets.only(bottom: TixSpace.s7),
      children: [
        TixSection(
          title: l10n.calendarFeed,
          info: l10n.calendarFeedInfo,
          children: [
            ListTile(
              key: const Key('calendar.active'),
              leading: Icon(Icons.event_available, color: context.tix.ok),
              title: Text(l10n.calendarActive),
              subtitle: Text(
                created == null
                    ? l10n.calendarShownOnce
                    : l10n.calendarCreatedOn(formatDay(context, created)),
              ),
            ),
            ListTile(
              key: const Key('calendar.filter'),
              title: Text(l10n.calendarFilter),
              subtitle: Text(
                feed.filter.isEmpty ? l10n.calendarFilterDefault : feed.filter,
                style: feed.filter.isEmpty ? null : tixMono(context),
              ),
              trailing: TixButton(
                key: const Key('calendar.editFilter'),
                label: l10n.calendarEditFilter,
                size: TixButtonSize.small,
                onPressed: () => _filter(context, ref),
              ),
            ),
            ListTile(
              title: Text(l10n.calendarRotate),
              subtitle: Text(l10n.calendarRotateHelp),
              trailing: TixButton(
                key: const Key('calendar.rotate'),
                label: l10n.calendarRotateButton,
                size: TixButtonSize.small,
                onPressed: () => runIssue(
                  context,
                  () => ref.read(calendarProvider.notifier).rotate(),
                  rotated: true,
                ),
              ),
            ),
          ],
        ),
        TixSection(
          title: l10n.calendarRevoke,
          danger: true,
          children: [
            ListTile(
              title: Text(l10n.calendarRevoke),
              subtitle: Text(l10n.calendarRevokeHelp),
              trailing: TixButton.danger(
                key: const Key('calendar.revoke'),
                label: l10n.calendarRevokeButton,
                size: TixButtonSize.small,
                onPressed: () => _revoke(context, ref),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _filter(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final filter = await showTixSheet<String>(
      context,
      builder: (_) => _FilterSheet(initial: feed.filter, create: false),
    );
    if (filter == null || !context.mounted) return;
    try {
      await ref.read(calendarProvider.notifier).setFilter(filter);
      if (context.mounted) showTixToast(context, l10n.calendarFilterSaved);
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.calendarRevokeTitle,
      body: l10n.calendarRevokeBody,
      action: l10n.calendarRevokeButton,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(calendarProvider.notifier).revoke();
      if (context.mounted) showTixToast(context, l10n.calendarRevoked);
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial, required this.create});

  final String initial;
  final bool create;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final _filter = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: widget.create ? l10n.calendarCreate : l10n.calendarEditFilter,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('calendar.save'),
          label: widget.create ? l10n.calendarCreate : l10n.calendarSaveFilter,
          onPressed: () => Navigator.of(context).pop(_filter.text),
        ),
      ],
      child: TixTextField(
        label: l10n.calendarFilter,
        controller: _filter,
        fieldKey: const Key('calendar.filterField'),
        hint: l10n.calendarFilterHint,
        help: l10n.calendarFilterHelp,
        autofocus: true,
      ),
    );
  }
}

/// A feed's address, shown once, with how to subscribe to it.
class FeedAddressSheet extends ConsumerWidget {
  /// Shows [issued]'s address; [rotated] says it replaced another.
  const FeedAddressSheet({
    required this.issued,
    required this.rotated,
    super.key,
  });

  /// The feed as issued, address and all.
  final IssuedCalendarFeed issued;

  /// Whether this address replaced an older one.
  final bool rotated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final base = ref.watch(sessionControllerProvider).value?.baseUrl ?? '';
    final address = feedAddress(issued, base);
    final sharing = ref.read(textSharingProvider);
    final webcal = address.replaceFirst(RegExp('^https?://'), 'webcal://');
    final small = Theme.of(context).textTheme.bodyMedium;
    return TixSheetBody(
      title: l10n.calendarTitle,
      actions: [
        Builder(
          builder: (context) => TixButton.quiet(
            key: const Key('secret.share'),
            label: l10n.secretShare,
            icon: Icons.ios_share,
            onPressed: () => sharing.share(address, origin: originOf(context)),
          ),
        ),
        TixButton.quiet(
          key: const Key('calendar.subscribe'),
          label: l10n.calendarSubscribeHere,
          icon: Icons.event,
          onPressed: () =>
              ref.read(attachmentsProvider).openLink(Uri.parse(webcal)),
        ),
        TixButton.primary(
          key: const Key('secret.done'),
          label: l10n.secretDone,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OneTimeSecret(
            heading: l10n.calendarAddress,
            note: rotated ? l10n.calendarRotatedOnce : l10n.calendarOnce,
            values: [address],
          ),
          const SizedBox(height: TixSpace.s3),
          Text(
            issued.filter.trim().isEmpty
                ? l10n.calendarListsDefault
                : l10n.calendarLists(issued.filter.trim()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: TixSpace.s3),
          Text(l10n.calendarHowGoogle, style: small),
          const SizedBox(height: TixSpace.s1),
          Text(l10n.calendarHowApple, style: small),
          const SizedBox(height: TixSpace.s1),
          Text(l10n.calendarHowOutlook, style: small),
        ],
      ),
    );
  }
}

/// The address of [issued]: its URL when the server knew its own, else its
/// path on [base].
String feedAddress(IssuedCalendarFeed issued, String base) {
  if (issued.url.isNotEmpty) return issued.url;
  return '${withoutTrailingSlash(base)}${issued.path}';
}
