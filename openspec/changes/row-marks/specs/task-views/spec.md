## ADDED Requirements

### Requirement: Rows say who holds a claim and when one ran out

A row and a card SHALL mark a task an agent holds with "held" and the holder's handle, while its lease runs or when
the claim has no lease. A task whose last claim ran out within the last day, with nothing holding it since, SHALL
be marked "claim expired" with how long ago, and with the number of claims when there were more than one.

#### Scenario: A held task

- **WHEN** atlas holds a claim on a task whose lease ends in an hour
- **THEN** its row reads "held · @atlas"

#### Scenario: A claim that keeps running out

- **WHEN** a task claimed four times had its last claim run out three hours ago
- **THEN** its row reads "claim expired · 3 h ago · 4 claims"

#### Scenario: An old lapse

- **WHEN** the last claim ran out more than a day ago
- **THEN** the row carries no claim mark

### Requirement: Rows name what a task waits on

A row and a card SHALL mark a task blocked by an unfinished dependency with the reference it waits on, or with how
many it waits on when there are several. Tapping the mark SHALL open the first of them.

#### Scenario: One dependency

- **WHEN** a task waits on AICP-12
- **THEN** its row reads "waiting on AICP-12", and tapping that opens AICP-12

#### Scenario: Several

- **WHEN** a task waits on two unfinished tasks
- **THEN** its row reads "waiting on 2 tasks"

### Requirement: Rows show the repeat rule and the checklist

A row and a card SHALL show a repeating task's rule beside the repeat glyph, and a task with a checklist the count of
ticked items over all items, in the ok colour once every item is ticked.

#### Scenario: A weekly task with a checklist

- **WHEN** a task repeats every week and has three of five checklist items ticked
- **THEN** its row shows "every week" by the repeat glyph and "3/5"
