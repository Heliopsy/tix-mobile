// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quick_add.g.dart';

/// A line waiting to be added: typed nowhere yet, shared from another app,
/// or asked for from a shortcut.
@immutable
class QuickAddDraft {
  /// A draft holding [text], to add in [project] when given.
  const QuickAddDraft({this.text = '', this.project});

  /// The line, on one line.
  final String text;

  /// The project to add in, or null for the one on show.
  final String? project;
}

/// Where every feature asks for quick add. The quick-add host, mounted around
/// the signed-in screens, opens the sheet for each draft and takes it; a
/// draft written while nobody is signed in waits.
@Riverpod(keepAlive: true)
class QuickAddDrafts extends _$QuickAddDrafts {
  @override
  QuickAddDraft? build() => null;

  /// Asks for quick add holding [text], in [project] when given.
  void open({String text = '', String? project}) =>
      state = QuickAddDraft(text: oneLine(text), project: project);

  /// Hands over the waiting draft, if any, and clears it.
  QuickAddDraft? take() {
    final draft = state;
    state = null;
    return draft;
  }
}

/// [text] with its lines joined by spaces and trimmed: a quick-add line is
/// one line.
String oneLine(String text) => text
    .split(RegExp(r'\s*[\r\n]+\s*'))
    .where((s) => s.isNotEmpty)
    .join(' ')
    .trim();

/// Ticks when a task is created outside the screen listing it, so lists
/// that watch it reload.
@Riverpod(keepAlive: true)
class TasksChanged extends _$TasksChanged {
  @override
  int build() => 0;

  /// Says tasks changed.
  void touch() => state++;
}
