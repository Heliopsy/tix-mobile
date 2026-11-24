## ADDED Requirements

### Requirement: The open app sees a refusal the background run recorded

The app SHALL read settings again before it writes the connections list, before it records a refusal and when it
returns to the foreground. A refusal SHALL stay recorded until a new credential is saved.

#### Scenario: Token refused while the app is open

- **WHEN** the background run records a token refused and the app then switches to that connection
- **THEN** the connection stays marked refused

### Requirement: A refusal recorded elsewhere signs the app out

When the app confirms a refusal of the active connection that is already recorded, or of a sign-in whose session
is already deleted, it SHALL drop the session and open reconnect without showing the notification again.

#### Scenario: Session refused while the app is open

- **WHEN** the background run records a session refused and the app's next sync is answered `401`
- **THEN** the app signs out and opens reconnect, and one notification has shown
