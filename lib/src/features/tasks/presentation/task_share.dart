// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/sharing.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/task_link.dart';

/// What the Share menu does with a task.
enum TaskShareKind {
  /// Hand the link to another app through the system share sheet.
  native,

  /// Copy the task's address.
  link,

  /// Copy a Markdown link labelled with the reference and the title.
  markdown,

  /// Copy the reference and the title.
  text,
}

/// Whether the platform has a share sheet to hand a link to. Linux has none,
/// so the menu leaves Share… out there, as the web does in a browser
/// without one.
bool get hasShareSheet => switch (defaultTargetPlatform) {
  TargetPlatform.android ||
  TargetPlatform.iOS ||
  TargetPlatform.macOS ||
  TargetPlatform.windows => true,
  _ => false,
};

/// Opens the Share menu for [task] and does what is picked: Share…, Copy
/// link, Copy as Markdown or Copy key and title. Each copy says so in a
/// toast.
Future<void> shareTask(BuildContext context, WidgetRef ref, Task task) async {
  final l10n = context.l10n;
  final origin = originOf(context);
  final kind = await showActionSheet<TaskShareKind>(
    context,
    title: l10n.taskShareTitle(task.ref),
    actions: [
      if (hasShareSheet)
        TixSheetAction(
          key: const Key('share.native'),
          value: TaskShareKind.native,
          label: l10n.taskShareNative,
          icon: Icons.ios_share,
        ),
      TixSheetAction(
        key: const Key('share.link'),
        value: TaskShareKind.link,
        label: l10n.taskShareCopyLink,
        icon: Icons.link,
      ),
      TixSheetAction(
        key: const Key('share.markdown'),
        value: TaskShareKind.markdown,
        label: l10n.taskShareCopyMarkdown,
        icon: Icons.code,
      ),
      TixSheetAction(
        key: const Key('share.text'),
        value: TaskShareKind.text,
        label: l10n.taskShareCopyText,
        icon: Icons.short_text,
      ),
    ],
  );
  if (kind == null || !context.mounted) return;
  final base = ref.read(sessionControllerProvider).value?.baseUrl ?? '';
  final url = taskLink(task.ref, task.webUrl, base);
  switch (kind) {
    case TaskShareKind.native:
      unawaited(
        ref
            .read(textSharingProvider)
            .share(
              url,
              subject: taskLinkText(task.ref, task.title),
              origin: origin,
            ),
      );
      return;
    case TaskShareKind.link:
      await _copy(context, url, l10n.taskShareLinkCopied);
    case TaskShareKind.markdown:
      await _copy(
        context,
        taskLinkMarkdown(task.ref, task.title, url),
        l10n.taskShareMarkdownCopied,
      );
    case TaskShareKind.text:
      await _copy(
        context,
        taskLinkText(task.ref, task.title),
        l10n.taskShareTextCopied,
      );
  }
}

Future<void> _copy(BuildContext context, String text, String done) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) showTixToast(context, done);
}
