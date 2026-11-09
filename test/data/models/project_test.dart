// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/project.dart';

void main() {
  const infra = Project(key: 'infra', name: 'Infrastructure');
  const web = Project(key: 'web', name: 'Web');
  const ops = Project(key: 'ops', name: 'Operations');

  test('starred projects come first, each part in its own order', () {
    expect(
      starredFirst([
        infra,
        web,
        ops,
      ], (p) => p.key != 'infra').map((p) => p.key),
      ['web', 'ops', 'infra'],
    );
  });

  group('StarredProjects', () {
    test('a new star goes last and is marked starred', () {
      final stars = const StarredProjects([web]).toggled(infra, starred: true);
      expect(stars.projects.map((p) => (p.key, p.starred)), [
        ('web', false),
        ('infra', true),
      ]);
      expect(stars.keys, {'web', 'infra'});
      expect(stars.has('infra'), isTrue);
    });

    test('starring a starred project keeps its place', () {
      final stars = const StarredProjects([web, infra, ops])
          .toggled(infra, starred: true);
      expect(stars.projects.map((p) => p.key), ['web', 'infra', 'ops']);
    });

    test('taking a star off removes the project', () {
      final stars = const StarredProjects([web, infra])
          .toggled(web, starred: false);
      expect(stars.projects.map((p) => p.key), ['infra']);
      expect(stars.has('web'), isFalse);
    });

    test('puts the starred ones first in a list', () {
      expect(
        const StarredProjects([ops]).first([infra, web, ops]).map((p) => p.key),
        ['ops', 'infra', 'web'],
      );
    });

    test('equal when the same projects are starred in the same order', () {
      expect(
        const StarredProjects([infra, web]),
        const StarredProjects([infra, web]),
      );
      expect(
        const StarredProjects([infra, web]),
        isNot(const StarredProjects([web, infra])),
      );
    });
  });
}
