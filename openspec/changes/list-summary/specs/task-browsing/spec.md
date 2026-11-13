## REMOVED Requirements

### Requirement: The task screen says how many tasks an agent holds

**Reason**: The held count moves into the summary line under the filter, which says it with the rest of what the
list adds up to.

**Migration**: Read "N held by an agent" in the summary line.

## ADDED Requirements

### Requirement: The task screen sums up the list

Under the filter, in every drawing, the task screen SHALL say what the listed tasks add up to as tix's web does:
the open count in bold then "to go", ", N done" when some are done, "· across N projects" outside a project,
"· N held by an agent" in the accent for live leases, and "· N waiting on other tasks" for tasks waiting on an
unfinished dependency.

#### Scenario: A mixed list

- **WHEN** the loaded tasks are three open in two projects, one done, one of them held under a live lease and
  two waiting on another task
- **THEN** the line reads `3 to go, 1 done · across 2 projects · 1 held by an agent · 2 waiting on other tasks`

#### Scenario: A lapsed or lease-less claim

- **WHEN** one loaded task's lease has already expired and another is claimed with no lease
- **THEN** neither counts as held

### Requirement: The summary line counts every page

While more pages follow the loaded ones, the summary line SHALL count tix's tally of the whole selection, asked
for with `tally=true`, and SHALL count the loaded rows once the list is loaded in full, or when no tally comes.

#### Scenario: A list longer than a page

- **WHEN** two of three open tasks in two projects are loaded and more pages follow
- **THEN** the line reads `3 to go · across 2 projects`, from the server's tally

#### Scenario: A list loaded in full

- **WHEN** every task the list selects is loaded
- **THEN** the line counts the loaded rows and asks the server for no tally

### Requirement: The summary line says when there is nothing to count

The summary line SHALL read "Nothing open." for an empty list of open work, "Nothing on the list." for any other
empty list, and "All clear. Everything here is done." when every loaded task is done.

#### Scenario: An empty open list

- **WHEN** the list shows open work only and nothing matches
- **THEN** the line reads `Nothing open.`

### Requirement: The summary line leads to what it counts

Tapping the waiting count SHALL add `is:waiting-on` to the filter, unless it or `is:blocked` is already there.
A list hiding finished work SHALL add "· open work only ·" and a "show finished too" button that shows it.

#### Scenario: Waiting tasks

- **WHEN** a person taps `2 waiting on other tasks`
- **THEN** the filter gains `is:waiting-on` and the list shows those two tasks
