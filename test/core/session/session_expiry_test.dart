// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/offline/connectivity.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/session/signed_out.dart';
import 'package:tix_mobile/src/data/api/credential.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_notes.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

class _Timer implements Timer {
  bool cancelled = false;

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;
}

class _Timers {
  final started = <(_Timer, void Function(Timer))>[];

  Timer start(Duration period, void Function(Timer) tick) {
    final timer = _Timer();
    started.add((timer, tick));
    return timer;
  }

  void fire() {
    for (final (timer, tick) in started) {
      tick(timer);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeTix server;
  late _Timers timers;
  late FakeNotes notes;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  setUp(() {
    server = FakeTix();
    timers = _Timers();
    notes = FakeNotes();
    stores = signInStores(server);
  });

  Future<ProviderContainer> container({
    bool autoSync = true,
    ({MemoryKeyValueStore settings, MemorySecretStore secrets})? using,
  }) async {
    final s = using ?? stores;
    final c = makeContainer([
      ...fakeOverrides(
        server,
        settings: s.settings,
        secrets: s.secrets,
        notes: notes,
        autoSync: autoSync,
      ),
      deviceProbeProvider.overrideWithValue(
        () async => const DeviceConditions(),
      ),
      periodicTimerProvider.overrideWithValue(timers.start),
    ]);
    await c.read(sessionControllerProvider.future);
    c.read(offlineSyncProvider);
    await pumpEventQueue();
    return c;
  }

  int projectReads() => server.requestsTo('/api/v1/projects').length;

  void expectSignedOut(ProviderContainer c) {
    expect(c.read(sessionControllerProvider).value, isNull);
    expect(stores.secrets.values.containsKey('session.s1'), isFalse);
    final kept = c.read(instancesRepositoryProvider).connection('s1');
    expect(kept?.email, 'ana@example.com');
    expect(c.read(instancesRepositoryProvider).instance('i1'), isNotNull);
    expect(c.read(sessionControllerProvider.notifier).awaitingSignIn(), 's1');
  }

  test('an expired session refused by the periodic sync signs out and '
      'stops polling', () async {
    final c = await container();
    expect(projectReads(), greaterThan(0));
    expect(timers.started, hasLength(1));
    server.sessions.clear();

    timers.fire();
    await pumpEventQueue();

    expectSignedOut(c);
    final (first, _) = timers.started.first;
    expect(first.cancelled, isTrue);
    expect(timers.started.where((t) => !t.$1.cancelled), isEmpty);
    expect(notes.shown.single.payload, signedOutNotePayload);
    expect(notes.shown.single.channel, NoteChannel.account);
    expect(notes.shown.single.title, contains('Work'));

    final after = server.requests.length;
    timers.fire();
    await pumpEventQueue();
    expect(server.requests.length, after);
  });

  test('a session refused on a screen signs out and stops polling', () async {
    final c = await container();
    server.sessions.clear();

    await expectLater(
      c.read(tasksRepositoryProvider).allProjects(),
      throwsA(anything),
    );
    await pumpEventQueue();

    expectSignedOut(c);
    expect(timers.started.single.$1.cancelled, isTrue);
  });

  test('no notification shows while notifications are not allowed', () async {
    notes.enabled = false;
    final c = await container();
    server.sessions.clear();
    timers.fire();
    await pumpEventQueue();
    expectSignedOut(c);
    expect(notes.shown, isEmpty);
  });

  test('a 401 the session survives keeps it signed in', () async {
    final c = await container();
    final whoamis = server.requestsTo('/api/v1/whoami').length;
    server.failing['/api/v1/workflows'] = FakeResponse(
      401,
      envelope('unauthenticated', 'incorrect code'),
    );

    await c.read(offlineSyncProvider.notifier).syncNow();
    await pumpEventQueue();

    expect(c.read(sessionControllerProvider).value, isNotNull);
    expect(stores.secrets.values.containsKey('session.s1'), isTrue);
    expect(server.requestsTo('/api/v1/whoami').length, whoamis + 1);
    expect(timers.started.where((t) => !t.$1.cancelled), hasLength(1));
    expect(notes.shown, isEmpty);
  });

  test('many refusals at once check the session once', () async {
    final c = await container();
    server.sessions.clear();
    final whoamis = server.requestsTo('/api/v1/whoami').length;

    await c.read(offlineSyncProvider.notifier).syncNow();
    await pumpEventQueue();

    expectSignedOut(c);
    expect(server.requestsTo('/api/v1/whoami').length, whoamis + 1);
    expect(notes.shown, hasLength(1));
  });

  test('a refused API token is left to the person', () async {
    final tokens = signedInStores(token: 'revoked');
    final c = await container(using: tokens);
    await pumpEventQueue();
    expect(c.read(sessionControllerProvider).value, isNotNull);
    expect(tokens.secrets.values['token.c1'], 'revoked');
    expect(notes.shown, isEmpty);
  });

  test('signing in again keeps the connection and syncs again', () async {
    final c = await container();
    server.sessions.clear();
    timers.fire();
    await pumpEventQueue();
    expectSignedOut(c);

    final session = server.startSession('ana@example.com', 'default');
    final me = await c
        .read(authRepositoryProvider)
        .whoami('https://tix.example', SessionCredential(session));
    await c
        .read(sessionControllerProvider.notifier)
        .saveSignIn(
          baseUrl: 'https://tix.example',
          email: 'ana@example.com',
          session: session,
          me: me,
          pinned: false,
          replacing: 's1',
        );
    c.read(offlineSyncProvider);
    await pumpEventQueue();

    expect(c.read(sessionControllerProvider).value?.connection.id, 's1');
    expect(notes.cancelled, contains(signedOutNoteId));
    final before = projectReads();
    timers.started.last.$2(timers.started.last.$1);
    await pumpEventQueue();
    expect(projectReads(), greaterThan(before));
  });
}
