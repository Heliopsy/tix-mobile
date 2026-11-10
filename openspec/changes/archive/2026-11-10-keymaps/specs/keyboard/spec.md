# keyboard

## ADDED Requirements

### Requirement: Commands name actions and presets bind them

A command SHALL name an abstract action, such as `list.next`, `nav.back`, `task.assign` or `palette.open`, and the active keymap preset SHALL decide which keys run it. A binding SHALL be one key or chord, or a sequence of two.

#### Scenario: Same action, other keys

- **WHEN** the Emacs preset is active on the task list and the person presses Ctrl+N
- **THEN** the cursor moves to the next task, as `j` does under Default

### Requirement: Two-key sequences wait for their second key

A key that starts a longer binding SHALL wait up to one second for the next key. When the keys typed so far also complete a binding, that binding SHALL run when the wait ends. A key that completes nothing after a waiting key SHALL be tried on its own.

#### Scenario: g then p

- **WHEN** the person presses `g` then `p` within a second under Default
- **THEN** Projects opens and the list does not jump to its first row

#### Scenario: g alone

- **WHEN** the person presses `g` under Default and nothing else for a second
- **THEN** the list moves to its first row

### Requirement: Default preset

Default SHALL keep the app's existing keys and add tix web's: `j`/`k` and the arrows move, `g`/Home and `G`/End jump, Enter opens, Esc goes back or clears the selection, `d` marks done, `/` filters, `?` helps and Ctrl+K or Cmd+K opens the palette. `g` then `p`, `t`, `m`, `i`, `a`, `s` or `w`, and Ctrl+1 to Ctrl+6, open the destinations.

#### Scenario: Ctrl+2

- **WHEN** the person presses Ctrl+2 on Projects
- **THEN** Tasks opens

### Requirement: Vim preset

Vim SHALL layer over Default: `g g` and `G` jump, Ctrl+D and Ctrl+U page, `l` opens, `h` goes back, `o` adds a task, `i` renames, `D` edits the description, `v` selects, `g v` switches view, `J`/`K` extend the selection, and `d d`, `x` or Delete deletes the open task after a confirmation.

#### Scenario: dd

- **WHEN** a task is open under Vim and the person presses `d` twice
- **THEN** the delete confirmation opens

### Requirement: Emacs preset

Emacs SHALL layer over Default: Ctrl+N and Ctrl+P move, Ctrl+V and Alt+V page, Alt+< and Alt+> jump, Ctrl+S filters, Ctrl+G cancels or goes back, Ctrl+Space selects, Ctrl+L refreshes, Alt+N opens quick add and Alt+X opens the palette.

#### Scenario: M-x

- **WHEN** the Emacs preset is active and the person presses Alt+X outside a text field
- **THEN** the command palette opens

### Requirement: Off keeps only chords

The Off preset SHALL drop every binding whose first key is not held with Ctrl, Alt or Cmd, so no single key runs a command, while Ctrl+K or Cmd+K still opens the palette.

#### Scenario: j does nothing

- **WHEN** Off is active on the task list and the person presses `j`
- **THEN** the cursor does not move and Ctrl+K still opens the palette

### Requirement: Shortcuts can be turned off

A switch SHALL turn every keyboard shortcut off, the palette chord included. Keys the platform handles, such as Tab, Enter on a focused control and Esc in a dialog, SHALL keep working.

#### Scenario: Switched off

- **WHEN** shortcuts are off and the person presses Ctrl+K
- **THEN** nothing opens

### Requirement: Typing stays in the field

While a text field has focus, no binding SHALL run except the palette chord and leaving the field, which is Esc, and Ctrl+G under Emacs. Every other key SHALL be left unhandled so it reaches the field.

#### Scenario: Emacs keys while typing

- **WHEN** the Emacs preset is active and the person presses Ctrl+N in the filter field
- **THEN** the key is left to the field and the cursor in the list does not move

#### Scenario: Esc leaves the field

- **WHEN** the filter field has focus under Vim and the person presses Esc then `j`
- **THEN** the field loses focus and the list moves to the next task

### Requirement: Every page works from the keyboard

Every signed-in page SHALL be operable without a pointer: the list actions move focus between rows and scroll the focused row into view, Enter activates the focused control, Esc goes back, and a visible focus ring marks keyboard focus. A page hidden behind another page or in an inactive destination SHALL not answer keys.

#### Scenario: Settings rows

- **WHEN** the person presses `j` twice on Settings
- **THEN** focus moves down two rows and the ring shows where

#### Scenario: Hidden list

- **WHEN** a task is open on its own page over the list and the person presses `j`
- **THEN** the list behind it does not move

### Requirement: Dialogs and sheets keep and return focus

A dialog or sheet SHALL hold keyboard focus while open, close on Esc, and return focus to where it was.

#### Scenario: Help closes

- **WHEN** the person opens `?` and presses Esc
- **THEN** the help closes and keys reach the page again
