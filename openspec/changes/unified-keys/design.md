# Design

## One table for the app and tix web

tix (web, `internal/web`) and this app bind the same table. Each surface binds the subset it can do; a key never
means two different things across them.

| Action | Default | App notes |
| --- | --- | --- |
| Command palette | Ctrl+K, Cmd+K | |
| Shortcut help | `?` | |
| Go to Inbox, My work, Tasks, Projects | `g i`, `g m`, `g t`, `g p` | Ctrl+1 to Ctrl+4 |
| Go to Activity | `g a` | `g w` kept as a second key; Ctrl+5 |
| Go to Manage | `g M` | was `g a`; Ctrl+6. The web has no Manage page |
| Go to Settings | `g s` | Ctrl+7 |
| Go to Statistics | `g S` | web only, the app has no such screen |
| Next / previous row | `j` / `k`, Down / Up | |
| First / last row | `g` / `G`, Home / End | a lone `g` waits one second for a chord |
| Page down / up | PgDn / PgUp | |
| Open, back | Enter, Esc | Esc also clears a selection |
| Select, extend, select all | `x`, Shift+Down / Shift+Up, Ctrl+A | |
| Filter, refresh, switch view | `/`, `r`, `v` | |
| New task | `n` | |
| Mark done | `d` | list and task screen |
| Edit title | `e` | |
| Edit description | `E` | was `d` |
| Move to another status | `t` | was `m` |
| Comment | `m` | was `c` |
| Tag | `#` | was `t` |
| Star / unstar | `s`, `*` | |
| Priority, assign, due, snooze | `p`, `a`, `u`, `z` | |
| Copy reference | `y` | was Copy to… |
| Delete (after confirming) | Delete | app only |
| Quick add, from the clipboard | Ctrl+N, Ctrl+Shift+V | app only, the browser owns Ctrl+N |

Ctrl+digit is app only because the browser owns it.

**Vim** layers over Default: Esc or `h` back, Enter or `l` open, `g g` to the top, Ctrl+D / Ctrl+U (and Ctrl+F /
Ctrl+B, which the web drops) to page, `v` selects, `J` / `K` extend, `g v` switches view, `o` new, `i` renames, `D`
edits the description, `d d`, `x` or Delete deletes, `/` or `:` filters. `d` alone still marks done once the second
`d` has not come within a second. The app's old `e` for done is gone, as is the web's old `a` for comment.

**Emacs** layers over Default as before: Alt+X palette, Ctrl+G back and clear, Ctrl+N / Ctrl+P move, Alt+< / Alt+>
jump, Ctrl+V / Alt+V page, Ctrl+Space select, Ctrl+S filter, Ctrl+L refresh, Alt+N quick add. The web leaves out the
chords the browser owns (Ctrl+N, Ctrl+P, Ctrl+S, Ctrl+L).

**Off** drops every binding whose first key is not a chord; Ctrl+1 to Ctrl+7 stay.

## The tix TUI

`internal/tui` is not changed. It has about eighty bindings and its own history. It already agrees on `m` comment,
`t` transition, `e` edit, `*` star, `p` priority, `/` filter, `?` help and Ctrl+K palette. It differs elsewhere, for
example `v` is its live tail and it has no `g` destinations; its own help documents those.

## Help groups and words

`core/keyboard/key_help.dart` maps every action to a group (Navigate, Lists, Task, General) and to the label both
help overlays use ("Move selection down", "Edit the description", "Copy the reference" and so on). The `?` help reads
a command bound to an action by the action's label, not the command's, so two scopes registering the same action
show one row. A command with no action (its own fixed key) is listed under General by its own label. The settings
list uses the same groups and labels. The palette keeps the commands' own labels, which name the thing the command
does on that screen.

Esc is shared on purpose: it goes back, or clears a selection when there is one, so `nav.back` and `list.clear` keep
it both. A test checks that no other key runs two actions under any preset.

## Mark done on the task screen

`d` runs `completeTask`, which moves the task to the first terminal state in the done category, by a direct
transition when one exists and by the server's route otherwise, through the same path the move sheet uses, so it
toasts and offers Undo the same way. A task already in a terminal state (done or cancelled) stays put, as on the
list.

## Compatibility

Presets are stored by id (`default`, `vim`, `emacs`, `off`) and none changed. Action ids are not stored; the
Activity action keeps its old id `nav.watch` anyway, so nothing keyed by it moves.
