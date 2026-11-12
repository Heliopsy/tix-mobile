// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/keyboard/keymap.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// The sections the shortcut help and the Settings list group actions in,
/// in order, as tix web's help groups them.
enum KeyGroup {
  /// The `g` chords and Ctrl+1 to Ctrl+7.
  navigate,

  /// Moving and selecting in a list.
  lists,

  /// Acting on a task.
  task,

  /// The palette, the help and anything else.
  general,
}

/// The section [action] is listed under; [KeyGroup.general] for one with no
/// keymap action.
KeyGroup keyActionGroup(String? action) => switch (action) {
  KeyActions.navInbox ||
  KeyActions.navMyWork ||
  KeyActions.navTasks ||
  KeyActions.navProjects ||
  KeyActions.navWatch ||
  KeyActions.navManage ||
  KeyActions.navSettings => KeyGroup.navigate,
  KeyActions.listNext ||
  KeyActions.listPrev ||
  KeyActions.listTop ||
  KeyActions.listBottom ||
  KeyActions.listPageDown ||
  KeyActions.listPageUp ||
  KeyActions.listOpen ||
  KeyActions.navBack ||
  KeyActions.listSelect ||
  KeyActions.listExtendDown ||
  KeyActions.listExtendUp ||
  KeyActions.listSelectAll ||
  KeyActions.listClear ||
  KeyActions.listFilter ||
  KeyActions.listRefresh ||
  KeyActions.listView => KeyGroup.lists,
  KeyActions.listNew ||
  KeyActions.listDone ||
  KeyActions.taskRename ||
  KeyActions.taskDescribe ||
  KeyActions.taskMove ||
  KeyActions.taskComment ||
  KeyActions.taskTag ||
  KeyActions.taskStar ||
  KeyActions.taskPriority ||
  KeyActions.taskAssign ||
  KeyActions.taskDue ||
  KeyActions.taskSnooze ||
  KeyActions.taskCopy ||
  KeyActions.taskDelete => KeyGroup.task,
  _ => KeyGroup.general,
};

/// The heading of [group].
String keyGroupLabel(AppLocalizations l10n, KeyGroup group) => switch (group) {
  KeyGroup.navigate => l10n.keyGroupNavigate,
  KeyGroup.lists => l10n.keyGroupLists,
  KeyGroup.task => l10n.keyGroupTask,
  KeyGroup.general => l10n.keyGroupGeneral,
};

/// What [action] does, in the words tix web's help uses for it; the action
/// itself for one it does not know.
String keyActionLabel(AppLocalizations l10n, String action) => switch (action) {
  KeyActions.paletteOpen => l10n.keyHelpPalette,
  KeyActions.helpShow => l10n.keyHelpHelp,
  KeyActions.fieldLeave => l10n.keysLeaveField,
  KeyActions.navInbox => l10n.keyHelpGoInbox,
  KeyActions.navMyWork => l10n.keyHelpGoMyWork,
  KeyActions.navTasks => l10n.keyHelpGoTasks,
  KeyActions.navProjects => l10n.keyHelpGoProjects,
  KeyActions.navWatch => l10n.keyHelpGoActivity,
  KeyActions.navManage => l10n.keyHelpGoManage,
  KeyActions.navSettings => l10n.keyHelpGoSettings,
  KeyActions.listNext => l10n.keyHelpNext,
  KeyActions.listPrev => l10n.keyHelpPrevious,
  KeyActions.listTop => l10n.keyHelpFirst,
  KeyActions.listBottom => l10n.keyHelpLast,
  KeyActions.listPageDown => l10n.keyHelpPageDown,
  KeyActions.listPageUp => l10n.keyHelpPageUp,
  KeyActions.listOpen => l10n.keyHelpOpen,
  KeyActions.navBack => l10n.keyHelpBack,
  KeyActions.listSelect => l10n.keyHelpSelect,
  KeyActions.listExtendDown => l10n.keyHelpExtendDown,
  KeyActions.listExtendUp => l10n.keyHelpExtendUp,
  KeyActions.listSelectAll => l10n.keyHelpSelectAll,
  KeyActions.listClear => l10n.keyHelpClear,
  KeyActions.listFilter => l10n.keyHelpFilter,
  KeyActions.listRefresh => l10n.keyHelpRefresh,
  KeyActions.listView => l10n.keyHelpView,
  KeyActions.listNew => l10n.keyHelpNew,
  KeyActions.listDone => l10n.keyHelpDone,
  KeyActions.taskRename => l10n.keyHelpRename,
  KeyActions.taskDescribe => l10n.keyHelpDescribe,
  KeyActions.taskMove => l10n.keyHelpMove,
  KeyActions.taskComment => l10n.keyHelpComment,
  KeyActions.taskTag => l10n.keyHelpTag,
  KeyActions.taskStar => l10n.keyHelpStar,
  KeyActions.taskPriority => l10n.keyHelpPriority,
  KeyActions.taskAssign => l10n.keyHelpAssign,
  KeyActions.taskDue => l10n.keyHelpDue,
  KeyActions.taskSnooze => l10n.keyHelpSnooze,
  KeyActions.taskCopy => l10n.keyHelpCopyRef,
  KeyActions.taskDelete => l10n.keyHelpDelete,
  KeyActions.quickAdd => l10n.quickAddTitle,
  KeyActions.quickPaste => l10n.quickAddPaste,
  _ => action,
};
