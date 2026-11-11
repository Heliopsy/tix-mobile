# task-browsing

## ADDED Requirements

### Requirement: The task screen says how many tasks an agent holds

The task screen's subtitle SHALL add "N held by an agent" after the task count, in the accent, when N of the loaded
tasks have a claimant and a lease that has not yet expired, as tix's web summary counts them. It SHALL leave the note
out when no loaded task is held, and SHALL follow claims, releases and lapses as the listing refreshes on them.

#### Scenario: Agents at work

- **WHEN** two of the loaded tasks are claimed with leases that end in the future
- **THEN** the subtitle reads the task count, then `2 held by an agent` in the accent

#### Scenario: A lapsed or lease-less claim

- **WHEN** one loaded task's lease has already expired and another is claimed with no lease
- **THEN** neither counts as held

#### Scenario: Nothing held

- **WHEN** no loaded task is claimed
- **THEN** the subtitle shows only the task count
