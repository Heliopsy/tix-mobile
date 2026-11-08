# task-views Specification

## Purpose
Working through tasks: one query drawn as a list, a board or lanes, filtered with tix's language and saved filters, My work, quick and bulk actions with Undo, and the reader's own arrangement of columns and lanes.

## Requirements

### Requirement: One query drawn as a list, a board or lanes

The task screen SHALL draw one query as a list, a board or lanes, switched without reloading. The Tasks
screen covers every project; a project screen is scoped to its project and offers the list and the board.

#### Scenario: Switching the drawing

- **WHEN** a person filtered by `tag:ops` switches from the board to lanes
- **THEN** the lanes show the same tasks and no new listing request is made

### Requirement: Filters use tix's expression

The filter field SHALL take tix's filter expression and send it as `GET /api/v1/tasks` parameters: project,
status, tag, assignee, creator, claimed-by, priority, due, is, has, checklist, text, title, body, negation with
`-` and free words as `q`. An unknown key SHALL be reported under the field.

#### Scenario: Mine and a tag

- **WHEN** a person types `assignee:me tag:ops -status:done`
- **THEN** the request carries `assignee=me`, `tag=ops` and `not_status=done`

#### Scenario: Unknown key

- **WHEN** a person types `colour:red`
- **THEN** the field says the key is unknown and the list keeps its rows

### Requirement: Filter chips toggle with one tap

The filter bar SHALL offer chips for mine, starred, snoozed, blocked, overdue, due today, due this week and
show finished. A chip SHALL add its term to the expression or take it out, and show whether it is on.

#### Scenario: Starred chip

- **WHEN** a person taps Starred
- **THEN** the field reads `is:starred` and the list holds only starred tasks

### Requirement: The list shows open work by default

When the expression names no status and Finished is off, the list SHALL ask only for the unfinished states of
the tenant's workflows. The board and lanes SHALL show finished tasks.

#### Scenario: Default list

- **WHEN** the default workflow is in use and nothing is filtered
- **THEN** the list request names todo, doing and blocked as statuses

### Requirement: The list sorts and groups

The list SHALL sort by urgency, priority, due date, created, updated, number or title, ascending or
descending, and SHALL group the loaded rows by status or by project when asked.

#### Scenario: Sort by due date

- **WHEN** a person picks Due date
- **THEN** the list reloads from the first page with `sort=due_at`

### Requirement: Rows have quick actions

A row SHALL complete or reopen with its tick, star with its star, and on touch SHALL swipe right to complete
and left to snooze. Its action sheet SHALL offer complete, star, snooze, assign to me and select. Each SHALL
change the row at once, roll back on refusal and offer Undo.

#### Scenario: Swipe to complete

- **WHEN** a person swipes an open task right
- **THEN** it is ticked at once, a move to the done state is sent, and the toast offers Undo

#### Scenario: Refused

- **WHEN** the server refuses a star
- **THEN** the star goes back and the server's message is shown

### Requirement: Many tasks are acted on at once

A long press or `x` SHALL select rows. With rows selected a bar SHALL offer move, priority, add tag, remove
tag, assign, star, unstar, copy to a project and delete, each sent as one `POST /api/v1/tasks/bulk`.

#### Scenario: Bulk star

- **WHEN** a person selects three tasks and taps Star
- **THEN** one bulk request with action `star` and the three references is sent

#### Scenario: Partly refused

- **WHEN** one of three tasks cannot reach the chosen status
- **THEN** the toast says two changed and names the refused task with the reason

### Requirement: A bulk action has one Undo

The toast after a bulk action SHALL offer one Undo that reverses what changed: unstar for star, restore for
delete, removing the tag only from tasks that lacked it, deleting the copies, and moving, reassigning or
re-prioritising each task back to its previous value.

#### Scenario: Undo a bulk move

- **WHEN** a person moves a todo and a doing task to done and taps Undo
- **THEN** one task goes back to todo and the other to doing

### Requirement: The board draws a workflow's columns

The board SHALL draw one column per state of the projects' workflow, in declared order, each with its count.
When the projects run workflows whose states or transitions differ, the board SHALL say so and draw the list.

#### Scenario: Disagreeing workflows

- **WHEN** the Tasks screen covers projects on two different workflows
- **THEN** the board names both workflows and shows the list

### Requirement: Cards move by drag

Dragging a card SHALL light the columns its workflow reaches without a required comment. Dropping it SHALL
move the card at once with a haptic tick, send the move, roll back on refusal and offer Undo.

#### Scenario: Drag to doing

- **WHEN** a person drags a todo card onto Doing
- **THEN** the card shows in Doing at once and a move to doing is sent

### Requirement: Lanes draw one lane per project

Lanes SHALL draw one lane per project holding a loaded task, or named by a `project:` term, each with its
cards, a tick that completes or reopens and the status on the card. Finished cards SHALL show only while Finished is on.

#### Scenario: Two projects

- **WHEN** the loaded tasks are in infra and web
- **THEN** two lanes are drawn, headed by each project in its colour

### Requirement: Columns and lanes keep the reader's arrangement

Each column and lane SHALL offer star, collapse, move earlier, move later and hide, saved with the view API for
`board`, `project:KEY` or `lanes`. Hidden groups SHALL be listed with a way to show them, and Reset SHALL
forget the arrangement.

#### Scenario: Hiding a column

- **WHEN** a person hides Blocked on a project board
- **THEN** the column goes and `PATCH /views/project:KEY/groups/blocked` sends `hidden: true`

### Requirement: Saved filters are one tap away

Saved filters SHALL show as chips, the reader's own in their order then shared ones. Tapping one SHALL apply
its expression, sort and view. The current filter SHALL save with a name and a shared switch; one the reader
may edit SHALL rename, share, move and delete.

#### Scenario: Saving

- **WHEN** a person saves `tag:ops` as Ops, shared
- **THEN** `POST /api/v1/filters` sends the name, query, sort, view and `shared: true`

### Requirement: My work lists the reader's open tasks by deadline

My work SHALL list the reader's open assigned tasks under Overdue, Today, This week, Later and No date,
leaving out empty headings, and SHALL keep each heading's collapse and hide in the `mine` view.

#### Scenario: Overdue

- **WHEN** a task assigned to the reader was due yesterday
- **THEN** it is under Overdue

### Requirement: Lists are fast to get around

The keyboard SHALL move through rows with `j` and `k`, open with Enter, select with `x`, focus the filter with
`/`, switch the view with `v` and clear the selection with Escape, each registered in the command palette.
A listing seen in the last minutes SHALL draw at once when reopened, then refresh.

#### Scenario: Keyboard

- **WHEN** a person presses `j` twice and Enter
- **THEN** the second task opens
