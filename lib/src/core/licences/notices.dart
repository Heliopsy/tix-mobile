// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:ffi' show Abi;

// Pure Dart on purpose: tool/licences.dart runs it outside Flutter to report
// what a build's Licenses page lists.

/// One licence text and the packages it covers.
typedef Notice = ({List<String> packages, String text});

/// SPDX identifiers whose terms ask for no notice in a binary.
const noNoticeSpdx = {
  'CC0-1.0',
  'Unlicense',
  '0BSD',
  'LicenseRef-public-domain',
};

/// Splits Flutter's NOTICES file into its blocks, as Flutter itself does.
List<Notice> parseFlutterNotices(String raw) => [
  for (final block in raw.split('\n${'-' * 80}\n'))
    if (block.indexOf('\n\n') case final int split when split >= 0)
      (
        packages: block.substring(0, split).split('\n'),
        text: block.substring(split + 2),
      )
    else
      (packages: const <String>[], text: block),
];

/// Whether [text] is a licence that asks for no notice: CC0, the
/// Unlicense, or 0BSD. Anything not recognised needs one.
bool needsNoNotice(String text) {
  final t = text.replaceAll(RegExp(r'\s+'), ' ');
  if (t.contains('CC0 1.0 Universal')) return true;
  if (t.contains(
    'This is free and unencumbered software released into the '
    'public domain',
  )) {
    return true;
  }
  const zeroBsd =
      'Permission to use, copy, modify, and/or distribute this software for '
      'any purpose with or without fee is hereby granted.';
  return t.contains(zeroBsd) && !t.contains('provided that the above');
}

/// The blocks of Flutter's notices that the shipped app needs: dev-only
/// packages are dropped from each block, a block left with none of its
/// packages goes, and so does one whose licence asks for no notice. Names
/// that are no pub package (the engine's components) are kept.
List<Notice> keepShipped(
  List<Notice> notices, {
  required Set<String> devOnly,
}) => [
  for (final n in notices)
    if (!needsNoNotice(n.text))
      if (n.packages.where((p) => !devOnly.contains(p)).toList() case final kept
          when kept.isNotEmpty || n.packages.isEmpty)
        (packages: kept, text: n.text),
];

/// The GOOS/GOARCH libtix is built for on [abi], or null where none ships.
String? engineTarget(Abi abi) => switch (abi) {
  Abi.androidArm64 => 'android/arm64',
  Abi.androidArm => 'android/arm',
  Abi.androidX64 => 'android/amd64',
  Abi.iosArm64 => 'ios/arm64',
  Abi.iosX64 => 'ios/amd64',
  Abi.macosArm64 => 'darwin/arm64',
  Abi.macosX64 => 'darwin/amd64',
  Abi.linuxX64 => 'linux/amd64',
  Abi.linuxArm64 => 'linux/arm64',
  Abi.windowsX64 => 'windows/amd64',
  _ => null,
};

/// The notices of the Go modules libtix links on [target], from the merged
/// `assets/licenses/libtix.json`, without those that ask for none.
List<Notice> engineNotices(String json, String target) {
  final doc = jsonDecode(json) as Map<String, Object?>;
  final modules = (doc['modules'] as List? ?? const [])
      .cast<Map<String, Object?>>();
  return [
    for (final m in modules)
      if ((m['targets'] as List? ?? const []).contains(target) &&
          !noNoticeSpdx.contains(m['license'])) ...[
        (packages: [_name(m)], text: '${m['license_text'] ?? ''}'),
        for (final f
            in (m['other_files'] as List? ?? const [])
                .cast<Map<String, Object?>>())
          if (!needsNoNotice('${f['text'] ?? ''}'))
            (packages: [_name(m)], text: '${f['text'] ?? ''}'),
      ],
  ];
}

String _name(Map<String, Object?> m) =>
    m['module'] == 'std' ? 'Go' : '${m['module']}';
