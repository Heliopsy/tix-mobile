## ADDED Requirements

### Requirement: Global commands

Whatever screen shows, the palette SHALL offer quick add, templates, switching to each saved context, the theme
choices, settings, and the inbox and my work once they are routed.

#### Scenario: Theme

- **WHEN** a person opens the palette and runs "Dark theme"
- **THEN** the app switches to the dark theme

### Requirement: The palette searches

The palette SHALL match by letters in order, ranking consecutive and word-start matches first, over commands,
projects and the tasks opened in this session. A query shaped like a task reference SHALL offer to open that task.

#### Scenario: Project

- **WHEN** a person types `infr`
- **THEN** "Infrastructure" is offered and Enter opens its tasks

#### Scenario: Reference

- **WHEN** a person types `web-12`
- **THEN** "Open web-12" is offered and Enter opens the task

### Requirement: Features register commands

A feature SHALL add commands and searches through the command registry, for as long as the widget registering them
is mounted, and the `?` help SHALL list every registered command that has a key.

#### Scenario: Help

- **WHEN** a person presses `?`
- **THEN** the help lists Ctrl N for quick add
