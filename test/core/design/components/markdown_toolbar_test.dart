// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

class _Host extends StatefulWidget {
  const _Host(this.controller);

  final TextEditingController controller;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(TixSpace.s3),
    child: MarkdownEditor(
      controller: widget.controller,
      focusNode: _focus,
      field: TextField(
        key: const Key('field'),
        controller: widget.controller,
        focusNode: _focus,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
        inputFormatters: const [MarkdownListFormatter()],
      ),
    ),
  );
}

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pump(WidgetTester tester, {Size size = phone}) =>
      pumpComponent(tester, _Host(controller), size: size);

  void select(String text, int start, int end) =>
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection(baseOffset: start, extentOffset: end),
      );

  Finder tool(String name) => find.descendant(
    of: find.byKey(const Key('markdown.toolbar')),
    matching: find.byKey(Key('markdown.$name')),
  );

  testWidgets('every web tool is a labelled 48 dp button, in its order', (
    tester,
  ) async {
    await pump(tester);
    final tips = [
      for (final b in tester.widgetList<TixIconButton>(
        find.descendant(
          of: find.byKey(const Key('markdown.toolbar')),
          matching: find.byType(TixIconButton),
        ),
      ))
        b.tooltip,
    ];
    expect(tips, [
      'Bold',
      'Italic',
      'Strikethrough',
      'Heading',
      'Bulleted list',
      'Numbered list',
      'Checklist',
      'Quote',
      'Code',
      'Link',
      'Table',
    ]);
    final size = tester.getSize(tool('bold'));
    expect(size.height, greaterThanOrEqualTo(TixSize.target));
  });

  for (final (name, size, below) in [
    ('compact', phone, true),
    ('expanded', desktop, false),
  ]) {
    testWidgets('at $name width the toolbar is ${below ? 'under' : 'over'} '
        'the field', (tester) async {
      await pump(tester, size: size);
      final bar = tester.getTopLeft(find.byKey(const Key('markdown.toolbar')));
      final field = tester.getTopLeft(find.byKey(const Key('field')));
      expect(bar.dy > field.dy, below);
    });

    testWidgets('at $name width a tool edits the selection and keeps focus', (
      tester,
    ) async {
      await pump(tester, size: size);
      await tester.tap(find.byKey(const Key('field')));
      select('a plan', 2, 6);
      await tester.tap(tool('bold'));
      await tester.pump();
      expect(controller.text, 'a **plan**');
      expect(
        controller.selection,
        const TextSelection(baseOffset: 4, extentOffset: 8),
      );
      await tester.tap(tool('checklist'));
      await tester.pump();
      expect(controller.text, '- [ ] a **plan**');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('field')))
            .focusNode!
            .hasFocus,
        isTrue,
      );
    });
  }

  testWidgets('Ctrl+B, Ctrl+I and Ctrl+` format inside the field', (
    tester,
  ) async {
    await pump(tester, size: desktop);
    await tester.tap(find.byKey(const Key('field')));
    select('word', 0, 4);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(controller.text, '**word**');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(controller.text, '***word***');
    select('run ls', 4, 6);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.backquote);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    expect(controller.text, 'run `ls`');
  });

  testWidgets('Link asks for the address and wraps the selection', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('field')));
    select('see docs', 4, 8);
    await tester.ensureVisible(tool('link'));
    await tester.tap(tool('link'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('markdown.link.address')),
      'https://tix.example',
    );
    await tester.tap(find.byKey(const Key('markdown.link.add')));
    await tester.pumpAndSettle();
    expect(controller.text, 'see [docs](https://tix.example)');
  });

  testWidgets('Link on a link takes it off, and Cancel changes nothing', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('field')));
    select('[docs](https://tix.example)', 2, 2);
    await tester.ensureVisible(tool('link'));
    await tester.tap(tool('link'));
    await tester.pumpAndSettle();
    expect(controller.text, 'docs');
    expect(find.byKey(const Key('markdown.link.address')), findsNothing);
    select('docs', 0, 4);
    await tester.ensureVisible(tool('link'));
    await tester.tap(tool('link'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.text, 'docs');
  });

  testWidgets('Enter in the field continues a checklist', (tester) async {
    await pump(tester);
    await tester.showKeyboard(find.byKey(const Key('field')));
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '- [x] one',
        selection: TextSelection.collapsed(offset: 9),
      ),
    );
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '- [x] one\n',
        selection: TextSelection.collapsed(offset: 10),
      ),
    );
    await tester.pump();
    expect(controller.text, '- [x] one\n- [ ] ');
    expect(controller.selection.baseOffset, controller.text.length);
  });
}
