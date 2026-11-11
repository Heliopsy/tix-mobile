## MODIFIED Requirements

### Requirement: History reads the audit trail

The task view SHALL show the task's audit entries from `GET /tasks/{ref}/audit`, newest first and paged, naming
who changed what and through which channel, with the API token's name when one made the change, and SHALL say so
when the credential cannot read the audit.

#### Scenario: A change in history

- **WHEN** the audit holds a task.update changing priority from 3 to 2
- **THEN** history shows the actor, the time and that priority changed

#### Scenario: A change made with a token

- **WHEN** deploy-bot changed the task with the ci-runner token
- **THEN** its history row shows deploy-bot and "via token ci-runner"

#### Scenario: An entry from a server that records no channel

- **WHEN** an entry carries no `via`
- **THEN** its history row shows the surface it came through instead
