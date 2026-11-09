## ADDED Requirements

### Requirement: Project stars queue like task stars

A project star or unstar made while the server is out of reach SHALL be queued in the outbox against the
project's key, drawn on the starred list at once, and sent in order when the server is back. It SHALL never
conflict. A project the server no longer has SHALL make the write refused, not a deleted task to restore.

#### Scenario: Starring offline

- **WHEN** the person stars Web with no network
- **THEN** Web shows under Starred at once and the outbox holds a project star for `web`
- **AND** the star is sent when the server is reachable again

#### Scenario: The project is gone

- **WHEN** a queued project star is replayed and the server answers 404
- **THEN** the write is marked refused with the server's reason and no conflict is opened
