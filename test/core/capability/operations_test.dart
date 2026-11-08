// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/capability/registry.dart';

import '../../../tool/parity.dart';

/// Holds the app to the whole tix API: every operation in the vendored spec
/// is bound in registry.dart, or exempt or pending in exemptions.yaml.
void main() {
  final parity = Parity(
    File(specPath).readAsStringSync(),
    File(exemptionsPath).readAsStringSync(),
    bindings,
  );

  test('every operation in the spec is classified', () {
    expect(
      parity.unclassified,
      isEmpty,
      reason:
          'bind these in registry.dart, or list them as exempt (with a '
          'reason) or pending (in a wave) in exemptions.yaml',
    );
    // ignore: avoid_print, the remaining work is the point of the test.
    print(
      '${parity.pending.length} of ${parity.operations.length} operations '
      'still pending',
    );
  });

  test('no operation is classified twice', () {
    expect(parity.conflicting, isEmpty);
  });

  test('nothing names an operation the spec no longer has', () {
    expect(parity.stale, isEmpty);
  });

  test('every exemption says why', () {
    expect(parity.unexplained, isEmpty);
    expect(parity.badWaves, isEmpty);
  });

  test('every binding names a feature that exists', () {
    for (final MapEntry(:key, :value) in bindings.entries) {
      final dir = value.feature.startsWith('core/')
          ? 'lib/src/${value.feature}'
          : 'lib/src/features/${value.feature}';
      expect(Directory(dir).existsSync(), isTrue, reason: '$key: $dir');
      expect(value.wave, inInclusiveRange(0, 3), reason: key);
    }
  });

  test('a new operation fails until it is classified', () {
    final spec = File(specPath)
        .readAsStringSync()
        .replaceFirst('operationId: task.list', 'operationId: task.list_new');
    final bumped = Parity(spec, File(exemptionsPath).readAsStringSync(), {
      ...bindings,
    });
    expect(bumped.unclassified, ['task.list_new']);
    expect(bumped.stale, ['task.list']);
  });
}
