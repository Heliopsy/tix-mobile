# audit-log

## ADDED Requirements

### Requirement: A row names its channel and token

Each audit log row SHALL name the channel the change arrived through with the API token's or job's name, as
"via API (ci-bot)", and SHALL never show a secret.

#### Scenario: A token's change

- **WHEN** an entry's `via` has kind `api` and token name `ci-bot`
- **THEN** its row reads "via API (ci-bot)"
