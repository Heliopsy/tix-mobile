# maintenance

## ADDED Requirements

### Requirement: Retention windows are edited in days

The retention screen SHALL show how long events, audit entries and webhook deliveries are kept, in days, and SHALL save a changed window as a duration in hours.

#### Scenario: Ten days of events

- **WHEN** a person sets events to 10 and saves
- **THEN** the app sends `events: "240h"`

### Requirement: Pruning previews and confirms

The retention screen SHALL preview what pruning would remove, and SHALL prune only after a red confirmation, then say what was removed and what was kept for subscribers.

#### Scenario: Cancelled prune

- **WHEN** a person presses Prune and cancels
- **THEN** no prune request is sent

### Requirement: Housekeeping rules and runs

The housekeeping screen SHALL show the tenant rules for done, cancelled and trashed tasks with how many tasks each would act on now, SHALL say when housekeeping is paused because the trash is off, and SHALL run the rules only after a preview button or a red confirmation.

#### Scenario: Run after confirming

- **WHEN** a person confirms Run housekeeping
- **THEN** the app sends a run without `dry_run` and shows what moved and what was deleted

### Requirement: The trash restores

The trash screen SHALL list trashed tasks a keyset page at a time with when each was deleted, and SHALL restore a task with one action. It SHALL say that tix deletes trashed tasks for good only through housekeeping.

#### Scenario: Restore

- **WHEN** a person restores a trashed task
- **THEN** it leaves the list and is back in its project
