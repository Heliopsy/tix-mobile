// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';
import 'package:tix_mobile/src/data/update/play_feed.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

/// What a tap on an update notification hands back.
const updateNotePayload = 'tix-update';

/// The update notification's id: there is one at a time, and a newer
/// version replaces it.
final int updateNoteId = stableNoteId(updateNotePayload);

/// What an update notification says.
enum UpdateNoteKind {
  /// A newer release is out, downloaded by hand from its page.
  available,

  /// The App Store serves a newer version.
  store,

  /// Google Play serves a newer version.
  play,

  /// A newer release is downloaded and installs on Restart to update.
  ready,

  /// A newer release is downloaded and installs when tix quits.
  readyAuto,
}

/// What to notify about [state] in [mode], updating from [store], null
/// when nothing.
UpdateNoteKind? updateNoteKind(
  UpdateMode mode,
  UpdateState state, {
  required bool autoInstall,
  UpdateStore? store,
}) => switch (state.phase) {
  UpdatePhase.available when state.offer != null => _availableKind(mode, store),
  UpdatePhase.ready =>
    autoInstall ? UpdateNoteKind.readyAuto : UpdateNoteKind.ready,
  _ => null,
};

UpdateNoteKind _availableKind(UpdateMode mode, UpdateStore? store) =>
    mode != UpdateMode.store
    ? UpdateNoteKind.available
    : store == UpdateStore.play
    ? UpdateNoteKind.play
    : UpdateNoteKind.store;

/// The notification for [version], worded for [kind].
LocalNote updateNote(
  AppLocalizations l10n,
  String version,
  UpdateNoteKind kind,
) {
  final ready =
      kind == UpdateNoteKind.ready || kind == UpdateNoteKind.readyAuto;
  return LocalNote(
    id: updateNoteId,
    title: ready
        ? l10n.updateNoteReadyTitle(version)
        : l10n.updateNoteTitle(version),
    body: switch (kind) {
      UpdateNoteKind.available => l10n.updateNoteBody,
      UpdateNoteKind.store => l10n.updateNoteStoreBody,
      UpdateNoteKind.play => l10n.updateNotePlayBody,
      UpdateNoteKind.ready => l10n.updateNoteReadyBody,
      UpdateNoteKind.readyAuto => l10n.updateNoteReadyAutoBody,
    },
    payload: updateNotePayload,
    channel: NoteChannel.updates,
  );
}

/// The app's language outside any screen: the chosen one, else the
/// system's when the app speaks it, else English.
AppLocalizations storedL10n(KeyValueStore store) {
  final code =
      SettingsRepository(store).languageCode() ??
      PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == code,
  );
  return lookupAppLocalizations(Locale(supported ? code : 'en'));
}

/// Shows [note] about [version] through [notes], once per version: not
/// when one was shown for [version] already, and not while the platform
/// lets no notification show, in which case a later check tries again.
/// True when it showed.
Future<bool> notifyUpdateOnce({
  required LocalNotifier notes,
  required SettingsRepository settings,
  required String version,
  required LocalNote note,
}) async {
  if (settings.updateNotified() == version) return false;
  if (!await notes.allowed()) return false;
  await notes.show(note);
  await settings.setUpdateNotified(version);
  return true;
}

/// Whether an automatic check is due at [now] after one at [last]. A clock
/// set back makes it due.
bool updateCheckDue(DateTime? last, DateTime now) =>
    last == null ||
    now.isBefore(last) ||
    now.difference(last) >= updateCheckInterval;

/// The `tixwidget://` hosts a background run looks for updates on: the
/// widgets' refresh (iOS background refresh, Android's widget worker) and
/// Android's own update worker.
const updateBackgroundHosts = {'refresh', 'update'};

/// Looks for an update from a background run while the app is closed, at
/// most once per [updateCheckInterval], and notifies a newer version once.
/// Does nothing where updates are off or "Check for updates" is. The Play
/// build has no Play channel here, so it counts only the runs whose [uri]
/// carries Play's answer, which the Android update worker adds.
Future<void> runBackgroundUpdateCheck(
  Uri? uri,
  ProviderContainer container,
) async {
  if (uri == null || !updateBackgroundHosts.contains(uri.host)) return;
  final store = container.read(keyValueStoreProvider);
  final settings = SettingsRepository(store);
  if (!settings.updateCheck()) return;
  try {
    final mode = await container.read(updateModeProvider.future);
    if (mode == UpdateMode.off) return;
    final from = await container.read(updateStoreProvider.future);
    if (from == UpdateStore.play && PlayUpdateInfo.fromUri(uri) == null) {
      return;
    }
    final now = container.read(clockProvider)();
    if (!updateCheckDue(settings.updateLastCheck(), now)) return;
    await settings.setUpdateLastCheck(now);
    final updater = await container.read(updaterProvider.future);
    final offer = await updater.check();
    if (offer == null) return;
    final version = offer.version.toString();
    final kind = _availableKind(mode, from);
    await notifyUpdateOnce(
      notes: container.read(localNotesProvider),
      settings: settings,
      version: version,
      note: updateNote(storedL10n(store), version, kind),
    );
  } on UpdateException catch (e) {
    log('update: background check failed: $e');
  }
}
