// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/json.dart';

void main() {
  test('a Patch holds a value or a clear and compares by it', () {
    expect(const Patch(1), const Patch(1));
    expect(const Patch(1).hashCode, const Patch(1).hashCode);
    expect(const Patch(1), isNot(const Patch(2)));
    expect(const Patch<int>.clear(), const Patch<int>.clear());
    expect(const Patch<int>.clear(), isNot(const Patch(1)));
    expect(const Patch<int>.clear().value, isNull);
    expect(const Patch(2).encode((v) => v * 2), 4);
    expect(const Patch<int>.clear().encode((v) => v * 2), isNull);
    expect(const Patch(1).toString(), 'Patch(1)');
    expect(const Patch<int>.clear().toString(), 'Patch.clear()');
  });

  group('UpdateTaskInput.toBody', () {
    test('a cleared due date is an explicit null', () {
      final body = const UpdateTaskInput(dueAt: Patch.clear()).toBody();
      expect(body, {'due_at': null});
      expect(body.containsKey('due_at'), isTrue);
    });

    test('a set due date goes out in UTC', () {
      final due = DateTime.utc(2026, 11, 2, 9);
      expect(UpdateTaskInput(dueAt: Patch(due), version: 3).toBody(), {
        'due_at': '2026-11-02T09:00:00.000Z',
        'version': 3,
      });
    });

    test('an omitted due date leaves the key out', () {
      final body = const UpdateTaskInput(title: 'x').toBody();
      expect(body, {'title': 'x'});
      expect(body.containsKey('due_at'), isFalse);
    });

    test('a null inside custom_fields survives', () {
      expect(const UpdateTaskInput(customFields: {'k': null}).toBody(), {
        'custom_fields': {'k': null},
      });
    });
  });
}
