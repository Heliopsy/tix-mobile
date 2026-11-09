// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/features/quick/application/quick.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/eventually.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  group('completionAt', () {
    test('finds the sigil word under the cursor', () {
      final c = completionAt('Fix #au now', 7)!;
      expect((c.sigil, c.partial, c.start, c.end), ('#', 'au', 4, 7));
      expect(completionAt('Fix @r', 6)!.sigil, '@');
      expect(completionAt('Fix +we', 7)!.partial, 'we');
      expect(completionAt('Fix #', 5)!.partial, '');
    });

    test('a word without a sigil completes nothing', () {
      expect(completionAt('Fix login', 9), isNull);
      expect(completionAt('Fix !high', 9), isNull);
      expect(completionAt('Fix ', 4), isNull);
      expect(completionAt('', 0), isNull);
      expect(completionAt('x', 9), isNull);
    });
  });

  test('rankCompletions puts recent then prefix matches first', () {
    final ranked = rankCompletions(
      ['ui', 'auth', 'audit', 'build'],
      'u',
      names: (t) => [t],
      id: (t) => t,
      recent: ['audit'],
    );
    expect(ranked, ['audit', 'ui', 'auth', 'build']);
  });

  test('RecentValues keeps eight of each, newest first, no blanks', () {
    var r = const RecentValues();
    for (var i = 0; i < 10; i++) {
      r = r.adding(projects: ['p$i'], handles: ['']);
    }
    r = r.adding(projects: ['p3'], tags: ['a', 'b']);
    expect(r.projects.first, 'p3');
    expect(r.projects, hasLength(RecentValues.keep));
    expect(r.handles, isEmpty);
    expect(RecentValues.fromJson(jsonDecode(jsonEncode(r.toJson()))).tags, [
      'a',
      'b',
    ]);
    expect(RecentValues.fromJson('nonsense').projects, isEmpty);
  });

  group('with a server', () {
    late FakeTix server;
    late ProviderContainer c;

    setUp(() async {
      server = FakeTix();
      c = await signedInContainer(server);
    });

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 200));

    ProviderSubscription<Object?> keep(ProviderListenable<Object?> p) {
      final sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      return sub;
    }

    test('the preview waits for typing to pause', () async {
      c = makeContainer([
        ...fakeOverrides(
          server,
          settings: signedInStores().settings,
          secrets: signedInStores().secrets,
        ),
        previewDebounceProvider.overrideWithValue(Duration.zero),
      ]);
      await c.read(sessionControllerProvider.future);
      keep(quickPreviewerProvider);
      c.read(quickPreviewerProvider.notifier)
        ..request('infra', 'F')
        ..request('infra', 'Fi')
        ..request('infra', 'Fix');
      await eventually(
        () => c.read(quickPreviewerProvider).value?.line.title == 'Fix',
      );
      expect(server.previewedLines, ['Fix']);
      expect(c.read(quickPreviewerProvider).value!.line.title, 'Fix');
    });

    test('only the newest answer is kept', () async {
      c = makeContainer([
        ...fakeOverrides(
          server,
          settings: signedInStores().settings,
          secrets: signedInStores().secrets,
        ),
        previewDebounceProvider.overrideWithValue(Duration.zero),
      ]);
      await c.read(sessionControllerProvider.future);
      keep(quickPreviewerProvider);
      final slow = Completer<void>();
      server.previewHolds['old'] = slow;
      final previewer = c.read(quickPreviewerProvider.notifier)
        ..request('infra', 'old');
      await settle();
      previewer.request('infra', 'new');
      await settle();
      slow.complete();
      await settle();
      expect(server.previewedLines, ['old', 'new']);
      expect(c.read(quickPreviewerProvider).value!.line.title, 'new');
    });

    test('a forbidden dry run stops previews in the context', () async {
      c = makeContainer([
        ...fakeOverrides(
          server,
          settings: signedInStores().settings,
          secrets: signedInStores().secrets,
        ),
        previewDebounceProvider.overrideWithValue(Duration.zero),
      ]);
      await c.read(sessionControllerProvider.future);
      keep(quickPreviewerProvider);
      server.importForbidden = true;
      final previewer = c.read(quickPreviewerProvider.notifier)
        ..request('infra', 'one');
      await settle();
      expect(c.read(previewBlockedProvider), isTrue);
      expect(c.read(quickPreviewerProvider).value, isNull);
      previewer.request('infra', 'two');
      await settle();
      expect(server.previewedLines, ['one']);
    });

    test('a failed preview is an error, not a refusal', () async {
      c = makeContainer([
        ...fakeOverrides(
          server,
          settings: signedInStores().settings,
          secrets: signedInStores().secrets,
        ),
        previewDebounceProvider.overrideWithValue(Duration.zero),
      ]);
      await c.read(sessionControllerProvider.future);
      keep(quickPreviewerProvider);
      server.override = FakeResponse(500, envelope('internal', 'boom'));
      c.read(quickPreviewerProvider.notifier).request('infra', 'one');
      await settle();
      expect(c.read(quickPreviewerProvider).hasError, isTrue);
      expect(c.read(previewBlockedProvider), isFalse);
    });

    test('an empty line clears the preview without asking', () async {
      keep(quickPreviewerProvider);
      c.read(quickPreviewerProvider.notifier).request('infra', '  ');
      await settle();
      expect(server.previewedLines, isEmpty);
    });

    test('add creates with parse, remembers and says tasks changed', () async {
      keep(recentQuickValuesProvider);
      keep(quickAdderProvider);
      await c.read(quickActorsProvider.future);
      final before = c.read(tasksChangedProvider);
      final task = await c
          .read(quickAdderProvider.notifier)
          .add('web', 'Ship it !high #release');
      expect(task.ref, 'web-1');
      final sent = server.requestsTo('/api/v1/tasks').single.body;
      expect(sent, {
        'title': 'Ship it !high #release',
        'project_ref': 'web',
        'parse': true,
      });
      expect(c.read(tasksChangedProvider), before + 1);
      expect(c.read(recentQuickValuesProvider).projects, ['web']);
      final store = c.read(keyValueStoreProvider) as MemoryKeyValueStore;
      final stored = store.values.entries
          .where((e) => e.key.startsWith('quick.recent.'))
          .single;
      expect(stored.value, contains('"web"'));
    });

    test('use creates from a template and counts it', () async {
      keep(quickAdderProvider);
      final t = server.addTemplate('weekly', project: 'infra', uses: 1);
      final templates = await c.read(quickTemplatesProvider.future);
      expect(templates.single.name, 'weekly');
      final task = await c
          .read(quickAdderProvider.notifier)
          .use(templates.single);
      expect(task.ref, 'infra-3');
      expect(server.templates[t['id']]!['uses'], 2);
    });

    test('quickTemplates keeps the six most used', () async {
      for (var i = 0; i < 8; i++) {
        server.addTemplate('t$i', uses: i);
      }
      final top = await c.read(quickTemplatesProvider.future);
      expect(top.map((t) => t.name), ['t7', 't6', 't5', 't4', 't3', 't2']);
    });

    test('lookups read projects, tags and actors', () async {
      expect((await c.read(quickProjectsProvider.future)).map((p) => p.key), [
        'infra',
        'web',
      ]);
      expect(await c.read(quickTagsProvider.future), contains('auth'));
      expect(
        (await c.read(quickActorsProvider.future)).map((a) => a.handle),
        contains('raj'),
      );
    });

    test('recent tasks keep the newest first with their titles', () async {
      keep(recentTasksProvider);
      final recent = c.read(recentTasksProvider.notifier);
      await recent.visit('infra-1', 'infra');
      await recent.visit('infra-2', 'infra');
      await recent.visit('infra-1', 'infra');
      expect(c.read(recentTasksProvider).map((t) => (t.ref, t.title)), [
        ('infra-1', 'Fix login'),
        ('infra-2', 'Rotate keys'),
      ]);
      await recent.visit('gone-9', 'gone');
      expect(c.read(recentTasksProvider).first.title, isEmpty);
    });

    test('add another is remembered', () async {
      expect(c.read(addAnotherProvider), isFalse);
      await c.read(addAnotherProvider.notifier).set(on: true);
      expect(c.read(keyValueStoreProvider).read('quick.addAnother'), 'true');
    });
  });
}
