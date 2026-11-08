// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/access.dart';
import 'package:tix_mobile/src/data/models/actor.dart';

void main() {
  test('nothing grants nothing', () {
    expect(Access.none.has(Scope.taskRead), isFalse);
  });

  test('a direct scope grants that scope only', () {
    const a = Access(Actor(scopes: ['task:read']));
    expect(a.has(Scope.taskRead), isTrue);
    expect(a.has(Scope.projectRead), isFalse);
  });

  test('* grants everything but global:admin and account:read', () {
    const a = Access(Actor(scopes: ['*']));
    expect(a.has(Scope.workflowWrite), isTrue);
    expect(a.has(Scope.tenantAdmin), isTrue);
    expect(a.hasValue('global:admin'), isFalse);
    expect(a.hasValue('account:read'), isFalse);
  });

  test('global:admin counts only when named', () {
    const a = Access(Actor(scopes: ['global:admin']));
    expect(a.hasValue('global:admin'), isTrue);
  });

  test('a member reads workflows and projects but writes neither', () {
    const a = Access(Actor(role: Role.member));
    expect(a.has(Scope.workflowRead), isTrue);
    expect(a.has(Scope.projectRead), isTrue);
    expect(a.has(Scope.workflowWrite), isFalse);
    expect(a.has(Scope.projectWrite), isFalse);
    expect(a.has(Scope.taskWrite), isTrue);
  });

  test('a viewer only reads', () {
    const a = Access(Actor(role: Role.viewer));
    expect(a.has(Scope.taskRead), isTrue);
    expect(a.has(Scope.taskWrite), isFalse);
  });

  test('an admin role holds every scope', () {
    const a = Access(Actor(role: Role.admin));
    expect(a.has(Scope.userAdmin), isTrue);
    expect(a.hasValue('global:admin'), isFalse);
  });

  test('a role adds to direct scopes', () {
    const a = Access(Actor(role: Role.viewer, scopes: ['project:write']));
    expect(a.has(Scope.projectWrite), isTrue);
    expect(a.has(Scope.projectRead), isTrue);
  });
}
