# app-settings

## ADDED Requirements

### Requirement: Offline availability is chosen per context

Settings SHALL offer an Offline screen where a person picks, for the active context, which projects stay available
offline and whether My work and Starred do. My work and Starred SHALL be on until turned off, and each context SHALL
keep its own choice.

#### Scenario: Picking a project

- **WHEN** a person turns on a project on the Offline screen
- **THEN** the next sync keeps it offline, and the choice is still there after a restart

#### Scenario: Another context

- **WHEN** a person switches to another context
- **THEN** the Offline screen shows that context's own choice

### Requirement: Offline storage and sync are visible

The Offline screen SHALL show how much room the context's saved copies take, a Clear action that asks for
confirmation, when the last sync finished, a Sync now action that shows while it runs, and the error of a sync that
failed.

#### Scenario: Clear confirmed

- **WHEN** a person presses Clear and confirms
- **THEN** the saved copies are deleted and the size shown drops

#### Scenario: Sync fails

- **WHEN** Sync now fails because the server cannot be reached
- **THEN** the error is shown with a way to retry

### Requirement: Local instances need no offline settings

For a local instance the Offline screen SHALL say that the instance is on this device and always available, and
SHALL offer nothing else.

#### Scenario: Local context

- **WHEN** the active context is a local instance and the person opens the Offline screen
- **THEN** only the note is shown
