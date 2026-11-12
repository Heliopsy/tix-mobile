// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

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
    final bound = [
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
        for (final group in KeyGroup.values)
          if (bound.where((a) => keyActionGroup(a) == group).toList()
              case final rows when rows.isNotEmpty) ...[
            Padding(
              key: Key('settings.keyBindings.group.${group.name}'),
              padding: const EdgeInsets.only(
                top: TixSpace.s3,
                bottom: TixSpace.s1,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  keyGroupLabel(l10n, group),
                  style: const TextStyle(
                    fontSize: TixText.sm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
