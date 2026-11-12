// SPDX-License-Identifier: AGPL-3.0-or-later

/// The three forms a shared task takes, as tix's `internal/tasklink` writes
/// them for the web, the command line and the terminal interface.
library;

/// The task's address: [webUrl] when tix sent one (`server.public_url` is
/// set), else `/tasks/REF` on [base], the server the app talks to.
String taskLink(String ref, String webUrl, String base) {
  if (webUrl.isNotEmpty) return webUrl;
  final b = base.replaceFirst(RegExp(r'/+$'), '');
  return '$b/tasks/${Uri.encodeComponent(ref)}';
}

/// The reference and the title on one line, for a chat message or a commit.
String taskLinkText(String ref, String title) {
  final t = title.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).join(' ');
  return t.isEmpty ? ref : '$ref $t';
}

/// A Markdown link to [url] labelled with the reference and the title, with
/// `\`, `[` and `]` escaped so the label cannot end early.
String taskLinkMarkdown(String ref, String title, String url) {
  final label = taskLinkText(
    ref,
    title,
  ).replaceAllMapped(RegExp(r'[\\\[\]]'), (m) => '\\${m[0]}');
  return '[$label]($url)';
}
