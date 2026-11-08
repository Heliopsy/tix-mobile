// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'attachments.dart';
import 'fake_people.dart';
import 'fake_tix.dart';
import 'sharing.dart';

/// A server with people, and the fakes a people screen hands things to.
class PeopleRig {
  /// A fresh server with [FakePeople] installed.
  PeopleRig() : server = FakeTix() {
    people = FakePeople.on(server);
  }

  /// The server.
  final FakeTix server;

  /// Its people, tokens, feed and transfers.
  late final FakePeople people;

  /// Files saved and picked.
  final files = FakeAttachments();

  /// Text shared.
  final sharing = FakeTextSharing();

  /// Pumps [screen] signed in to [server] at [size].
  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = phone,
    bool settle = true,
    Locale locale = const Locale('en'),
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      screen,
      size: size,
      settle: settle,
      locale: locale,
      overrides: [
        ...fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        files.asOverride,
        sharing.asOverride,
      ],
    );
  }

  /// The JSON bodies sent with [method] to [path].
  List<Map<String, dynamic>> sent(String method, String path) => [
    for (final r in server.requestsTo(path))
      if (r.method == method) r.data as Map<String, dynamic>,
  ];
}

/// Taps [finder] after scrolling it into view, then settles.
Future<void> tapIn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
