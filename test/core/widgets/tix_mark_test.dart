// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';

void main() {
  testWidgets('draws the bundled mark at the size asked for', (tester) async {
    await tester.pumpWidget(const Center(child: TixMark(size: 40)));
    final image = tester.widget<Image>(
      find.descendant(of: find.byType(TixMark), matching: find.byType(Image)),
    );
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, TixMark.asset);
    expect(tester.getSize(find.byType(TixMark)), const Size.square(40));
  });

  testWidgets('the mark is bundled with the app', (tester) async {
    final data = await rootBundle.load(TixMark.asset);
    expect(data.lengthInBytes, greaterThan(0));
  });
}
