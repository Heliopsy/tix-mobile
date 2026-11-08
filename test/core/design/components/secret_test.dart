// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/design.dart';

void main() {
  testWidgets('shows every value and copies them all', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await pumpComponent(
      tester,
      const OneTimeSecret(
        heading: 'Copy these codes now',
        note: 'Shown once.',
        values: ['aaaa-bbbb', 'cccc-dddd'],
      ),
    );
    expect(find.text('Copy these codes now'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('secret.values')),
        matching: find.text('aaaa-bbbb\ncccc-dddd'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('secret.copy')));
    await tester.pump();
    expect(copied, 'aaaa-bbbb\ncccc-dddd');
    expect(find.text('Copied.'), findsOneWidget);
  });
}
