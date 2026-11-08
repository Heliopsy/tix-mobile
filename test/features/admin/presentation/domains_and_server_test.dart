// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/admin/presentation/domains_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/server_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_admin.dart';
import '../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;
  late FakeAdmin admin;

  setUp(() {
    server = FakeTix();
    admin = FakeAdmin.on(server);
  });

  group('domains', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      group(width, () {
        testWidgets('loading, then the domains', (tester) async {
          server.gate = Completer<void>();
          await pumpAdmin(
            tester,
            server,
            const DomainsScreen(),
            size: size,
            settle: false,
          );
          expect(find.byType(SkeletonList), findsOneWidget);
          server.gate!.complete();
          await tester.pumpAndSettle();
          final row = find.byKey(const Key('domain.tix.example.com'));
          expect(
            find.descendant(of: row, matching: find.text('Verified')),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: row,
              matching: find.text('Terminated elsewhere'),
            ),
            findsOneWidget,
          );
        });

        testWidgets('empty carries the add action', (tester) async {
          admin.domains.clear();
          await pumpAdmin(tester, server, const DomainsScreen(), size: size);
          expect(
            find.descendant(
              of: find.byType(EmptyState),
              matching: find.text('Add domain'),
            ),
            findsOneWidget,
          );
        });

        testWidgets('error', (tester) async {
          server.override = FakeResponse(403, envelope('forbidden', 'no'));
          await pumpAdmin(tester, server, const DomainsScreen(), size: size);
          expect(
            find.text('This token is not allowed to do that.'),
            findsOneWidget,
          );
        });
      });
    }

    testWidgets('adding one with a certificate file sends the paths', (
      tester,
    ) async {
      await pumpAdmin(tester, server, const DomainsScreen(), size: desktop);
      await tester.tap(find.byKey(const Key('domains.add')).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('domain.certPath')), findsNothing);
      await tester.enterText(
        find.byKey(const Key('domain.hostname')),
        'board.example.com',
      );
      await tester.tap(find.text('Certificate file').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('domain.certPath')), '/c');
      await tester.enterText(find.byKey(const Key('domain.keyPath')), '/k');
      await tester.tap(find.byKey(const Key('form.submit')));
      await tester.pumpAndSettle();
      expect(server.requests.last.body, {
        'hostname': 'board.example.com',
        'cert_mode': 'file',
        'cert_path': '/c',
        'key_path': '/k',
      });
      expect(find.byKey(const Key('domain.board.example.com')), findsOneWidget);
    });

    testWidgets('removing one asks first', (tester) async {
      await pumpAdmin(tester, server, const DomainsScreen());
      await tester.tap(find.byKey(const Key('domain.remove.tix.example.com')));
      await tester.pumpAndSettle();
      expect(admin.domains['default'], hasLength(1));
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      expect(admin.domains['default'], isEmpty);
      expect(find.byType(EmptyState), findsOneWidget);
    });
  });

  group('server', () {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      group(width, () {
        testWidgets('loading, then the version, counts and connections', (
          tester,
        ) async {
          server.gate = Completer<void>();
          await pumpAdmin(
            tester,
            server,
            const ServerScreen(),
            size: size,
            settle: false,
          );
          expect(find.byType(SkeletonList), findsOneWidget);
          server.gate!.complete();
          await tester.pumpAndSettle();
          expect(find.text('tix v1.2.3'), findsOneWidget);
          expect(find.text('srv-1'), findsOneWidget);
          await reveal(tester, find.byKey(const Key('connection.c2')));
          expect(
            find.descendant(
              of: find.byKey(const Key('connection.c2')),
              matching: find.text('@ana · SSH'),
            ),
            findsOneWidget,
          );
        });

        testWidgets('no connections says so', (tester) async {
          admin.connections.clear();
          await pumpAdmin(tester, server, const ServerScreen(), size: size);
          await reveal(tester, find.byKey(const Key('connections.empty')));
          expect(find.byKey(const Key('connections.empty')), findsOneWidget);
        });

        testWidgets('error', (tester) async {
          server.override = FakeResponse(500, envelope('internal', 'x'));
          await pumpAdmin(tester, server, const ServerScreen(), size: size);
          expect(find.byType(ErrorState), findsOneWidget);
        });
      });
    }

    testWidgets('ending a connection asks first', (tester) async {
      await pumpAdmin(tester, server, const ServerScreen(), size: desktop);
      await tapShown(tester, find.byKey(const Key('connection.end.c1')));
      expect(admin.connections, hasLength(2));
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      expect(admin.connections.single['id'], 'c2');
      expect(find.byKey(const Key('connection.c1')), findsNothing);
    });
  });
}
