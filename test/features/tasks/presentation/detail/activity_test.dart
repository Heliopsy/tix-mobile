// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
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

  group('comment channel', () {
    testWidgets('names the token a comment came through', (tester) async {
      server.comments['infra-1'] = [
        comment('c1', 'From CI'),
        comment('c2', 'By hand'),
      ];
      server.audit['infra-1'] = [
        {
          'seq': 9,
          'action': 'comment.add',
          'actor_id': 'a1',
          'subject_type': 'comment',
          'subject_id': 'c1',
          'via': {'kind': 'api', 'token_name': 'ci-agent', 'token_id': 't1'},
        },
        {
          'seq': 8,
          'action': 'task.update',
          'actor_id': 'a1',
          'subject_type': 'task',
          'subject_id': 'c2',
          'via': {'kind': 'web'},
        },
      ];
      await pumpTask(tester, server);
      expect(
        tester.widget<Text>(find.byKey(const Key('comment.via.c1'))).data,
        'via token ci-agent',
      );
      expect(find.textContaining('t1'), findsNothing);
      expect(find.byKey(const Key('comment.via.c2')), findsNothing);
      expect(
        server.requestsTo('/api/v1/tasks/infra-1/audit').last.uri.query,
        contains('action=comment.add'),
      );
    });

    testWidgets('a refused audit log leaves comments without one', (
      tester,
    ) async {
      server.comments['infra-1'] = [comment('c1', 'Hi')];
      server.failures['GET /api/v1/tasks/infra-1/audit'] = FakeResponse(
        403,
        envelope('forbidden', 'audit:read'),
      );
      await pumpTask(tester, server);
      expect(find.byKey(const Key('comment.c1')), findsOneWidget);
      expect(find.byKey(const Key('comment.via.c1')), findsNothing);
    });
  });

  group('reactions', () {
    Map<String, Object?> reacted(String id) => {
      ...comment(id, 'Ship it'),
      'reactions': [
        {
          'emoji': '👍',
          'count': 2,
          'actor_ids': ['a1', 'me'],
        },
        {
          'emoji': '🚀',
          'count': 1,
          'actor_ids': ['a1'],
        },
      ],
    };

    ReactionChip chip(WidgetTester tester, String key) =>
        tester.widget<ReactionChip>(find.byKey(Key(key)));

    List<Map<String, Object?>> reactionsOf(String id) => [
      for (final r
          in (server.comments['infra-1']!.firstWhere(
                    (c) => c['id'] == id,
                  )['reactions']
                  as List?) ??
              const [])
        r as Map<String, Object?>,
    ];

    testWidgets('show each emoji with its count, mine marked', (tester) async {
      server.comments['infra-1'] = [reacted('c1')];
      await pumpTask(tester, server);
      final up = chip(tester, 'reaction.c1.👍');
      expect((up.count, up.mine), (2, true));
      final rocket = chip(tester, 'reaction.c1.🚀');
      expect((rocket.count, rocket.mine), (1, false));
    });

    testWidgets('a tap on mine takes it off, on another adds it', (
      tester,
    ) async {
      server.comments['infra-1'] = [reacted('c1')];
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('reaction.c1.👍')));
      expect(chip(tester, 'reaction.c1.👍').count, 1);
      expect(chip(tester, 'reaction.c1.👍').mine, isFalse);
      await press(tester, find.byKey(const Key('reaction.c1.🚀')));
      expect(chip(tester, 'reaction.c1.🚀').mine, isTrue);
      expect(reactionsOf('c1').map((r) => r['count']), [1, 2]);
      expect(
        [
          for (final r in server.requests)
            if (r.path.contains('/reactions/')) r.method,
        ],
        ['DELETE', 'PUT'],
      );
    });

    testWidgets('the picker adds a new one', (tester) async {
      server.comments['infra-1'] = [comment('c1', 'Plain')];
      await pumpTask(tester, server);
      expect(find.byKey(const Key('reaction.c1.🎉')), findsNothing);
      await press(tester, find.byKey(const Key('reaction.add.c1')));
      for (final e in ['👍', '👎', '❤️', '🎉', '😄', '😕', '👀', '🚀']) {
        expect(find.byKey(Key('reaction.pick.$e')), findsOneWidget);
      }
      await press(tester, find.byKey(const Key('reaction.pick.🎉')));
      expect(chip(tester, 'reaction.c1.🎉').mine, isTrue);
      expect(reactionsOf('c1').single['emoji'], '🎉');
    });

    testWidgets('a long press says who reacted', (tester) async {
      server.comments['infra-1'] = [reacted('c1')];
      await pumpTask(tester, server);
      await tester.longPress(find.byKey(const Key('reaction.c1.🚀')));
      await tester.pumpAndSettle();
      expect(find.text('Reacted with 🚀'), findsOneWidget);
      expect(find.text('Raj'), findsWidgets);
    });

    testWidgets('a server without reactions hides the add button on 404', (
      tester,
    ) async {
      server
        ..comments['infra-1'] = [comment('c1', 'Old server')]
        ..reactionsMissing = true;
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('reaction.add.c1')));
      await press(tester, find.byKey(const Key('reaction.pick.👍')));
      expect(find.byKey(const Key('reaction.add.c1')), findsNothing);
      expect(find.byKey(const Key('comment.c1')), findsOneWidget);
    });

    testWidgets('a comment still in the outbox offers none', (tester) async {
      server.comments['infra-1'] = [
        {...comment('c1', 'Queued'), 'task_id': ''},
      ];
      await pumpTask(tester, server);
      expect(find.byKey(const Key('reaction.add.c1')), findsNothing);
    });
  });

  group('history', () {
    String? meta(WidgetTester tester, int seq) =>
        tester.widget<Text>(find.byKey(Key('history.$seq.meta'))).data;

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
      expect(meta(tester, 3), endsWith(' · via web'));
      expect(meta(tester, 2), endsWith(' · cli'));
      expect(
        find.textContaining('tix created the task', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('names the API token a change was made with', (tester) async {
      server.audit['infra-1'] = [
        {
          'seq': 5,
          'action': 'task.update',
          'actor_id': 'a1',
          'before': {'priority': 3},
          'after': {'priority': 2},
          'occurred_at': '2026-10-31T10:00:00Z',
          'via': {'kind': 'api', 'token_id': 't9', 'token_name': 'ci-runner'},
        },
        {
          'seq': 4,
          'action': 'task.update',
          'actor_id': 'a1',
          'before': {'priority': 2},
          'after': {'priority': 1},
          'occurred_at': '2026-10-31T11:00:00Z',
          'via': {'kind': 'mcp', 'token_name': 'claude'},
        },
      ];
      await pumpTask(tester, server);
      await tab(tester, 'History');
      expect(meta(tester, 5), endsWith(' · via token ci-runner'));
      expect(meta(tester, 4), endsWith(' · via MCP (token claude)'));
      expect(
        find.textContaining('Raj changed priority', findRichText: true),
        findsNWidgets(2),
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
