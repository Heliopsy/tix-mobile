# task-views

## ADDED Requirements

### Requirement: The tick follows the workflow's routes

A tick SHALL complete along the shortest route to each terminal done state, or reopen along the routes with the
fewest steps to an open state. One candidate SHALL be applied at once. Several SHALL open a menu of the usable
ones naming each destination and, for a route through other states, the journey and its length.

#### Scenario: Two ways to finish

- **WHEN** a task in todo can reach done directly and shipped through review, and a person ticks it
- **THEN** a menu offers Done and Shipped via Review in 2 steps, and picking Shipped sends
  `POST /tasks/{ref}/route` with `route: [review, shipped]`

#### Scenario: One way to finish

- **WHEN** a task can reach only one done state and a person ticks it
- **THEN** it moves there at once with no menu

### Requirement: A tick that cannot work says why

A tick SHALL be drawn dashed when no route is usable: the reader cannot move tasks, the workflow could not be
read, no route leads there, or every route needs a comment or a scope the reader lacks. Pressing it SHALL say
which, and SHALL send nothing.

#### Scenario: Finishing needs a comment

- **WHEN** the only move to done requires a comment and a person presses the tick
- **THEN** the tick is dashed and a sheet says "Not from here: finishing it needs a comment."

### Requirement: A row snoozes to a picked date

A row's snooze SHALL offer Later today, Tomorrow morning, Next week and Pick a date, and Wake now when the task
is snoozed.

#### Scenario: Pick a date from a row

- **WHEN** a person opens a row's menu, picks Snooze and then Pick a date, and confirms a date and time
- **THEN** the task is snoozed until then and the toast offers Undo
