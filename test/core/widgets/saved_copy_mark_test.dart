// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';
import 'package:tix_mobile/src/core/widgets/saved_copy_mark.dart';

import '../../helpers/app.dart';

void main() {
  testWidgets('says when the saved copy it shows is from', (tester) async {
    await pumpScreen(
      tester,
      const SavedCopyMark(),
      overrides: [
        savedCopySinceProvider.overrideWithValue(
          AsyncData(DateTime(2026, 11, 1, 9, 30)),
        ),
      ],
    );
    expect(
      find.text('Offline, showing saved copy from Nov 1, 2026 09:30'),
      findsOneWidget,
    );
  });

  testWidgets('shows nothing while everything is fresh', (tester) async {
    await pumpScreen(
      tester,
      const SavedCopyMark(),
      overrides: [
        savedCopySinceProvider.overrideWithValue(const AsyncData(null)),
      ],
    );
    expect(find.textContaining('Offline'), findsNothing);
  });
}
