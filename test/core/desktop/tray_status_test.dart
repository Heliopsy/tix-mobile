// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/desktop/tray_status.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/data/events/live_events.dart';

void main() {
  final now = DateTime.utc(2026, 11, 10, 12);
  TixTimes times(String lang) =>
      TixTimes(TixTimeStyle.device, lookupAppLocalizations(Locale(lang)));
  final en = times('en');

  const work = TrayInstance(name: 'work', host: 'tix.example.com');
  const home = TrayInstance(name: 'home', local: true);

  List<String> lines(TrayStatus status, {TixTimes? t}) {
    final tooltip = trayTooltip(t ?? en, status, now);
    return [tooltip.title, ...tooltip.body];
  }

  String active(TrayInstance i) =>
      lines(TrayStatus(signedIn: true, instances: [i]))[1];

  test('signed out it says so and nothing else', () {
    expect(lines(const TrayStatus()), ['tix · not signed in']);
  });

  test('the headline, a line per instance and the unread count', () {
    final status = TrayStatus(
      signedIn: true,
      instances: [
        TrayInstance(
          name: work.name,
          host: work.host,
          link: TrayLink.live,
          syncedAt: now.subtract(const Duration(minutes: 2)),
        ),
        home,
      ],
      unread: 5,
    );
    expect(lines(status), [
      'tix · 2 instances connected',
      'work (tix.example.com): synced 2 minutes ago',
      'home (local)',
      '5 unread in inbox',
    ]);
  });

  test('offline with queued changes', () {
    expect(
      active(
        const TrayInstance(
          name: 'home',
          local: true,
          link: TrayLink.offline,
          queued: 3,
        ),
      ),
      'home (local): offline, 3 changes queued',
    );
  });

  test('offline and syncing come before when it last synced', () {
    final synced = now.subtract(const Duration(hours: 3));
    TrayInstance w(TrayLink link) => TrayInstance(
      name: 'work',
      host: 'tix.example.com',
      link: link,
      syncedAt: synced,
    );
    expect(active(w(TrayLink.offline)), 'work (tix.example.com): offline');
    expect(active(w(TrayLink.syncing)), 'work (tix.example.com): syncing');
    expect(
      active(w(TrayLink.live)),
      'work (tix.example.com): synced 3 hours ago',
    );
  });

  test('never synced it says how it is connected', () {
    TrayInstance w(TrayLink link, {int queued = 0}) => TrayInstance(
      name: 'work',
      host: 'tix.example.com',
      link: link,
      queued: queued,
    );
    expect(active(w(TrayLink.live)), 'work (tix.example.com): live');
    expect(
      active(w(TrayLink.connecting)),
      'work (tix.example.com): connecting',
    );
    expect(active(w(TrayLink.idle)), 'work (tix.example.com)');
    expect(
      active(w(TrayLink.idle, queued: 1)),
      'work (tix.example.com): 1 change queued',
    );
  });

  test('past three instances the rest are counted', () {
    final status = TrayStatus(
      signedIn: true,
      instances: [
        for (var i = 1; i <= 5; i++) TrayInstance(name: 'i$i', local: true),
      ],
    );
    expect(lines(status), [
      'tix · 5 instances connected',
      'i1 (local)',
      'i2 (local)',
      'i3 (local)',
      '+2 more',
    ]);
  });

  test('nothing unread leaves the count out; one is singular', () {
    const none = TrayStatus(signedIn: true, instances: [home], unread: 0);
    expect(lines(none), ['tix · 1 instance connected', 'home (local)']);
    const one = TrayStatus(signedIn: true, instances: [home], unread: 1);
    expect(lines(one).last, '1 unread in inbox');
  });

  test('plural forms follow the language', () {
    const status = TrayStatus(
      signedIn: true,
      instances: [TrayInstance(name: 'home', local: true, queued: 2)],
      unread: 1,
    );
    expect(lines(status, t: times('de')), [
      'tix · 1 Instanz verbunden',
      'home (lokal): 2 Änderungen warten',
      '1 ungelesen im Posteingang',
    ]);
    expect(lines(status, t: times('bg')), [
      'tix · 1 свързана инстанция',
      'home (локална): 2 промени чакат',
      '1 непрочетено във Входящи',
    ]);
    expect(
      lines(status, t: times('fr'))[1],
      'home (locale) : 2 modifications en attente',
    );
  });

  test('live modes map to what the tray says', () {
    TrayLink link(LiveMode? m, {bool syncing = false, bool offline = false}) =>
        trayLink(m, syncing: syncing, offline: offline);
    expect(link(LiveMode.websocket), TrayLink.live);
    expect(link(LiveMode.polling), TrayLink.live);
    expect(link(LiveMode.refreshing), TrayLink.live);
    expect(link(LiveMode.connecting), TrayLink.connecting);
    expect(link(LiveMode.offline), TrayLink.offline);
    expect(link(LiveMode.paused), TrayLink.idle);
    expect(link(null), TrayLink.idle);
    expect(link(LiveMode.websocket, syncing: true), TrayLink.syncing);
    expect(link(LiveMode.websocket, offline: true), TrayLink.offline);
  });

  group('TrayTooltip.text', () {
    const tooltip = TrayTooltip(
      'tix · 3 instances connected',
      details: ['a (local)', 'b (local)', 'c (local)'],
      footer: '5 unread in inbox',
    );

    test('joins the lines when there is room', () {
      expect(
        tooltip.text(),
        'tix · 3 instances connected\na (local)\nb (local)\nc (local)\n'
        '5 unread in inbox',
      );
    });

    test('drops details from the end, then the footer, then cuts', () {
      expect(
        tooltip.text(max: 60),
        'tix · 3 instances connected\na (local)\n5 unread in inbox',
      );
      expect(tooltip.text(max: 40), 'tix · 3 instances connected');
      expect(tooltip.text(max: 10), 'tix · 3 i…');
    });
  });
}
