// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

const _pretty = JsonEncoder.withIndent('  ');

/// Copies [json] to the clipboard, indented by two spaces, and says so in
/// a toast.
Future<void> copyJson(BuildContext context, Map<String, Object?> json) async {
  final done = context.l10n.copyJsonDone;
  await Clipboard.setData(ClipboardData(text: _pretty.convert(json)));
  if (context.mounted) showTixToast(context, done);
}

/// Copy JSON: puts [json] on the clipboard with [copyJson].
class CopyJsonButton extends StatelessWidget {
  /// A button copying [json].
  const CopyJsonButton({
    required this.json,
    this.size = TixButtonSize.regular,
    super.key,
  });

  /// The object copied.
  final Map<String, Object?> json;

  /// The button's size.
  final TixButtonSize size;

  @override
  Widget build(BuildContext context) => TixButton.quiet(
    label: context.l10n.copyJson,
    icon: Icons.data_object,
    size: size,
    onPressed: () => unawaited(copyJson(context, json)),
  );
}
