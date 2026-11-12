// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/platform/app_shortcuts.dart';
import 'package:tix_mobile/src/core/platform/share_intake.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/features/quick/application/quick.dart';
import 'package:tix_mobile/src/features/quick/presentation/quick_actions_host.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

class FakeAppShortcuts implements AppShortcuts {
  List<AppShortcut> items = [];
  void Function(String type)? pick;

  @override
  Future<void> install(
    List<AppShortcut> items,
    void Function(String type) onPick,
  ) async {
    this.items = items;
    pick = onPick;
  }
}

void main() {
  const channel = MethodChannel('tix/share-host-test');
  late FakeTix server;
  late FakeAppShortcuts shortcuts;
  Map<String, String>? pending;

  setUp(() {
    server = FakeTix();
    shortcuts = FakeAppShortcuts();
    pending = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final p = pending;
          pending = null;
          return p;
        });
  });

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  late ProviderContainer container;

  Future<void> pump(WidgetTester tester, {Size size = desktop}) async {
    final stores = signedInStores();
    container = await pumpScreen(
      tester,
      const QuickActionsHost(
        child: TixShortcuts(child: Scaffold(body: Text('home'))),
      ),
      size: size,
      overrides: [
        ...fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        previewDebounceProvider.overrideWithValue(Duration.zero),
        appShortcutsProvider.overrideWithValue(shortcuts),
        shareIntakeProvider.overrideWithValue(ShareIntake(channel)),
      ],
    );
    await tester.pumpAndSettle();
  }

  Finder line() => find.byKey(const Key('quickAdd.line'));

  Future<void> chord(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    bool shift = false,
  }) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(key);
    if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('Ctrl+N opens quick add', (tester) async {
    await pump(tester);
    expect(line(), findsNothing);
    await chord(tester, LogicalKeyboardKey.keyN);
    expect(line(), findsOneWidget);
  });

  testWidgets('a draft from anywhere opens quick add holding it, and a '
      'created task offers Open', (tester) async {
    await pump(tester, size: phone);
    container
        .read(quickAddDraftsProvider.notifier)
        .open(text: 'Renew cert', project: 'web');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(line()).controller!.text, 'Renew cert');
    await tester.tap(find.byKey(const Key('quickAdd.submit')));
    await tester.pumpAndSettle();
    expect(
      server.requestsTo('/api/v1/tasks').single.body['project_ref'],
      'web',
    );
    expect(find.text('Created web-1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toast.action')));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/web/tasks/web-1'), findsOneWidget);
  });

  testWidgets('More details carries the typed line and project into Add '
      'with details, which sends it unparsed', (tester) async {
    await pump(tester, size: phone);
    container
        .read(quickAddDraftsProvider.notifier)
        .open(text: 'Renew cert !high', project: 'web');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quickAdd.details')));
    await tester.pumpAndSettle();
    expect(line(), findsNothing);
    final title = find.byKey(const Key('addDetails.title'));
    expect(
      tester.widget<TextField>(title).controller!.text,
      'Renew cert !high',
    );
    final create = find.byKey(const Key('addDetails.create'));
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/tasks').single.body, {
      'project_ref': 'web',
      'title': 'Renew cert !high',
      'priority': 3,
    });
    expect(find.text('Created web-1'), findsOneWidget);
  });

  testWidgets('the palette opens Add with details', (tester) async {
    await pump(tester);
    await chord(tester, LogicalKeyboardKey.keyK);
    await tester.enterText(
      find.byKey(const Key('palette.query')),
      'add with details',
    );
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('addDetails.title')), findsOneWidget);
    expect(line(), findsNothing);
  });

  testWidgets('a project the loaded list lacks reloads the list and stays '
      'chosen', (tester) async {
    await pump(tester, size: phone);
    expect(await container.read(quickProjectsProvider.future), hasLength(2));
    server.projects.add({
      'id': 'p3',
      'key': 'mobile',
      'name': 'Mobile app',
      'color': 'green',
      'workflow_id': 'wf1',
    });
    container.read(quickAddDraftsProvider.notifier).open(project: 'mobile');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('quickAdd.project')),
        matching: find.text('Mobile app'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a share that started the app opens quick add', (tester) async {
    pending = {'text': 'https://example.com/bug', 'subject': 'Login fails'};
    await pump(tester, size: phone);
    expect(
      tester.widget<TextField>(line()).controller!.text,
      'Login fails https://example.com/bug',
    );
    expect(server.requestsTo('/api/v1/tasks'), isEmpty);
  });

  testWidgets('Ctrl+Shift+V opens quick add with the clipboard', (
    tester,
  ) async {
    await pump(tester);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          ..setMockMethodCallHandler(
            SystemChannels.platform,
            (call) async => call.method == 'Clipboard.getData'
                ? {'text': 'From clipboard'}
                : null,
          );
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await chord(tester, LogicalKeyboardKey.keyV, shift: true);
    expect(tester.widget<TextField>(line()).controller!.text, 'From clipboard');
  });

  testWidgets('launcher shortcuts open quick add and the inbox', (
    tester,
  ) async {
    await pump(tester, size: phone);
    expect(shortcuts.items.map((i) => i.type), [
      AppShortcutTypes.quickAdd,
      AppShortcutTypes.inbox,
      AppShortcutTypes.myWork,
    ]);
    shortcuts.pick!(AppShortcutTypes.quickAdd);
    await tester.pumpAndSettle();
    expect(line(), findsOneWidget);
    await tester.tap(find.byKey(const Key('quickAdd.cancel')));
    await tester.pumpAndSettle();
    shortcuts.pick!(AppShortcutTypes.inbox);
    await tester.pumpAndSettle();
    expect(find.text('route:/inbox'), findsOneWidget);
  });

  testWidgets('the palette finds a project and a task by reference', (
    tester,
  ) async {
    await pump(tester);
    await chord(tester, LogicalKeyboardKey.keyK);
    final palette = find.byKey(const Key('palette'));
    await tester.enterText(find.byKey(const Key('palette.query')), 'infr');
    await tester.pump();
    expect(
      find.descendant(
        of: palette,
        matching: find.byKey(const Key('palette.project.infra')),
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('palette.query')), 'web-12');
    await tester.pump();
    expect(
      find.descendant(of: palette, matching: find.text('Open web-12')),
      findsOneWidget,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/web/tasks/web-12'), findsOneWidget);
  });

  testWidgets('? lists Ctrl N for quick add', (tester) async {
    await pump(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash, character: '?');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pumpAndSettle();
    final help = find.byKey(const Key('shortcuts.help'));
    expect(
      find.descendant(of: help, matching: find.text('Ctrl N')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: help, matching: find.text('Quick add')),
      findsOneWidget,
    );
  });

  test('task references are recognised', () {
    expect(taskRefPattern.hasMatch('web-12'), isTrue);
    expect(taskRefPattern.hasMatch(' ops_x-3 '), isTrue);
    expect(taskRefPattern.hasMatch('web'), isFalse);
    expect(taskRefPattern.hasMatch('12'), isFalse);
  });
}
