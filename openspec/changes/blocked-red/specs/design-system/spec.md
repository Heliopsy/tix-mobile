## MODIFIED Requirements

### Requirement: Meaning colours are not themeable

Status, priority and project colours SHALL be the same whatever accent the tenant names. The `blocked` category,
and the mark on a task blocked by an unfinished dependency, SHALL be drawn in the danger red that tix uses for
blocked on every other surface, not in the warning colour.

#### Scenario: A themed tenant

- **WHEN** the tenant's accent is plum
- **THEN** an in-progress status is still tix's teal, blocked still red and highest priority still red

#### Scenario: A blocked task

- **WHEN** a task is in a state of the `blocked` category, or waits on an unfinished dependency
- **THEN** its status pill, or its blocked mark, is drawn in the danger colour in light, dark and black themes
