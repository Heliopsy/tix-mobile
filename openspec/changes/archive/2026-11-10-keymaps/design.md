# Design

## Actions and presets

`TixCommand` gains `action`, an abstract id. `Keymap.of(preset)` resolves an action to `KeyBinding`s, each a list
of `KeyStroke`s. Presets are written as a base table (Default) plus per-preset overrides, the way tix's
`internal/tui/scheme.go` and `internal/web/shortcuts.go` layer `schemeKeys` over `DefaultKeyMap`, so no preset can
leave an action unbound by accident. Off is the Default table with every binding whose first key carries no Ctrl,
Alt or Cmd removed. The master switch gives an empty keymap.

`TixCommand.shortcut` stays for commands with no action (Inbox, Watch). Those keys obey the switch and Off, but no
preset rebinds them. Keeping it avoids breaking branches in flight that still register `shortcut:`.

## Resolution

`KeySequencer` holds the keys typed so far. A key that completes a binding and starts no longer one runs at once.
A key that starts a longer binding waits; if the same keys also complete a binding, that one runs when the timeout
(one second, Vim's default) passes. A key that matches nothing after a pending prefix is tried again on its own.
The sequencer takes a timer factory so its tests run without a clock.

Candidates are ordered newest scope first, so a page's Esc (clear the selection) beats the shell's Esc (go back).
A scope that registers again keeps its place: the shell rebuilding on a resize must not jump ahead of the page.

## Typing

Each binding says whether it applies outside text fields (most), also inside (the palette chord), or only inside
(leave the field: Esc, and C-g in Emacs). While a field has focus only the last two are candidates, and anything
else returns `KeyEventResult.ignored`, as since #70, so the key reaches the field.

## Keyboard-only

- `CommandScope` registers only while `TickerMode` is on: an inactive shell branch, or a page under a pushed page,
  drops its keys. A dialog does not turn tickers off, so the palette still lists the page's commands.
- `TixListKeys` (in `TixPage`, unless the page owns its list keys) moves real focus between focusable rows with
  the list actions, skipping text fields, and scrolls the row into view. The task list keeps its own cursor and
  marks itself as owner; its cursor now scrolls into view and drops a stale button focus, and its Enter activates
  a focused control first.
- `TixFocusRing` draws a 2 px accent outline around keyboard focus while focus is driven by keys, except around
  text fields, which draw their own.
- Dialogs and sheets already close on Esc and return focus to the route below; the shell's `nav.back` pops through
  the router delegate, which honours `PopScope`.

## Settings

`settings.shortcuts` (`off` when off) and `settings.keymap` (preset name) in the existing key-value store, read
by a `core/keyboard` provider so `TixShortcuts` in `core` can watch it.
