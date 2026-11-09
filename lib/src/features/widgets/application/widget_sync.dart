// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/l10n/generated/app_localizations.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/widget_snapshot.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';
import 'package:tix_mobile/src/features/widgets/application/feed.dart';
import 'package:tix_mobile/src/features/widgets/application/writer.dart';

part 'widget_sync.g.dart';

/// How long a burst of events is gathered before the widgets are rewritten.
const widgetEventDebounce = Duration(seconds: 2);

/// The app's language for text written outside any screen: the chosen one,
/// else the system's when the app speaks it, else English.
AppLocalizations widgetL10n(KeyValueStore store) {
  final code =
      SettingsRepository(store).languageCode() ??
      PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == code,
  );
  return lookupAppLocalizations(Locale(supported ? code : 'en'));
}

/// The context a widget link names: [WidgetKeys.active] or
/// `<connectionId>.<tenantKey>`, null for the active one.
ContextRef? widgetContextRef(String? ctx) {
  if (ctx == null || ctx.isEmpty || ctx == WidgetKeys.active) return null;
  final dot = ctx.indexOf('.');
  if (dot <= 0) return ContextRef(connectionId: ctx);
  return ContextRef(
    connectionId: ctx.substring(0, dot),
    tenantKey: ctx.substring(dot + 1),
  );
}

/// Keeps the home screen widgets current while the signed-in app runs:
/// after the session changes, events about tasks, the inbox or projects,
/// a quick add, a resume, and when the app goes out of sight. Runs the
/// queue of widget ticks first each time.
@riverpod
class WidgetSync extends _$WidgetSync {
  Future<void> _chain = Future.value();

  @override
  Future<void> build() async {
    final bridge = ref.watch(widgetBridgeProvider);
    if (!bridge.supported) return;
    ref.watch(sessionControllerProvider.select((s) => s.value?.ref));
    onEvents(
      ref,
      {
        ...EventTopics.tasks,
        ...EventTopics.inbox,
        ...EventTopics.projects,
        ...EventTopics.workflows,
      },
      (_) => unawaited(sync()),
      debounce: widgetEventDebounce,
    );
    ref
      ..listen(tasksChangedProvider, (_, _) => unawaited(sync()))
      ..listen(widgetsStaleProvider, (_, _) => unawaited(sync()))
      ..listen(appResumedProvider, (_, _) => unawaited(sync()))
      ..listen(appHiddenProvider, (_, _) => unawaited(sync()));
    final queued = bridge.queued.listen((_) => unawaited(sync()));
    ref.onDispose(queued.cancel);
    unawaited(bridge.init());
    await sync();
  }

  /// Runs the widget queue, then rewrites every snapshot this app can
  /// reach. Runs one at a time.
  Future<void> sync() => _chain = _chain.then((_) => _sync());

  Future<void> _sync() async {
    if (!ref.mounted) return;
    final writer = _writer();
    try {
      final settled = await writer.drain(reachable: _reachable);
      if (settled > 0 && ref.mounted) {
        ref.read(tasksChangedProvider.notifier).touch();
      }
      if (!ref.mounted) return;
      await writer.refresh(reachable: _reachable);
    } on Object catch (e, s) {
      log('widgets: sync failed', error: e, stackTrace: s);
    }
  }

  WidgetWriter _writer() {
    final store = ref.read(keyValueStoreProvider);
    return WidgetWriter(
      bridge: ref.read(widgetBridgeProvider),
      instances: ref.read(instancesRepositoryProvider),
      store: store,
      l10n: widgetL10n(store),
      now: ref.read(clockProvider),
      open: _open,
    );
  }

  Session? get _session {
    final s = ref.read(sessionControllerProvider).value;
    return s == null || s.problem != null ? null : s;
  }

  bool _isActive(WidgetTarget t) {
    final s = _session;
    return s != null && widgetContextId(s.ref) == t.ctx.id;
  }

  bool _reachable(WidgetTarget t) => !t.local || _isActive(t);

  Future<WidgetFeed?> _open(WidgetTarget t) async {
    if (_isActive(t)) {
      return WidgetFeed(
        tasks: ref.read(tasksRepositoryProvider),
        lists: ref.read(taskListRepositoryProvider),
        inbox: ref.read(inboxRepositoryProvider),
      );
    }
    return await openStoredFeed(
      t,
      instances: ref.read(instancesRepositoryProvider),
      factory: ref.read(tixApiFactoryProvider),
      cache: ref.read(cacheStoreProvider),
    );
  }

  /// Handles a link tapped in a widget: switches to its context when it is
  /// not the active one, marks an inbox item read, asks for quick add, and
  /// answers the route to show, or null to stay.
  Future<String?> open(Uri uri) async {
    if (uri.scheme != 'tixwidget') return null;
    final q = uri.queryParameters;
    final route = uri.host == 'open' ? q['route'] ?? '' : '';
    final landing = route.startsWith('/') ? route : null;
    final target = widgetContextRef(q['ctx']);
    if (target != null && !await _switchTo(target, landing)) return null;
    if (!ref.mounted) return null;
    switch (uri.host) {
      case 'open':
        final item = q['item'] ?? '';
        if (item.isNotEmpty) await _markRead(item);
        return landing;
      case 'quickadd':
        ref.read(quickAddDraftsProvider.notifier).open(project: q['project']);
        return null;
      default:
        return null;
    }
  }

  Future<bool> _switchTo(ContextRef target, String? landing) async {
    final current = _session?.ref;
    if (current != null &&
        current.connectionId == target.connectionId &&
        (current.tenantKey == target.tenantKey || target.tenantKey.isEmpty)) {
      return true;
    }
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .activate(target, landing: landing);
      return true;
    } on Object catch (e) {
      log('widgets: could not switch context: ${e.runtimeType}');
      return false;
    }
  }

  Future<void> _markRead(String item) async {
    try {
      await ref.read(inboxRepositoryProvider).markRead(item);
    } on Object catch (e) {
      log('widgets: mark read failed: ${e.runtimeType}');
    }
  }
}
