## MODIFIED Requirements

### Requirement: Wide screens show the task beside the list

From 840 logical pixels wide, opening a task SHALL show it in a resizable panel beside its task list, with the open
task highlighted in the list only while the panel is shown. With no task open the list SHALL take the whole width.
Narrower screens SHALL show the task on a screen of its own. The task's location SHALL be the same at every width.

#### Scenario: Two panes

- **WHEN** a person opens a task on a 1280 pixel wide window
- **THEN** the task list stays visible and the task is shown beside it

#### Scenario: Nothing selected

- **WHEN** a project is open on a wide window and no task is open
- **THEN** the list takes the whole width and no second pane is shown

#### Scenario: Closed or narrowed

- **WHEN** the open task's panel is closed, or the window narrows so the panel goes
- **THEN** no row is highlighted
