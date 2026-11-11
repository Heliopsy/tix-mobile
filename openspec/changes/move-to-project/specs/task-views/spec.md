# task-views

## ADDED Requirements

### Requirement: Move the picked tasks into another project

The bulk bar SHALL offer moving the picked tasks into another project with the move sheet, leaving out the
source project when every picked task is in it, and SHALL send one bulk request with action `move_project` and
`project_ref`. The lists SHALL reload after it.

#### Scenario: Bulk move to another project

- **WHEN** a person picks infra-1 and moves it to web from the bulk bar
- **THEN** one bulk request with action `move_project`, refs `[infra-1]` and `project_ref: web` is sent

## MODIFIED Requirements

### Requirement: A bulk action has one Undo

The toast after a bulk action SHALL offer one Undo that reverses what changed: unstar for star, restore for
delete, removing the tag only from tasks that lacked it, deleting the copies, and moving, reassigning or
re-prioritising each task back to its previous value. A move to another project SHALL offer no Undo.

#### Scenario: Undo a bulk move

- **WHEN** a person moves a todo and a doing task to done and taps Undo
- **THEN** one task goes back to todo and the other to doing

#### Scenario: No Undo for a move to another project

- **WHEN** a person moves two tasks into another project
- **THEN** the toast says two changed and offers no Undo
