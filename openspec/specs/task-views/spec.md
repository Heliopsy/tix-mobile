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
and left to snooze. Its action sheet, opened from its "more" button or a secondary click, SHALL offer complete,
move, star, snooze, assign to me, assign to anyone, priority, due date, add tag and select. Each SHALL change the
row at once, roll back on refusal and offer Undo.

#### Scenario: Swipe to complete

- **WHEN** a person swipes an open task right
- **THEN** it is ticked at once, a move to the done state is sent, and the toast offers Undo

#### Scenario: Refused

- **WHEN** the server refuses a star
- **THEN** the star goes back and the server's message is shown

#### Scenario: The menu from the dots

- **WHEN** a person taps a row's "more" button
- **THEN** the action sheet opens and select mode stays off

#### Scenario: A due date from the menu

- **WHEN** a person picks Due date and then Tomorrow from a row's menu
- **THEN** the row's task is sent `due_at` for the next local midnight and the toast offers Undo

#### Scenario: A tag from the menu

- **WHEN** a person picks Add tag and then a tag from a row's menu
- **THEN** the row's task carries the tag at once and the tag is added on the server

### Requirement: Many tasks are acted on at once

In select mode a bar SHALL say how many tasks are picked and offer move, priority, add tag, remove tag, assign,
star, unstar, copy to a project and delete, each sent as one `POST /api/v1/tasks/bulk`. With nothing picked the
actions SHALL be unavailable. A bulk action SHALL end select mode.

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

The keyboard SHALL move through rows with `j` and `k`, open with Enter, select with `x`, extend the selection
with Shift+Up and Shift+Down, mark the focused task done with `e`, focus the filter with `/`, switch the view
with `v` and leave select mode with Escape, each registered in the command palette. A listing seen in the last
minutes SHALL draw at once when reopened, then refresh.

#### Scenario: Keyboard

- **WHEN** a person presses `j` twice and Enter
- **THEN** the second task opens

#### Scenario: Extending the selection

- **WHEN** a person presses `j`, `x` and Shift+Down
- **THEN** the first two tasks are picked and the cursor is on the second

#### Scenario: Marking done from the keyboard

- **WHEN** a person moves the cursor to an open task and presses `e`
- **THEN** the task is ticked at once and a move to the done state is sent

### Requirement: A saved filter opens by name

The task screen SHALL open the saved filter named by `/tasks?filter=<name or id>` with `filter.show`, and say so
when it is gone. A tapped saved chip SHALL apply at once and then take the server's copy when it changed.

#### Scenario: Link

- **WHEN** the app opens `/tasks?filter=ops`
- **THEN** the filter named Ops is applied

#### Scenario: Changed elsewhere

- **WHEN** a chip's query changed on another device
- **THEN** the screen applies the new query after the tap

### Requirement: Select mode is explicit

The task screen SHALL have a select mode that is on or off independently of what is picked. It SHALL turn on
from a Select button in the app bar, `x`, a Shift-click or Ctrl/Cmd-click on a row or card, and a long press on
a row or card, which picks it. From the Select button it SHALL be on with nothing picked.

#### Scenario: The Select button

- **WHEN** a person taps Select in the app bar
- **THEN** every row shows a checkbox and the bar says 0 selected

#### Scenario: A long press

- **WHEN** a person long-presses a row
- **THEN** the row is picked, select mode is on and no action sheet opens

### Requirement: Select mode marks rows apart from the tick

In select mode every row and card SHALL lead with a square checkbox read as "Select". The done tick SHALL still
show whether the task is done, muted, with no tap target and left out of the semantics tree. A tap SHALL pick or
unpick, and a Shift-click SHALL pick every task between the last one picked and the one clicked, in the order
drawn.

#### Scenario: The tick does not complete

- **WHEN** a person in select mode taps where an open task's tick is drawn
- **THEN** the task is picked and nothing is sent to the server

#### Scenario: A range

- **WHEN** a person Ctrl-clicks the first row and Shift-clicks the second
- **THEN** both rows are picked and the third is not

#### Scenario: Two labels

- **WHEN** a screen reader reaches a row outside select mode
- **THEN** its tick is read as "Mark done", and in select mode its checkbox is read as "Select"

### Requirement: Select mode is left the way it is expected

Select mode SHALL end with Escape, the close button on the bulk bar, the system back gesture or button, and when
the last picked task is unpicked after the mode was entered by picking. Entered from the Select button, it SHALL
stay on with nothing picked until left. Each change in the count SHALL be announced.

#### Scenario: Unpicking the last task

- **WHEN** a person long-presses a row and then taps it again
- **THEN** select mode ends and the rows show only their ticks

#### Scenario: Entered from the button

- **WHEN** a person taps Select, picks a row and unpicks it
- **THEN** select mode stays on with 0 selected until Escape or the close button

#### Scenario: Back

- **WHEN** a person in select mode presses back
- **THEN** select mode ends and the task screen stays

### Requirement: The board and lanes select like the list

Board and lane cards SHALL enter, show and leave select mode as rows do, through the same selection and the
same bulk bar. In select mode a card SHALL not drag. On a phone board a long press SHALL still start a drag, and
letting go where it began SHALL pick the card.

#### Scenario: Picking cards on a board

- **WHEN** a person Ctrl-clicks one card and taps another
- **THEN** both are picked and Star sends one bulk request with both references

#### Scenario: A long press on a phone board

- **WHEN** a person long-presses a card on a phone and lets go without moving
- **THEN** the card is picked and not moved

### Requirement: The focused row is edited from the keyboard

On the task screen `m` SHALL move, `p` change the priority, `a` assign, `u` set the due date and `t` add a tag to
the task under the keyboard cursor, through the same pickers as its menu, each registered in the command palette.
While a task is open beside the list these keys SHALL belong to that task.

#### Scenario: Priority from the keyboard

- **WHEN** a person presses `j` twice, then `p`, and picks the highest priority
- **THEN** the second task is sent priority 1 and the first is not changed

### Requirement: Rows change status and priority in place

A list row's status pill SHALL open the moves its workflow allows and its priority mark SHALL open the priority
picker, each applied to the row at once with Undo. With Shift, Ctrl or Cmd held, or in select mode, a tap on
either SHALL pick the row instead. Assignee, due date and tags SHALL stay in the menu so a phone row keeps its
height.

#### Scenario: Priority on the row

- **WHEN** a person taps a row's priority and picks high
- **THEN** the row shows high at once, `{"priority": 2}` is sent, and Undo sends the old priority back

#### Scenario: Status on the row

- **WHEN** a person taps a row's status and picks Doing
- **THEN** a move to doing is sent and the toast says so

#### Scenario: Select mode

- **WHEN** a person in select mode taps another row's priority
- **THEN** that row is picked and no picker opens

### Requirement: Ticking a row shows it

Turning a row done SHALL fill its circle with a small bounce and draw the check, strike the title through from
the start of the line and mute it, and wash the row green and back, with a light haptic on touch. Turning it
open SHALL play the same backwards. A row drawn already done SHALL not animate. With reduced motion the change
SHALL be instant.

#### Scenario: Ticking

- **WHEN** a person ticks an open row
- **THEN** the strike-through sweeps across the title and settles as a struck-through title with a filled tick

#### Scenario: Reduced motion

- **WHEN** a person who asked for reduced motion ticks a row
- **THEN** the filled tick and the struck-through title show in the next frame, with no sweep

### Requirement: A ticked row settles before it moves

A row just ticked SHALL keep its place while its tick plays, then move to where the listing puts it, or collapse
away when a refresh drops it from the listing. The move SHALL be sent at once, not after the wait, and Undo
SHALL work as before. With reduced motion the row SHALL move or go at once.

#### Scenario: Dropped by a refresh

- **WHEN** a person ticks a row of open work and the list refreshes
- **THEN** the row stays for a moment, then collapses and is gone

#### Scenario: Dropped with reduced motion

- **WHEN** the same happens with reduced motion
- **THEN** the row is gone as soon as the refresh arrives
