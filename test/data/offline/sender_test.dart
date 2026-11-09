// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/credential.dart';
import 'package:tix_mobile/src/data/offline/outbox_entry.dart';
import 'package:tix_mobile/src/data/offline/sender.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late ApiOutboxSender sender;
  final since = DateTime.utc(2026, 11, 9, 8);

  Map<String, Object?> task(String ref, String title, {DateTime? at}) => {
    'id': 'id-$ref',
    'ref': ref,
    'title': title,
    'project_id': 'id-infra',
    'created_at': (at ?? since.add(const Duration(minutes: 1)))
        .toIso8601String(),
  };

  setUp(() {
    server = FakeTix();
    sender = ApiOutboxSender(
      server.factory('https://tix.example', const BearerCredential('tok')),
    );
  });

  void listTasks(List<List<Map<String, Object?>>> pages) {
    server.routes.add((o, path, caller) {
      if (o.method != 'GET' || path != '/api/v1/tasks') return null;
      final n = int.tryParse('${o.queryParameters['cursor'] ?? 0}') ?? 0;
      return FakeResponse(200, {
        'items': pages[n],
        'next_cursor': n + 1 < pages.length ? '${n + 1}' : '',
      });
    });
  }

  const line = {'title': 'Call Bob re invoice', 'project_ref': 'infra'};

  test('only an exact title is adopted; a prefix is only similar', () async {
    listTasks([
      [task('infra-1', 'Call Bob'), task('infra-2', 'Call  Bob re invoice ')],
    ]);
    final found = await sender.findCreated(line, since);
    expect(found.exact.map((t) => t.ref), ['infra-2']);
    expect(found.similar, 1);
    expect(found.certain, isNull, reason: 'something similar makes it ask');
  });

  test('a prefix alone is never certain, and not none either', () async {
    listTasks([
      [task('infra-1', 'Call Bob')],
    ]);
    final found = await sender.findCreated(line, since);
    expect((found.certain, found.none), (null, false));
  });

  test('pages past the first until tasks are older than the write', () async {
    listTasks([
      [for (var i = 0; i < 3; i++) task('infra-1$i', 'Other $i')],
      [task('infra-9', 'Call Bob re invoice')],
      [
        task(
          'infra-0',
          'Call Bob re invoice',
          at: since.subtract(const Duration(days: 1)),
        ),
      ],
    ]);
    final found = await sender.findCreated(line, since);
    expect(found.certain?.ref, 'infra-9');
    expect(server.requestsTo('/api/v1/tasks'), hasLength(3));
  });

  test('a comment is found by its exact body and author', () async {
    server.routes.add((o, path, caller) {
      if (path != '/api/v1/tasks/infra-1/comments') return null;
      final lines = [
        {
          'id': 'c1',
          'author_actor_id': 'someone',
          'body': 'Before Friday',
          'created_at': since.add(const Duration(minutes: 1)).toIso8601String(),
        },
        {
          'id': 'c2',
          'author_actor_id': 'me',
          'body': 'Before Friday, please',
          'created_at': since.add(const Duration(minutes: 1)).toIso8601String(),
        },
      ].map(jsonEncode).join('\n');
      return FakeResponse(200, lines, 'application/x-ndjson');
    });
    expect(
      await sender.findComment('infra-1', 'Before Friday', since),
      isFalse,
    );
    expect(
      await sender.findComment('infra-1', ' Before  Friday, please', since),
      isTrue,
    );
  });

  test('a project star is put and taken off under the write key', () async {
    server.keepsProjectStars = true;
    await sender.send(OutboxOp.projectStar, 'infra', const {}, key: 'k1');
    var sent = server.requests.last;
    expect(
      (sent.method, sent.uri.path),
      ('PUT', '/api/v1/projects/infra/star'),
    );
    expect(sent.headers['Idempotency-Key'], 'k1');
    expect(server.projectStars, ['infra']);
    await sender.send(OutboxOp.projectUnstar, 'infra', const {}, key: 'k2');
    sent = server.requests.last;
    expect(sent.method, 'DELETE');
    expect(server.projectStars, isEmpty);
  });
}
