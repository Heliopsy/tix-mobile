// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/l10n/generated/app_localizations_en.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/update/play_updates.dart';
import 'package:tix_mobile/src/core/update/update_notice.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';
import 'package:tix_mobile/src/data/update/play_feed.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';
import 'package:tix_mobile/src/data/update/updater.dart';

import '../../helpers/container.dart';
import '../../helpers/fake_notes.dart';
import '../../helpers/fake_update.dart';
import '../../helpers/fixed_updates.dart';
import '../../helpers/stores.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final t0 = DateTime.utc(2026, 11, 1, 12);

  group('notifyUpdateOnce', () {
    late FakeNotes notes;
    late SettingsRepository settings;

    setUp(() {
      notes = FakeNotes();
      settings = SettingsRepository(MemoryKeyValueStore());
    });

    Future<bool> notify(String version) => notifyUpdateOnce(
      notes: notes,
      settings: settings,
      version: version,
      note: updateNote(l10n, version, UpdateNoteKind.available),
    );

    test('shows a version once, then a newer one once', () async {
      expect(await notify('0.21.0'), isTrue);
      expect(await notify('0.21.0'), isFalse);
      expect(await notify('0.21.0'), isFalse);
      expect(await notify('0.22.0'), isTrue);
      expect(notes.shown.map((n) => n.title), [
        'tix 0.21.0 is available',
        'tix 0.22.0 is available',
      ]);
      expect(settings.updateNotified(), '0.22.0');
    });

    test('remembers the version across restarts', () async {
      final store = MemoryKeyValueStore();
      settings = SettingsRepository(store);
      await notify('0.21.0');
      settings = SettingsRepository(store);
      expect(await notify('0.21.0'), isFalse);
      expect(notes.shown, hasLength(1));
    });

    test(
      'shows nothing while notifications are off, and tries again',
      () async {
        notes.enabled = false;
        expect(await notify('0.21.0'), isFalse);
        expect(notes.shown, isEmpty);
        expect(settings.updateNotified(), isNull);
        expect(notes.asked, 0);
        notes.enabled = true;
        expect(await notify('0.21.0'), isTrue);
        expect(notes.shown, hasLength(1));
      },
    );
  });

  group('updateNote', () {
    test('words each kind and opens the update on tap', () {
      LocalNote note(UpdateNoteKind kind) => updateNote(l10n, '0.21.0', kind);
      expect(note(UpdateNoteKind.available).title, 'tix 0.21.0 is available');
      expect(
        note(UpdateNoteKind.available).body,
        'Tap to see the update and download it.',
      );
      expect(
        note(UpdateNoteKind.store).body,
        'Tap to update from the App Store.',
      );
      expect(
        note(UpdateNoteKind.ready).title,
        'tix 0.21.0 is ready to install',
      );
      expect(
        note(UpdateNoteKind.ready).body,
        'Tap to update: tix restarts into the new version.',
      );
      expect(
        note(UpdateNoteKind.readyAuto).body,
        'It installs when you quit tix. Tap to update now.',
      );
      for (final kind in UpdateNoteKind.values) {
        expect(note(kind).payload, updateNotePayload);
        expect(note(kind).channel, NoteChannel.updates);
        expect(note(kind).id, updateNoteId);
      }
    });
  });

  group('updateNoteKind', () {
    final offer = offerOf('0.21.0');

    test('follows the mode and the phase', () {
      UpdateNoteKind? kind(
        UpdateMode mode,
        UpdatePhase phase, {
        bool auto = false,
      }) => updateNoteKind(
        mode,
        UpdateState(phase: phase, offer: offer),
        autoInstall: auto,
      );
      expect(
        kind(UpdateMode.notify, UpdatePhase.available),
        UpdateNoteKind.available,
      );
      expect(
        kind(UpdateMode.store, UpdatePhase.available),
        UpdateNoteKind.store,
      );
      expect(
        updateNoteKind(
          UpdateMode.store,
          UpdateState(phase: UpdatePhase.available, offer: offer),
          autoInstall: false,
          store: UpdateStore.play,
        ),
        UpdateNoteKind.play,
      );
      expect(kind(UpdateMode.install, UpdatePhase.ready), UpdateNoteKind.ready);
      expect(
        kind(UpdateMode.install, UpdatePhase.ready, auto: true),
        UpdateNoteKind.readyAuto,
      );
      expect(kind(UpdateMode.install, UpdatePhase.downloading), isNull);
      expect(kind(UpdateMode.notify, UpdatePhase.current), isNull);
      expect(kind(UpdateMode.notify, UpdatePhase.failed), isNull);
    });
  });

  test('a Play note says Google Play', () {
    final note = updateNote(l10n, '0.21.0', UpdateNoteKind.play);
    expect(note.title, 'tix 0.21.0 is available');
    expect(note.body, 'Tap to update from Google Play.');
  });

  group('updateCheckDue', () {
    test('is due first, then once three hours have passed', () {
      expect(updateCheckDue(null, t0), isTrue);
      expect(updateCheckDue(t0, t0), isFalse);
      expect(
        updateCheckDue(t0, t0.add(const Duration(hours: 2, minutes: 59))),
        isFalse,
      );
      expect(updateCheckDue(t0, t0.add(const Duration(hours: 3))), isTrue);
    });

    test('a clock set back makes it due', () {
      expect(updateCheckDue(t0, t0.subtract(const Duration(days: 1))), isTrue);
    });
  });

  group('runBackgroundUpdateCheck', () {
    late MemoryKeyValueStore store;
    late FakeReleaseFeed feed;
    late FakeNotes notes;
    late DateTime now;

    setUp(() {
      store = MemoryKeyValueStore();
      feed = FakeReleaseFeed(
        release: Release(
          tag: 'v0.21.0',
          version: const ReleaseVersion(0, 21, 0),
          page: Uri.parse(
            'https://github.com/heliopsy/tix-mobile/releases/tag/v0.21.0',
          ),
          assets: const [],
        ),
      );
      notes = FakeNotes();
      now = t0;
    });

    ProviderContainer container({UpdateMode mode = UpdateMode.notify}) =>
        makeContainer([
          keyValueStoreProvider.overrideWithValue(store),
          clockProvider.overrideWithValue(() => now),
          localNotesProvider.overrideWithValue(notes),
          updateModeProvider.overrideWithValue(AsyncData(mode)),
          updaterProvider.overrideWith(
            (ref) async => Updater(
              feed: feed,
              installer: FakeInstaller(),
              current: const ReleaseVersion(0, 20, 0),
              publicKey: '',
            ),
          ),
        ]);

    Future<void> run(String link, {UpdateMode mode = UpdateMode.notify}) =>
        runBackgroundUpdateCheck(Uri.parse(link), container(mode: mode));

    test('notifies a newer version once and records the check', () async {
      await run('tixwidget://refresh');
      expect(notes.shown.single.title, 'tix 0.21.0 is available');
      expect(notes.shown.single.payload, updateNotePayload);
      expect(SettingsRepository(store).updateLastCheck(), t0);
      now = t0.add(const Duration(hours: 4));
      await run('tixwidget://update');
      expect(SettingsRepository(store).updateLastCheck(), now);
      expect(notes.shown, hasLength(1));
    });

    test('asks at most once every three hours', () async {
      await run('tixwidget://update');
      store.values.remove('update.notified');
      now = t0.add(const Duration(hours: 1));
      await run('tixwidget://update');
      expect(notes.shown, hasLength(1));
      now = t0.add(const Duration(hours: 3, minutes: 1));
      await run('tixwidget://update');
      expect(notes.shown, hasLength(2));
    });

    test('a store build words it for the store', () async {
      await run('tixwidget://refresh', mode: UpdateMode.store);
      expect(notes.shown.single.body, 'Tap to update from the App Store.');
    });

    test('does nothing while checking is off or updates are', () async {
      store.values['settings.updateCheck'] = 'off';
      await run('tixwidget://refresh');
      store.values.remove('settings.updateCheck');
      await run('tixwidget://refresh', mode: UpdateMode.off);
      expect(notes.shown, isEmpty);
      expect(store.values, isNot(contains('update.lastCheck')));
    });

    test('a widget tick does not look for updates', () async {
      await run('tixwidget://drain');
      expect(notes.shown, isEmpty);
      expect(store.values, isNot(contains('update.lastCheck')));
    });

    test('a failed check still counts towards the limit', () async {
      feed.failure = const UpdateException(UpdateErrorKind.network);
      await run('tixwidget://refresh');
      expect(notes.shown, isEmpty);
      expect(SettingsRepository(store).updateLastCheck(), t0);
    });
  });
  group('runBackgroundUpdateCheck in the Play build', () {
    late MemoryKeyValueStore store;
    late FakeNotes notes;
    late DateTime now;

    setUp(() {
      store = MemoryKeyValueStore();
      notes = FakeNotes();
      now = t0;
    });

    Future<void> run(String link) {
      final uri = Uri.parse(link);
      return runBackgroundUpdateCheck(
        uri,
        makeContainer([
          keyValueStoreProvider.overrideWithValue(store),
          clockProvider.overrideWithValue(() => now),
          localNotesProvider.overrideWithValue(notes),
          updateModeProvider.overrideWithValue(
            const AsyncData(UpdateMode.store),
          ),
          updateStoreProvider.overrideWithValue(
            const AsyncData(UpdateStore.play),
          ),
          updaterProvider.overrideWith(
            (ref) async => Updater(
              feed: PlayReleaseFeed(LinkPlayUpdates(uri)),
              installer: FakeInstaller(),
              current: const ReleaseVersion(0, 20, 0),
              publicKey: '',
            ),
          ),
        ]),
      );
    }

    void later() => now = now.add(const Duration(hours: 3, minutes: 1));

    test('notifies once per version code', () async {
      await run('tixwidget://update?play=1&code=21000');
      later();
      await run('tixwidget://update?play=1&code=21000');
      expect(notes.shown, hasLength(1));
      expect(notes.shown.single.title, 'tix 0.21.0 is available');
      expect(notes.shown.single.body, 'Tap to update from Google Play.');
      later();
      await run('tixwidget://update?play=1&code=21001');
      expect(notes.shown.map((n) => n.title), [
        'tix 0.21.0 is available',
        'tix 0.21.1 is available',
      ]);
    });

    test('Play saying no update notifies nothing', () async {
      await run('tixwidget://update?play=0&code=21000');
      expect(notes.shown, isEmpty);
      expect(SettingsRepository(store).updateLastCheck(), t0);
    });

    test("a run without Play's answer does not use up the limit", () async {
      await run('tixwidget://refresh');
      await run('tixwidget://update');
      expect(store.values, isNot(contains('update.lastCheck')));
      await run('tixwidget://update?play=1&code=21000');
      expect(notes.shown, hasLength(1));
    });
  });
}
