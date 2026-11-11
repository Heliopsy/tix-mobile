## MODIFIED Requirements

### Requirement: Quick add opens from anywhere

The signed-in screens SHALL open quick add from a button above the navigation bar on phones and in the rail on
wider windows, and from Ctrl+N or Cmd+N. The project SHALL start as the one the caller asks for, else the project
on show, even when the loaded project list lacks it. Only with neither SHALL it start as the last one used.

#### Scenario: Keyboard

- **WHEN** a person presses Ctrl+N on the projects screen
- **THEN** quick add opens

#### Scenario: Project on show

- **WHEN** quick add opens on project `web`
- **THEN** the project picker shows `web`

#### Scenario: Project on show beats the last one used

- **WHEN** a person last added to `web` and opens quick add on project `mobile`, which the loaded list lacks
- **THEN** the project picker shows `mobile` as its choice and the line is added there

#### Scenario: No project on show

- **WHEN** a person last added to `web` and opens quick add from the inbox
- **THEN** the project picker shows `web` and offers every project to change it

## ADDED Requirements

### Requirement: Quick add knows new projects

Opening quick add on a project the loaded project list lacks SHALL reload that list, so the picker names it.

#### Scenario: Project created since sign-in

- **WHEN** a project is created after quick add loaded the list and quick add opens on it
- **THEN** the picker shows the project's name
