# app-settings

## ADDED Requirements

### Requirement: Date and time follow the account

Settings SHALL show the caller's date format and timezone from `time.settings`, what is in force and the level it
came from, and change them with `time.prefs.set`; an empty value SHALL return to the tenant's. A credential that is
not a person SHALL see the values without controls that change them.

#### Scenario: Own format

- **WHEN** a person picks the long format
- **THEN** the app saves it and shows it in force, from them

#### Scenario: Bad zone

- **WHEN** a person saves the zone "Mars"
- **THEN** the server's refusal is shown and nothing changes
