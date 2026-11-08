# task-detail Specification

## Purpose
Viewing and changing one task in full: every attribute the tix web UI edits, what hangs off the task, and the actions on it.

## Requirements

### Requirement: Attributes are edited in place

The task view SHALL let a person with write access change the title, priority, assignee, due date, tags, repeat
rule and every custom field where each is shown, with `PATCH /api/v1/tasks/{ref}` naming only the attribute
changed. A value the server refuses SHALL be shown with the server's message and the old value restored.

#### Scenario: Renaming

- **WHEN** a person edits the title and confirms
- **THEN** the app sends `PATCH /tasks/{ref}` with only `title` and the new title stays

#### Scenario: Refused value

- **WHEN** the server refuses a repeat rule as invalid
- **THEN** the old rule is shown again with the server's message

### Requirement: Quick changes are optimistic with Undo

A change of priority, assignee, due date, tag, star or snooze SHALL show at once, before the server answers. A
change the server accepts SHALL offer Undo, which sends the inverse change. A change the server refuses SHALL
roll back and say why.

#### Scenario: Undo a priority change

- **WHEN** a person sets the priority to high and presses Undo
- **THEN** the app sends the old priority and shows it

#### Scenario: Refusal rolls back

- **WHEN** the server answers a star with an error
- **THEN** the star goes back off and an error toast names the reason

### Requirement: Custom fields follow their type

The task view SHALL list the project's custom fields from `GET /api/v1/projects/{ref}/fields` and edit each with
a control for its type: text for string and text, a number for int and float, a switch for bool, a date or date
and time picker, a choice of the options for enum, the actor directory for actor, and JSON text for json.

#### Scenario: Enum field

- **WHEN** a field of type enum has options low, mid and high
- **THEN** editing it offers those three options and clearing it

### Requirement: The description is Markdown with a tickable checklist

The description SHALL be drawn as Markdown that never loads an image. Each checklist item SHALL be a tick a
person can press, which sends `POST /tasks/{ref}/checklist` with the item's number in reading order and the
task's version. The description SHALL be editable as Markdown text.

#### Scenario: Ticking an item

- **WHEN** a person ticks the second checklist item
- **THEN** it shows ticked at once and the app sends item 2 with done true

### Requirement: Status moves follow the workflow

The status control SHALL offer every state the project's workflow can reach from the current one, naming the
states passed through on the way, and move with `POST /tasks/{ref}/route`. A transition that requires a comment
SHALL ask for one. A move that stops partway SHALL say where and why.

#### Scenario: Move through a state

- **WHEN** done is reachable from todo only through doing
- **THEN** the menu offers done via doing and moving there sends `to: done`

#### Scenario: Stopped partway

- **WHEN** the route answer names a stopped state and a reason
- **THEN** the task shows its new status and a message gives the reason

### Requirement: Assignees come from the directory

Choosing an assignee SHALL offer the tenant's actors from `GET /api/v1/actors`, searchable by name and handle,
and a way to unassign.

#### Scenario: Picking an actor

- **WHEN** a person searches raj and picks Raj
- **THEN** the task is assigned to Raj's id

### Requirement: Subtasks, parent and dependencies are linked

The task view SHALL list the task's direct subtasks and the tasks it waits for, each opening its own task, link
the parent and the task it was copied from, add a subtask with `POST /tasks` and `parent_ref`, add a dependency by
reference and remove one.

#### Scenario: Adding a dependency

- **WHEN** a person adds infra-2 as a dependency
- **THEN** the app sends `POST /tasks/{ref}/deps` and lists infra-2 with its title and status

### Requirement: Comments are written and kept

The task view SHALL list comments oldest first with author and time, drawn as Markdown, add one, let its author
edit or delete it, delete only after confirmation, and complete `@handle` from the actor directory while typing.

#### Scenario: Mention completion

- **WHEN** a person types `@ra` in the comment box
- **THEN** the app offers `@raj` and picking it completes the handle

### Requirement: History reads the audit trail

The task view SHALL show the task's audit entries from `GET /tasks/{ref}/audit`, newest first and paged, naming
who changed what and through which channel, and SHALL say so when the credential cannot read the audit.

#### Scenario: A change in history

- **WHEN** the audit holds a task.update changing priority from 3 to 2
- **THEN** history shows the actor, the time and that priority changed

### Requirement: Artifacts are listed and attached

The task view SHALL list artifacts with kind, name and time, attach a file or a photo as a `file` artifact of at
most 1 MiB, and open or save an artifact's content. A larger file SHALL be refused before it is sent.

#### Scenario: Attaching a file

- **WHEN** a person picks a 2 KiB text file
- **THEN** the app sends `PUT /tasks/{ref}/artifacts` with kind file, the name, the type and the content

### Requirement: Star and snooze

The task view SHALL star and unstar the task for the reader and snooze it until later today, tomorrow morning,
next week or a chosen time, and wake a snoozed task.

#### Scenario: Snooze until tomorrow

- **WHEN** a person picks Tomorrow morning at 15:00 on a Tuesday
- **THEN** the app sends `PUT /tasks/{ref}/snooze` for 09:00 local on Wednesday

### Requirement: Copy into a project

The task view SHALL copy the task into any project with a new title, choosing whether its subtasks, comments
and dependencies travel, whether it keeps its status and links back, and open the copy.

#### Scenario: Copy with subtasks

- **WHEN** a person copies infra-1 into web with subtasks
- **THEN** the app sends `POST /tasks/infra-1/copy` with `project_ref: web` and `with_subtasks: true`

### Requirement: Delete with Undo where tix keeps a trash

Deleting SHALL move the task to the trash and offer Undo, which restores it, when the tenant keeps a trash.
Without a trash, or when deleting permanently, the app SHALL confirm first. Subtasks SHALL be deleted only when
the person asks.

#### Scenario: Undo a delete

- **WHEN** the tenant keeps a trash and a person deletes a task, then presses Undo
- **THEN** the app sends `POST /tasks/{ref}/restore` and the task is back

### Requirement: Faster than the browser

Every action SHALL be reachable from the task's menu or a visible control; on a keyboard the main ones SHALL
have single keys listed in the shortcut help. Touch devices SHALL give haptic feedback on ticks and moves. A pane
760 dp or wider SHALL put the properties beside the description.

#### Scenario: Keyboard move

- **WHEN** the task is open on a desktop and the person presses m
- **THEN** the move menu opens

### Requirement: A claim can be force-released

When a task is claimed, the task menu SHALL offer a red "Force-release claim" that asks for an optional reason and
sends `POST /api/v1/tasks/{ref}/claim/reclaim`. An unclaimed task SHALL NOT offer it, and a refusal SHALL keep the
form open with the server's message.

#### Scenario: Release with a reason

- **WHEN** an admin releases the claim on a claimed task with the reason "worker died"
- **THEN** the app sends the reason, the task shows unclaimed and a toast says so
