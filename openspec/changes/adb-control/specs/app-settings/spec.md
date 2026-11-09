# app-settings

## ADDED Requirements

### Requirement: ADB control is chosen

On Android, Settings SHALL offer, under Advanced, a switch Allow control over ADB, off by default and remembered
on this device, with a line saying what it allows.

#### Scenario: Turned on

- **WHEN** a person turns Allow control over ADB on
- **THEN** a release build runs commands sent over `am broadcast`

#### Scenario: Not Android

- **WHEN** Settings opens on Linux
- **THEN** there is no Advanced section
