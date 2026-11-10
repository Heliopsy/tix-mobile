# Proposal

## Why

The app has a command palette, a `?` overlay and single-key shortcuts on the task list and the task, but not every
screen can be used without a mouse. The nav rail has no keys, most lists cannot be walked with the arrows or `j`
and `k`, focus is hard to see, and a list hidden behind another page keeps its keys. tix's web interface and its
terminal interface both offer Default, Vim and Emacs key schemes; the app offers none, and nobody can turn the
single keys off.

## What Changes

- A keymap layer in `core/keyboard`: commands name an abstract action (`list.next`, `nav.back`, `task.assign`,
  `palette.open`), and a preset maps each action to keys, including two-key sequences such as `g p` with a
  one-second timeout.
- Presets: **Default** (today's keys plus tix web's), **Vim**, **Emacs** and **Off** (only chords held with Ctrl,
  Alt or Cmd). A switch turns every shortcut off, the palette's included.
- Keys typed into a text field stay there, as now. Only the palette chord, and Esc or Emacs's C-g to leave the
  field, act while typing.
- Keyboard-only use: `g` sequences and Ctrl+1 to Ctrl+6 switch destinations, Esc goes back, lists on every page move
  focus with the arrows or the preset's keys, the task list's cursor scrolls into view, Enter yields to a focused
  control, a visible focus ring follows keyboard focus, and a page hidden behind another drops its keys.
- A Keyboard section in Settings, on every platform: the switch, the preset, and the active bindings. The `?`
  overlay shows the active preset's keys. Both are in the settings search.

## Impact

- Capabilities: new `keyboard`; `command-palette` help follows the preset; `app-settings` gains the Keyboard section.
- `core/keyboard` (new), `core/design/components/commands.dart`, a list-keys layer and a focus ring in
  `core/design`, the shell, the task list and task, quick actions, Settings.
- Strings in English, Bulgarian, German and French. No new dependency, no server change.
