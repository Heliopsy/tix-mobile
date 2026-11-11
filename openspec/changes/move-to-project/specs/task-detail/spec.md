# task-detail

## ADDED Requirements

### Requirement: Move into another project

The task menu and the command palette SHALL offer moving the task into another project. A sheet SHALL list the
other projects, starred first, and once one is picked SHALL say that the task takes a new reference there and
that the old one keeps leading to it. Confirming SHALL send `POST /tasks/{ref}/move` with `project_ref`.

#### Scenario: Move

- **WHEN** a person moves infra-1 into web
- **THEN** the app sends `POST /tasks/infra-1/move` with `project_ref: web`

#### Scenario: The sheet says the reference changes

- **WHEN** a person picks web in the move sheet for infra-1
- **THEN** the sheet says infra-1 takes the next number in web and infra-1 keeps leading to it

#### Scenario: Nowhere to go

- **WHEN** the tenant has no other project
- **THEN** the sheet says so and offers no Move button

### Requirement: A moved task opens under its new reference

After a move the app SHALL open the task under the reference the server answered, reload every task list, and
say the old and new reference, adding when the status started over and which custom fields were left behind.

#### Scenario: Status kept

- **WHEN** the server answers that infra-1 is now web-50 with its status kept
- **THEN** the app opens web-50 and says "infra-1 is now web-50."

#### Scenario: Status lost and fields left behind

- **WHEN** the server answers `status_kept: false` and `dropped_fields: [team, size]`
- **THEN** the toast also says the task starts in the project's first status and names team and size

### Requirement: A refused move says why

A refused move SHALL leave the task where it was and show the server's reason with the usual error text.

#### Scenario: Claimed by somebody else

- **WHEN** the server answers 409 because somebody else holds a claim on the task
- **THEN** the task stays open as it was and the toast carries the server's message

### Requirement: Move hides where it cannot work

Moving SHALL NOT be offered on a task made offline and not yet sent. After a server answers the move route as
unknown (405, or 404 with no envelope or tix's `no such route`), the app SHALL say the server cannot move tasks
and offer no move on that connection until the session changes.

#### Scenario: Older server

- **WHEN** a person moves a task and the server answers 404 `no such route`
- **THEN** a message says the server cannot move tasks to another project and the menu no longer offers it
