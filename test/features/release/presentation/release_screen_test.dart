// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/release/presentation/release_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

Map<String, Object?> newer() => {
  'running': '0.58.0',
  'latest': '0.59.0',
  'status': 'newer',
  'newer': true,
  'checked': true,
  'failed': false,
  'notes': '### Features\n\n* reactions on comments',
  'methods': [
    {
      'id': 'binary',
      'name': 'Release binary',
      'help': '…',
      'command': 'tix update',
    },
    {
      'id': 'container',
      'name': 'Container image',
      'help': '…',
      'command': 'podman pull ghcr.io/heliopsy/tix:0.59.0',
    },
  ],
  'changes': {
    'running': {
      'version': '0.58.0',
      'date': '2026-11-10',
      'notes': '* sessions',
    },
    'earlier': [
      {'version': '0.57.0', 'date': '2026-11-05', 'notes': '* move'},
    ],
    'untagged': false,
  },
};

void main() {
  late FakeTix server;
  late Map<String, Object?> answer;

  setUp(() {
    server = FakeTix();
    answer = newer();
    server.routes.add((o, path, _) {
      if (o.method == 'GET' && path == '/api/v1/release') {
        return FakeResponse(200, answer);
      }
      return null;
    });
  });

  Future<void> reveal(WidgetTester tester, Finder target) =>
      tester.scrollUntilVisible(
        target,
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const ReleaseScreen(),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: a newer release, how to upgrade and the notes', (
      tester,
    ) async {
      server.gate = Completer<void>();
      await pump(tester, size: size, settle: false);
      await tester.pump();
      expect(find.byType(SkeletonList), findsWidgets);
      server.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('release.status.newer')), findsOneWidget);
      expect(find.text('v0.59.0 is available'), findsOneWidget);
      expect(find.text('v0.58.0'), findsWidgets);
      expect(
        find.byKey(const Key('release.command.container')),
        findsOneWidget,
      );
      await reveal(tester, find.byKey(const Key('release.notes')));
      await reveal(tester, find.byKey(const Key('release.entry.0.58.0')));
    });

    testWidgets('$width: a refusal is shown and can be retried', (
      tester,
    ) async {
      server.failures['GET /api/v1/release'] = FakeResponse(
        404,
        envelope('not_found', 'no route'),
      );
      await pump(tester, size: size);
      expect(find.byType(ErrorState), findsOneWidget);
      server.failures.clear();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('release.status.newer')), findsOneWidget);
    });
  }

  final quiet = {
    'current': 'This installation is up to date',
    'failed': 'The release feed could not be reached',
    'pending': 'Not checked yet',
  };
  for (final MapEntry(key: status, value: heading) in quiet.entries) {
    testWidgets('$status: says so and offers no upgrade', (tester) async {
      answer = {
        'running': '0.58.0',
        'latest': status == 'current' ? '0.58.0' : '',
        'status': status,
        'methods': <Object>[],
        'changes': {'earlier': <Object>[], 'untagged': false},
      };
      await pump(tester);
      expect(find.text(heading), findsOneWidget);
      expect(find.byKey(const Key('release.upgrade')), findsNothing);
      expect(find.byKey(const Key('release.notes')), findsNothing);
    });
  }
}
