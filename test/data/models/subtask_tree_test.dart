// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/subtask_tree.dart';
import 'package:tix_mobile/src/data/models/task.dart';

Task _t(String ref, [String parent = 'root']) =>
    Task(id: ref, ref: ref, parentId: parent);

void main() {
  test('nests depth-first descendants three levels deep', () {
    final tree = SubtaskTree(
      tasks: [_t('a'), _t('a1', 'a'), _t('a11', 'a1'), _t('b')],
    );
    expect(tree.nodes.map((n) => n.task.ref), ['a', 'b']);
    final a1 = tree.nodes.first.children.single;
    expect(a1.task.ref, 'a1');
    expect(a1.level, 2);
    expect(a1.children.single.level, 3);
    expect(tree.nested, isTrue);
    expect(tree.complete, isTrue);
  });

  test('the fourth level is counted, not drawn', () {
    final tree = SubtaskTree(
      tasks: [
        _t('a'),
        _t('a1', 'a'),
        _t('a11', 'a1'),
        _t('x', 'a11'),
        _t('y', 'a11'),
      ],
    );
    final deepest = tree.nodes.single.children.single.children.single;
    expect(deepest.children, isEmpty);
    expect(deepest.more, 2);
    expect(tree.complete, isFalse);
  });

  test('a task whose parent is not in the tree is a direct subtask', () {
    final tree = SubtaskTree(tasks: [_t('a')]).plus([_t('draft', 'draft-1')]);
    expect(tree.nodes.map((n) => n.task.ref), ['a', 'draft']);
    expect(tree.nested, isFalse);
  });

  test('a shallow tree is never complete', () {
    final tree = SubtaskTree(tasks: [_t('a')], shallow: true);
    expect(tree.complete, isFalse);
    expect(tree.plus([_t('b')]).shallow, isTrue);
  });

  test('an empty tree is empty', () {
    expect(SubtaskTree().isEmpty, isTrue);
    expect(SubtaskTree().nodes, isEmpty);
  });
}
