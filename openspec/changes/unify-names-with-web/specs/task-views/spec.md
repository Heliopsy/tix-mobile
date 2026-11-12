# task-views

## MODIFIED Requirements

### Requirement: Filter chips toggle with one tap

The filter bar SHALL offer chips for mine, starred, snoozed, waiting on (a dependency that is not finished), overdue, due today, due this week and show finished. A chip SHALL add its term to the expression or take it out, and show whether it is on. The waiting chip SHALL read "Waiting on", as tix web says, so it is not taken for the Blocked status category.

#### Scenario: Starred chip

- **WHEN** a person taps Starred
- **THEN** the field reads `is:starred` and the list holds only starred tasks

#### Scenario: Waiting on chip

- **WHEN** a person looks at the filter bar
- **THEN** the dependency chip reads "Waiting on" and no chip reads "Blocked"
