# app-settings

## MODIFIED Requirements

### Requirement: Keyboard shortcuts are chosen per device

Settings SHALL offer a Keyboard section on every platform, kept on the device: a switch for keyboard shortcuts, a preset of Default, Vim, Emacs or Off, and a read-only list of the active preset's bindings, grouped and labelled as the `?` help groups and labels them. Search SHALL find it by keyboard, shortcut, keymap, Vim and Emacs.

#### Scenario: Pick Vim

- **WHEN** the person picks Vim and opens Settings again after a restart
- **THEN** Vim is still picked and the list shows `g g` for the first item

#### Scenario: Search

- **WHEN** the person searches Settings for "emacs"
- **THEN** the Keyboard section shows

#### Scenario: Grouped list

- **WHEN** the person opens the Keyboard section under Default
- **THEN** "Mark done" with `d` is listed under Task
