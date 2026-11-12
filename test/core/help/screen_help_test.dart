// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/help/screen_help.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/router/router.dart';

import '../../../hook/src/libtix.dart' show TixLock;
import '../../helpers/app.dart';
import '../../helpers/attachments.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_admin.dart';
import '../../helpers/fake_tix.dart';

/// Routes that draw no page of their own: they load, move or sign in.
const Set<String> _pageless = {
  Routes.splash,
  Routes.switching,
  Routes.connect,
  Routes.gallery,
};

/// The pattern of every route that builds a screen under [routes].
List<String> _screens(List<RouteBase> routes, [String parent = '']) => [
  for (final r in routes)
    if (r is GoRoute) ...[
      if (r.builder != null || r.pageBuilder != null) _join(parent, r.path),
      ..._screens(r.routes, _join(parent, r.path)),
    ] else
      ..._screens(r.routes, parent),
];

String _join(String parent, String path) =>
    path.startsWith('/') ? path : '$parent/$path';

void main() {
  group('the map', () {
    test('every routed screen has an entry, and every entry a route', () async {
      final c = await signedInContainer(FakeTix());
      final routes = _screens(c.read(routerProvider).configuration.routes)
          .where((r) => !_pageless.contains(r))
          .toSet();
      expect(routes, contains('/manage/trash'));
      expect(routes, contains('/projects/:key/tasks/:ref'));
      expect(
        routes.difference(screenDocs.keys.toSet()),
        isEmpty,
        reason: 'screens with no entry in screenDocs',
      );
      expect(
        screenDocs.keys.toSet().difference(routes),
        isEmpty,
        reason: 'entries for no route',
      );
    });

    test('every section is a heading of tix docs at the pinned commit', () {
      final lock = TixLock.parse(File('tix.lock').readAsStringSync());
      final vendored = jsonDecode(
        File('api/tix-doc-anchors.json').readAsStringSync(),
      ) as Map<String, Object?>;
      expect(
        vendored['commit'],
        lock.commit,
        reason: 'run `just doc-anchors-sync` after moving tix.lock',
      );
      final pages = (vendored['pages']! as Map).map(
        (k, v) => MapEntry(k as String, (v as List).cast<String>().toSet()),
      );
      final redirectable = RegExp(r'^[a-z0-9][a-z0-9_-]{0,127}$');
      for (final MapEntry(key: route, value: doc) in screenDocs.entries) {
        if (doc == null) continue;
        expect(pages, contains(doc.page), reason: route);
        expect(pages[doc.page], contains(doc.anchor), reason: route);
        expect(doc.anchor, matches(redirectable), reason: route);
      }
    });
  });

  group('the link', () {
    const trash = DocSection('tenancy.md', 'the-trash');

    test('goes through the server, with or without a trailing slash', () {
      for (final base in ['https://tix.example', 'https://tix.example/']) {
        expect(
          serverDocsUri(base, trash).toString(),
          'https://tix.example/docs/tenancy.md?section=the-trash',
        );
      }
    });

    test('keeps the path and port a server is under', () {
      expect(
        serverDocsUri('https://example.com/tix/', trash).toString(),
        'https://example.com/tix/docs/tenancy.md?section=the-trash',
      );
      expect(
        serverDocsUri('http://10.0.0.2:8080/a/b', trash).toString(),
        'http://10.0.0.2:8080/a/b/docs/tenancy.md?section=the-trash',
      );
    });

    test('without a server, GitHub at the release tag or at main', () {
      const tag =
          'https://github.com/heliopsy/tix/blob/v0.57.0/docs/'
          'tenancy.md#the-trash';
      expect(githubDocsUri(trash, release: 'v0.57.0').toString(), tag);
      expect(githubDocsUri(trash, release: '0.57.0').toString(), tag);
      for (final dev in [null, '', 'in-memory', 'v0.57.0-3-gabcdef']) {
        expect(
          githubDocsUri(trash, release: dev).toString(),
          'https://github.com/heliopsy/tix/blob/main/docs/tenancy.md'
          '#the-trash',
          reason: '$dev',
        );
      }
    });
  });

  group('in the app', () {
    Future<(ProviderContainer, FakeAttachments)> pumpApp(
      WidgetTester tester,
      Size size,
    ) async {
      final server = FakeTix();
      FakeAdmin.on(server);
      final stores = signedInStores();
      final links = FakeAttachments();
      await setSize(tester, size);
      await tester.pumpWidget(
        ProviderScope(
          retry: noRetry,
          overrides: [
            ...fakeOverrides(
              server,
              settings: stores.settings,
              secrets: stores.secrets,
            ),
            attachmentsProvider.overrideWithValue(links),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
      return (
        ProviderScope.containerOf(tester.element(find.byType(App))),
        links,
      );
    }

    final help = find.byKey(const Key('page.help'));

    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width: the (?) opens the screen section on the server', (
        tester,
      ) async {
        final (c, links) = await pumpApp(tester, size);
        c.read(routerProvider).go(Routes.trash);
        await tester.pumpAndSettle();
        expect(help, findsOneWidget);
        await tester.tap(help);
        await tester.pumpAndSettle();
        expect(links.links, [
          Uri.parse('https://tix.example/docs/tenancy.md?section=the-trash'),
        ]);
      });
    }

    testWidgets('a screen tix docs do not describe has no (?)', (tester) async {
      final (c, _) = await pumpApp(tester, desktop);
      c.read(routerProvider).go(Routes.conflicts);
      await tester.pumpAndSettle();
      expect(find.byType(TixPage), findsOneWidget);
      expect(help, findsNothing);
      c.read(routerProvider).go(Routes.settings);
      await tester.pumpAndSettle();
      expect(help, findsOneWidget);
    });
  });
}
