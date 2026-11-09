# about

## ADDED Requirements

### Requirement: Connection details from About

About SHALL offer Connection details for the active context, opening the same sheet as the live indicator, so
there is a way in when the indicator shows nothing. It SHALL NOT be offered without a context.

#### Scenario: Indicator hidden

- **WHEN** a person signed in opens About and taps Connection details
- **THEN** the connection details of the active context open

#### Scenario: Signed out

- **WHEN** nobody is signed in
- **THEN** About offers no Connection details
