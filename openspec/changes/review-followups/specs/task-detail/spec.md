# task-detail

## MODIFIED Requirements

### Requirement: The claim length is shown

The task view SHALL show the lease a claim naming no length would get, from `task.lease`, as a human duration with
the level it came from, the ceiling and its level, and whether it was cut to the ceiling. The row SHALL be left out
when the server does not answer. The lease SHALL be read again when the task is claimed, released, reclaimed or its
lease expires.

#### Scenario: Inherited lease

- **WHEN** the project sets two hours and the tenant caps at a day
- **THEN** the row reads "2 h, from the project" and "At most 1 d, from the tenant"

#### Scenario: Claim changes

- **WHEN** the task is claimed or released while its page is open
- **THEN** the claim length is read from the server again
