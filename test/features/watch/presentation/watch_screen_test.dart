// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/data/events/event_stream.dart';
import 'package:tix_mobile/src/features/watch/application/watch.dart';
import 'package:tix_mobile/src/features/watch/presentation/watch_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;

  setUp(() {
    server = FakeTix();
    sockets = FakeEventSockets();
  });

  /// Pumps Watch; with [motion] false, as by default, the platform asks
  /// for reduced motion so the live dot holds still and lists settle.
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    Size size = phone,
    EventSocketConnector? events,
    bool motion = false,
  }) {
    if (!motion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const WatchScreen(),
      size: size,
      settle: !motion,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: events ?? sockets.connect,
      ),
    );
  }

  /// Acknowledges the app's subscription and Watch's tail [id].
  Future<void> live(WidgetTester tester, [String id = 'w1']) async {
    sockets.last
      ..ack('s1')
      ..ack(id);
    await tester.pumpAndSettle();
  }

  void emit(
    int seq,
    String type, {
    String id = 'w1',
    String actor = 'pax',
    Map<String, Object?> payload = const {},
    Map<String, Object?>? via,
    String subjectId = 'id-infra-1',
  }) => sockets.last.event(
    seq,
    type,
    id: id,
    actorId: '01${actor.toUpperCase()}',
    subjectId: subjectId,
    payload: {'actor_handle': actor, ...payload},
    via: via,
  );

  List<String> clipboard(WidgetTester tester) {
    final copied = <String>[];
    final messenger = tester.binding.defaultBinaryMessenger
      ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    return copied;
  }

  const pretty = JsonEncoder.withIndent('  ');

  /// The event object [emit] sends for [seq] and [type], with [payload].
  Map<String, Object?> sent(
    int seq,
    String type, {
    Map<String, Object?> payload = const {},
    Map<String, Object?>? via,
  }) => {
    'seq': seq,
    'type': type,
    'subject_type': type.split('.').first,
    'subject_id': 'id-infra-1',
    'project_id': 'p1',
    'actor_id': '01PAX',
    'payload': {'actor_handle': 'pax', ...payload},
    'via': ?via,
    'occurred_at': '2026-11-08T10:00:00Z',
  };

  Finder inRow(int seq, Finder f) =>
      find.descendant(of: find.byKey(Key('watch.$seq')), matching: f);

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('connecting, then waiting for events', (tester) async {
        await pump(tester, size: size);
        expect(find.byKey(const Key('watch.connecting')), findsOneWidget);
        expect(find.byKey(const Key('watch.empty')), findsNothing);
        await live(tester);
        expect(find.byKey(const Key('watch.connecting')), findsNothing);
        expect(find.byKey(const Key('watch.empty')), findsOneWidget);
      });

      testWidgets('events arrive newest first, one line each', (tester) async {
        await pump(tester, size: size);
        await live(tester);
        emit(41, 'task.created', payload: {'ref': 'infra-1', 'title': 'Fix'});
        emit(
          42,
          'task.transitioned',
          payload: {'ref': 'infra-1', 'from': 'todo', 'to': 'doing'},
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('watch.empty')), findsNothing);
        expect(
          tester.getTopLeft(find.byKey(const Key('watch.42'))).dy,
          lessThan(tester.getTopLeft(find.byKey(const Key('watch.41'))).dy),
        );
        expect(inRow(42, find.text('#000042')), findsOneWidget);
        expect(inRow(42, find.text('@pax')), findsOneWidget);
        expect(inRow(42, find.text('task.transitioned')), findsOneWidget);
        expect(inRow(42, find.text('infra-1')), findsOneWidget);
        expect(
          tester
              .widgetList<StatusPill>(inRow(42, find.byType(StatusPill)))
              .map((p) => p.label),
          ['todo', 'doing'],
        );
        expect(inRow(41, find.text('Fix')), findsOneWidget);
      });

      testWidgets(
        'a server refusal explains the scope and points to Instances',
        (tester) async {
          await pump(tester, size: size, events: refusingEventSocket);
          expect(find.byKey(const Key('watch.refused')), findsOneWidget);
          expect(find.textContaining('event:subscribe'), findsOneWidget);
          expect(find.text('Back'), findsNothing);
          expect(find.byKey(const Key('watch.list')), findsNothing);
          await tester.tap(find.byKey(const Key('watch.refused.instances')));
          await tester.pumpAndSettle();
          expect(find.text('route:/settings/instances'), findsOneWidget);
        },
      );
    });
  }

  testWidgets('a task row opens the task', (tester) async {
    await pump(tester);
    await live(tester);
    emit(5, 'comment.added', payload: {'ref': 'infra-1'});
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.5')));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-1'), findsOneWidget);
  });

  testWidgets('back from the task returns to Watch as it was', (tester) async {
    final container = await pump(tester);
    await live(tester);
    await tester.tap(find.byKey(const Key('watch.type.comment.*')));
    await tester.pumpAndSettle();
    sockets.last.ack('w2');
    emit(5, 'comment.added', id: 'w2', payload: {'ref': 'infra-1'});
    emit(6, 'comment.added', id: 'w2', payload: {'ref': 'infra-1'});
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.5')));
    await tester.pumpAndSettle();
    final task = find.text('route:/projects/infra/tasks/infra-1');
    expect(task, findsOneWidget);
    final router = GoRouter.of(tester.element(task));
    expect(router.canPop(), isTrue);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.list')), findsOneWidget);
    expect(find.byKey(const Key('watch.5')), findsOneWidget);
    expect(find.byKey(const Key('watch.6')), findsOneWidget);
    expect(container.read(watchFilterProvider).types, ['comment.*']);
    expect(find.byKey(const Key('watch.filtering')), findsOneWidget);
    expect(sockets.last.subscribes('w3'), isEmpty);
  });

  testWidgets('a row names the person, the token and the channel', (
    tester,
  ) async {
    server.actors['01PAX'] = {
      'id': '01PAX',
      'handle': 'pax',
      'display_name': 'Pax Ito',
      'kind': 'user',
    };
    await pump(tester);
    await live(tester);
    emit(
      7,
      'task.claimed',
      payload: {'ref': 'infra-1'},
      via: {'kind': 'api', 'token_name': 'deploy-bot'},
    );
    emit(8, 'task.updated', payload: {'ref': 'infra-1'}, via: {'kind': 'web'});
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('watch.7.actor'))).data,
      'Pax Ito',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('watch.7.handle'))).data,
      '@pax',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('watch.7.via'))).data,
      'via API (deploy-bot)',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('watch.8.via'))).data,
      'via web',
    );
    expect(
      tester.widget<TixAvatar>(find.byKey(const Key('watch.7.avatar'))).label,
      'Pax Ito',
    );
  });

  testWidgets('a comment row shows the start of the comment', (tester) async {
    server.comments['infra-1'] = [
      {
        'id': 'c1',
        'task_id': 'id-infra-1',
        'author_actor_id': '01PAX',
        'body': 'Deployed to staging.\n\nLooks fine so far.\nMore later.',
      },
      {
        'id': 'c2',
        'task_id': 'id-infra-1',
        'author_actor_id': 'a1',
        'body': 'Imported note',
      },
    ];
    await pump(tester);
    await live(tester);
    emit(9, 'comment.added', subjectId: 'c1', payload: {'ref': 'infra-1'});
    emit(10, 'comment.added', subjectId: 'c2', payload: {'ref': 'infra-1'});
    await tester.pumpAndSettle();
    Text comment(int seq) => tester.widget<Text>(
      find.descendant(
        of: find.byKey(Key('watch.$seq.comment')),
        matching: find.byType(Text),
      ),
    );
    expect(comment(9).data, 'Deployed to staging.\nLooks fine so far.');
    expect(comment(10).data, 'Raj: Imported note');
  });

  testWidgets('a field change names the fields', (tester) async {
    await pump(tester);
    await live(tester);
    emit(
      11,
      'task.updated',
      payload: {
        'ref': 'infra-1',
        'fields': ['body', 'due_at'],
      },
    );
    await tester.pumpAndSettle();
    expect(
      inRow(11, find.text('changed description, due date')),
      findsOneWidget,
    );
  });

  testWidgets('type badges take the colour of what happened', (tester) async {
    await pump(tester, size: const Size(1280, 2400));
    await live(tester);
    final tones = {
      'task.created': TixTone.ok,
      'comment.added': TixTone.ok,
      'task.updated': TixTone.accent,
      'task.transitioned': TixTone.accent,
      'task.deleted': TixTone.danger,
      'task.lease_expired': TixTone.warn,
      'task.starred': TixTone.neutral,
    };
    var seq = 20;
    for (final type in tones.keys) {
      emit(seq++, type, payload: {'ref': 'infra-1'});
    }
    await tester.pumpAndSettle();
    seq = 20;
    for (final MapEntry(key: type, value: tone) in tones.entries) {
      final at = seq++;
      final badge = tester.widget<TixBadge>(find.byKey(Key('watch.$at.type')));
      expect((badge.label, badge.tone), (type, tone));
    }
  });

  testWidgets('a row says how long ago it happened', (tester) async {
    await pump(tester);
    await live(tester);
    emit(12, 'task.created', payload: {'ref': 'infra-1'});
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('watch.12.meta')),
        matching: find.textContaining(RegExp('ago|just now|In a moment')),
      ),
      findsOneWidget,
    );
  });

  group('the live dot', () {
    double opacity(WidgetTester tester) => tester
        .widget<FadeTransition>(find.byKey(const Key('live.pulse')))
        .opacity
        .value;

    testWidgets('breathes while live', (tester) async {
      await pump(tester, motion: true);
      sockets.last
        ..ack('s1')
        ..ack('w1');
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('live.pulse')), findsOneWidget);
      final first = opacity(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(opacity(tester), isNot(closeTo(first, 0.01)));
    });

    testWidgets('holds still when motion is reduced', (tester) async {
      await pump(tester);
      await live(tester);
      expect(find.byKey(const Key('live.pulse')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(opacity(tester), 1);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  testWidgets('a row with no screen opens its details and payload', (
    tester,
  ) async {
    await pump(tester, size: desktop);
    await live(tester);
    emit(6, 'filter.saved', payload: {'name': 'Mine'});
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.6')));
    await tester.pumpAndSettle();
    final detail = find.byKey(const Key('watch.detail.6'));
    expect(detail, findsOneWidget);
    expect(
      find.descendant(
        of: detail,
        matching: find.textContaining('"name": "Mine"'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('watch.detail.open')), findsNothing);
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: Copy JSON in the details copies the event', (
      tester,
    ) async {
      final copied = clipboard(tester);
      await pump(tester, size: size);
      await live(tester);
      emit(6, 'filter.saved', payload: {'name': 'Mine'}, via: {'kind': 'ssh'});
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('watch.details.6')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('watch.detail.copyJson')));
      await tester.pumpAndSettle();
      expect(copied, [
        pretty.convert(
          sent(
            6,
            'filter.saved',
            payload: {'name': 'Mine'},
            via: {'kind': 'ssh'},
          ),
        ),
      ]);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('JSON copied.'),
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('a long press on a row copies its JSON', (tester) async {
    final copied = clipboard(tester);
    await pump(tester);
    await live(tester);
    emit(7, 'task.created', payload: {'ref': 'infra-1'});
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const Key('watch.7')));
    await tester.pumpAndSettle();
    expect(copied, [
      pretty.convert(sent(7, 'task.created', payload: {'ref': 'infra-1'})),
    ]);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('JSON copied.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('pausing holds new events and counts them', (tester) async {
    await pump(tester);
    await live(tester);
    emit(1, 'task.created');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.pause')));
    await tester.pumpAndSettle();
    emit(2, 'task.updated');
    emit(3, 'task.updated');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.2')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('watch.paused')),
        matching: find.text('Paused, 2 new events.'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('watch.resume')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.paused')), findsNothing);
    expect(find.byKey(const Key('watch.3')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('watch.3'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('watch.1'))).dy),
    );
  });

  testWidgets('keeps the latest 500 events', (tester) async {
    final container = await pump(tester);
    await live(tester);
    for (var i = 1; i <= watchCap + 5; i++) {
      emit(i, 'task.updated');
    }
    await tester.pumpAndSettle();
    final events = container.read(watchFeedProvider).events;
    expect(events, hasLength(watchCap));
    expect(events.first.seq, watchCap + 5);
    expect(events.last.seq, 6);
  });

  testWidgets('the actor filter is applied here, without resubscribing', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    emit(1, 'task.created');
    emit(2, 'task.created', actor: 'ana');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('watch.filters')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('watch.actors')), '@ana');
    await tester.tap(find.byKey(const Key('watch.apply')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.1')), findsNothing);
    expect(find.byKey(const Key('watch.2')), findsOneWidget);
    expect(sockets.last.subscribes('w2'), isEmpty);
    expect(sockets.sockets, hasLength(1));
  });

  testWidgets('a type prefix goes to the server as a new subscription', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    await tester.tap(find.byKey(const Key('watch.type.task.*')));
    await tester.pumpAndSettle();
    final sub = sockets.last.subscribes('w2').single;
    expect(sub['filter'], {
      'types': ['task.*'],
    });
    expect(
      sockets.last.sent,
      contains(equals({'type': 'unsubscribe', 'id': 'w1'})),
    );
    expect(sockets.sockets, hasLength(1));
    expect(find.byKey(const Key('watch.filtering')), findsOneWidget);
  });

  testWidgets('a refused filter says why and keeps the connection', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    sockets.last.push({
      'type': 'error',
      'id': 'w1',
      'error': {'code': 'forbidden', 'message': 'not your project'},
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.refused')), findsOneWidget);
    expect(find.textContaining('not your project'), findsOneWidget);
  });

  testWidgets('an invalid filter is shown above the list with a way out', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    sockets.last.push({
      'type': 'error',
      'id': 'w1',
      'error': {'code': 'invalid', 'message': 'unknown event type bogus'},
    });
    await tester.pumpAndSettle();
    final notice = find.byKey(const Key('watch.filterRefused'));
    expect(notice, findsOneWidget);
    expect(
      find.descendant(
        of: notice,
        matching: find.text('unknown event type bogus'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('watch.refused')), findsNothing);
  });

  testWidgets('replay sends the cursor and says when it expired', (
    tester,
  ) async {
    await pump(tester);
    await live(tester);
    await tester.tap(find.byKey(const Key('watch.filters')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('watch.since')), '3');
    await tester.tap(find.byKey(const Key('watch.apply')));
    await tester.pumpAndSettle();
    expect(sockets.last.subscribes('w2').single['since_seq'], 3);
    sockets.last.push({
      'type': 'error',
      'id': 'w2',
      'error': {
        'code': 'invalid',
        'message':
            'cursor 3 is no longer available; the oldest retained event is 40',
      },
    });
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('watch.expired')),
        matching: find.textContaining('Events after #3'),
      ),
      findsOneWidget,
    );
    expect(sockets.last.subscribes('w2'), hasLength(2));
    sockets.last.ack('w2');
    emit(41, 'task.created', id: 'w2');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('watch.41')), findsOneWidget);
  });
}
