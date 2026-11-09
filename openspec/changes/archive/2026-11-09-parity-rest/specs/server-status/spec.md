# server-status

## ADDED Requirements

### Requirement: The status report is shown

A Manage entry SHALL show `status.read`: the version, schema and database, each registered server with whether it
still heartbeats and its uptime as a duration, the tenant's work counts and the second factor's state. A refusal
SHALL be shown with a retry.

#### Scenario: Quiet server

- **WHEN** a registered server missed its heartbeats
- **THEN** its row says since when it has been quiet

#### Scenario: Not an admin

- **WHEN** the credential lacks `tenant:admin`
- **THEN** the screen shows the refusal and can retry
