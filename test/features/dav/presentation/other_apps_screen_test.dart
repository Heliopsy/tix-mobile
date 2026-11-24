// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/platform/dav_handoff.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/refused_mark.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/features/dav/presentation/other_apps_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/attachments.dart';
import '../../../helpers/fake_dav.dart';
import '../../../helpers/fake_people.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/people_app.dart';
import '../../../helpers/stores.dart';

/// A server with CalDAV, and the fakes the screen hands things to.
class _Rig {
  _Rig({DavPlatform platform = DavPlatform.linux, bool dav = true})
    : server = FakeTix(),
      handoff = FakeDavHandoff(platform: platform) {
    FakePeople.on(server);
    if (dav) this.dav = FakeDav.on(server);
  }

  final FakeTix server;
  FakeDav? dav;
  final FakeDavHandoff handoff;
  final files = FakeAttachments();
  ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores =
      signedInStores();

  FakeDav get d => dav!;

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    Size size = phone,
    bool settle = true,
  }) => pumpScreen(
    tester,
    const OtherAppsScreen(),
    size: size,
    settle: settle,
    overrides: [
      ...fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
      files.asOverride,
      handoff.asOverride,
    ],
  );

  /// Opens setup, optionally names it, and creates the password.
  Future<void> create(WidgetTester tester, {String? name}) async {
    await tester.tap(find.byKey(const Key('dav.setUp')));
    await tester.pumpAndSettle();
    if (name != null) {
      await tester.enterText(find.byKey(const Key('dav.name')), name);
    }
    await tapIn(tester, find.byKey(const Key('dav.create')));
  }
}

Finder _inDetails(Finder f) =>
    find.descendant(of: find.byKey(const Key('dav.details')), matching: f);

void main() {
  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('ready: lead, details, passwords and guides', (tester) async {
        final rig = _Rig();
        await rig.pump(tester, size: size);
        expect(find.byKey(const Key('dav.setUp')), findsOneWidget);
        expect(
          find.textContaining('changes made in the other app do not come back'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('dav.privacy')), findsOneWidget);
        expect(find.text('https://tix.example/dav/'), findsOneWidget);
        expect(find.text('ana@example.com'), findsOneWidget);
        expect(find.byKey(const Key('dav.password.p1')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('dav.password.p1.state')),
            matching: find.text('Active'),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('Assigned to me'), findsWidgets);
        await tester.scrollUntilVisible(
          find.byKey(const Key('dav.guide.reminders')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const Key('dav.guide.reminders')), findsOneWidget);
      });

      testWidgets('an older server names the release that has it', (
        tester,
      ) async {
        final rig = _Rig(dav: false);
        await rig.pump(tester, size: size);
        expect(find.byKey(const Key('dav.old')), findsOneWidget);
        expect(find.textContaining('tix 0.69.0 or later'), findsOneWidget);
        expect(find.byKey(const Key('dav.setUp')), findsNothing);
      });

      testWidgets('turned off: the reason, and revoke still works', (
        tester,
      ) async {
        final rig = _Rig();
        rig.d.info = {'enabled': false, 'reason': 'turned off by the admin'};
        await rig.pump(tester, size: size);
        expect(find.byKey(const Key('dav.off')), findsOneWidget);
        expect(find.text('turned off by the admin'), findsOneWidget);
        expect(find.byKey(const Key('dav.setUp')), findsNothing);
        expect(find.byKey(const Key('dav.password.p1.revoke')), findsOneWidget);
      });

      testWidgets('a token tix refuses is told to sign in instead', (
        tester,
      ) async {
        final rig = _Rig();
        rig.server.failing['/api/v1/dav'] = FakeResponse(
          403,
          envelope('forbidden', 'an agent cannot have an app password'),
        );
        await rig.pump(tester, size: size);
        expect(find.byKey(const Key('dav.forbidden')), findsOneWidget);
        expect(
          find.textContaining('an agent cannot have an app password'),
          findsOneWidget,
        );
        expect(find.textContaining('Sign in as yourself'), findsOneWidget);
        expect(find.byKey(const Key('dav.setUp')), findsNothing);
      });

      testWidgets('error offers Retry', (tester) async {
        final rig = _Rig();
        rig.server.failing['/api/v1/dav'] = FakeResponse(
          500,
          envelope('internal', 'x'),
        );
        await rig.pump(tester, size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
        rig.server.failing.remove('/api/v1/dav');
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('dav.ready')), findsOneWidget);
      });

      testWidgets('loading is a skeleton', (tester) async {
        final rig = _Rig();
        rig.server.gate = Completer<void>();
        await rig.pump(tester, size: size, settle: false);
        await tester.pump();
        expect(find.byType(SkeletonList), findsOneWidget);
        rig.server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('dav.ready')), findsOneWidget);
      });

      testWidgets('no passwords yet offers setup', (tester) async {
        final rig = _Rig();
        rig.d.passwords.clear();
        await rig.pump(tester, size: size);
        expect(find.byKey(const Key('dav.none')), findsOneWidget);
      });
    });
  }

  testWidgets('a local instance says it needs a server and asks nothing', (
    tester,
  ) async {
    final rig = _Rig();
    rig.stores.settings.values
      ..clear()
      ..['storage.version'] = '2'
      ..['instances'] = jsonEncode([
        {
          'id': 'l1',
          'name': 'Notes',
          'kind': 'local',
          'db_path': '/data/notes.db',
          'created_at': '2026-11-01T00:00:00.000Z',
        },
      ])
      ..['connections'] = jsonEncode([
        {
          'id': 'k1',
          'instance_id': 'l1',
          'kind': 'token',
          'tenant_key': 'default',
          'created_at': '2026-11-01T00:00:00.000Z',
        },
      ])
      ..['context.active'] = jsonEncode({'connection_id': 'k1'});
    rig.stores.secrets.values['token.k1'] = 'tok';
    await rig.pump(tester);
    expect(find.byKey(const Key('dav.local')), findsOneWidget);
    expect(find.byKey(const Key('dav.setUp')), findsNothing);
    expect(rig.server.requestsTo('/api/v1/dav'), isEmpty);
  });

  group('setup', () {
    testWidgets('default name and lists, then the details with copy', (
      tester,
    ) async {
      final rig = _Rig();
      await rig.pump(tester, size: desktop);
      await tester.tap(find.byKey(const Key('dav.setUp')));
      await tester.pumpAndSettle();
      expect(find.text('tix app, Linux, 2026-11-01'), findsOneWidget);
      await tapIn(tester, find.byKey(const Key('dav.create')));
      expect(rig.d.created.single, {
        'name': 'tix app, Linux, 2026-11-01',
        'collections': 'assigned',
      });
      final secret = rig.d.issued.single;

      expect(find.textContaining('shown only now'), findsOneWidget);
      expect(find.textContaining('Thunderbird: New Calendar'), findsOneWidget);
      expect(find.textContaining('Evolution: New'), findsOneWidget);
      expect(_inDetails(find.text('https://tix.example/dav/')), findsOneWidget);
      expect(_inDetails(find.text('ana@example.com')), findsOneWidget);
      expect(find.text(secret), findsNothing);
      expect(find.byKey(const Key('dav.hidden')), findsOneWidget);

      await tapIn(tester, find.byKey(const Key('dav.reveal')));
      expect(find.text(secret), findsOneWidget);

      await tapIn(tester, find.byKey(const Key('dav.detail.password.copy')));
      expect(rig.handoff.copied, [secret]);
      expect(find.textContaining('Clear the clipboard'), findsOneWidget);

      await tapIn(tester, find.byKey(const Key('dav.done')));
      expect(find.text(secret), findsNothing);
      expect(rig.handoff.cleanUps, 1);
      expect(find.text('tix app, Linux, 2026-11-01'), findsOneWidget);
    });

    testWidgets('hidden password reads as hidden to a screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final rig = _Rig();
      await rig.pump(tester, size: desktop);
      await rig.create(tester);
      final secret = rig.d.issued.single;
      expect(
        tester.getSemantics(find.byKey(const Key('dav.hidden'))).value,
        isNot(contains(secret)),
      );
      expect(_inDetails(find.byTooltip('Copy password')), findsOneWidget);
      expect(_inDetails(find.byTooltip('Copy address')), findsOneWidget);
      expect(_inDetails(find.byTooltip('Copy user name')), findsOneWidget);
      expect(_inDetails(find.byTooltip('Show password')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('dav.detail.password.copy'))),
        const Size(48, 48),
      );
      handle.dispose();
    });

    testWidgets('one list per project, expiring in 90 days', (tester) async {
      final rig = _Rig();
      await rig.pump(tester, size: desktop);
      await tester.tap(find.byKey(const Key('dav.setUp')));
      await tester.pumpAndSettle();
      await tapIn(tester, find.text('One list per project'));
      await tapIn(tester, find.text('In 90 days'));
      await tapIn(tester, find.byKey(const Key('dav.create')));
      expect(rig.d.created.single, {
        'name': 'tix app, Linux, 2026-11-01',
        'collections': 'projects',
        'expires_at': fixedNow
            .add(const Duration(days: 90))
            .toUtc()
            .toIso8601String(),
      });
      expect(find.byKey(const Key('dav.readOnly')), findsNothing);
    });

    testWidgets("a name in use keeps the sheet open with tix's message", (
      tester,
    ) async {
      final rig = _Rig();
      await rig.pump(tester, size: desktop);
      await rig.create(tester, name: 'iPhone');
      expect(
        find.text('an app password named "iPhone" exists'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dav.create')), findsOneWidget);
      expect(rig.d.issued, isEmpty);
    });

    testWidgets('iOS opens the profile in Safari, then offers to save it', (
      tester,
    ) async {
      final rig = _Rig(platform: DavPlatform.ios)..handoff.serves = false;
      await rig.pump(tester);
      await rig.create(tester);
      expect(rig.d.created.single['name'], 'tix app, iOS, 2026-11-01');
      expect(find.textContaining('Profile Downloaded'), findsOneWidget);
      expect(find.textContaining('Not Verified'), findsOneWidget);
      await tapIn(tester, find.byKey(const Key('dav.openProfile')));
      final profile = rig.handoff.profiles.single;
      expect(profile, contains(rig.d.issued.single));
      expect(profile, contains('red.tix.mobile.caldav.c1'));
      expect(profile, contains('<string>ana@example.com</string>'));
      expect(find.byKey(const Key('dav.notFetched')), findsOneWidget);
      await tapIn(tester, find.byKey(const Key('dav.saveProfile')));
      expect(rig.handoff.saved.single, contains('com.apple.caldav.account'));
      await tapIn(tester, find.byKey(const Key('dav.detail.password.copy')));
      expect(
        find.textContaining('clears from the clipboard in 2'),
        findsOneWidget,
      );
    });

    testWidgets('macOS opens the profile in System Settings', (tester) async {
      final rig = _Rig(platform: DavPlatform.macos);
      await rig.pump(tester, size: desktop);
      await rig.create(tester);
      await tapIn(tester, find.byKey(const Key('dav.openProfile')));
      expect(rig.handoff.profiles, hasLength(1));
      expect(find.text('Opened System Settings'), findsOneWidget);
      expect(find.byKey(const Key('dav.saveProfile')), findsNothing);
    });

    testWidgets('Android hands the account to DAVx5', (tester) async {
      final rig = _Rig(platform: DavPlatform.android);
      await rig.pump(tester);
      await rig.create(tester);
      await tapIn(tester, find.byKey(const Key('dav.openDavx5')));
      final account = rig.handoff.davx5.single;
      expect(account.url, 'https://tix.example/dav/');
      expect(account.username, 'ana@example.com');
      expect(account.password, rig.d.issued.single);
      expect(find.text('Opened DAVx5'), findsOneWidget);
    });

    testWidgets('DAVx5 that fails to open falls back to the details', (
      tester,
    ) async {
      final rig = _Rig(platform: DavPlatform.android)..handoff.opens = false;
      await rig.pump(tester);
      await rig.create(tester);
      await tapIn(tester, find.byKey(const Key('dav.openDavx5')));
      expect(find.byKey(const Key('dav.openFailed')), findsOneWidget);
      expect(find.byKey(const Key('dav.details')), findsOneWidget);
    });

    for (final play in [false, true]) {
      testWidgets('without DAVx5, store links (play: $play)', (tester) async {
        final rig = _Rig(platform: DavPlatform.android)
          ..handoff.installed = false
          ..handoff.play = play;
        await rig.pump(tester);
        await rig.create(tester);
        expect(find.byKey(const Key('dav.noDavx5')), findsOneWidget);
        expect(find.byKey(const Key('dav.openDavx5')), findsNothing);
        for (final k in ['dav.getDavx5', 'dav.getTasksOrg', 'dav.getJtx']) {
          await tapIn(tester, find.byKey(Key(k)));
        }
        final hosts = rig.files.links.map((u) => u.host).toSet();
        expect(hosts, {if (play) 'play.google.com' else 'f-droid.org'});
        expect(
          rig.files.links.first.toString(),
          contains('at.bitfire.davdroid'),
        );
      });
    }

    testWidgets('Windows names Thunderbird', (tester) async {
      final rig = _Rig(platform: DavPlatform.windows);
      await rig.pump(tester, size: desktop);
      await rig.create(tester);
      expect(
        find.textContaining('Windows has no built-in app'),
        findsOneWidget,
      );
      expect(find.textContaining('Evolution: New'), findsNothing);
    });

    testWidgets('switching context closes the sheet and drops the password', (
      tester,
    ) async {
      final rig = _Rig();
      rig.stores.settings.values['contexts'] = jsonEncode([
        {
          'id': 'c1',
          'name': 'Work',
          'base_url': 'https://tix.example',
          'handle': 'ana',
        },
        {
          'id': 'c2',
          'name': 'Home',
          'base_url': 'https://tix.example',
          'handle': 'ana',
        },
      ]);
      rig.stores.secrets.values['token.c2'] = 'tok2';
      rig.server.tokens['tok2'] = 'default';
      final c = await rig.pump(tester, size: desktop);
      await rig.create(tester);
      await tapIn(tester, find.byKey(const Key('dav.reveal')));
      final secret = rig.d.issued.single;
      expect(find.text(secret), findsOneWidget);
      await c
          .read(sessionControllerProvider.notifier)
          .activate(const ContextRef(connectionId: 'c2'));
      await tester.pumpAndSettle();
      expect(find.text(secret), findsNothing);
      expect(find.byKey(const Key('dav.done')), findsNothing);
      expect(rig.handoff.cleanUps, 1);
    });
  });

  testWidgets('revoke confirms, then the row reads revoked, never refused', (
    tester,
  ) async {
    final rig = _Rig();
    final c = await rig.pump(tester, size: desktop);
    await tapIn(tester, find.byKey(const Key('dav.password.p1.revoke')));
    expect(find.text('Revoke iPhone?'), findsOneWidget);
    expect(rig.d.revoked, isEmpty);
    await tapIn(tester, find.byKey(const Key('confirm.ok')));
    expect(rig.d.revoked, ['p1']);
    expect(
      find.descendant(
        of: find.byKey(const Key('dav.password.p1.state')),
        matching: find.text('Revoked'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('dav.password.p1.revoke')), findsNothing);
    expect(find.byType(RefusedMark), findsNothing);
    expect(
      c.read(instancesRepositoryProvider).connection('c1')?.refused,
      isFalse,
    );
  });

  testWidgets('an expired password is marked, not refused', (tester) async {
    final rig = _Rig();
    rig.d.passwords.first['expires_at'] = '2026-10-31T00:00:00Z';
    await rig.pump(tester, size: desktop);
    expect(
      find.descendant(
        of: find.byKey(const Key('dav.password.p1.state')),
        matching: find.text('Expired'),
      ),
      findsOneWidget,
    );
    expect(find.byType(RefusedMark), findsNothing);
  });

  group('once the server takes writes', () {
    testWidgets('the lead says changes come back and Read only is offered', (
      tester,
    ) async {
      final rig = _Rig();
      rig.d.info = {...rig.d.info, 'write': true};
      await rig.pump(tester, size: desktop);
      expect(find.textContaining('come back to tix'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dav.setUp')));
      await tester.pumpAndSettle();
      await tapIn(tester, find.byKey(const Key('dav.readOnly')));
      await tapIn(tester, find.byKey(const Key('dav.create')));
      expect(rig.d.created.single['read_only'], isTrue);
    });

    testWidgets('a password that writes needs no replacing', (tester) async {
      final rig = _Rig();
      rig.d.info = {...rig.d.info, 'write': true};
      await rig.pump(tester, size: desktop);
      expect(find.byKey(const Key('dav.password.p1.readOnly')), findsNothing);
      expect(find.byKey(const Key('dav.password.p1.replace')), findsNothing);
    });

    testWidgets('a read-only password is replaced and the old one revoked', (
      tester,
    ) async {
      final rig = _Rig();
      rig.d.info = {...rig.d.info, 'write': true};
      rig.d.passwords.first
        ..['read_only'] = true
        ..['collections'] = 'projects';
      await rig.pump(tester, size: desktop);
      expect(find.byKey(const Key('dav.password.p1.readOnly')), findsOneWidget);
      await tapIn(tester, find.byKey(const Key('dav.password.p1.replace')));
      await tapIn(tester, find.byKey(const Key('dav.create')));
      expect(rig.d.created.single['collections'], 'projects');
      expect(rig.d.created.single.containsKey('read_only'), isFalse);
      await tapIn(tester, find.byKey(const Key('dav.done')));
      expect(find.text('Revoke iPhone now?'), findsOneWidget);
      await tapIn(tester, find.byKey(const Key('confirm.ok')));
      expect(rig.d.revoked, ['p1']);
    });

    testWidgets('while the server reads only, no password is marked', (
      tester,
    ) async {
      final rig = _Rig();
      rig.d.passwords.first['read_only'] = true;
      await rig.pump(tester, size: desktop);
      expect(find.byKey(const Key('dav.password.p1.readOnly')), findsNothing);
    });
  });

  testWidgets('nothing overflows at 200% text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final rig = _Rig(platform: DavPlatform.ios);
    await rig.pump(tester);
    expect(tester.takeException(), isNull);
    await rig.create(tester);
    expect(tester.takeException(), isNull);
  });
}
