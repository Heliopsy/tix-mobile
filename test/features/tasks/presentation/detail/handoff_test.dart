// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';

import '../../../../helpers/app.dart';
import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;
  late List<String> copied;

  setUp(() {
    server = FakeTix();
    copied = [];
  });

  void watchClipboard(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
  }

  Finder inBlock(String key, Finder matching) =>
      find.descendant(of: find.byKey(Key(key)), matching: matching);

  for (final MapEntry(key: width, value: size) in {
    'compact': tallPhone,
    'expanded': tallDesktop,
  }.entries) {
    testWidgets('$width: the header hands the task to an agent', (
      tester,
    ) async {
      watchClipboard(tester);
      await pumpTask(tester, server, size: size);
      await press(tester, find.byKey(const Key('task.handoff')));

      expect(find.text('Hand to an agent'), findsOneWidget);
      final prompt = tester
          .widget<SelectableText>(
            inBlock('handoff.prompt', find.byType(SelectableText)),
          )
          .data!;
      expect(prompt, startsWith('Work on tix task INFRA-1 ("Fix login")'));
      expect(prompt, contains('on the tix server at https://tix.example.'));
      expect(prompt, contains('`tix claim task INFRA-1 -o json`'));
      expect(
        inBlock('handoff.command', find.textContaining("claude 'Work on")),
        findsOneWidget,
      );

      await press(
        tester,
        inBlock('handoff.prompt', find.byKey(const Key('handoff.copy'))),
      );
      expect(copied, [prompt]);
      expect(server.requests.where((r) => r.method != 'GET'), isEmpty);
    });
  }

  testWidgets('a client with no command gets the MCP prompt to paste', (
    tester,
  ) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('task.handoff')));
    await press(tester, find.widgetWithText(ChoiceChip, 'Zed'));
    expect(find.byKey(const Key('handoff.command')), findsNothing);
    expect(
      find.textContaining('Zed has no command that starts it'),
      findsOneWidget,
    );
    expect(
      inBlock('handoff.paste', find.textContaining('Use the tix MCP tools.')),
      findsOneWidget,
    );
  });

  testWidgets('the task menu offers it too', (tester) async {
    await pumpTask(tester, server);
    await press(tester, find.byKey(const Key('task.menu')));
    await press(tester, find.byKey(const Key('menu.handoff')));
    expect(find.byKey(const Key('handoff.prompt')), findsOneWidget);
    await press(tester, find.byKey(const Key('handoff.close')));
    expect(find.byKey(const Key('handoff.prompt')), findsNothing);
  });

  testWidgets('the command palette lists it', (tester) async {
    final container = await pumpTask(tester, server, size: tallDesktop);
    final command = container
        .read(commandRegistryProvider)
        .commands
        .singleWhere((c) => c.id == 'taskDetail.handoff');
    expect(command.label, 'Hand to an agent');
    command.run();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('handoff.mcp')), findsOneWidget);
  });

  testWidgets('a task made offline is not handed off', (tester) async {
    final shown = ValueNotifier('infra-1');
    addTearDown(shown.dispose);
    final stores = signedInStores();
    final container = await pumpScreen(
      tester,
      TixShortcuts(
        child: ValueListenableBuilder(
          valueListenable: shown,
          builder: (_, ref, _) =>
              TaskDetailScreen(key: ValueKey(ref), taskRef: ref),
        ),
      ),
      size: tallDesktop,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    expect(find.byKey(const Key('task.handoff')), findsOneWidget);
    server.offline = true;
    final adding = container
        .read(tasksRepositoryProvider)
        .quickAdd('infra', 'Spike the cache');
    await tester.pumpAndSettle();
    final draft = await adding;
    expect(draft.ref, 'infra-draft1');
    shown.value = draft.ref;
    await tester.pumpAndSettle();

    expect(find.text('Spike the cache'), findsOneWidget);
    expect(find.byKey(const Key('task.handoff')), findsNothing);
    expect(
      container
          .read(commandRegistryProvider)
          .commands
          .where((c) => c.id == 'taskDetail.handoff'),
      isEmpty,
    );
    await press(tester, find.byKey(const Key('task.menu')));
    expect(find.byKey(const Key('menu.delete')), findsOneWidget);
    expect(find.byKey(const Key('menu.handoff')), findsNothing);
  });
}
