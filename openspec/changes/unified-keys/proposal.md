# Proposal

## Why

The app and tix web gave the same keys different meanings. On the app `e` marked a row done and renamed a task, `d`
marked done on a list but edited the description on a task, `m` moved where the web comments, `c` commented, `t`
tagged where tix moves, and `g a` opened Manage. Someone using both had to remember which one they were in. tix and
the app now share one key table, decided together for both surfaces, and both help overlays use the same groups and
words.

## What Changes

- Default: `d` marks done everywhere, the task screen included. `e` renames, `E` edits the description, `t` moves to
  another status, `m` comments, `#` adds a tag, `s` or `*` stars, `y` copies the reference.
- Destinations: `g a` opens Activity (`g w` still works), `g M` opens Manage, and Ctrl+1 to Ctrl+7 follow the
  navigation order: Inbox, My work, Tasks, Projects, Activity, Manage, Settings.
- Vim: `e` no longer marks done (`d` does, after the one second `d d` waits for), and `:` also focuses the filter.
  Emacs and Off are unchanged.
- The `?` help is grouped Navigate, Lists, Task and General, with the labels tix web's help uses, and lists each
  action once. Settings lists the active bindings under the same headings and words.
- The task screen's Copy to… keeps its place in the menu and the palette but no longer has a key.

## Impact

- Capabilities: `keyboard`, `command-palette`, `app-settings`.
- Code: `core/keyboard` (the table, the groups and labels), `core/design/components/commands.dart` (the help),
  `features/settings` (the bindings list), `features/tasks` (`d` and `y` on the task screen), l10n in English,
  Bulgarian, German and French, README.
- Stored settings: unchanged. The preset is stored by its id, and no action id changed.
