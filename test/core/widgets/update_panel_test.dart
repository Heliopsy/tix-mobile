// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/core/widgets/update_panel.dart';

import '../../helpers/app.dart';
import '../../helpers/attachments.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/fixed_updates.dart';

const _app = AppInfo(
  version: '0.11.0',
  build: '',
  platform: 'Linux',
  osVersion: 'Ubuntu 24.04',
);

void main() {
  late FakeAttachments links;

  setUp(() => links = FakeAttachments());

  Future<FixedUpdates> pump(
    WidgetTester tester,
    UpdateState state, {
    UpdateMode mode = UpdateMode.install,
    Size size = phone,
    Map<String, String> settings = const {},
  }) async {
    final updates = FixedUpdates(state);
    final server = FakeTix();
    final stores = signedInStores();
    stores.settings.values.addAll(settings);
    await pumpScreen(
      tester,
      const Scaffold(body: SingleChildScrollView(child: UpdatePanel())),
      size: size,
      overrides: [
        ...fakeOverrides(server, settings: stores.settings, updates: mode),
        fixedUpdates(updates),
        appInfoProvider.overrideWithValue(const AsyncData(_app)),
        links.asOverride,
      ],
    );
    return updates;
  }

  String status(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('update.status'))).data!;

  Finder button(String id) => find.byKey(Key('update.$id'));

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('a staged update offers Restart to update ($width)', (
      tester,
    ) async {
      final updates = await pump(tester, readyState('0.12.0'), size: size);
      expect(status(tester), 'tix 0.12.0 is ready to install.');
      expect(button('download'), findsNothing);
      expect(button('notes'), findsOneWidget);
      await tester.tap(button('restart'));
      await tester.pumpAndSettle();
      expect(updates.restarts, 1);
    });
  }

  testWidgets('with install on quit, a staged update says so', (tester) async {
    await pump(
      tester,
      readyState('0.12.0'),
      settings: {'settings.updateAutoInstall': 'true'},
    );
    expect(
      find.text('It installs when you quit tix, or now with a restart.'),
      findsOneWidget,
    );
  });

  testWidgets('before the first check, Check now checks', (tester) async {
    final updates = await pump(tester, const UpdateState());
    expect(status(tester), 'Not checked yet.');
    expect(button('restart'), findsNothing);
    expect(button('notes'), findsNothing);
    await tester.tap(button('check'));
    await tester.pumpAndSettle();
    expect(updates.checks, 1);
  });

  testWidgets('the latest version says so', (tester) async {
    await pump(tester, const UpdateState(phase: UpdatePhase.current));
    expect(status(tester), 'tix 0.11.0 is the latest version.');
  });

  testWidgets('an offered update links to its release page', (tester) async {
    await pump(
      tester,
      UpdateState(phase: UpdatePhase.available, offer: offerOf('0.12.0')),
      mode: UpdateMode.notify,
    );
    expect(status(tester), 'Update available: tix 0.12.0');
    expect(find.text('Download it from the release page.'), findsOneWidget);
    expect(button('restart'), findsNothing);
    await tester.tap(button('download'));
    await tester.tap(button('notes'));
    await tester.pumpAndSettle();
    final page = Uri.parse(
      'https://github.com/heliopsy/tix-mobile/releases/tag/v0.12.0',
    );
    expect(links.links, [page, page]);
  });

  testWidgets('a download in progress shows how far it is', (tester) async {
    await pump(
      tester,
      UpdateState(
        phase: UpdatePhase.downloading,
        offer: offerOf('0.12.0'),
        progress: 0.42,
      ),
    );
    expect(status(tester), 'Downloading tix 0.12.0… 42%');
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(button('download'), findsNothing);
  });

  testWidgets('an unverified update falls back to Download', (tester) async {
    await pump(
      tester,
      UpdateState(
        phase: UpdatePhase.failed,
        offer: offerOf('0.12.0'),
        error: UpdateErrorKind.unverified,
      ),
    );
    expect(
      status(tester),
      "The update couldn't be verified, so it wasn't installed.",
    );
    expect(find.text('Update available: tix 0.12.0'), findsOneWidget);
    expect(button('download'), findsOneWidget);
    expect(button('restart'), findsNothing);
  });

  testWidgets('a failed check says GitHub was not reached', (tester) async {
    await pump(
      tester,
      const UpdateState(
        phase: UpdatePhase.failed,
        error: UpdateErrorKind.network,
      ),
    );
    expect(status(tester), "Couldn't reach GitHub to check for updates.");
    expect(button('download'), findsNothing);
  });

  testWidgets("a release without this system's archive says so", (
    tester,
  ) async {
    await pump(
      tester,
      UpdateState(
        phase: UpdatePhase.available,
        offer: offerOf('0.12.0', asset: false),
        error: UpdateErrorKind.noAsset,
      ),
    );
    expect(
      find.text('There is no download for this system in the release.'),
      findsOneWidget,
    );
  });

  testWidgets('nothing where updates are off', (tester) async {
    await pump(tester, readyState('0.12.0'), mode: UpdateMode.off);
    expect(find.byKey(const Key('update.status')), findsNothing);
  });
}
