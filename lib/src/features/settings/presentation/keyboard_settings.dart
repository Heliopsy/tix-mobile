// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// What [action] does, for the Settings list of bindings.
String keyActionLabel(AppLocalizations l10n, String action) => switch (action) {
  KeyActions.paletteOpen => l10n.openCommandPalette,
  KeyActions.helpShow => l10n.showShortcuts,
  KeyActions.fieldLeave => l10n.keysLeaveField,
  KeyActions.navBack => l10n.keysBack,
  KeyActions.navProjects => l10n.goProjects,
  KeyActions.navTasks => l10n.goTasks,
  KeyActions.navMyWork => l10n.goMyWork,
  KeyActions.navInbox => l10n.goInbox,
  KeyActions.navManage => l10n.goManage,
  KeyActions.navSettings => l10n.goSettings,
  KeyActions.navWatch => l10n.goWatch,
  KeyActions.quickAdd => l10n.quickAddTitle,
  KeyActions.quickPaste => l10n.quickAddPaste,
  KeyActions.listNext => l10n.keysNextRow,
  KeyActions.listPrev => l10n.keysPreviousRow,
  KeyActions.listTop => l10n.keysFirstRow,
  KeyActions.listBottom => l10n.keysLastRow,
  KeyActions.listPageDown => l10n.keysPageDown,
  KeyActions.listPageUp => l10n.keysPageUp,
  KeyActions.listOpen => l10n.keysOpenRow,
  KeyActions.listSelect => l10n.bulkSelect,
  KeyActions.listExtendDown => l10n.bulkExtendDown,
  KeyActions.listExtendUp => l10n.bulkExtendUp,
  KeyActions.listSelectAll => l10n.bulkSelectAll,
  KeyActions.listClear => l10n.bulkExit,
  KeyActions.listFilter => l10n.filterFocus,
  KeyActions.listRefresh => l10n.refresh,
  KeyActions.listView => l10n.viewSwitch,
  KeyActions.listNew => l10n.newTask,
  KeyActions.listDone => l10n.markDone,
  KeyActions.taskRename => l10n.taskDetailRename,
  KeyActions.taskDescribe => l10n.taskDetailEditDescription,
  KeyActions.taskMove => l10n.taskDetailMoveTitle,
  KeyActions.taskPriority => l10n.taskDetailPriorityTitle,
  KeyActions.taskAssign => l10n.taskDetailAssigneeTitle,
  KeyActions.taskDue => l10n.taskDetailDueTitle,
  KeyActions.taskTag => l10n.taskDetailAddTag,
  KeyActions.taskStar => l10n.taskDetailStar,
  KeyActions.taskSnooze => l10n.taskDetailSnooze,
  KeyActions.taskComment => l10n.taskDetailCommentLabel,
  KeyActions.taskCopy => l10n.taskDetailCopyTo,
  KeyActions.taskDelete => l10n.taskDetailDelete,
  _ => action,
};

/// The name of [preset].
String keymapPresetLabel(AppLocalizations l10n, KeymapPreset preset) =>
    switch (preset) {
      KeymapPreset.standard => l10n.keymapDefault,
      KeymapPreset.vim => l10n.keymapVim,
      KeymapPreset.emacs => l10n.keymapEmacs,
      KeymapPreset.off => l10n.keymapOff,
    };

String _presetHelp(AppLocalizations l10n, KeymapPreset preset) =>
    switch (preset) {
      KeymapPreset.standard => l10n.keymapDefaultHelp,
      KeymapPreset.vim => l10n.keymapVimHelp,
      KeymapPreset.emacs => l10n.keymapEmacsHelp,
      KeymapPreset.off => l10n.keymapOffHelp,
    };

/// Turns every keyboard shortcut on or off.
class KeyboardShortcutsEntry extends ConsumerWidget {
  /// Creates the switch.
  const KeyboardShortcutsEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixSwitchRow(
    key: const Key('settings.shortcuts'),
    title: context.l10n.shortcutsTitle,
    subtitle: context.l10n.settingsShortcutsHelp,
    value: ref.watch(keyboardSettingProvider).enabled,
    onChanged: (on) =>
        ref.read(keyboardSettingProvider.notifier).setEnabled(on: on),
  );
}

/// Picks the keymap preset, and says what it does.
class KeymapEntry extends ConsumerWidget {
  /// Creates the picker.
  const KeymapEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final preset = ref.watch(keyboardSettingProvider).preset;
    return _Labelled(
      label: l10n.settingsKeymap,
      children: [
        TixChoices<KeymapPreset>(
          key: const Key('settings.keymap'),
          choices: [
            for (final p in KeymapPreset.values)
              TixChoice(p, keymapPresetLabel(l10n, p)),
          ],
          selected: preset,
          onSelected: (p) =>
              ref.read(keyboardSettingProvider.notifier).setPreset(p),
        ),
        const SizedBox(height: TixSpace.s2),
        Text(
          _presetHelp(l10n, preset),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// The active preset's bindings, read only, one row per action.
class KeyBindingsEntry extends ConsumerWidget {
  /// Creates the list.
  const KeyBindingsEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final keymap = ref.watch(activeKeymapProvider);
    final rows = [
      for (final a in keymap.actions)
        if (keymap.bindingsFor(a).isNotEmpty) a,
    ];
    return _Labelled(
      key: const Key('settings.keyBindings'),
      label: l10n.settingsKeyBindings,
      children: [
        if (!keymap.enabled)
          Text(
            l10n.settingsKeyBindingsOff,
            style: TextStyle(color: context.tix.muted),
          ),
        for (final a in rows)
          Padding(
            key: Key('settings.keyBindings.$a'),
            padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: TixSpace.s3,
              runSpacing: TixSpace.s1,
              children: [
                Text(keyActionLabel(l10n, a)),
                KeyBindingKeys(keymap.bindingsFor(a)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.children, super.key});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(TixSpace.s3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: TixText.xs,
            fontWeight: FontWeight.w500,
            color: context.tix.muted,
          ),
        ),
        const SizedBox(height: TixSpace.s2),
        ...children,
      ],
    ),
  );
}
