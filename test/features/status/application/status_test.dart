// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/status/application/status.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix();
    FakeParity.on(server);
  });

  test('the status report loads from the server', () async {
    final c = await signedInContainer(server);
    c.listen(statusReportStateProvider, (_, _) {});
    final report = await c.read(statusReportStateProvider.future);
    expect(report.work?.webhooksFailed, 3);
    expect(server.requestsTo('/api/v1/status'), hasLength(1));
  });
}
