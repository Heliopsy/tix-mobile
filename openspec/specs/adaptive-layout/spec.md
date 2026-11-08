# adaptive-layout Specification

## Purpose
How navigation and panes adapt to the width of the screen, from phones to desktops.

## Requirements

### Requirement: Navigation follows the screen width

Below 600 logical pixels wide the app SHALL show a bottom navigation bar; from 600 it SHALL show a
navigation rail instead, with labels beside the icons from 1200. Tapping the current destination SHALL
return to its first screen.

#### Scenario: Phone

- **WHEN** the window is 400 pixels wide
- **THEN** a bottom navigation bar is shown and no rail

#### Scenario: Desktop

- **WHEN** the window is 1280 pixels wide
- **THEN** an extended navigation rail is shown and no bottom bar

### Requirement: Wide screens show the task beside the list

From 840 logical pixels wide, opening a task SHALL show it beside its project's task list, with the open task
highlighted in the list. Narrower screens SHALL show the task on a screen of its own. The task's location
SHALL be the same at every width.

#### Scenario: Two panes

- **WHEN** a person opens a task on a 1280 pixel wide window
- **THEN** the task list stays visible and the task is shown beside it

#### Scenario: Nothing selected

- **WHEN** a project is open on a wide window and no task is
- **THEN** the second pane asks the person to pick a task
