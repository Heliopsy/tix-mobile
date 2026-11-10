// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';

/// Whether a click is held with Shift, Ctrl or Cmd, which makes it pick
/// rather than open or edit.
bool pickKeyHeld() {
  final keys = HardwareKeyboard.instance;
  return keys.isShiftPressed || keys.isControlPressed || keys.isMetaPressed;
}

/// What tapping [taskRef] does on a screen over [scope]: Shift picks the
/// range from the anchor in [order], Ctrl or Cmd picks the one task, and in
/// select mode a plain tap picks it too. Otherwise it calls [open].
void tapTask(
  WidgetRef ref,
  TaskScope scope,
  String taskRef, {
  required List<String> order,
  required void Function() open,
}) {
  final keys = HardwareKeyboard.instance;
  final selector = ref.read(taskSelectionProvider(scope).notifier);
  if (keys.isShiftPressed) {
    selector.selectRange(order, taskRef);
  } else if (keys.isControlPressed ||
      keys.isMetaPressed ||
      ref.read(taskSelectionProvider(scope)).active) {
    selector.toggle(taskRef);
  } else {
    open();
  }
}

/// Picks [taskRef] from a long press, turning select mode on.
void longPressTask(WidgetRef ref, TaskScope scope, String taskRef) {
  unawaited(TixHaptics.tick());
  ref.read(taskSelectionProvider(scope).notifier).toggle(taskRef);
}
