# task-detail

## ADDED Requirements

### Requirement: The claim length is shown

The task view SHALL show the lease a claim naming no length would get, from `task.lease`, as a human duration with
the level it came from, the ceiling and its level, and whether it was cut to the ceiling. The row SHALL be left out
when the server does not answer.

#### Scenario: Inherited lease

- **WHEN** the project sets two hours and the tenant caps at a day
- **THEN** the row reads "2 h, from the project" and "At most 1 d, from the tenant"

### Requirement: A one-step move is a transition

A move to a state the workflow reaches in one transition SHALL be sent as `task.transition` with its comment. A
move through other states SHALL stay a route.

#### Scenario: Next state

- **WHEN** a person moves a task from to do to doing
- **THEN** the app sends `POST /tasks/{ref}/transition` with `to: doing`

### Requirement: The tag picker reads the task's tags

The tag picker SHALL read the task's tags with `task.tags` when it opens and leave out any already on the task,
including ones added elsewhere since the task was read.

#### Scenario: Added elsewhere

- **WHEN** someone else tagged the task `ops` and the picker opens
- **THEN** `ops` is not offered
