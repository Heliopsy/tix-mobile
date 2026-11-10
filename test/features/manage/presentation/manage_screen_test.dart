// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/data/models/access.dart';
import 'package:tix_mobile/src/features/manage/manage_sections.dart';
import 'package:tix_mobile/src/features/manage/presentation/manage_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    FakeTix server, {
    Size size = phone,
    bool settle = true,
    List<ManageEntry>? entries,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      ManageScreen(entries: entries),
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
    group(width, () {
      testWidgets('loading, then every group an admin can use', (tester) async {
        final server = FakeTix()..gate = Completer<void>();
        await pump(tester, server, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('manage.group.projects')), findsOneWidget);
        expect(find.byKey(const Key('manage.group.workflows')), findsOneWidget);
        expect(find.byKey(const Key('manage.group.fields')), findsOneWidget);
        expect(find.byKey(const Key('manage.group.people')), findsOneWidget);
        expect(find.byKey(const Key('manage.group.server')), findsNothing);
      });

      testWidgets('a credential that manages nothing says so', (tester) async {
        final server = FakeTix()
          ..identity = {
            'scopes': ['task:read'],
          };
        await pump(tester, server, size: size);
        expect(
          find.text('Nothing to manage with this credential.'),
          findsOneWidget,
        );
        expect(find.byType(TixSection), findsNothing);
      });

      testWidgets('error', (tester) async {
        final server = FakeTix()
          ..override = FakeResponse(500, envelope('internal', 'x'));
        await pump(tester, server, size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });
    });
  }

  testWidgets('an admin with event:subscribe finds no Watch here', (
    tester,
  ) async {
    final server = FakeTix()
      ..identity = {
        'role': 'admin',
        'scopes': ['event:subscribe', 'audit:read'],
      };
    await pump(tester, server, size: desktop);
    final audit = find.byKey(const Key('manage.tenant.audit'));
    await tester.scrollUntilVisible(
      audit,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(audit, findsOneWidget);
    expect(find.byKey(const Key('manage.tenant.watch')), findsNothing);
    expect(find.text('Watch'), findsNothing);
  });

  testWidgets('a member sees what its role reads', (tester) async {
    final server = FakeTix()..identity = {'role': 'member'};
    await pump(tester, server);
    expect(find.byKey(const Key('manage.projects.list')), findsOneWidget);
    expect(find.byKey(const Key('manage.workflows.list')), findsOneWidget);
  });

  testWidgets('a token without workflow:read gets no Workflows', (
    tester,
  ) async {
    final server = FakeTix()
      ..identity = {
        'scopes': ['project:read', 'project:write'],
      };
    await pump(tester, server);
    expect(find.byKey(const Key('manage.projects.list')), findsOneWidget);
    expect(find.byKey(const Key('manage.group.workflows')), findsNothing);
  });

  testWidgets('an entry opens its screen', (tester) async {
    await pump(tester, FakeTix());
    await tester.tap(find.byKey(const Key('manage.workflows.list')));
    await tester.pumpAndSettle();
    expect(find.text('route:/manage/workflows'), findsOneWidget);
  });

  testWidgets('entries other features add are grouped in order', (
    tester,
  ) async {
    await pump(
      tester,
      FakeTix(),
      entries: [
        ...manageSections,
        ManageEntry(
          id: 'people.custom',
          group: ManageGroup.people,
          icon: Icons.group_outlined,
          title: (_) => 'Users',
          subtitle: (_) => 'Who signs in',
          route: '/manage',
          scope: Scope.userAdmin,
        ),
        ManageEntry(
          id: 'server.global',
          group: ManageGroup.server,
          icon: Icons.public,
          title: (_) => 'Global admins',
          subtitle: (_) => 'Across tenants',
          route: '/manage',
          when: (a) => a.globalAdmin,
        ),
      ],
    );
    expect(find.byKey(const Key('manage.people.custom')), findsOneWidget);
    expect(find.byKey(const Key('manage.server.global')), findsNothing);
    final people = tester.getTopLeft(
      find.byKey(const Key('manage.group.people')),
    );
    final fields = tester.getTopLeft(
      find.byKey(const Key('manage.group.fields')),
    );
    expect(people.dy, greaterThan(fields.dy));
  });

  testWidgets('people, access and transfer follow their scopes', (
    tester,
  ) async {
    final server = FakeTix()
      ..identity = {
        'scopes': ['user:admin', 'export'],
      };
    await pump(tester, server);
    expect(find.byKey(const Key('manage.people.users')), findsOneWidget);
    expect(find.byKey(const Key('manage.tenant.transfer')), findsOneWidget);
    expect(find.byKey(const Key('manage.access.tokens')), findsNothing);
    expect(find.byKey(const Key('manage.group.projects')), findsNothing);
  });
}
