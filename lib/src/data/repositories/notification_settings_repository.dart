// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';

/// Which inbox items notify on this device, and the newest one already
/// seen per context, so none notifies twice.
class NotificationSettingsRepository {
  /// Keeps the choices in [_store].
  NotificationSettingsRepository(this._store);

  static const _kindsKey = 'notif.kinds';

  final KeyValueStore _store;

  /// Whether notifications are on for the context [context]; off until
  /// turned on.
  bool enabled(String context) => _store.read('notif.on.$context') == 'true';

  /// Turns notifications on or off for [context].
  Future<void> setEnabled(String context, {required bool on}) => on
      ? _store.write('notif.on.$context', 'true')
      : _store.delete('notif.on.$context');

  /// The kinds that notify; every kind until some is turned off.
  Set<InboxKind> kinds() {
    final raw = _store.read(_kindsKey);
    if (raw == null) return inboxKinds.toSet();
    return {for (final name in raw.split(',')) ?inboxKindNamed(name)};
  }

  /// Saves the kinds that notify.
  Future<void> setKinds(Set<InboxKind> kinds) => _store.write(
    _kindsKey,
    [
      for (final k in inboxKinds)
        if (kinds.contains(k)) k.value,
    ].join(','),
  );

  /// When the newest item already seen in [context] was created.
  DateTime? seen(String context) =>
      DateTime.tryParse(_store.read('notif.seen.$context') ?? '');

  /// Records [at] as the newest item seen in [context].
  Future<void> setSeen(String context, DateTime at) =>
      _store.write('notif.seen.$context', at.toUtc().toIso8601String());

  /// Whether the person put off the inbox's offer to turn notifications on.
  bool nudgeDismissed() => _store.read('notif.nudge') == 'dismissed';

  /// Puts the offer off for good.
  Future<void> dismissNudge() => _store.write('notif.nudge', 'dismissed');
}
