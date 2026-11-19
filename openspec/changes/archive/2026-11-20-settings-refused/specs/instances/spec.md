## ADDED Requirements

### Requirement: Connection lists mark a refused connection

The instances screen and the context switcher SHALL mark a refused connection with a warning icon and a line saying "Signed out, sign in again" for a sign-in or "Token refused" for a token, with a semantics label naming the state. A connection that is not refused SHALL carry no mark.

#### Scenario: Refused token

- **WHEN** the server refused a saved token and the person opens the instances screen
- **THEN** its row shows the warning icon and "Token refused"

#### Scenario: Healthy connection

- **WHEN** a connection's credential was never refused
- **THEN** its row shows no mark

### Requirement: A refused connection opens reconnect

Tapping a refused connection in the instances screen or the context switcher, or running its switch command, SHALL open the reconnect screen for it instead of switching to it. Its menu SHALL offer Sign in again for a token as well as a sign-in.

#### Scenario: Tap

- **WHEN** the person taps a refused token connection
- **THEN** the reconnect screen for that connection opens and the active context stays

### Requirement: A sign-in without its session reads as refused

Once per run, on start, the app SHALL record as refused every remote sign-in whose session is missing from secure storage. A session secure storage cannot read SHALL NOT count as missing. Saving a new credential SHALL clear the mark.

#### Scenario: Signed out by 0.22.0

- **WHEN** a sign-in whose session 0.22.0 deleted is listed after the upgrade
- **THEN** its row says "Signed out, sign in again"

#### Scenario: New token

- **WHEN** the person saves a new token for a refused connection
- **THEN** its row no longer shows the mark
