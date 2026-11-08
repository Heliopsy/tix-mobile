# audit-log

## ADDED Requirements

### Requirement: The audit log is filtered and paged

The audit log screen SHALL list entries newest first, a keyset page at a time, and SHALL narrow them by text, access channel, surface, actor, action, API token and time. A change of filter SHALL start a new listing.

#### Scenario: SSH only

- **WHEN** a person picks the ssh channel
- **THEN** the list asks for `via=ssh` and shows only those entries

#### Scenario: Token

- **WHEN** a person filters by the token name `ci-bot`
- **THEN** the request carries `token=ci-bot`

### Requirement: An entry shows its detail

Opening an entry SHALL show when, who, the record, the surface, every channel detail recorded (token, session, key, address, agent) and the record before and after. On a wide window the detail SHALL sit beside the list.

#### Scenario: Before and after

- **WHEN** a person opens an update entry
- **THEN** both the old and the new values are shown
