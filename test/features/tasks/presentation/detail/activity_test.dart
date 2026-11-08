// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';

import '../../../../helpers/attachments.dart';
import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Map<String, Object?> comment(String id, String body, {String by = 'a1'}) => {
    'id': id,
    'task_id': 'id-infra-1',
    'author_actor_id': by,
    'body': body,
    'created_at': '2026-10-30T09:00:00Z',
    'updated_at': '2026-10-30T09:00:00Z',
  };

  Future<void> tab(WidgetTester tester, String name) => press(
    tester,
    find.descendant(
      of: find.byKey(const Key('activity.tabs')),
      matching: find.textContaining(name),
    ),
  );

  group('comments', () {
    testWidgets('are listed with author and Markdown, counted on the tab', (
      tester,
    ) async {
      server.comments['infra-1'] = [comment('c1', 'First **one**')];
      await pumpTask(tester, server);
      expect(
        find.descendant(
          of: find.byKey(const Key('activity.tabs')),
          matching: find.text('Comments 1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('comment.c1')),
          matching: find.text('Raj'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('comment.c1')),
          matching: find.textContaining('First one', findRichText: true),
        ),
        findsWidgets,
      );
    });

    testWidgets('none says so', (tester) async {
      await pumpTask(tester, server);
      expect(find.text('No comments yet.'), findsOneWidget);
    });

    testWidgets('a failed list offers a retry', (tester) async {
      server.failures['GET /api/v1/tasks/infra-1/comments'] = FakeResponse(
        500,
        envelope('internal', 'boom'),
      );
      await pumpTask(tester, server);
      expect(find.text('Retry'), findsOneWidget);
      server.failures.clear();
      await press(tester, find.text('Retry'));
      expect(find.text('No comments yet.'), findsOneWidget);
    });

    testWidgets('the button adds one and clears the box', (tester) async {
      await pumpTask(tester, server);
      final send = find.byKey(const Key('comment.send'));
      await tester.enterText(find.byKey(const Key('comment.field')), 'Done');
      await press(tester, send);
      expect(bodies(server, 'POST', '/tasks/infra-1/comments'), [
        {'body': 'Done'},
      ]);
      expect(find.text('No comments yet.'), findsNothing);
      final field = tester.widget<TextField>(
        find.byKey(const Key('comment.field')),
      );
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('Ctrl+Enter sends', (tester) async {
      await pumpTask(tester, server, size: tallDesktop);
      await tester.enterText(find.byKey(const Key('comment.field')), 'Quick');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(bodies(server, 'POST', '/tasks/infra-1/comments'), [
        {'body': 'Quick'},
      ]);
    });

    testWidgets('an empty box cannot be sent', (tester) async {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('comment.send')));
      expect(count(server, 'POST', '/tasks/infra-1/comments'), 0);
    });

    testWidgets('@ offers handles and completes one', (tester) async {
      await pumpTask(tester, server);
      final field = find.byKey(const Key('comment.field'));
      await tester.enterText(field, 'ask @ra');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mention.ana')), findsNothing);
      await press(tester, find.byKey(const Key('mention.raj')));
      expect(tester.widget<TextField>(field).controller!.text, 'ask @raj ');
      expect(find.byKey(const Key('mention.raj')), findsNothing);
    });

    testWidgets('are edited', (tester) async {
      server.comments['infra-1'] = [comment('c1', 'Old', by: 'me')];
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('comment.menu.c1')));
      await press(tester, find.byKey(const Key('comment.edit')));
      await tester.enterText(find.byKey(const Key('mention.field')), 'New');
      await press(tester, find.byKey(const Key('text.save')));
      expect(bodies(server, 'PATCH', '/comments/c1'), [
        {'body': 'New'},
      ]);
      expect(
        find.descendant(
          of: find.byKey(const Key('comment.c1')),
          matching: find.textContaining('New', findRichText: true),
        ),
        findsWidgets,
      );
    });

    testWidgets('are deleted only after confirming', (tester) async {
      server.comments['infra-1'] = [comment('c1', 'Gone soon', by: 'me')];
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('comment.menu.c1')));
      await press(tester, find.byKey(const Key('comment.delete')));
      await press(tester, find.text('Cancel').last);
      expect(count(server, 'DELETE', '/comments/c1'), 0);
      expect(find.byKey(const Key('comment.c1')), findsOneWidget);
      await press(tester, find.byKey(const Key('comment.menu.c1')));
      await press(tester, find.byKey(const Key('comment.delete')));
      await press(tester, find.byKey(const Key('confirm.ok')));
      expect(count(server, 'DELETE', '/comments/c1'), 1);
      expect(find.byKey(const Key('comment.c1')), findsNothing);
    });
  });

  group('history', () {
    setUp(() {
      server.audit['infra-1'] = [
        {
          'seq': 3,
          'action': 'task.update',
          'actor_id': 'a1',
          'before': {'priority': 3, 'version': 2},
          'after': {'priority': 2, 'version': 3},
          'occurred_at': '2026-10-31T10:00:00Z',
          'via': {'kind': 'web'},
        },
        {
          'seq': 2,
          'action': 'task.transition',
          'actor_id': 'a1',
          'before': {'status': 'todo'},
          'after': {'status': 'doing'},
          'occurred_at': '2026-10-30T10:00:00Z',
          'source': 'cli',
        },
        {
          'seq': 1,
          'action': 'task.create',
          'actor_id': '',
          'occurred_at': '2026-10-29T10:00:00Z',
        },
      ];
    });

    testWidgets('names who changed what, through which channel', (
      tester,
    ) async {
      await pumpTask(tester, server);
      await tab(tester, 'History');
      expect(
        find.textContaining('Raj changed priority', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Raj moved it from todo to doing',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.textContaining('· web'), findsOneWidget);
      expect(find.textContaining('· cli'), findsOneWidget);
      expect(
        find.textContaining('tix created the task', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('pages with Show older', (tester) async {
      server.pageSize = 2;
      await pumpTask(tester, server);
      await tab(tester, 'History');
      expect(
        find.textContaining('created the task', findRichText: true),
        findsNothing,
      );
      await press(tester, find.byKey(const Key('history.more')));
      expect(
        find.textContaining('created the task', findRichText: true),
        findsOneWidget,
      );
      expect(find.byKey(const Key('history.more')), findsNothing);
      expect(
        server.requestsTo('/tasks/infra-1/audit').last.uri.query,
        contains('cursor=2'),
      );
    });

    testWidgets('a credential without the audit scope is told so', (
      tester,
    ) async {
      server.failures['GET /api/v1/tasks/infra-1/audit'] = FakeResponse(
        403,
        envelope('forbidden', 'audit:read'),
      );
      await pumpTask(tester, server);
      await tab(tester, 'History');
      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('created the task'), findsNothing);
    });
  });

  group('artifacts', () {
    testWidgets('attaching a file sends it as a file artifact', (tester) async {
      final files = FakeAttachments(
        picked: PickedFile(
          name: 'log.txt',
          bytes: Uint8List.fromList(utf8.encode('hello')),
          mimeType: 'text/plain',
        ),
      );
      await pumpTask(tester, server, files: files);
      await tab(tester, 'Artifacts');
      expect(find.text('No artifacts.'), findsOneWidget);
      expect(find.byKey(const Key('artifact.photo')), findsNothing);
      await press(tester, find.byKey(const Key('artifact.file')));
      expect(bodies(server, 'PUT', '/tasks/infra-1/artifacts'), [
        {
          'kind': 'file',
          'name': 'log.txt',
          'content_type': 'text/plain',
          'blob': base64Encode(utf8.encode('hello')),
        },
      ]);
      expect(find.text('log.txt'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('activity.tabs')),
          matching: find.text('Artifacts 1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a file over 1 MiB is refused before it is sent', (
      tester,
    ) async {
      final files = FakeAttachments(
        picked: PickedFile(
          name: 'big.bin',
          bytes: Uint8List(1024 * 1024 + 1),
          mimeType: 'application/octet-stream',
        ),
      );
      await pumpTask(tester, server, files: files);
      await tab(tester, 'Artifacts');
      await press(tester, find.byKey(const Key('artifact.file')));
      expect(files.picks, 1);
      expect(count(server, 'PUT', '/tasks/infra-1/artifacts'), 0);
      expect(toast('Files over 1 MiB cannot be attached.'), findsOneWidget);
    });

    testWidgets('a cancelled picker sends nothing', (tester) async {
      final files = FakeAttachments();
      await pumpTask(tester, server, files: files);
      await tab(tester, 'Artifacts');
      await press(tester, find.byKey(const Key('artifact.file')));
      expect(files.picks, 1);
      expect(count(server, 'PUT', '/tasks/infra-1/artifacts'), 0);
    });

    testWidgets('a camera adds Take photo', (tester) async {
      final files = FakeAttachments(
        hasCamera: true,
        photo: PickedFile(
          name: 'shot.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
          mimeType: 'image/jpeg',
        ),
      );
      await pumpTask(tester, server, files: files);
      await tab(tester, 'Artifacts');
      await press(tester, find.byKey(const Key('artifact.photo')));
      expect(files.photos, 1);
      expect(
        bodies(server, 'PUT', '/tasks/infra-1/artifacts').single['name'],
        'shot.jpg',
      );
    });

    testWidgets('an artifact with content is saved', (tester) async {
      server.artifacts['infra-1'] = [
        {
          'id': 'a9',
          'kind': 'file',
          'name': 'out.txt',
          'content_type': 'text/plain',
          'blob': base64Encode(utf8.encode('hi')),
        },
      ];
      final files = FakeAttachments();
      await pumpTask(tester, server, files: files);
      await tab(tester, 'Artifacts');
      await press(tester, find.byKey(const Key('artifact.a9')));
      expect(files.saved.single.name, 'out.txt');
      expect(utf8.decode(files.saved.single.bytes), 'hi');
      expect(files.saved.single.mimeType, 'text/plain');
    });

    testWidgets('an artifact with a payload shows it', (tester) async {
      server.artifacts['infra-1'] = [
        {
          'id': 'a8',
          'kind': 'result',
          'name': 'summary',
          'payload': {'ok': true},
        },
      ];
      final files = FakeAttachments();
      await pumpTask(tester, server, files: files);
      await tab(tester, 'Artifacts');
      await press(tester, find.byKey(const Key('artifact.a8')));
      expect(find.textContaining('"ok": true'), findsOneWidget);
      expect(files.saved, isEmpty);
      await press(tester, find.text('Close'));
      expect(find.textContaining('"ok": true'), findsNothing);
    });
  });
}
