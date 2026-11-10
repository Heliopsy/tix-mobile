## MODIFIED Requirements

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

## ADDED Requirements

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
