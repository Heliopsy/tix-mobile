// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The languages the app speaks, which the native widget text must too.
const _languages = ['en', 'bg', 'fr', 'de'];

Map<String, String> _androidStrings(String dir) {
  final text = File('android/app/src/main/res/$dir/widget_strings.xml')
      .readAsStringSync();
  return {
    for (final m in RegExp(
      '<string name="([^"]+)">(.*?)</string>',
    ).allMatches(text))
      m.group(1)!: m.group(2)!,
  };
}

void main() {
  test('Android widget text has every key in every language', () {
    final en = _androidStrings('values');
    expect(en, isNotEmpty);
    for (final lang in _languages.skip(1)) {
      final other = _androidStrings('values-$lang');
      expect(other.keys.toSet(), en.keys.toSet(), reason: lang);
      expect(other.values, everyElement(isNotEmpty), reason: lang);
    }
  });

  test('iOS and macOS widget text is translated into every language', () {
    final catalog = jsonDecode(
      File('ios/TixWidgets/Localizable.xcstrings').readAsStringSync(),
    ) as Map<String, dynamic>;
    final strings = catalog['strings'] as Map<String, dynamic>;
    expect(strings, isNotEmpty);
    for (final MapEntry(:key, :value) in strings.entries) {
      final local =
          (value as Map<String, dynamic>)['localizations']
              as Map<String, dynamic>? ??
          const {};
      for (final lang in _languages) {
        final unit =
            (local[lang] as Map<String, dynamic>?)?['stringUnit']
                as Map<String, dynamic>?;
        if (lang == 'en' && unit == null) continue;
        expect(unit?['value'], isNotEmpty, reason: '$key in $lang');
      }
    }
  });
}
