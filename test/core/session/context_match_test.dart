// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/context_match.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/models/membership.dart';

void main() {
  final at = DateTime.utc(2026, 11);
  final work = Instance(
    id: 'i1',
    name: 'Work',
    kind: InstanceKind.remote,
    createdAt: at,
    baseUrl: 'https://tix.example',
  );
  final home = Instance(
    id: 'i2',
    name: 'Home',
    kind: InstanceKind.remote,
    createdAt: at,
    baseUrl: 'https://home.example',
  );
  final signIn = Connection(
    id: 's1',
    instanceId: 'i1',
    kind: ConnectionKind.signIn,
    createdAt: at,
    tenantKey: 'acme',
    tenantName: 'Acme',
    pinned: false,
    memberships: const [
      Membership(tenantKey: 'acme', tenantName: 'Acme'),
      Membership(tenantKey: 'ops', tenantName: 'Operations'),
    ],
  );
  final token = Connection(
    id: 't1',
    instanceId: 'i2',
    kind: ConnectionKind.token,
    createdAt: at,
    tenantKey: 'acme',
    tenantName: 'Acme',
  );
  final entries = [...entriesOf(work, signIn), ...entriesOf(home, token)];
  const inAcme = ContextRef(connectionId: 's1', tenantKey: 'acme');

  test('keys and labels name a connection and its tenant', () {
    expect(entries.map(contextKey), ['s1.acme', 's1.ops', 't1.acme']);
    expect(entries.map(contextLabel), [
      'Work · Acme',
      'Work · Operations',
      'Home · Acme',
    ]);
  });

  test('a key or a connection id is matched before any name', () {
    expect(contextsNamed('s1.ops', entries).map(contextKey), ['s1.ops']);
    expect(contextsNamed('T1', entries).map(contextKey), ['t1.acme']);
    expect(contextsNamed('s1', entries).map(contextKey), ['s1.acme', 's1.ops']);
  });

  test('names match instances, tenants and both, ignoring case', () {
    expect(contextsNamed('home', entries).map(contextKey), ['t1.acme']);
    expect(contextsNamed('Operations', entries).map(contextKey), ['s1.ops']);
    expect(contextsNamed('work/ops', entries).map(contextKey), ['s1.ops']);
    expect(contextsNamed('acme', entries).map(contextKey), [
      's1.acme',
      't1.acme',
    ]);
    expect(contextsNamed('  ', entries), isEmpty);
    expect(contextsNamed('nowhere', entries), isEmpty);
  });

  test('an unknown name is unknown', () {
    expect(
      matchContext('nowhere', entries, inAcme).kind,
      ContextMatchKind.unknown,
    );
  });

  test('naming the active context stays, even among others', () {
    expect(
      matchContext('s1.acme', entries, inAcme).kind,
      ContextMatchKind.stay,
    );
    expect(matchContext('acme', entries, inAcme).kind, ContextMatchKind.stay);
  });

  test('one other context is switched to', () {
    final m = matchContext('home', entries, inAcme);
    expect(m.kind, ContextMatchKind.switchTo);
    expect(
      m.choices.single.ref,
      const ContextRef(connectionId: 't1', tenantKey: 'acme'),
    );
  });

  test('a name fitting several other contexts asks', () {
    const inOps = ContextRef(connectionId: 's1', tenantKey: 'ops');
    final m = matchContext('acme', entries, inOps);
    expect(m.kind, ContextMatchKind.ambiguous);
    expect(m.choices.map(contextKey), ['s1.acme', 't1.acme']);
  });

  test('with no active context any match switches or asks', () {
    expect(matchContext('home', entries, null).kind, ContextMatchKind.switchTo);
    expect(
      matchContext('acme', entries, null).kind,
      ContextMatchKind.ambiguous,
    );
  });

  test('a pinned connection is active whatever tenant the ref names', () {
    final e = entriesOf(home, token).single;
    expect(isActiveContext(e, const ContextRef(connectionId: 't1')), isTrue);
    expect(isActiveContext(e, inAcme), isFalse);
    expect(isActiveContext(e, null), isFalse);
  });
}
