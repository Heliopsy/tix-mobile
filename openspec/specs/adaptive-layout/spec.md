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

### Requirement: The phone bar holds at most five destinations

Below 600 logical pixels wide the bottom bar SHALL show at most five destinations. When there are more, or the
bar carries a link such as About, it SHALL show the first four and More, which opens a sheet listing the rest and
then the links; the destination open from More SHALL mark More as selected. The rail SHALL show every destination.

#### Scenario: Six destinations

- **WHEN** the app has six destinations on a 400 pixel wide window
- **THEN** the bar shows four and More, and More lists the other two, then About
