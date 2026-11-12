# task-detail

## MODIFIED Requirements

### Requirement: Subtasks, parent and dependencies are linked

The task view SHALL list the task's subtasks as a tree and the tasks it waits for, each opening its own task, link
the parent and the task it was copied from, add a subtask with `POST /tasks` and `parent_ref`, add a dependency by
reference and remove one.

#### Scenario: Adding a dependency

- **WHEN** a person adds infra-2 as a dependency
- **THEN** the app sends `POST /tasks/{ref}/deps` and lists infra-2 with its title and status

## ADDED Requirements

### Requirement: The subtask tree folds and loads deeper levels

The task view SHALL read `GET /tasks/{ref}/tree` with `depth=4` and draw three levels, each indented under its
parent. A subtask with subtasks SHALL carry a fold control, open at first. A third-level subtask with subtasks of
its own SHALL offer "Show N subtasks", which reads that subtask's tree and draws it in place.

#### Scenario: Nested subtasks

- **WHEN** infra-1 has the subtask infra-3, which has the subtask infra-4
- **THEN** infra-4 is drawn under infra-3, indented further

#### Scenario: Folding

- **WHEN** a person folds infra-3
- **THEN** infra-4 is hidden, and unfolding shows it again

#### Scenario: A deeper level

- **WHEN** a third-level subtask infra-5 has one subtask
- **THEN** it offers "Show 1 subtask", and pressing it reads `GET /tasks/infra-5/tree` and draws the subtask

### Requirement: A tree too large to walk falls back to direct subtasks

When the server refuses the tree as `precondition_failed`, the app SHALL read it with `depth=1` and say that only
direct subtasks are shown. The count beside the heading SHALL be the direct subtasks.

#### Scenario: Too large

- **WHEN** `GET /tasks/infra-1/tree?depth=4` answers 422 `precondition_failed`
- **THEN** the app reads `depth=1`, lists the direct subtasks and says the tree is too large to draw whole

### Requirement: Deleting with subtasks counts them all

The delete confirmation SHALL count every subtask in the tree when the whole tree was read, and otherwise SHALL
say the subtasks are deleted at every level without a number.

#### Scenario: Two levels

- **WHEN** infra-1 has a subtask with a subtask of its own and a person deletes infra-1
- **THEN** the confirmation says its 2 subtasks are deleted with it
