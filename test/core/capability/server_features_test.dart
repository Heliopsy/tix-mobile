// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/capability/server_features.dart';

void main() {
  test('tenant icons start at their release', () {
    final (major, minor, patch) = tenantIconsSince;
    expect(supportsTenantIcons('v$major.$minor.$patch'), isTrue);
    expect(supportsTenantIcons('$major.$minor.${patch + 1}'), isTrue);
    expect(supportsTenantIcons('v$major.${minor + 1}.0-rc.1'), isTrue);
    expect(supportsTenantIcons('v1.0.0'), isTrue);
    expect(supportsTenantIcons('v0.60.0'), isFalse);
    expect(supportsTenantIcons('v0.9.9'), isFalse);
  });

  test('a version the app cannot read is taken to have them', () {
    expect(supportsTenantIcons('dev'), isTrue);
    expect(supportsTenantIcons(''), isTrue);
  });
}
