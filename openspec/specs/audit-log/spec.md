# audit-log Specification

## Purpose
The tenant's audit log, filtered, paged and read entry by entry.

## Requirements

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

### Requirement: An entry copies as JSON

An entry's detail SHALL offer Copy JSON, on a phone and beside the list on a wide window, and a long press on its
row SHALL do the same. It SHALL put on the clipboard the JSON object tix returned for that entry, indented by two
spaces, with no field added or dropped, and SHALL confirm with a toast.

#### Scenario: Copy from the detail

- **WHEN** a person opens an entry and picks Copy JSON
- **THEN** the clipboard holds that entry's JSON exactly as tix sent it, pretty-printed
- **THEN** a toast says the JSON was copied

#### Scenario: Nothing filled in

- **WHEN** tix sent an entry whose `via` carries only `kind`
- **THEN** the copied `via` carries only `kind`

### Requirement: A row names its channel and token

Each audit log row SHALL name the channel the change arrived through with the API token's or job's name, as
"via token ci-bot", and SHALL never show a secret.

#### Scenario: A token's change

- **WHEN** an entry's `via` has kind `api` and token name `ci-bot`
- **THEN** its row reads "via token ci-bot"
