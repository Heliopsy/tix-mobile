// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/audit/application/audit.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_integrations.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('the log follows the filter and pages', () async {
    final server = FakeTix()..pageSize = 1;
    FakeIntegrations(server).audit
        .addAll([auditJson(2, via: 'ssh'), auditJson(1)]);
    final c = await signedInContainer(server);
    final filter = c.listen(auditFilterProvider, (_, _) {});
    final picked = c.listen(auditSelectionProvider, (_, _) {});
    addTearDown(filter.close);
    addTearDown(picked.close);
    expect(c.read(auditFilterProvider), const AuditQuery());
    final all = auditLogProvider(const AuditQuery());
    final sub = c.listen(all, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(all.future)).items.single.seq, 2);
    await c.read(all.notifier).loadMore();
    expect(c.read(all).value!.items.map((e) => e.seq), [2, 1]);
    c
        .read(auditFilterProvider.notifier)
        .change((q) => q.copyWith(vias: {'web'}));
    final web = auditLogProvider(c.read(auditFilterProvider));
    final entry = (await c.read(web.future)).items.single;
    expect(entry.seq, 1);
    c.read(auditSelectionProvider.notifier).show(entry);
    expect(c.read(auditSelectionProvider), 1);
    c.read(auditSelectionProvider.notifier).clear();
    expect(c.read(auditSelectionProvider), isNull);
  });
}
