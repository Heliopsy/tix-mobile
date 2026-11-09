## MODIFIED Requirements

### Requirement: Rows have quick actions

A row SHALL complete or reopen with its tick, star with its star, and on touch SHALL swipe right to complete
and left to snooze. Its action sheet, opened from its "more" button or a secondary click, SHALL offer complete,
star, snooze, assign to me and select. Each SHALL change the row at once, roll back on refusal and offer Undo.

#### Scenario: Swipe to complete

- **WHEN** a person swipes an open task right
- **THEN** it is ticked at once, a move to the done state is sent, and the toast offers Undo

#### Scenario: Refused

- **WHEN** the server refuses a star
- **THEN** the star goes back and the server's message is shown

#### Scenario: The menu from the dots

- **WHEN** a person taps a row's "more" button
- **THEN** the action sheet opens and select mode stays off

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

## ADDED Requirements

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
