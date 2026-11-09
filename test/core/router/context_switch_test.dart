// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/features/manage/presentation/manage_screen.dart';
import 'package:tix_mobile/src/features/projects/presentation/projects_screen.dart';
import 'package:tix_mobile/src/features/shell/presentation/home_shell.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_screen.dart';
import 'package:tix_mobile/src/features/workflows/presentation/workflow_editor_screen.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

void main() {
  const acme = ContextRef(connectionId: 's1', tenantKey: 'acme');
  const channel = MethodChannel('tix/links-switch-test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late FakeTix server;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;
  String? pending;

  setUp(() {
    server = FakeTix()
      ..tenants['acme'] = (name: 'Acme', host: '')
      ..tenantProjects['acme'] = [
        {
          'id': 'p9',
          'key': 'ops',
          'name': 'Operations',
          'color': 'green',
          'workflow_id': 'wf1',
        },
      ];
    stores = signInStores(server, tenants: ['default', 'acme']);
    pending = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'take') return null;
      final p = pending;
      pending = null;
      return p;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  });

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await setSize(tester, phone);
    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: <Override>[
          ...fakeOverrides(
            server,
            settings: stores.settings,
            secrets: stores.secrets,
          ),
          deepLinkIntakeProvider.overrideWith((ref) {
            final intake = DeepLinkIntake(channel);
            ref.onDispose(intake.dispose);
            return intake;
          }),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(App)));
  }

  String location(ProviderContainer c) =>
      c.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();

  String tenant(ProviderContainer c) =>
      c.read(sessionControllerProvider).value!.connection.tenantKey;

  Future<void> visit(
    WidgetTester tester,
    ProviderContainer c,
    String to,
  ) async {
    c.read(routerProvider).go(to);
    await tester.pumpAndSettle();
  }

  Future<void> activate(
    WidgetTester tester,
    ProviderContainer c,
    ContextRef to,
  ) async {
    final done = c.read(sessionControllerProvider.notifier).activate(to);
    await tester.pumpAndSettle();
    await done;
  }

  Future<void> openTab(WidgetTester tester, int index) async {
    tester.widget<HomeShell>(find.byType(HomeShell)).shell.goBranch(index);
    await tester.pumpAndSettle();
  }

  List<String> requestsSince(int count) => [
    for (final r in server.requests.skip(count)) r.uri.toString(),
  ];

  testWidgets('switching tenant on a task lands on the projects list and '
      'never asks the new tenant for the old task', (tester) async {
    final c = await pumpApp(tester);
    await visit(tester, c, Routes.workflow('default'));
    expect(find.byType(WorkflowEditorScreen), findsOneWidget);
    await visit(tester, c, Routes.task('infra', 'infra-1'));
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    final before = server.requests.length;

    await activate(tester, c, acme);

    expect(tenant(c), 'acme');
    expect(location(c), Routes.projects);
    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(find.byType(TaskListScreen), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ProjectsScreen),
        matching: find.text('Operations'),
      ),
      findsOneWidget,
    );
    final since = requestsSince(before);
    expect(since, contains(endsWith('/auth/switch')));
    expect(since.where((u) => u.contains('infra')), isEmpty);

    await openTab(tester, 4);
    expect(location(c), Routes.manage);
    expect(find.byType(ManageScreen), findsOneWidget);
    expect(find.byType(WorkflowEditorScreen), findsNothing);
    expect(requestsSince(before).where((u) => u.contains('infra')), isEmpty);
  });

  testWidgets('a link naming another context lands on its target there', (
    tester,
  ) async {
    final c = await pumpApp(tester);
    await visit(tester, c, Routes.workflow('default'));
    await visit(tester, c, Routes.task('infra', 'infra-1'));
    final before = server.requests.length;

    pending = 'tix://projects/ops?context=s1.acme';
    await messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(const MethodCall('opened')),
      (_) {},
    );
    await tester.pumpAndSettle();

    expect(tenant(c), 'acme');
    expect(location(c), Routes.project('ops'));
    expect(
      tester.widget<TaskListScreen>(find.byType(TaskListScreen)).projectKey,
      'ops',
    );
    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(requestsSince(before).where((u) => u.contains('infra')), isEmpty);

    await openTab(tester, 4);
    expect(find.byType(WorkflowEditorScreen), findsNothing);
    expect(find.byType(ManageScreen), findsOneWidget);
  });

  testWidgets('the same context again keeps the screen and its tabs', (
    tester,
  ) async {
    final c = await pumpApp(tester);
    await visit(tester, c, Routes.workflow('default'));
    await visit(tester, c, Routes.task('infra', 'infra-1'));

    await activate(
      tester,
      c,
      const ContextRef(connectionId: 's1', tenantKey: 'default'),
    );
    c.invalidate(sessionControllerProvider);
    await tester.pumpAndSettle();

    expect(tenant(c), 'default');
    expect(location(c), Routes.task('infra', 'infra-1'));
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    await openTab(tester, 4);
    expect(find.byType(WorkflowEditorScreen), findsOneWidget);
  });

  testWidgets('a switch closes the sheets and dialogs of the old context', (
    tester,
  ) async {
    final c = await pumpApp(tester);
    await visit(tester, c, Routes.task('infra', 'infra-1'));
    final screen = tester.element(find.byType(TaskDetailScreen));
    showModalBottomSheet<void>(
      context: screen,
      builder: (_) => const Text('old sheet'),
    );
    await tester.pumpAndSettle();
    showDialog<void>(context: screen, builder: (_) => const Text('old dialog'));
    await tester.pumpAndSettle();
    expect(find.text('old sheet'), findsOneWidget);
    expect(find.text('old dialog'), findsOneWidget);

    await activate(tester, c, acme);

    expect(tenant(c), 'acme');
    expect(find.text('old sheet'), findsNothing);
    expect(find.text('old dialog'), findsNothing);
    expect(location(c), Routes.projects);
  });
}
