// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';

import '../../../../helpers/app.dart';
import '../../../../helpers/attachments.dart';
import '../../../../helpers/fake_tix.dart';

/// A phone tall enough that the whole task screen is built at once.
const tallPhone = Size(400, 4000);

/// A desktop tall enough for the whole task screen.
const tallDesktop = Size(1280, 3000);

/// Pumps the task screen for [ref] against [server], under the app's
/// shortcuts so single keys reach the screen's commands.
Future<ProviderContainer> pumpTask(
  WidgetTester tester,
  FakeTix server, {
  String ref = 'infra-1',
  Size size = tallPhone,
  Locale locale = const Locale('en'),
  bool settle = true,
  FakeAttachments? files,
}) {
  final stores = signedInStores();
  final screen = TixShortcuts(child: TaskDetailScreen(taskRef: ref));
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
      (files ?? FakeAttachments()).asOverride,
    ],
  );
}

/// The JSON bodies [server] received for [method] on [path].
List<Map<String, dynamic>> bodies(FakeTix server, String method, String path) =>
    [
      for (final r in server.requestsTo(path))
        if (r.method == method) r.data as Map<String, dynamic>,
    ];

/// How many [method] requests [server] received on [path].
int count(FakeTix server, String method, String path) => [
  for (final r in server.requestsTo(path))
    if (r.method == method) r,
].length;

/// Taps [finder] after scrolling it into view, then settles.
Future<void> press(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The text of the toast on screen, scoped to the snack bar.
Finder toast(String text) =>
    find.descendant(of: find.byType(SnackBar), matching: find.text(text));
