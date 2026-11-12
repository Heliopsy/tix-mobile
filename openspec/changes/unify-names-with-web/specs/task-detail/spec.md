# task-detail

## MODIFIED Requirements

### Requirement: Star and snooze

The task view SHALL star and unstar the task for the reader and snooze it until later today, tomorrow morning,
next week or a chosen time, and unsnooze a snoozed task with an action named "Unsnooze", as the CLI, the API and
tix web name it.

#### Scenario: Snooze until tomorrow

- **WHEN** a person picks Tomorrow morning at 15:00 on a Tuesday
- **THEN** the app sends `PUT /tasks/{ref}/snooze` for 09:00 local on Wednesday

#### Scenario: Unsnooze

- **WHEN** a person opens the menu of a snoozed task
- **THEN** it offers Unsnooze

### Requirement: A claim can be force-released

When a task is claimed, the task menu SHALL offer a red "Reclaim the lease", as tix web and the terminal name it,
that asks for an optional reason and sends `POST /api/v1/tasks/{ref}/claim/reclaim`. An unclaimed task SHALL NOT
offer it, and a refusal SHALL keep the form open with the server's message.

#### Scenario: Release with a reason

- **WHEN** an admin reclaims the lease on a claimed task with the reason "worker died"
- **THEN** the app sends the reason, the task shows unclaimed and a toast says so

## ADDED Requirements

### Requirement: Dependency waits read waiting on

A task waiting on a dependency that is not finished SHALL say "Waiting on a task that is not finished.", and its dependencies section SHALL explain that the task waits until each listed task reaches a finished state. Neither SHALL call the task blocked, which names a status category.

#### Scenario: A waiting task

- **WHEN** a person opens a task that depends on an open task
- **THEN** it reads "Waiting on a task that is not finished."

### Requirement: Copy reference copies the reference

The task menu's Copy reference SHALL put the task's reference, such as `INFRA-5`, on the clipboard: not its id and not a link.

#### Scenario: Copy reference

- **WHEN** a person picks Copy reference on infra-5
- **THEN** the clipboard holds `infra-5` and a toast says the reference was copied
