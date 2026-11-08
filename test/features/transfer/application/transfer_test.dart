// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/transfer/application/transfer.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_people.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('formats name their files and wire values as tix does', () {
    expect(ExportFormat.markdown.wire, 'markdown');
    expect(ExportFormat.markdown.extension, 'md');
    expect(ExportFormat.ndjson.wire, 'ndjson');
    expect(defaultExportColumns.every(exportColumns.contains), isTrue);
  });

  test('an export is named for its project and format', () async {
    final server = FakeTix();
    final people = FakePeople.on(server);
    final c = await signedInContainer(server);
    final file = await c
        .read(transferProvider.notifier)
        .exportTasks(
          project: 'infra',
          format: ExportFormat.json,
          columns: const ['ref'],
          trashed: true,
        );
    expect(file.name, 'infra-tasks.json');
    expect(file.mimeType, 'application/json');
    expect(people.lastExport, {
      'format': 'json',
      'columns': ['ref'],
      'exclude_finished': false,
      'exclude_subtasks': false,
      'include_trashed': true,
      'dates': 'iso',
    });
    expect(await c.read(transferProjectsProvider.future), hasLength(2));
  });
}
