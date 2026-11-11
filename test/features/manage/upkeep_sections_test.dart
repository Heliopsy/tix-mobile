// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/data/models/access.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/features/manage/manage_sections.dart';

void main() {
  Set<String> visible(Actor actor) => {
    for (final e in manageSections)
      if (e.visibleTo(Access(actor))) e.route,
  };

  const upkeep = {
    Routes.webhooks,
    Routes.sync,
    Routes.retention,
    Routes.housekeeping,
    Routes.trash,
    Routes.audit,
  };

  test('a tenant admin sees every integration and upkeep screen', () {
    expect(visible(const Actor(role: Role.admin)), containsAll(upkeep));
  });

  test('a member sees only the audit log of them', () {
    expect(visible(const Actor(role: Role.member)).intersection(upkeep), {
      Routes.audit,
    });
  });

  test('a token with webhook:admin alone sees webhooks only', () {
    final routes = visible(const Actor(scopes: ['webhook:admin']));
    expect(routes.intersection(upkeep), {Routes.webhooks});
  });

  test('Activity is a destination of its own, not listed under Manage', () {
    final all = Actor(scopes: [for (final s in Scope.values) s.value]);
    expect(visible(all), isNot(contains(Routes.activity)));
    expect(visible(all), isNot(contains('/manage/watch')));
    expect(manageSections.map((e) => e.id), isNot(contains('tenant.watch')));
  });

  test('they sit in the Tenant group', () {
    for (final e in manageSections) {
      if (upkeep.contains(e.route)) {
        expect(e.group, ManageGroup.tenant, reason: e.id);
      }
    }
  });
}
