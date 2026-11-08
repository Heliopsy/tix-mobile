// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/data/models/access.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/features/manage/manage_sections.dart';

void main() {
  ManageEntry entry(String id) => manageSections.singleWhere((e) => e.id == id);

  Access holding(List<String> scopes) => Access(Actor(scopes: scopes));

  test('status, bundles and snapshot import each need their own scope', () {
    expect(entry('server.status').route, Routes.manageStatus);
    expect(entry('tenant.bundles').route, Routes.manageBundles);
    expect(entry('tenant.snapshot').route, Routes.manageSnapshot);
    final viewer = holding(['workflow:read']);
    expect(entry('tenant.bundles').visibleTo(viewer), isTrue);
    expect(entry('server.status').visibleTo(viewer), isFalse);
    expect(entry('tenant.snapshot').visibleTo(viewer), isFalse);
    final admin = holding(['tenant:admin', 'import']);
    expect(entry('server.status').visibleTo(admin), isTrue);
    expect(entry('tenant.snapshot').visibleTo(admin), isTrue);
  });
}
