# command-palette

## MODIFIED Requirements

### Requirement: Features register commands

A feature SHALL add commands and searches through the command registry, for as long as the widget registering them is mounted and shown, and the `?` help SHALL list every registered command that has a key in the active keymap preset, with that preset's keys.

#### Scenario: Help

- **WHEN** a person presses `?`
- **THEN** the help lists Ctrl N for quick add

#### Scenario: Help follows the preset

- **WHEN** the Vim preset is active on the task list and the person presses `?`
- **THEN** the help lists `o` for a new task, not `n`

## ADDED Requirements

### Requirement: Help is grouped as tix web's

The `?` help SHALL group its rows under Navigate, Lists, Task and General, in that order, and SHALL name a keymap action with the label tix web's help uses for it, such as "Move selection down" or "Edit the description", listing each action once however many screens register it.

#### Scenario: Grouped

- **WHEN** a person presses `?` on the task list
- **THEN** "Go to Inbox" is under Navigate and "Move selection down" under Lists, above General
