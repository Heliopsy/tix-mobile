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

  const tenantRoutes = {
    Routes.manageTenant,
    Routes.manageDomains,
    Routes.manageServer,
  };
  const serverRoutes = {Routes.manageTenants, Routes.manageGlobalAdmins};

  test('a tenant admin sees the tenant screens, not the server ones', () {
    final routes = visible(const Actor(role: Role.admin));
    expect(routes, containsAll(tenantRoutes));
    expect(routes.intersection(serverRoutes), isEmpty);
  });

  test('a member sees neither', () {
    final routes = visible(const Actor(role: Role.member));
    expect(routes.intersection({...tenantRoutes, ...serverRoutes}), isEmpty);
  });

  test('a global admin sees the server screens', () {
    final routes = visible(const Actor(role: Role.admin, globalAdmin: true));
    expect(routes, containsAll({...tenantRoutes, ...serverRoutes}));
  });

  test('the server screens sit in the Server group', () {
    for (final e in manageSections) {
      if (serverRoutes.contains(e.route)) {
        expect(e.group, ManageGroup.server, reason: e.id);
      }
      if (tenantRoutes.contains(e.route)) {
        expect(e.group, ManageGroup.tenant, reason: e.id);
      }
    }
  });
}
