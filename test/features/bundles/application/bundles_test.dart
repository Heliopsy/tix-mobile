// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/bundles/application/bundles.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeParity parity;

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
  });

  test('an export is named for its label and lists kinds in order', () async {
    final c = await signedInContainer(server);
    final file = await c
        .read(bundleTransferProvider.notifier)
        .export(
          kinds: {ComponentKind.webhook, ComponentKind.workflow},
          name: 'Team Setup!',
        );
    expect(file.name, 'tix-bundle-team-setup.ndjson');
    expect(server.requests.last.body['kinds'], ['workflow', 'webhook']);
    expect(utf8.decode(file.bytes), contains('"kinds":2'));
    final plain = await c.read(bundleTransferProvider.notifier).export();
    expect(plain.name, 'tix-bundle.ndjson');
  });

  test('imports pass the rule and the project through', () async {
    final c = await signedInContainer(server);
    await c
        .read(bundleTransferProvider.notifier)
        .import(
          '{}',
          preview: true,
          onCollision: BundleCollision.skip,
          projectRef: ' infra ',
        );
    expect(parity.bundleImports.last['on_collision'], 'skip');
    expect(parity.bundleImports.last['project_ref'], 'infra');
    final r = await c
        .read(bundleTransferProvider.notifier)
        .importSnapshot('{}\n', mode: SnapshotImportMode.merge, dryRun: false);
    expect(r.dryRun, isFalse);
    expect(parity.snapshotImports.last['mode'], 'merge');
  });
}
