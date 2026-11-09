// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/data/models/project.dart';

import '../../../helpers/design.dart';

void main() {
  const t = TixTokens.light;
  const infra = Project(
    key: 'INFRA',
    name: 'Infrastructure',
    color: 'teal',
    iconName: 'server',
  );
  const web = Project(key: 'WEB', name: 'Web', color: 'violet', icon: '🌐');
  const bare = Project(key: 'OPS', name: 'Operations');

  Finder mark(String key) => find.byKey(Key('projectOption.$key.mark'));

  testWidgets('draws the built-in icon in the project colour', (tester) async {
    await pumpComponent(tester, const ProjectOption(project: infra));
    final glyph = tester.widget<Icon>(
      find.descendant(of: mark('INFRA'), matching: find.byType(Icon)),
    );
    expect(glyph.icon, Icons.dns_outlined);
    expect(glyph.color, t.projectColour('teal'));
    expect(find.text('Infrastructure'), findsOneWidget);
    expect(find.text('INFRA'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('a project with no icon or colour gets the monogram in muted', (
    tester,
  ) async {
    await pumpComponent(tester, const ProjectOption(project: bare));
    final monogram = tester.widget<Text>(
      find.descendant(of: mark('OPS'), matching: find.byType(Text)),
    );
    expect(monogram.data, 'OP');
    expect(monogram.style!.color, t.muted);
  });

  testWidgets('reads as the project name, selected, with the mark silent', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpComponent(
      tester,
      const ProjectOption(project: web, selected: true),
    );
    expect(
      tester.getSemantics(find.byType(ProjectOption)),
      isSemantics(label: 'Web', isSelected: true, hasSelectedState: true),
    );
    expect(find.bySemanticsLabel('🌐'), findsNothing);
    expect(find.byKey(const Key('projectOption.WEB.check')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('an archived project carries the badge', (tester) async {
    await pumpComponent(
      tester,
      ProjectOption(project: bare.copyWith(archivedAt: DateTime.utc(2026))),
    );
    expect(find.text('archived'), findsOneWidget);
  });

  testWidgets('the picker marks every project and checks the current one', (
    tester,
  ) async {
    String? picked;
    await pumpComponent(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => picked = await showProjectPicker(
            context,
            title: 'Switch project',
            keyPrefix: 'pick',
            current: 'INFRA',
            projects: const [infra, web, bare],
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    for (final key in ['INFRA', 'WEB', 'OPS']) {
      expect(
        find.descendant(
          of: find.byKey(Key('pick.$key')),
          matching: find.byType(ProjectMark),
        ),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(
        of: find.byKey(const Key('pick.INFRA')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.byKey(const Key('pick.WEB')));
    await tester.pumpAndSettle();
    expect(picked, 'WEB');
  });
}
