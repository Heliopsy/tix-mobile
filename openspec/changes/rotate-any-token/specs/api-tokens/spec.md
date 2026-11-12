## ADDED Requirements

### Requirement: Any active token can be rotated

Each active token row SHALL offer Rotate. Its sheet SHALL name the token, say when it is somebody else's, and offer
how long the old token keeps working: now, 10 minutes, 1 hour or 24 hours, now proposed. Rotating SHALL call
`POST /tokens/{id}/rotate` with that grace, show the new value once as an issued token's is, and show a refusal
in the sheet.

#### Scenario: Rotate with a grace

- **WHEN** a person rotates "ci" keeping the old token for 1 hour
- **THEN** the app sends `{"grace": "1h"}` to `/tokens/t1/rotate` and shows the new value once

#### Scenario: Refused

- **WHEN** the server refuses to rotate somebody else's token
- **THEN** the sheet stays open with the server's reason and no value is shown

### Requirement: Rotating the app's own token swaps its credential

When the token rotated is the one the app's remote token connection presents, the app SHALL rotate it through
that connection, with the chosen grace, so the stored credential is replaced by the new value, and SHALL show the
value once only when secure storage refuses it.

#### Scenario: Own token

- **WHEN** the person rotates the token this app connects with
- **THEN** the connection keeps the new token and the app says it now uses it

### Requirement: A rotated token reads retiring

A token whose `revoked_at` is still to come and that has not expired SHALL read "retiring" with when it stops,
keep Revoke and offer no Rotate. Once `revoked_at` has passed it SHALL read revoked.

#### Scenario: Inside the grace window

- **WHEN** a token was rotated with an hour's grace ten minutes ago
- **THEN** its row reads retiring and says when it stops
