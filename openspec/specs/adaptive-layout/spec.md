# adaptive-layout Specification

## Purpose
How navigation and panes adapt to the width of the screen, from phones to desktops.

## Requirements

### Requirement: Navigation follows the screen width

Below 600 logical pixels wide the app SHALL show a bottom navigation bar; from 600 it SHALL show a
navigation rail instead. Until the person collapses or expands the rail, it SHALL show labels beside the icons
from 1200 and below them under 1200. Tapping the current destination SHALL return to its first screen.

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

#### Scenario: The app's destinations

- **WHEN** a signed-in person opens the app on a 400 pixel wide window
- **THEN** the bar shows Projects, Tasks, My work, Inbox and More, and More lists Watch, Manage, Settings, then About

### Requirement: The rail can be resized

From 600 logical pixels wide the expanded rail SHALL have a drag handle on its edge that resizes it between 180
and 480 pixels, and never wider than half the window. Letting go of a drag under 120 pixels SHALL collapse the
rail. Double-clicking the handle SHALL restore the default width and expand the rail.

#### Scenario: Dragging wider

- **WHEN** a person drags the handle of a 256 pixel rail 100 pixels to the right on a 1280 pixel window
- **THEN** the rail is 356 pixels wide

#### Scenario: Dragging past the minimum

- **WHEN** a person drags the handle until the rail would be under 120 pixels and lets go
- **THEN** the rail collapses to icons

#### Scenario: Double-click

- **WHEN** a person double-clicks the handle of a resized rail
- **THEN** the rail returns to its default width

### Requirement: The resize handle works from the keyboard

The handle SHALL be focusable and announced as a resizable separator with its width. Left and Right SHALL move it
by 16 pixels, 64 with Shift; Home and End SHALL move it to the minimum and maximum; Enter SHALL reset it. Left at
the minimum SHALL collapse the rail and Right on a collapsed rail SHALL expand it.

#### Scenario: Arrow key

- **WHEN** the handle of a 256 pixel rail has focus and the person presses Right
- **THEN** the rail is 272 pixels wide

#### Scenario: Collapse from the keyboard

- **WHEN** the handle of a 180 pixel rail has focus and the person presses Left
- **THEN** the rail collapses

### Requirement: The rail collapses and expands

From 600 logical pixels wide the rail SHALL carry a button at its top that collapses it to its icons and expands it
again, labelled for what it will do, and the command palette SHALL offer the same.

#### Scenario: Collapse

- **WHEN** a person presses Collapse sidebar on a 1280 pixel window
- **THEN** the rail shows icons without labels beside them and the button offers Expand sidebar

### Requirement: The layout is remembered on the device

The rail's width, whether the person collapsed or expanded it, and the width of the task panel beside a board
SHALL be kept in the device's settings and restored on the next start. A width wider than the window allows SHALL
be drawn at the window's limit without being forgotten.

#### Scenario: Restart

- **WHEN** a person collapses the rail and restarts the app
- **THEN** the rail is collapsed

### Requirement: The open task's panel closes

On a wide window the panel showing an open task SHALL have a close button in its header. Escape SHALL close it
unless select mode is on or a text field has focus, and moving to another screen SHALL close it. Closing SHALL
return to the plain list.

#### Scenario: Close button

- **WHEN** a task is open beside a project's list and the person presses Close task
- **THEN** the location is the project's and no task panel is shown

#### Scenario: Escape

- **WHEN** a task is open beside the Tasks list and the person presses Escape
- **THEN** no task panel is shown

#### Scenario: Navigating away

- **WHEN** a task is open beside the Tasks list and the person goes to Inbox and back
- **THEN** the Tasks list is shown without a task panel

### Requirement: The panel beside a board can be resized

Beside a board or lanes, the task panel SHALL have the same drag handle on its left edge, resizing it between 360
and 720 pixels and never more than 60 percent of the space; double-click and Enter SHALL restore its default.
Beside a list the panel SHALL take the rest of the window as before.

#### Scenario: Wider panel

- **WHEN** a person drags the panel's handle 100 pixels to the left beside a board
- **THEN** the panel is 100 pixels wider

### Requirement: Phones are unchanged

Below 600 logical pixels wide no resize handle, collapse button or task panel SHALL be shown.

#### Scenario: Phone

- **WHEN** the window is 400 pixels wide
- **THEN** there is no resize handle and no collapse button
