# app-settings

## ADDED Requirements

### Requirement: Keyboard shortcuts are chosen per device

Settings SHALL offer a Keyboard section on every platform, kept on the device: a switch for keyboard shortcuts, a preset of Default, Vim, Emacs or Off, and a read-only list of the active preset's bindings. Search SHALL find it by keyboard, shortcut, keymap, Vim and Emacs.

#### Scenario: Pick Vim

- **WHEN** the person picks Vim and opens Settings again after a restart
- **THEN** Vim is still picked and the list shows `g g` for the first item

#### Scenario: Search

- **WHEN** the person searches Settings for "emacs"
- **THEN** the Keyboard section shows
