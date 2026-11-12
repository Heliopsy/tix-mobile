# keyboard

## MODIFIED Requirements

### Requirement: Default preset

Default SHALL bind the key table shared with tix web: `j`/`k` and the arrows move, `g`/Home and `G`/End jump, Enter opens, Esc goes back or clears the selection, `/` filters, `?` helps and Ctrl+K or Cmd+K opens the palette. `g` then `i`, `m`, `t`, `p`, `a` (or `w`), `M` or `s`, and Ctrl+1 to Ctrl+7 in navigation order, open the destinations.

#### Scenario: Ctrl+2

- **WHEN** the person presses Ctrl+2 on Projects
- **THEN** My work opens, as Ctrl+1 opens Inbox

#### Scenario: g a

- **WHEN** the person presses `g` then `a` under Default
- **THEN** Activity opens, and `g` then `M` opens Manage

### Requirement: Vim preset

Vim SHALL layer over Default: `g g` and `G` jump, Ctrl+D and Ctrl+U page, `l` opens, `h` goes back, `o` adds a task, `i` renames, `D` edits the description, `v` selects, `g v` switches view, `J`/`K` extend the selection, `/` or `:` filters, `d` marks done once the wait for a second `d` ends, and `d d`, `x` or Delete deletes the open task after a confirmation.

#### Scenario: dd

- **WHEN** a task is open under Vim and the person presses `d` twice
- **THEN** the delete confirmation opens

#### Scenario: e does not complete

- **WHEN** the person presses `e` on the task list under Vim
- **THEN** no task is marked done

## ADDED Requirements

### Requirement: Task keys

Under Default the task list and the task screen SHALL bind `d` to mark done, `e` to rename, `E` to edit the description, `t` to move to another status, `m` to comment, `#` to add a tag, `s` or `*` to star, `p` priority, `a` assign, `u` due date, `z` snooze and `y` to copy the reference, each where the screen offers the action.

#### Scenario: d on the task screen

- **WHEN** an open task is in to do and the person presses `d`
- **THEN** the task moves to its workflow's done state, and a finished task stays where it is

#### Scenario: E

- **WHEN** a task is open and the person presses Shift+E
- **THEN** the description editor opens

### Requirement: One meaning per key

Within any preset no key or sequence SHALL run two different actions, except Esc (and Ctrl+G under Emacs), which goes back or clears the selection.

#### Scenario: e and d

- **WHEN** the person presses `e` on the task list under Default
- **THEN** no task is marked done
