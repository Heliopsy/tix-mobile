# instances

## ADDED Requirements

### Requirement: A rotated token is never dropped

Before rotating, the app SHALL check that secure storage accepts a write and SHALL NOT rotate when it does not. When
storing the rotated token fails anyway, the app SHALL show it once with Copy and a warning that it is not saved and
the old token stops in a minute, and SHALL keep using it until the app closes. The token SHALL NOT be logged.

#### Scenario: Locked keyring before rotating

- **WHEN** secure storage refuses a write and the person rotates a token
- **THEN** nothing is sent to the server, the old token stays and the reason is shown

#### Scenario: Write fails after rotating

- **WHEN** the server rotates the token but storing the new one fails
- **THEN** the new token is shown once with Copy and a warning, and the connection keeps working with it
