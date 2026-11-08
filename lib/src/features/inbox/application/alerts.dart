// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/l10n/generated/app_localizations.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/components/inbox_row.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/repositories/notification_settings_repository.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';

part 'alerts.g.dart';

/// The key notification settings are stored under for [context].
String notificationContextKey(ContextRef context) =>
    '${context.connectionId}.${context.tenantKey}';

/// Whether the notification context [key] is [context]. A token's tenant
/// is named only once whoami answers, so an empty tenant on either side
/// matches the same connection.
bool _sameContext(ContextRef context, String key) {
  final here = notificationContextKey(context);
  if (here == key) return true;
  final dot = key.indexOf('.');
  if (dot < 0 || key.substring(0, dot) != context.connectionId) return false;
  return context.tenantKey.isEmpty || key.substring(dot + 1).isEmpty;
}

/// Notification choices on this device.
@Riverpod(keepAlive: true)
NotificationSettingsRepository notificationSettingsRepository(Ref ref) =>
    NotificationSettingsRepository(ref.watch(keyValueStoreProvider));

/// Whether and for what the active context notifies.
@immutable
class NotificationPrefs {
  /// The choices.
  const NotificationPrefs({
    required this.enabled,
    required this.kinds,
    this.blocked = false,
    this.nudge = false,
    this.hideContent = false,
  });

  /// Notifications say only that something arrived, never what.
  final bool hideContent;

  /// Whether the inbox should offer to turn notifications on.
  final bool nudge;

  /// On for the active context.
  final bool enabled;

  /// The kinds that notify.
  final Set<InboxKind> kinds;

  /// The platform refused the permission the last time it was asked.
  final bool blocked;
}

/// The active context's notification choices.
@riverpod
class NotificationPrefsState extends _$NotificationPrefsState {
  @override
  NotificationPrefs build() {
    final context = ref.watch(
      sessionControllerProvider.select((s) => s.value?.ref),
    );
    final repo = ref.watch(notificationSettingsRepositoryProvider);
    return NotificationPrefs(
      enabled: context != null && repo.enabled(notificationContextKey(context)),
      kinds: repo.kinds(),
      hideContent:
          context != null && repo.hideContent(notificationContextKey(context)),
      nudge:
          context != null &&
          !repo.enabled(notificationContextKey(context)) &&
          !repo.nudgeDismissed(),
    );
  }

  /// Stops offering to turn notifications on.
  Future<void> dismissNudge() async {
    state = NotificationPrefs(
      enabled: state.enabled,
      kinds: state.kinds,
      blocked: state.blocked,
      hideContent: state.hideContent,
    );
    await ref.read(notificationSettingsRepositoryProvider).dismissNudge();
  }

  /// Turns notifications on, asking the platform first, or off.
  Future<void> setEnabled({required bool on}) async {
    final context = ref.read(sessionControllerProvider).value?.ref;
    if (context == null) return;
    final repo = ref.read(notificationSettingsRepositoryProvider);
    if (on && !await ref.read(localNotesProvider).requestPermission()) {
      if (!ref.mounted) return;
      state = NotificationPrefs(
        enabled: false,
        kinds: state.kinds,
        blocked: true,
        nudge: state.nudge,
        hideContent: state.hideContent,
      );
      return;
    }
    await repo.setEnabled(notificationContextKey(context), on: on);
    if (!ref.mounted) return;
    state = NotificationPrefs(
      enabled: on,
      kinds: state.kinds,
      hideContent: state.hideContent,
    );
  }

  /// Turns notifications for [kind] on or off.
  Future<void> setKind(InboxKind kind, {required bool on}) async {
    final kinds = on
        ? {...state.kinds, kind}
        : ({...state.kinds}..remove(kind));
    state = NotificationPrefs(
      enabled: state.enabled,
      kinds: kinds,
      blocked: state.blocked,
      hideContent: state.hideContent,
    );
    await ref.read(notificationSettingsRepositoryProvider).setKinds(kinds);
  }

  /// Leaves task content out of the active context's notifications, or
  /// puts it back.
  Future<void> setHideContent({required bool on}) async {
    final context = ref.read(sessionControllerProvider).value?.ref;
    if (context == null) return;
    state = NotificationPrefs(
      enabled: state.enabled,
      kinds: state.kinds,
      blocked: state.blocked,
      nudge: state.nudge,
      hideContent: on,
    );
    await ref
        .read(notificationSettingsRepositoryProvider)
        .setHideContent(notificationContextKey(context), on: on);
  }
}

/// Where a tapped notification leads.
@immutable
class NoteTarget {
  /// A tap on item [item] of [context], leading to [route].
  const NoteTarget({
    required this.route,
    required this.item,
    required this.context,
  });

  /// Reads a notification's payload, or null when it is not one of ours.
  static NoteTarget? parse(String payload) {
    try {
      final json = jsonDecode(payload);
      if (json is! Map<String, Object?>) return null;
      final route = json['route'];
      if (route is! String || route.isEmpty) return null;
      return NoteTarget(
        route: route,
        item: json['item'] as String? ?? '',
        context: json['context'] as String? ?? '',
      );
    } on FormatException {
      return null;
    }
  }

  /// The app location to open.
  final String route;

  /// The inbox item.
  final String item;

  /// The notification context key it was shown for.
  final String context;

  /// The payload to hand the platform.
  String encode() =>
      jsonEncode({'route': route, 'item': item, 'context': context});
}

/// The most notifications one check shows before it sums the rest up.
const maxNotesPerCheck = 3;

/// Notifies new inbox items of the active context while the app runs:
/// each item once, none that was there when the app started.
@riverpod
class InboxAlerts extends _$InboxAlerts {
  Future<void> _queue = Future.value();

  @override
  Future<void> build() async {
    final context = ref.watch(
      sessionControllerProvider.select((s) => s.value?.ref),
    );
    if (context == null) return;
    final key = notificationContextKey(context);
    unawaited(ref.read(localNotesProvider).init());
    onEvents(
      ref,
      EventTopics.inbox,
      (_) => unawaited(_enqueue(key, notify: true)),
    );
    await _enqueue(key, notify: false);
  }

  Future<void> _enqueue(String key, {required bool notify}) =>
      _queue = _queue.then((_) => _check(key, notify: notify));

  Future<void> _check(String key, {required bool notify}) async {
    if (!ref.mounted) return;
    final settings = ref.read(notificationSettingsRepositoryProvider);
    final List<InboxItem> items;
    final bool more;
    try {
      final page = await ref.read(inboxRepositoryProvider).items(unread: true);
      items = page.items;
      more = page.hasMore;
    } on Object catch (e) {
      log('notifications: inbox read failed: ${e.runtimeType}');
      return;
    }
    if (!ref.mounted) return;
    final seen = settings.seen(key);
    DateTime? newest;
    for (final i in items) {
      final at = i.createdAt;
      if (at != null && (newest == null || at.isAfter(newest))) newest = at;
    }
    if (notify && seen != null && settings.enabled(key)) {
      final kinds = settings.kinds();
      final fresh = [
        for (final i in items)
          if (i.createdAt != null &&
              i.createdAt!.isAfter(seen) &&
              kinds.contains(i.kind))
            i,
      ]..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      await _show(
        key,
        fresh,
        badge: more ? null : items.length,
        hide: settings.hideContent(key),
      );
    }
    final mark = newest ?? (seen == null ? ref.read(clockProvider)() : null);
    if (mark != null && (seen == null || mark.isAfter(seen))) {
      await settings.setSeen(key, mark);
    }
  }

  Future<void> _show(
    String key,
    List<InboxItem> fresh, {
    required bool hide,
    int? badge,
  }) async {
    if (fresh.isEmpty) return;
    final notifier = ref.read(localNotesProvider);
    final l10n = _l10n();
    final shown = fresh.length > maxNotesPerCheck
        ? fresh.sublist(fresh.length - maxNotesPerCheck)
        : fresh;
    for (final item in shown) {
      final route = item.opensTask
          ? Routes.task(item.projectKey, item.taskRef)
          : Routes.inbox;
      await notifier.show(
        LocalNote(
          id: stableNoteId(item.id),
          title: hide ? l10n.notifPrivateTitle : inboxWhat(l10n, item),
          body: hide
              ? l10n.notifPrivateBody
              : [
                  if (item.opensTask) '${item.taskRef}  ${item.taskTitle}',
                  if (item.excerpt.isNotEmpty &&
                      item.kind != InboxKind.assigned)
                    item.excerpt,
                ].join('\n'),
          publicTitle: l10n.notifPrivateTitle,
          publicBody: l10n.notifPrivateBody,
          payload: NoteTarget(
            route: route,
            item: item.id,
            context: key,
          ).encode(),
          badge: badge,
        ),
      );
    }
    final rest = fresh.length - shown.length;
    if (rest > 0) {
      await notifier.show(
        LocalNote(
          id: stableNoteId('more.$key'),
          title: l10n.notifMore(rest),
          body: l10n.notifMoreBody,
          publicTitle: l10n.notifPrivateTitle,
          publicBody: l10n.notifPrivateBody,
          payload: NoteTarget(
            route: Routes.inbox,
            item: '',
            context: key,
          ).encode(),
          badge: badge,
        ),
      );
    }
  }

  AppLocalizations _l10n() {
    final code =
        SettingsRepository(ref.read(keyValueStoreProvider)).languageCode() ??
        PlatformDispatcher.instance.locale.languageCode;
    final supported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == code,
    );
    return lookupAppLocalizations(Locale(supported ? code : 'en'));
  }

  /// Handles a tap on a notification: marks its item read when it belongs
  /// to the active context, and answers where to go, or null to stay.
  Future<String?> open(String payload) async {
    final target = NoteTarget.parse(payload);
    if (target == null) return null;
    final context = ref.read(sessionControllerProvider).value?.ref;
    if (context == null || !_sameContext(context, target.context)) {
      return null;
    }
    if (target.item.isNotEmpty) {
      unawaited(ref.read(localNotesProvider).cancel(stableNoteId(target.item)));
      try {
        await ref.read(inboxRepositoryProvider).markRead(target.item);
        if (ref.mounted) ref.invalidate(inboxUnreadProvider);
      } on Object catch (e) {
        log('notifications: mark read failed: ${e.runtimeType}');
      }
    }
    return target.route;
  }
}
